# Conventional Commits 1.0.0

## Summary

The Conventional Commits specification is a lightweight convention for commit messages. It provides a set of rules for creating an explicit, machine-readable commit history, making it easier to automate changelogs, versioning, and other tooling. It dovetails with [Semantic Versioning (SemVer)](https://semver.org/).

## Commit Message Format

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types
- **fix:** patches a bug (correlates with PATCH in SemVer)
- **feat:** introduces a new feature (correlates with MINOR in SemVer)
- **BREAKING CHANGE:** in footer or as `!` after type/scope, introduces breaking API change (correlates with MAJOR in SemVer)
- Other types (e.g. `build:`, `chore:`, `ci:`, `docs:`, `style:`, `refactor:`, `perf:`, `test:`) are allowed for clarity but are not required by the spec

### Example
```
feat(auth): add anonymous sign-in

Add support for passwordless device-based authentication.

BREAKING CHANGE: The old login endpoint was removed.
```

## Key Rules
1. Commits must be prefixed with a type, e.g. `fix:`, `feat:`.
2. Optional scope can be added in parentheses, e.g. `feat(auth):`.
3. Description must be concise and in the imperative mood.
4. Body and footers are optional but recommended for context.
5. BREAKING CHANGES must be indicated in the footer or by `!` after type/scope.
6. Types and footers are not case sensitive (except BREAKING CHANGE).

## Why Use Conventional Commits?
- Automate changelog generation
- Automate semantic versioning
- Communicate the nature of changes to the team and users
- Trigger build and release processes
- Encourage organized, meaningful commits

## FAQ Highlights
- **How does this relate to SemVer?**
    - `fix` → PATCH
    - `feat` → MINOR
    - `BREAKING CHANGE` → MAJOR
- **What if a commit fits multiple types?** Make multiple commits if possible.
- **What if I use the wrong type?** Amend before merge, or accept that some tooling may ignore it.
- **Do all contributors need to use it?** No, maintainers can squash and edit messages as needed.

---

For full details, see: https://www.conventionalcommits.org/en/v1.0.0/
