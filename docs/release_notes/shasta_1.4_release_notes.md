# SAT Changes in Shasta v1.4

In Shasta v1.4, SAT became an independent product, which meant we began to
designate a version number for the entire SAT product. We released version
2.0.3 of the SAT product in Shasta v1.4.

This version of the SAT product included the following components:

- Version 3.4.0 of the `sat` python package and CLI

It also added the following new component:

- Version 1.4.2 of the `sat-podman` wrapper script

The following sections detail the changes in this release.

## SAT as an Independent Product

SAT is now packaged and released as an independent product. The product
deliverable is called a "release distribution". The release distribution is a
gzipped tar file containing an install script. This install script loads the
`cray/cray-sat` container image into the Docker registry in Nexus and loads the
`cray-sat-podman` RPM into a package repository in Nexus.

In this release, the `cray-sat-podman` package is still installed in the master
and worker NCN images provided by CSM. This is changed in SAT 2.1.16 released in
Shasta v1.5.

## SAT Running in a Container Under Podman

The `sat` command now runs in a container under Podman. The `sat` executable is
now installed on all nodes in the Kubernetes management cluster (workers and
masters). This executable is a wrapper script that starts a SAT container in
Podman and invokes the `sat` Python CLI within that container. The admin can run
individual `sat` commands directly on the master or worker NCNs as before, or
they can run `sat` commands inside the SAT container after using `sat bash` to
enter an interactive shell inside the SAT container.

To view man pages for `sat` commands, the user can run `sat-man SAT_COMMAND`,
replacing `SAT_COMMAND` with the name of the `sat` command. Alternatively,
the user can enter the `sat` container with `sat bash` and use the `man` command.

## New `sat init` Command and Configuration File Location Change

The default location of the SAT configuration file has been changed from `/etc/sat.toml`
to `~/.config/sat/sat.toml`. A new command, `sat init`, has been added that
initializes a configuration file in the new default directory. This better supports
individual users on the system who want their own configuration files.

`~/.config/sat` is mounted into the container that runs under Podman, so changes
are persistent across invocations of the `sat` container. If desired, an alternate
configuration directory can be specified with the `SAT_CONFIG_DIR` environment
variable.

Additionally, if a configuration file does not yet exist when a user runs a `sat`
command, one is generated automatically.

## Additional Types Added to `sat hwinv`

Additional functionality has been added to `sat hwinv` including:

- List node enclosure power supplies with the `--list-node-enclosure-power-supplies`
  option.
- List node accelerators (for example, GPUs) with the `--list-node-accels` option.
  The count of node accelerators is also included for each node.
- List node accelerator risers (for example, Redstone modules) with the
  `--list-node-accel-risers` option. The count of node accelerator risers is also
  included for each node.
- List High-Speed Node Network Interface Cards (HSN NICs) with the
  `--list-node-hsn-nics` option. The count of HSN NICs is also included for each node.

Documentation for these new options has been added to the man page for `sat
hwinv`.

## Site Information Stored by `sat setrev` in S3

The `sat setrev` and `sat showrev` commands now use S3 to store and obtain site
information, including system name, site name, serial number, install date, and
system type. Since the information is stored in S3, it will now be consistent
regardless of the node on which `sat` is executed.

As a result of this change, S3 credentials must be configured for SAT. For more
information, see [Generate SAT S3 Credentials](../install.md#generate-sat-s3-credentials).

## Product Version Information Shown by `sat showrev`

`sat showrev` now shows product information from the `cray-product-catalog`
ConfigMap in Kubernetes.

## Additional Changes to `sat showrev`

The output from `sat showrev` has also been changed in the following ways:

- The `--docker` and `--packages` options were considered misleading and have
  been removed.
- Information pertaining to only to the local host, where the command is run,
  has been moved to the output of the `--local` option.

## Removal of `sat cablecheck`

The `sat cablecheck` command has been removed. To verify that the system's Slingshot
network is cabled correctly, admins should now use the `show cables` command in the
Slingshot Topology Tool (STT).

## `sat swap` Command Compatibility with Next-gen Fabric Controller

The `sat swap` command was added in Shasta v1.3.2. This command used the Fabric
Controller API. Shasta v1.4 introduced a new Fabric Manager API and removed the
Fabric Controller API, so this command has been rewritten to use the new
backwards-incompatible API. Usage of the command did not change.

## `sat bootsys` Functionality

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
- A command-line option, `--bos-templates`, and a corresponding configuration
  file option, `bos_templates`, were added, and the `--cle-bos-template` and
  `--uan-bos-template` options and their corresponding configuration file
  options were deprecated.

The following functionality has been removed from `sat bootsys`:

- The `hsn-bringup` stage of `sat bootsys boot` has been removed due to removal
  of the underlying Ansible playbook.
- The `bgp-check` stage of `sat bootys {boot,shutdown}` has been removed. It is
  now a manual procedure.

## Log File Location Change

The location of the sat log file has changed from `/var/log/cray/sat.log` to
`/var/log/cray/sat/sat.log`. This change simplifies mounting this file into the
sat container running under Podman.
