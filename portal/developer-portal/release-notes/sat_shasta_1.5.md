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
File Sections](#remove-obsolete-configuration-file-sections).

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