# SAT Release Notes

## Summary of Changes in SAT 2.3

The 2.3.4 version of the SAT product includes:

- Version 3.15.4 of the sat python package and CLI
- Version 1.6.11 of the sat-podman wrapper script
- Version 1.2.0 of the sat-cfs-install container image
- Version 2.0.0 of the sat-cfs-install Helm chart
- Version 1.5.0 of the sat-install-utility container image
- Version 2.0.3 of the cfs-config-util container image

### New `sat` Commands

None.

### Current Working Directory in SAT Container

When running `sat` commands, the current working directory is now mounted in the
container as `/sat/share`, and the current working directory within the container
is also `/sat/share`.

Files in the current working directory must be specified using relative paths to
that directory, because the current working directory is always mounted on `/sat/share`.
Absolute paths should be avoided, and paths that are outside of `$HOME` or `$PWD`
are never accessible to the container environment.

The home directory is still mounted on the same path inside the container as it
is on the host.

### Changes to `sat bootsys`

The following options were added to `sat bootsys`.

- `--bos-limit`
- `--recursive`

The `--bos-limit` option passes a given limit string to a BOS session. The `--recursive`
option specifies a slot or other higher-level component in the limit string

### Changes to `sat bootprep`

The `--delete-ims-jobs` option was added to `sat bootprep run`. It deletes IMS
jobs after `sat bootprep` is run. Jobs are no longer deleted by default.

### Changes to `sat status`

`sat status` now includes information about nodes' CFS configuration statuses, such
as desired configuration, configuration status, and error count.

The output of `sat status` now splits different component types into different report tables.

The following options were added to `sat status`.

- `--hsm-fields`, `--sls-fields`, `--cfs-fields`
- `--bos-template`

The `--hsm-fields`, `--sls-fields`, `--cfs-fields` options limit the output columns
according to specified CSM services.

The `--bos-template` option filters the status report according to the specified
session template's boot sets.

### Compatibility with CSM 1.2

The following components were modified to be compatible with CSM 1.2.

- `sat-cfs-install` container image and Helm chart
- `sat-install-utility` container image
- SAT product installer

### GPG Checking

The `sat-ncn` ansible role provided by `sat-cfs-install` was modified to enable
GPG checks on packages while leaving GPG checks disabled on repository metadata.

### Security

Updated urllib3 dependency to version 1.26.5 to mitigate CVE-2021-33503 and refreshed
Python dependency versions.

### Bug Fixes

Minor bug fixes were made in each of the repositories. For full change lists, see each
repository’s CHANGELOG.md file.

