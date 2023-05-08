# Changes in SAT 2.2

SAT 2.2.16 was released on February 25th, 2022.

This version of the SAT product included:

- Version 3.14.0 of the `sat` python package and CLI
- Version 1.6.4 of the `sat-podman` wrapper script
- Version 1.0.4 of the `sat-cfs-install` container image and Helm chart

It also added the following new components:

- Version 1.4.3 of the `sat-install-utility` container image
- Version 2.0.2 of the `cfs-config-util` container image

The following sections detail the changes in this release.

## Known Issues in SAT 2.2

### `sat` Command Unavailable in `sat bash` Shell

After launching a shell within the SAT container with `sat bash`, the `sat`
command will not be found. For example:

```screen
(CONTAINER-ID) sat-container:~ # sat status
bash: sat: command not found
```

This can be resolved temporarily in one of two ways. `/sat/venv/bin/` may be
prepended to the `$PATH` environment variable:

```screen
(CONTAINER-ID) sat-container:~ # export PATH=/sat/venv/bin:$PATH
(CONTAINER-ID) sat-container:~ # sat status
```

Or, the file `/sat/venv/bin/activate` may be sourced:

```screen
(CONTAINER-ID) sat-container:~ # source /sat/venv/bin/activate
(CONTAINER-ID) sat-container:~ # sat status
```

### Tab Completion Unavailable in `sat bash` Shell

After launching a shell within the SAT container with `sat bash`, tab completion
for `sat` commands does not work.

This can be resolved temporarily by sourcing the file
`/etc/bash_completion.d/sat-completion.bash`:

```screen
source /etc/bash_completion.d/sat-completion.bash
```

### OCI Runtime Permission Error when Running `sat` in Root Directory

`sat` commands will not work if the current directory is `/`. For example:

```screen
ncn-m001:/ # sat --help
Error: container_linux.go:380: starting container process caused: process_linux.go:545: container init caused: open /dev/console: operation not permitted: OCI runtime permission denied error
```

To resolve, run `sat` in another directory.

### Duplicate Mount Error when Running `sat` in Config Directory

`sat` commands will not work if the current directory is `~/.config/sat`.
For example:

```screen
ncn-m001:~/.config/sat # sat --help
Error: /root/.config/sat: duplicate mount destination
```

To resolve, run `sat` in another directory.

## New `sat` Commands

- `sat bootprep` automates the creation of CFS configurations, the build and
  customization of IMS images, and the creation of BOS session templates. For
  more information, see [SAT Bootprep](../usage/sat_bootprep.md).
- `sat slscheck` performs a check for consistency between the System Layout
  Service (SLS) and the Hardware State Manager (HSM).
- `sat bmccreds` provides a simple interface for interacting with the System
  Configuration Service (SCSD) to set BMC Redfish credentials.
- `sat hwhist` displays hardware component history by XName (location) or by
  its Field-Replaceable Unit ID (FRUID). This command queries the Hardware
  State Manager (HSM) API to obtain this information. Since the `sat hwhist`
  command supports querying for the history of a component by its FRUID, the
  FRUID of components has been added to the output of `sat hwinv`.

## Additional Install Automation

The following automation has been added to the install script, `install.sh`:

- Wait for the completion of the `sat-config-import` Kubernetes job, which is
  started when the `sat-cfs-install` Helm chart is deployed.
- Automate the modification of the CFS configuration, which applies to master
  management NCNs (for example, `ncn-personalization`).

## Changes to Product Catalog Data Schema

The SAT product uploads additional information to the `cray-product-catalog`
Kubernetes ConfigMap detailing the components it provides, including container
(Docker) images, Helm charts, RPMs, and package repositories.

This information is used to support uninstall and downgrade of SAT product
versions moving forward.

## Support for Uninstall and Downgrade of SAT Versions

Beginning with the 2.2 release, SAT now provides partial support for the
uninstall and downgrade of the SAT product stream.

