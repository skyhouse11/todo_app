# Semantic Versioning (SemVer)

## Summary

Given a version number MAJOR.MINOR.PATCH, increment the:

1. **MAJOR** version when you make incompatible API changes
2. **MINOR** version when you add functionality in a backward compatible manner
3. **PATCH** version when you make backward compatible bug fixes

Additional labels for pre-release and build metadata are available as extensions to the MAJOR.MINOR.PATCH format.

---

## Key Concepts

- **Dependency Hell:** Problems caused by tight or loose dependency specifications, leading to version lock or version promiscuity.
- **Public API:** Clearly defined and documented, changes to which are communicated via version numbers.
- **Version Format:** `X.Y.Z` (Major.Minor.Patch)
    - **Patch:** Bug fixes not affecting API
    - **Minor:** Backwards-compatible API additions/changes
    - **Major:** Incompatible API changes
- **Pre-release and Build Metadata:** Extensions like `1.0.0-alpha`, `1.0.0+20130313144700`

## Rules

1. Version numbers and the way they change convey meaning about the underlying code and what has been modified from one version to the next.
2. Software using SemVer must declare a public API.
3. Changes to the public API must result in a new version number as per the rules:
    - MAJOR version for incompatible API changes
    - MINOR version for backwards-compatible functionality
    - PATCH version for backwards-compatible bug fixes
4. Pre-release versions are denoted by appending a hyphen and a series of dot separated identifiers (e.g. `1.0.0-alpha.1`).
5. Build metadata is denoted by appending a plus sign and a series of dot separated identifiers (e.g. `1.0.0+20130313144700`).
6. Precedence is determined by the first difference when comparing each segment from left to right: MAJOR, MINOR, PATCH, pre-release.

## Why Use Semantic Versioning?

- Communicates intent and compatibility to users and systems.
- Enables safe, flexible dependency management.
- Avoids version lock and version promiscuity.

## Example Version Precedence

```
1.0.0-alpha < 1.0.0-alpha.1 < 1.0.0-alpha.beta < 1.0.0-beta < 1.0.0-beta.2 < 1.0.0-beta.11 < 1.0.0-rc.1 < 1.0.0
```

## BNF Grammar for Valid SemVer

```
<valid semver> ::= <version core>
                 | <version core> "-" <pre-release>
                 | <version core> "+" <build>
                 | <version core> "-" <pre-release> "+" <build>
<version core> ::= <major> "." <minor> "." <patch>
<major> ::= <numeric identifier>
<minor> ::= <numeric identifier>
<patch> ::= <numeric identifier>
<pre-release> ::= <dot-separated pre-release identifiers>
<dot-separated pre-release identifiers> ::= <pre-release identifier>
                                          | <pre-release identifier> "." <dot-separated pre-release identifiers>
<build> ::= <dot-separated build identifiers>
<dot-separated build identifiers> ::= <build identifier>
                                    | <build identifier> "." <dot-separated build identifiers>
```

## FAQ Highlights

- **Is “v1.2.3” a semantic version?** No, but prefixing with `v` is common in version control tags.
- **How should I handle deprecating functionality?** Announce in docs, deprecate in a minor release, remove in a major release.
- **Does SemVer have a size limit?** No, but use good judgment.

---

For full details, see: https://semver.org/
