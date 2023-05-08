# SAT Changes in Shasta v1.4.1

We released version 2.0.4 of the SAT product in Shasta v1.4.1.

This version of the SAT product included:

- Version 3.5.0 of the `sat` python package and CLI.
- Version 1.4.3 of the `sat-podman` wrapper script.

The following sections detail the changes in this release.

## New Commands to Translate Between NIDs and XNames

Two new commands were added to translate between NIDs and XNames:

- `sat nid2xname`
- `sat xname2nid`

These commands perform this translation by making requests to the Hardware
State Manager (HSM) API.

## Bug Fixes

- Fixed a problem in `sat swap` where creating the offline port policy failed.
- Changed `sat bootsys shutdown --stage bos-operations` to no longer forcefully
  power off *all* compute nodes and application nodes using CAPMC when BOS
  sessions complete or time out.
- Fixed an issue with the command `sat bootsys boot --stage cabinet-power`.
