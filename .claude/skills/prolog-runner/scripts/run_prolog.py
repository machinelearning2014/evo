#!/usr/bin/env python3
from __future__ import annotations

import argparse
import json
import os
import shutil
import subprocess
import sys
import tempfile
import uuid
from pathlib import Path


def _find_swipl(explicit_path: str | None) -> str | None:
    if explicit_path:
        return explicit_path
    return shutil.which("swipl") or shutil.which("swipl.exe")


def _build_runner_pl() -> str:
    # Reads the query from argv[0] and (optionally) a max-solutions integer from argv[1].
    # Produces JSON on stdout: {"solutions":[{...}, ...]}.
    #
    # Note: This intentionally does not consult user files; the caller should embed the
    # program into the same file before this runner logic.
    return r"""
:- use_module(library(http/json)).

maybe_use_findnsols(Max, Template, Goal, Solutions) :-
    ( var(Max) ->
        findall(Template, Goal, Solutions)
    ; integer(Max) ->
        (   catch(use_module(library(solution_sequences)), _, fail)
        ->  findnsols(Max, Template, Goal, Solutions)
        ;   findall(Template, Goal, All),
            length(Prefix, Max),
            append(Prefix, _, All),
            Solutions = Prefix
        )
    ).

bindings_pairs([], []).
bindings_pairs([Name=Value | Rest], [Name-Value | Pairs]) :-
    bindings_pairs(Rest, Pairs).

solution_dict(VarNames, Dict) :-
    bindings_pairs(VarNames, Pairs),
    dict_create(Dict, bindings, Pairs).

main :-
    current_prolog_flag(argv, Argv),
    (   Argv = [QueryAtom | Rest]
    ->  true
    ;   print_message(error, error(syntax_error(missing_query), _)),
        halt(2)
    ),
    (   Rest = [MaxAtom]
    ->  catch(atom_number(MaxAtom, Max0), _, Max0 = _),
        ( integer(Max0), Max0 >= 0 -> Max = Max0 ; Max = _ )
    ;   Max = _
    ),
    catch(
        read_term_from_atom(QueryAtom, Goal, [variable_names(VarNames), syntax_errors(error)]),
        Error,
        ( print_message(error, Error), halt(2) )
    ),
    catch(
        maybe_use_findnsols(Max, Dict, (call(Goal), solution_dict(VarNames, Dict)), Solutions),
        Error2,
        ( print_message(error, Error2), halt(2) )
    ),
    json_write_dict(current_output, _{solutions: Solutions}, [width(0)]),
    nl.

:- initialization(main, main).
""".lstrip()


def _write_combined_program(path: Path, program: str) -> None:
    # Put the user program first so predicates are available to the runner below.
    combined = (
        "% --- user program (embedded) ---\n"
        + (program.rstrip() + "\n" if program.strip() else "")
        + "% --- runner ---\n"
        + _build_runner_pl()
    )
    path.write_text(combined, encoding="utf-8", newline="\n")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(
        description="Run a Prolog query via SWI-Prolog (swipl) and return JSON solutions."
    )
    parser.add_argument(
        "--query",
        required=True,
        help='Prolog goal to run, e.g. "member(X,[1,2,3])."',
    )
    parser.add_argument(
        "--program",
        default="",
        help="Prolog program text (facts/rules) to embed before running the query.",
    )
    parser.add_argument(
        "--file",
        action="append",
        default=[],
        help="Additional .pl file to embed (concatenated into the program). May be repeated.",
    )
    parser.add_argument(
        "--max-solutions",
        type=int,
        default=None,
        help="Return at most N solutions (0 => empty list).",
    )
    parser.add_argument(
        "--swipl",
        default=None,
        help="Path to swipl executable (defaults to swipl on PATH).",
    )
    parser.add_argument(
        "--timeout-ms",
        type=int,
        default=10_000,
        help="Kill swipl after this many milliseconds.",
    )
    args = parser.parse_args(argv)

    swipl = _find_swipl(args.swipl)
    if not swipl:
        sys.stderr.write(
            "swipl not found. Install SWI-Prolog and ensure `swipl` is on PATH, or pass --swipl.\n"
        )
        return 127

    embedded_parts: list[str] = []
    for file_str in args.file:
        file_path = Path(file_str)
        # Use utf-8-sig to tolerate BOM-prefixed files (common on Windows).
        embedded_parts.append(file_path.read_text(encoding="utf-8-sig"))
    if args.program.strip():
        embedded_parts.append(args.program)
    program_text = "\n\n".join(embedded_parts)

    tmp_base = os.environ.get("CODEX_SKILL_TMPDIR")
    if tmp_base:
        tmp_base_path = Path(tmp_base)
    else:
        # Default to a stable per-user temp dir so the runner is global and does not
        # write into whatever repo you happen to be in.
        home = Path(os.environ.get("USERPROFILE") or Path.home())
        tmp_base_path = home / ".codex-tmp" / "prolog-runner"
    tmp_base_path.mkdir(parents=True, exist_ok=True)

    combined_pl = tmp_base_path / f"codex_runner_{uuid.uuid4().hex}.pl"
    try:
        _write_combined_program(combined_pl, program_text)

        cmd = [swipl, "-q", "-f", "none", "-s", str(combined_pl), "--", args.query]
        if args.max_solutions is not None:
            cmd.append(str(args.max_solutions))

        try:
            completed = subprocess.run(
                cmd,
                cwd=str(tmp_base_path),
                capture_output=True,
                text=True,
                timeout=max(0.0, args.timeout_ms / 1000.0),
            )
        except subprocess.TimeoutExpired as e:
            payload = {
                "ok": False,
                "exit_code": None,
                "timed_out": True,
                "timeout_ms": args.timeout_ms,
                "stdout": (e.stdout or ""),
                "stderr": (e.stderr or ""),
                "solutions": None,
            }
            sys.stdout.write(json.dumps(payload, ensure_ascii=False) + "\n")
            return 124
    finally:
        combined_pl.unlink(missing_ok=True)

    stdout = completed.stdout or ""
    stderr = completed.stderr or ""
    solutions = None
    ok = completed.returncode == 0
    timed_out = False

    if ok:
        try:
            decoded = json.loads(stdout)
            solutions = decoded.get("solutions")
        except json.JSONDecodeError:
            ok = False

    payload = {
        "ok": ok,
        "exit_code": completed.returncode,
        "timed_out": timed_out,
        "stdout": stdout,
        "stderr": stderr,
        "solutions": solutions,
    }
    sys.stdout.write(json.dumps(payload, ensure_ascii=False) + "\n")
    return completed.returncode


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