The [known issues listed under the SAT 2.2 release](#known-issues-in-sat-22) were fixed.

## Summary of changes in SAT 2.2

SAT 2.2.16 was released on February 25th, 2022.

This version of the SAT product included:

- Version 3.14.0 of the `sat` python package and CLI
- Version 1.6.4 of the `sat-podman` wrapper script
- Version 1.0.4 of the `sat-cfs-install` container image and Helm chart

It also added the following new components:

- Version 1.4.3 of the `sat-install-utility` container image
- Version 2.0.2 of the `cfs-config-util` container image

The following sections detail the changes in this release.

### Known issues in SAT 2.2

#### `sat` command unavailable in `sat bash` shell

After launching a shell within the SAT container with `sat bash`, the `sat` command will not
be found. For example:

```screen
(CONTAINER-ID) sat-container:~ # sat status
bash: sat: command not found
```

This can be resolved temporarily in one of two ways. `/sat/venv/bin/` may be prepended to the
`$PATH` environment variable:

```screen
(CONTAINER-ID) sat-container:~ # export PATH=/sat/venv/bin:$PATH
(CONTAINER-ID) sat-container:~ # sat status
```

Or, the file `/sat/venv/bin/activate` may be sourced:

```screen
(CONTAINER-ID) sat-container:~ # source /sat/venv/bin/activate
(CONTAINER-ID) sat-container:~ # sat status
```

#### Tab completion unavailable in `sat bash` shell

After launching a shell within the SAT container with `sat bash`, tab completion for `sat`
commands does not work.

This can be resolved temporarily by sourcing the file `/etc/bash_completion.d/sat-completion.bash`:

```screen
source /etc/bash_completion.d/sat-completion.bash
```

#### OCI runtime permission error when running `sat` in root directory

`sat` commands will not work if the current directory is `/`. For example:

```screen
ncn-m001:/ # sat --help
Error: container_linux.go:380: starting container process caused: process_linux.go:545: container init caused: open /dev/console: operation not permitted: OCI runtime permission denied error
```

To resolve, run `sat` in another directory.

#### Duplicate mount error when running `sat` in config directory

`sat` commands will not work if the current directory is `~/.config/sat`. For example:

```screen
ncn-m001:~/.config/sat # sat --help
Error: /root/.config/sat: duplicate mount destination
```

To resolve, run `sat` in another directory.

### New `sat` commands

- `sat bootprep` automates the creation of CFS configurations, the build and
  customization of IMS images, and the creation of BOS session templates. See
  [SAT Bootprep](usage.md#sat-bootprep) for details.
- `sat slscheck` performs a check for consistency between the System Layout
  Service (SLS) and the Hardware State Manager (HSM).
- `sat bmccreds` provides a simple interface for interacting with the System
  Configuration Service (SCSD) to set BMC Redfish credentials.
- `sat hwhist` displays hardware component history by xname (location) or by
  its Field-Replaceable Unit ID (FRUID). This command queries the Hardware
  State Manager (HSM) API to obtain this information. Since the `sat hwhist`
  command supports querying for the history of a component by its FRUID, the
  FRUID of components has been added to the output of `sat hwinv`.

### Additional Install Automation

The following automation has been added to the install script, `install.sh`:

- Wait for the completion of the `sat-config-import` Kubernetes job, which is
  started when the sat-cfs-install Helm chart is deployed.
- Automate the modification of the CFS configuration, which applies to master
  management NCNs (e.g. "ncn-personalization").

### Changes to Product Catalog Data Schema

The SAT product uploads additional information to the `cray-product-catalog`
Kubernetes ConfigMap detailing the components it provides, including container
(Docker) images, Helm charts, RPMs, and package repositories.

This information is used to support uninstall and activation of SAT product
versions moving forward.

### Support for Uninstall and Activation of SAT Versions

Beginning with the 2.2 release, SAT now provides partial support for the
uninstall and activation of the SAT product stream.

See [Uninstall: Removing a Version of SAT](install.md#uninstall-removing-a-version-of-sat)
and [Activate: Switching Between Versions](install.md#activate-switching-between-versions)
for details.

### Improvements to `sat status`

A `Subrole` column has been added to the output of `sat status`. This allows you
to easily differentiate between master, worker, and storage nodes in the
management role, for example.

Hostname information from SLS has been added to `sat status` output.

### Added Support for JSON Output

Support for JSON-formatted output has been added to commands which currently
support the `--format` option, such as `hwinv`, `status`, and `showrev`.

### Usability Improvements

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

### Default Log Level Changed

The default log level for stderr has been changed from "WARNING" to "INFO". For
details, see [SAT Logging](install.md#sat-logging).

### More Granular Log Level Configuration Options

With the command-line options `--loglevel-stderr` and `--loglevel-file`, the log level
can now be configured separately for stderr and the log file.

The existing `--loglevel` option is now an alias for the `--loglevel-stderr` option.

### Podman Wrapper Script Improvements

The Podman wrapper script is the script installed at `/usr/bin/sat` on the
master management NCNs by the `cray-sat-podman` RPM that runs the `cray-sat`
container in `podman`. The following subsections detail improvements that were
made to the wrapper script in this release.

#### Mounting of $HOME and Current Directories in cray-sat Container

The Podman wrapper script that launches the `cray-sat` container with `podman`
has been modified to mount the user's current directory and home directory into
the `cray-sat` container to provide access to local files in the container.

#### Podman Wrapper Script Documentation Improvements

The man page for the Podman wrapper script, which is accessed by typing `man
sat` on a master management NCN, has been improved to document the following:

- Environment variables that affect execution of the wrapper script
- Host files and directories mounted in the container

#### Fixes to Podman Wrapper Script Output Redirection

Fixed issues with redirecting stdout and stderr, and piping output to commands,
such as `awk`, `less`, and `more`.

### Configurable HTTP Timeout

A new `sat` option has been added to configure the HTTP timeout length for
requests to the API gateway. See `sat-man sat` for details.

### `sat bootsys` Improvements

Many improvements and fixes have been made to `sat bootsys`. The following are some
highlights:

- Added the `--excluded-ncns` option, which can be used to omit NCNs
  from the `platform-services` and `ncn-power` stages in case they are
  inaccessible.
- Disruptive shutdown stages in `sat bootsys shutdown` now prompt the user to
  continue before proceeding. A new option, `--disruptive`, will bypass this.
- Improvements to Ceph service health checks and restart during the `platform-services`
  stage of `sat bootsys boot`.

### `sat xname2nid` Improvements

`sat xname2nid` can now recursively expand slot, chassis, and cabinet xnames to
a list of nids in those locations.

A new `--format` option has been added to `sat xname2nid`. It sets the output format to
either "range" (the default) or "nid". The "range" format displays nids in a
compressed range format suitable for use with a workload manager like Slurm.

### Usage of v2 HSM API

The commands which interact with HSM (e.g., `sat status` and `sat hwinv`) now
use the v2 HSM API.

### `sat diag` Limited to HSN Switches

`sat diag` will now only operate against HSN switches by default. These are the
only controllers that support running diagnostics with HMJTD.

### `sat showrev` Enhancements

A column has been added to the output of `sat showrev` that indicates whether a
product version is "active". The definition of "active" varies across products,
and not all products may set an "active" version.

For SAT, the active version is the one with its hosted-type package repository in
Nexus set as the member of the group-type package repository in Nexus,
meaning that it will be used when installing the `cray-sat-podman` RPM.

### `cray-sat` Container Image Size Reduction

The size of the `cray-sat` container image has been approximately cut in half by
leveraging multi-stage builds. This also improved the repeatability of the unit
tests by running them in the container.

### Bug Fixes

Minor bug fixes were made in `cray-sat` and in `cray-sat-podman`. For full change lists,
see each repository's `CHANGELOG.md` file.

## Summary of SAT changes in Shasta v1.5

We released version 2.1.16 of the SAT product in Shasta v1.5.

This version of the SAT product included:

- Version 3.7.4 of the `sat` python package and CLI
- Version 1.4.10 of the `sat-podman` wrapper script

It also added the following new component:

- Version 1.0.3 of the `sat-cfs-install` docker image and helm chart

The following sections detail the changes in this release.

### Install Changes to Separate Product from CSM

This release further decouples the installation of the SAT product from the CSM
product. The `cray-sat-podman` RPM is no longer installed in the management
non-compute node (NCN) image. Instead, the `cray-sat-podman` RPM is installed on
all master management NCNs via an Ansible playbook which is referenced by a
layer of the CFS configuration that applies to management NCNs. This CFS
configuration is typically named "ncn-personalization".

The SAT product now includes a Docker image and a Helm chart named
`sat-cfs-install`. The SAT install script, `install.sh`, deploys the Helm chart
with Loftsman. This helm chart deploys a Kubernetes job that imports the
SAT Ansible content to a git repository in VCS (Gitea) named `sat-config-management`.
This repository is referenced by the layer added to the NCN personalization
CFS configuration.

### Removal of Direct Redfish Access

All commands which used to access Redfish directly have either been removed or
modified to use higher-level service APIs. This includes the following commands:

- `sat sensors`
- `sat diag`
- `sat linkhealth`

The `sat sensors` command has been rewritten to use the SMA telemetry API to
obtain the latest sensor values. The command's usage has changed slightly, but
legacy options work as before, so it is backwards compatible. Additionally, new
commands have been added.

The `sat diag` command has been rewritten to use a new service called Fox, which
is delivered with the CSM-diags product. The `sat diag` command now launches
diagnostics using the Fox service, which launches the corresponding diagnostic
executables on controllers using the Hardware Management Job and Task Daemon
(HMJTD) over Redfish. Essentially, Fox serves as a proxy for us to start
diagnostics over Redfish.

The `sat linkhealth` command has been removed. Its functionality has been
replaced by functionality from the Slingshot Topology Tool (STT) in the
fabric manager pod.

The Redfish username and password command line options and config file options
have been removed. For further instructions, see [Remove Obsolete Configuration
File Sections](install.md#remove-obsolete-configuration-file-sections).

### Additional Fields in `sat setrev` and `sat showrev`

`sat setrev` now collects the following information from the admin, which is then displayed by `sat showrev`:

- System description
- Product number
- Company name
- Country code

Additional guidance and validation has been added to each field collected by
`sat setrev`. This sets the stage for `sdu setup` to stop collecting this
information and instead collect it from `sat showrev` or its S3 bucket.

### Improvements to `sat bootsys`

The `platform-services` stage of the `sat bootsys boot` command has been
improved to start inactive Ceph services, unfreeze Ceph, and wait for Ceph
health in the correct order. The `ceph-check` stage has been removed as it is no
longer needed.

The `platform-services` stage of `sat bootsys` boot now prompts for confirmation
of the storage NCN hostnames in addition to the Kubernetes masters and workers.

### Bug Fixes and Security Fixes

- Improved error handling in `sat firmware`.
- Incremented version of Alpine Linux to 3.13.2 to address a security
  vulnerability.

### Other Notable Changes

- Ansible has been removed from the `cray-sat` container image.
- Support for the Firmware Update Service (FUS) has been removed from the `sat
  firmware` command.

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

## Summary of SAT Changes in Shasta v1.4

In Shasta v1.4, SAT became an independent product, which meant we began to
designate a version number for the entire SAT product. We released version
2.0.3 of the SAT product in Shasta v1.4.

This version of the SAT product included the following components:

- Version 3.4.0 of the `sat` python package and CLI

It also added the following new component:

- Version 1.4.2 of the `sat-podman` wrapper script

The following sections detail the changes in this release.

### SAT as an Independent Product

SAT is now packaged and released as an independent product. The product
deliverable is called a "release distribution". The release distribution is a
gzipped tar file containing an install script. This install script loads the
cray/cray-sat container image into the Docker registry in Nexus and loads the
`cray-sat-podman` RPM into a package repository in Nexus.

In this release, the `cray-sat-podman` package is still installed in the master
and worker NCN images provided by CSM. This is changed in SAT 2.1.16 released in
Shasta v1.5.

### SAT Running in a Container Under Podman

The `sat` command now runs in a container under Podman. The `sat` executable is
now installed on all nodes in the Kubernetes management cluster (i.e., workers
and masters). This executable is a wrapper script that starts a SAT container in
Podman and invokes the `sat` Python CLI within that container. The admin can run
individual `sat` commands directly on the master or worker NCNs as before, or
they can run `sat` commands inside the SAT container after using `sat bash` to
enter an interactive shell inside the SAT container.

To view man pages for `sat` commands, the user can run `sat-man SAT_COMMAND`,
replacing `SAT_COMMAND` with the name of the `sat` command. Alternatively,
the user can enter the `sat` container with `sat bash` and use the `man` command.

### New `sat init` Command and Config File Location Change

The default location of the SAT config file has been changed from `/etc/sat.toml`
to `~/.config/sat/sat.toml`. A new command, `sat init`, has been added that
initializes a configuration file in the new default directory. This better supports
individual users on the system who want their own config files.

`~/.config/sat` is mounted into the container that runs under Podman, so changes
are persistent across invocations of the `sat` container. If desired, an alternate
configuration directory can be specified with the `SAT_CONFIG_DIR` environment variable.

Additionally, if a config file does not yet exist when a user runs a `sat`
command, one is generated automatically.

### Additional Types Added to `sat hwinv`

Additional functionality has been added to `sat hwinv` including:

- List node enclosure power supplies with the `--list-node-enclosure-power-supplies` option.
- List node accelerators (e.g., GPUs) with the `--list-node-accels` option. The count of
   node accelerators is also included for each node.
- List node accelerator risers (e.g., Redstone modules) with the `--list-node-accel-risers`
   option. The count of node accelerator risers is also included for each node.
- List High-Speed Node Network Interface Cards (HSN NICs) with the `--list-node-hsn-nics`
   option. The count of HSN NICs is also included for each node.

Documentation for these new options has been added to the man page for `sat
hwinv`.

### Site Information Stored by `sat setrev` in S3

The `sat setrev` and `sat showrev` commands now use S3 to store and obtain site
information, including system name, site name, serial number, install date, and
system type. Since the information is stored in S3, it will now be consistent
regardless of the node on which `sat` is executed.

As a result of this change, S3 credentials must be configured for SAT. For detailed
instructions, see [Generate SAT S3 Credentials](install.md#generate-sat-s3-credentials).

### Product Version Information Shown by `sat showrev`

`sat showrev` now shows product information from the `cray-product-catalog`
ConfigMap in Kubernetes.

### Additional Changes to `sat showrev`

The output from `sat showrev` has also been changed in the following ways:

- The `--docker` and `--packages` options were considered misleading and have
  been removed.
- Information pertaining to only to the local host, where the command is run,
  has been moved to the output of the `--local ` option.

### Removal of `sat cablecheck`

The `sat cablecheck` command has been removed. To verify that the system's Slingshot
network is cabled correctly, admins should now use the `show cables` command in the
Slingshot Topology Tool (STT).

### `sat swap` Command Compatibility with Next-gen Fabric Controller

The `sat swap` command was added in Shasta v1.3.2. This command used the Fabric
Controller API. Shasta v1.4 introduced a new Fabric Manager API and removed the
Fabric Controller API, so this command has been rewritten to use the new
backwards-incompatible API. Usage of the command did not change.

### `sat bootsys` Functionality

Much of the functionality added to `sat bootsys` in Shasta v1.3.2 was broken
by changes introduced in Shasta v1.4, which removed the Ansible inventory
and playbooks.

The functionality in the `platform-services` stage of `sat bootsys` has been
re-implemented to use python directly instead of Ansible. This resulted in
a more robust procedure with better logging to the `sat` log file. Failures
to stop containers on Kubernetes nodes are handled more gracefully, and
more information about the containers that failed to stop, including how to
debug the problem, is included.

Improvements were made to console logging setup for non-compute nodes
(NCNs) when they are shut down and booted.

The following improvements were made to the `bos-operations` stage
of `sat bootsys`:

- More information about the BOS sessions, BOA jobs, and BOA pods is printed.
- A command-line option, `--bos-templates`, and a corresponding config-file
  option, `bos_templates`, were added, and the `--cle-bos-template` and
  `--uan-bos-template` options and their corresponding config file options were
  deprecated.

The following functionality has been removed from `sat bootsys`:

- The `hsn-bringup` stage of `sat bootsys boot` has been removed due to removal
  of the underlying Ansible playbook.
- The `bgp-check` stage of `sat bootys {boot,shutdown}` has been removed. It is
  now a manual procedure.

### Log File Location Change

The location of the sat log file has changed from `/var/log/cray/sat.log` to
`/var/log/cray/sat/sat.log`. This change simplifies mounting this file into the
sat container running under Podman.

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

## Summary of SAT Changes in Shasta v1.3

Shasta v1.3 included version 2.2.3 of the `sat` python package and CLI.

This version of the `sat` CLI contained the following commands:

- `auth`
- `bootsys`
- `cablecheck`
- `diag`
- `firmware`
- `hwinv`
- `hwmatch`
- `k8s`
- `linkhealth`
- `sensors`
- `setrev`
- `showrev`
- `status`
- `swap`
- `switch`

See the [System Admin Toolkit Command Overview](introduction.md#system-admin-toolkit-command-overview)
and the table of commands in the [SAT Authentication](install.md#sat-authentication) section
of this document for more details on each of these commands.
