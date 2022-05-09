# SAT Release Notes

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
