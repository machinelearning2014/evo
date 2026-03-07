# Examples

## Example 1: Debugging a failing test

Apply EVO:

- State assumptions (what version, how tests run, what changed)
- Locate failure (`rg` for error, open only the failing files)
- Fix root cause, not the symptom
- Run the smallest command that proves the fix (`<test runner> path/to/test`)
- Stop once green and report what changed

## Example 2: Security-sensitive change

Apply EVO:

- Identify threat model and secrets involved
- Avoid logging sensitive values
- Ask before any destructive action (revoking keys, deleting users)
- Add/verify tests around the security boundary

