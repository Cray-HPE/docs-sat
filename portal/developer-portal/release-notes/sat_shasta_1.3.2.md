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

## Summary of SAT Changes in Shasta v1.3.2

Shasta v1.3.2 included version 2.4.0 of the `sat` python package and CLI.

The following sections detail the changes in this release.

### `sat swap` Command for Switch and Cable Replacement

The `sat switch` command which supported operations for replacing a switch has
been deprecated and replaced with the `sat swap` command, which now supports
replacing a switch OR cable.

The `sat swap switch` command is equivalent to `sat switch`. The `sat switch`
command will be removed in a future release.

### Addition of Stages to `sat bootsys` Command 

The `sat bootsys` command now has multiple stages for both the `boot` and
`shutdown` actions. Please refer to the "System Power On Procedures" and "System
Power Off Procedures" sections of the Cray Shasta Administration Guide (S-8001)
for more details on using this command in the context of a full system power off
and power on.