For more information, see
[Uninstall: Remove a Version of SAT](../uninstall_and_downgrade.md#uninstall-remove-a-version-of-sat) and
[Downgrade: Switch Between SAT Versions](../uninstall_and_downgrade.md#downgrade-switch-between-sat-versions).

## Improvements to `sat status`

A `Subrole` column has been added to the output of `sat status`. This allows you
to easily differentiate between master, worker, and storage nodes in the
management role, for example.

Hostname information from SLS has been added to `sat status` output.

## Added Support for JSON Output

Support for JSON-formatted output has been added to commands which currently
support the `--format` option, such as `hwinv`, `status`, and `showrev`.

## Usability Improvements

Many usability improvements have been made to multiple `sat` commands,
mostly related to filtering command output. The following are some highlights:

- Added `--fields` option to display only specific fields for subcommands which
  display tabular reports.
- Added ability to filter on exact matches of a field name.
- Improved handling of multiple matches of a field name in `--filter` queries
  so that the first match is used, similar to `--sort-by`.
- Added support for `--filter`, `--fields`, and `--reverse` for summaries
  displayed by `sat hwinv`.
- Added borders to summary tables generated by `sat hwinv`.
- Improved documentation in the man pages.

## Default Log Level Changed

The default log level for `stderr` has been changed from "WARNING" to "INFO". For
more information, see [Update SAT Logging](../upgrade.md#update-sat-logging).

## More Granular Log Level Configuration Options

With the command-line options `--loglevel-stderr` and `--loglevel-file`, the log
level can now be configured separately for `stderr` and the log file.

The existing `--loglevel` option is now an alias for the `--loglevel-stderr`
option.

## Podman Wrapper Script Improvements

The Podman wrapper script is the script installed at `/usr/bin/sat` on the
master management NCNs by the `cray-sat-podman` RPM that runs the `cray-sat`
container in `podman`. The following subsections detail improvements that were
made to the wrapper script in this release.

### Mounting of $HOME and Current Directories in `cray-sat` Container

The Podman wrapper script that launches the `cray-sat` container with `podman`
has been modified to mount the user's current directory and home directory into
the `cray-sat` container to provide access to local files in the container.

### Podman Wrapper Script Documentation Improvements

The man page for the Podman wrapper script, which is accessed by typing `man
sat` on a master management NCN, has been improved to document the following:

- Environment variables that affect execution of the wrapper script
- Host files and directories mounted in the container

### Fixes to Podman Wrapper Script Output Redirection

Fixed issues with redirecting `stdout` and `stderr`, and piping output to
commands, such as `awk`, `less`, and `more`.

## Configurable HTTP Timeout

A new `sat` option has been added to configure the HTTP timeout length for
requests to the API gateway. For more information, refer to `sat-man sat`.

## `sat bootsys` Improvements

Many improvements and fixes have been made to `sat bootsys`. The following are
some highlights:

- Added the `--excluded-ncns` option, which can be used to omit NCNs
  from the `platform-services` and `ncn-power` stages in case they are
  inaccessible.
- Disruptive shutdown stages in `sat bootsys shutdown` now prompt the user to
  continue before proceeding. A new option, `--disruptive`, will bypass this.
- Improvements to Ceph service health checks and restart during the
  `platform-services` stage of `sat bootsys boot`.

## `sat xname2nid` Improvements

`sat xname2nid` can now recursively expand slot, chassis, and cabinet XNames to
a list of NIDs in those locations.

A new `--format` option has been added to `sat xname2nid`. It sets the output
format to either "range" (the default) or "NID". The "range" format displays NIDs
in a compressed range format suitable for use with a workload manager like Slurm.

## Usage of `v2` HSM API

The commands which interact with HSM (for example, `sat status` and `sat hwinv`)
now use the `v2` HSM API.

## `sat diag` Limited to HSN Switches

`sat diag` will now only operate against HSN switches by default. These are the
only controllers that support running diagnostics with HMJTD.

## `sat showrev` Enhancements

A column has been added to the output of `sat showrev` that indicates whether a
product version is "active". The definition of "active" varies across products,
and not all products may set an "active" version.

For SAT, the active version is the one with its hosted-type package repository
in Nexus set as the member of the group-type package repository in Nexus,
meaning that it will be used when installing the `cray-sat-podman` RPM.

## `cray-sat` Container Image Size Reduction

The size of the `cray-sat` container image has been approximately cut in half by
leveraging multi-stage builds. This also improved the repeatability of the unit
tests by running them in the container.

## Bug Fixes

Minor bug fixes were made in `cray-sat` and in `cray-sat-podman`. For full
change lists, refer to each repository's `CHANGELOG.md` file.
