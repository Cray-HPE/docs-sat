[//]: # ((C) Copyright 2022 Hewlett Packard Enterprise Development LP)

[//]: # (Permission is hereby granted, free of charge, to any person obtaining a)
[//]: # (copy of this software and associated documentation files (the "Software"),)
[//]: # (to deal in the Software without restriction, including without limitation)
[//]: # (the rights to use, copy, modify, merge, publish, distribute, sublicense,)
[//]: # (and/or sell copies of the Software, and to permit persons to whom the)
[//]: # (Software is furnished to do so, subject to the following conditions:)

[//]: # (The above copyright notice and this permission notice shall be included)
[//]: # (in all copies or substantial portions of the Software.)

[//]: # (THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR)
[//]: # (IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,)
[//]: # (FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL)
[//]: # (THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR)
[//]: # (OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,)
[//]: # (ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR)
[//]: # (OTHER DEALINGS IN THE SOFTWARE.)

## Summary of SAT Changes in Shasta v1.4.1

We released version 2.0.4 of the SAT product in Shasta v1.4.1.

This version of the SAT product included:

- Version 3.5.0 of the `sat` python package and CLI.
- Version 1.4.3 of the `sat-podman` wrapper script.

The following sections detail the changes in this release.

### New Commands to Translate Between NIDs and XNames

Two new commands were added to translate between NIDs and XNames:

- `sat nid2xname`
- `sat xname2nid`

These commands perform this translation by making requests to the Hardware
State Manager (HSM) API.

### Bug Fixes

- Fixed a problem in `sat swap` where creating the offline port policy failed.
- Changed `sat bootsys shutdown --stage bos-operations` to no longer forcefully
  power off *all* compute nodes and application nodes using CAPMC when BOS
  sessions complete or time out.
- Fixed an issue with the command `sat bootsys boot --stage cabinet-power`.
