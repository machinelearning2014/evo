#!/usr/bin/env python3
from __future__ import annotations

import argparse
import base64
import json
import sys
from pathlib import Path
from typing import Any


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8-sig")


def _repo_root() -> Path:
    """Best-effort repo root for repo-local installs.

    Historically this script lived at skills/evo/scripts/evo_run.py inside a repo.
    """

    return Path(__file__).resolve().parents[3]


def _skills_dir() -> Path:
    """Locate the containing skills directory.

    Works for both global installs and repo-local installs.
    """

    here = Path(__file__).resolve()
    for parent in here.parents:
        if parent.name.lower() == "skills":
            return parent

    # Fallback: preserve historical behavior.
    return _repo_root() / "skills"


def _run_prolog_runner(
    *,
    program: str,
    query: str,
    max_solutions: int | None,
    timeout_ms: int,
) -> dict[str, Any]:
    runner = _skills_dir() / "prolog-runner" / "scripts" / "run_prolog.py"
    if not runner.exists():
        raise FileNotFoundError(f"Missing prolog runner at {runner}")

    import subprocess

    cmd = [sys.executable, str(runner), "--program", program, "--query", query, "--timeout-ms", str(timeout_ms)]
    if max_solutions is not None:
        cmd += ["--max-solutions", str(max_solutions)]

    completed = subprocess.run(cmd, capture_output=True, text=True)
    try:
        return json.loads(completed.stdout)
    except json.JSONDecodeError as e:
        return {
            "ok": False,
            "exit_code": completed.returncode,
            "timed_out": False,
            "stdout": completed.stdout,
            "stderr": f"{completed.stderr}\nJSONDecodeError: {e}",
            "solutions": None,
        }


def _decode_kb_b64(value: str) -> str:
    try:
        raw = base64.b64decode(value, validate=True)
    except Exception as e:  # noqa: BLE001
        raise SystemExit(f"Invalid --kb-b64 (base64 decode failed): {e}")

    try:
        return raw.decode("utf-8")
    except UnicodeDecodeError as e:
        raise SystemExit(f"Invalid --kb-b64 (expected UTF-8 text): {e}")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="EVO helper: run EVO harness queries through the Prolog runner and summarize results as JSON."
    )
    parser.add_argument("--kb-file", action="append", default=[], help="Path to a task KB (.pl). May be repeated.")
    parser.add_argument("--kb", default="", help="Inline Prolog KB text (facts/rules/conclusion/1).")
    parser.add_argument(
        "--kb-b64",
        action="append",
        default=[],
        help="Inline Prolog KB as base64-encoded UTF-8 text. May be repeated.",
    )
    parser.add_argument(
        "--assumption",
        action="append",
        default=[],
        help="Enable an assumption by name (injects enabled_assumption(Name).). May be repeated.",
    )
    parser.add_argument("--max-solutions", type=int, default=50, help="Max solutions to fetch for conclusions.")
    parser.add_argument("--timeout-ms", type=int, default=10_000, help="Timeout for each Prolog invocation.")
    args = parser.parse_args(argv)

    harness_path = _skills_dir() / "evo" / "references" / "evo_harness.pl"
    harness = _read_text(harness_path)

    kb_parts: list[str] = []
    for kb_file in args.kb_file:
        kb_parts.append(_read_text(Path(kb_file)))
    if args.kb.strip():
        kb_parts.append(args.kb)
    for kb_b64 in args.kb_b64:
        kb_parts.append(_decode_kb_b64(kb_b64))
    kb = "\n\n".join(kb_parts)

    enabled = "\n".join([f"enabled_assumption({name})." for name in args.assumption])
    program = "\n\n".join([harness, kb, enabled]).strip() + "\n"

    inconsistent_out = _run_prolog_runner(
        program=program,
        query="inconsistent.",
        max_solutions=1,
        timeout_ms=args.timeout_ms,
    )
    inconsistent = bool(inconsistent_out.get("ok") and inconsistent_out.get("solutions"))

    conc_out = _run_prolog_runner(
        program=program,
        query="conclusion_with_proof(Answer, Proof).",
        max_solutions=args.max_solutions,
        timeout_ms=args.timeout_ms,
    )

    conclusions: list[dict[str, Any]] = []
    if conc_out.get("ok") and isinstance(conc_out.get("solutions"), list):
        for sol in conc_out["solutions"]:
            if not isinstance(sol, dict):
                continue
            conclusions.append({"answer": sol.get("Answer"), "proof": sol.get("Proof")})

    assumption_tests: list[dict[str, Any]] = []
    if args.assumption and conclusions:
        for c in conclusions:
            answer = c.get("answer")
            per_assumption: list[dict[str, Any]] = []
            for removed in args.assumption:
                remaining = [a for a in args.assumption if a != removed]
                enabled2 = "\n".join([f"enabled_assumption({name})." for name in remaining])
                program2 = "\n\n".join([harness, kb, enabled2]).strip() + "\n"
                out2 = _run_prolog_runner(
                    program=program2,
                    query="conclusion_with_proof(Answer, _).",
                    max_solutions=200,
                    timeout_ms=args.timeout_ms,
                )
                survives = False
                if out2.get("ok") and isinstance(out2.get("solutions"), list):
                    for sol in out2["solutions"]:
                        if isinstance(sol, dict) and sol.get("Answer") == answer:
                            survives = True
                            break

                per_assumption.append({"assumption": removed, "survives_without": survives})

            robust = all(t["survives_without"] for t in per_assumption)
            assumption_tests.append({"answer": answer, "robust": robust, "tests": per_assumption})

    payload = {
        "inconsistent": inconsistent,
        "inconsistent_raw": inconsistent_out,
        "conclusions_raw": conc_out,
        "conclusions": conclusions,
        "assumption_dependence": assumption_tests,
    }
    sys.stdout.write(json.dumps(payload, ensure_ascii=False) + "\n")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
