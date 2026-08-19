# Security policy

## Supported versions

Only the current `master` branch is supported. The image is rebuilt from the
latest patched packages rather than versioned, so "supported" means the most
recent build.

## Reporting a vulnerability

Report anything you find through
[GitHub security advisories](https://github.com/konstruktoid/container-aptcacherng-build/security/advisories/new),
not as a public issue.

Please include what the issue is, how to reproduce it, and which image digest or
commit you saw it on.

## Scope

Vulnerabilities in the packages this image installs belong upstream, with the
distribution or the project itself. What is in scope here is how this repository
builds and configures the image: the `Dockerfile`, the shipped configuration,
the entry point scripts and the GitHub Actions workflows.
