# Changes in SAT 2.3

The 2.3.4 version of the SAT product includes:

- Version 3.15.4 of the `sat` python package and CLI
- Version 1.6.11 of the `sat-podman` wrapper script
- Version 1.2.0 of the `sat-cfs-install` container image
- Version 2.0.0 of the `sat-cfs-install` Helm chart
- Version 1.5.0 of the `sat-install-utility` container image
- Version 2.0.3 of the `cfs-config-util` container image

## New `sat` Commands

None.

## Current Working Directory in SAT Container

When running `sat` commands, the current working directory is now mounted in the
container as `/sat/share`, and the current working directory within the container
is also `/sat/share`.

Files in the current working directory must be specified using relative paths to
that directory, because the current working directory is always mounted on
`/sat/share`. Absolute paths should be avoided, and paths that are outside of
`$HOME` or `$PWD` are never accessible to the container environment.

The home directory is still mounted on the same path inside the container as it
is on the host.

## Changes to `sat bootsys`

The following options were added to `sat bootsys`.

- `--bos-limit`
- `--recursive`

The `--bos-limit` option passes a given limit string to a BOS session. The
`--recursive` option specifies a slot or other higher-level component in the
limit string.

## Changes to `sat bootprep`

The `--delete-ims-jobs` option was added to `sat bootprep run`. It deletes IMS
jobs after `sat bootprep` is run. Jobs are no longer deleted by default.

## Changes to `sat status`

`sat status` now includes information about nodes' CFS configuration statuses,
such as desired configuration, configuration status, and error count.

The output of `sat status` now splits different component types into different
report tables.

The following options were added to `sat status`.

- `--hsm-fields`, `--sls-fields`, `--cfs-fields`
- `--bos-template`

The `--hsm-fields`, `--sls-fields`, `--cfs-fields` options limit the output
columns according to specified CSM services.

The `--bos-template` option filters the status report according to the specified
session template's boot sets.

## Compatibility with CSM 1.2

The following components were modified to be compatible with CSM 1.2.

- `sat-cfs-install` container image and Helm chart
- `sat-install-utility` container image
- SAT product installer

## GPG Checking

The `sat-ncn` Ansible role provided by `sat-cfs-install` was modified to enable
GPG checks on packages while leaving GPG checks disabled on repository metadata.

## Security

Updated `urllib3` dependency to version 1.26.5 to mitigate CVE-2021-33503 and
refreshed Python dependency versions.

## Bug Fixes

Minor bug fixes were made in each of the repositories. For full change lists,
refer to each repository’s `CHANGELOG.md` file.

The [known issues listed under the SAT 2.2 release](sat_2.2_release_notes.md#known-issues-in-sat-22)
were fixed.
