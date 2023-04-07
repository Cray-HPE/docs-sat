# SAT Changes in Shasta v1.3.2

Shasta v1.3.2 included version 2.4.0 of the `sat` python package and CLI.

The following sections detail the changes in this release.

## `sat swap` Command for Switch and Cable Replacement

The `sat switch` command which supported operations for replacing a switch has
been deprecated and replaced with the `sat swap` command, which now supports
replacing a switch OR cable.

The `sat swap switch` command is equivalent to `sat switch`. The `sat switch`
command will be removed in a future release.

## Addition of Stages to `sat bootsys` Command

The `sat bootsys` command now has multiple stages for both the `boot` and
`shutdown` actions. Please refer to the "System Power On Procedures" and "System
Power Off Procedures" sections of the *Cray Shasta Administration Guide (S-8001)*
for more details on using this command in the context of a full system power off
and power on.
