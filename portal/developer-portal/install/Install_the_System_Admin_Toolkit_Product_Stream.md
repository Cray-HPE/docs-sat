[//]: # ((C) Copyright 2021 Hewlett Packard Enterprise Development LP)

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

## Install the System Admin Toolkit Product Stream

Describes how to install the System Admin Toolkit (SAT) product stream.

### Prerequisites

- CSM is installed and verified.
- cray-product-catalog is running.
- There must be at least 2 gigabytes of free space on the manager NCN on which the
  procedure is run.

### Notes on the Procedures

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `2.2.x` with the version of the SAT product stream
  being installed.
- 'manager' and 'master' are used interchangeably in the steps below.
- To upgrade SAT, execute the pre-installation, installation, and post-installation
  procedures for a newer distribution. The newly installed version will become
  the default.

### Pre-Installation Procedure

1. Start a typescript.

    The typescript will record the commands and the output from this installation.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

### Installation Procedure

1. Copy the release distribution gzipped tar file to `ncn-m001`.

1. Unzip and extract the release distribution, `2.2.x`.

    ```screen
    ncn-m001# tar -xvzf sat-2.2.x.tar.gz
    ```

1. Change directory to the extracted release distribution directory.

    ```screen
    ncn-m001# cd sat-2.2.x
    ```

1. Run the installer: **install.sh**.

    The script produces a lot of output. A successful install ends with "SAT
    version 2.2.x has been installed".

    ```screen
    ncn-m001# ./install.sh
    ...
    ====> Updating active CFS configurations
    INFO: Retrieving available Ansible configurations from VCS
    INFO: Found matching Ansible configuration at remote ref "refs/heads/cray/sat/2.2.x" in VCS
    INFO: Querying CFS configurations for the following NCNs: <ncn-m001>, <ncn-m002>, <ncn-m003>
    INFO: Found the following configurations for NCNs: ncn-personalization
    INFO: Updating CFS configuration "ncn-personalization"
    INFO: Found existing layer with name "sat-ncn" in configuration "ncn-personalization"; updating.
    INFO: Successfully updated layer "sat-ncn" in configuration "ncn-personalization"
    ====> SAT version 2.2.x has been installed.
    ```

1. Note the name of each CFS configuration created or updated by the installer in the
   previous step. In this example, it is "ncn-personalization".

   ```screen
   ncn-m001# echo ncn-personalization >> /tmp/sat-ncn-cfs-configurations.txt
   ```

   Repeat the command above for each CFS configuration.

### Post-Installation Procedure

1. **Optional:** Remove the SAT release distribution tar file and extracted directory.

    ```screen
    ncn-m001# rm sat-2.2.x.tar.gz
    ncn-m001# rm -rf sat-2.2.x/
    ```

1. **Upgrade only**: Ensure that the environment variable `SAT_TAG` is not set
    in the `~/.bashrc` file on any of the management NCNs.

    **NOTE**: This step should only be required when updating from
    Shasta 1.4.1 or Shasta 1.4.2.

    The following example assumes three manager NCNs: `ncn-m001`, `ncn-m002`, and `ncn-m003`,
    and shows output from a system in which no further action is needed.

    ```screen
    ncn-m001# pdsh -w ncn-m00[1-3] cat ~/.bashrc
    ncn-m001: source <(kubectl completion bash)
    ncn-m003: source <(kubectl completion bash)
    ncn-m002: source <(kubectl completion bash)
    ```

    The following example shows that `SAT_TAG` is set in `~/.bashrc` on `ncn-m002`.
    Remove that line from the `~/.bashrc` file on `ncn-m002`.

    ```screen
    ncn-m001# pdsh -w ncn-m00[1-3] cat ~/.bashrc
    ncn-m001: source <(kubectl completion bash)
    ncn-m002: source <(kubectl completion bash)
    ncn-m002: export SAT_TAG=3.5.0
    ncn-m003: source <(kubectl completion bash)
    ```

1. Stop the typescript.

   **NOTE**: This step can be skipped if you wish to use the same typescript
   for the remainder of the SAT install. See [Next Steps](#next-steps).

    ```screen
    ncn-m001# exit
    ```

SAT version `2.2.x` is now installed/upgraded, meaning the SAT `2.2.x` release
has been loaded into the system software repository.

- SAT configuration content for this release has been uploaded to VCS.
- SAT content for this release has been uploaded to the CSM product catalog.
- SAT content for this release has been uploaded to Nexus repositories.
- The `sat` command won't be available until the [NCN Personalization](#perform-ncn-personalization)
  procedure has been executed.

### Next Steps

If other HPE Cray EX software products are being installed or upgraded in conjunction
with SAT, refer to the [*HPE Cray EX System Software Getting Started Guide*](https://www.hpe.com/support/ex-gsg)
to determine which step to execute next.

If no other HPE Cray EX software products are being installed or upgraded at this time,
proceed to the sections listed below.

**NOTE:** The **NCN Personalization** procedure **is required when
upgrading SAT**. The setup procedures in **SAT Setup**, however, are
**not required when upgrading SAT**. They should have been executed
during the first installation of SAT.

Execute the **NCN Personalization** procedure:

- [Perform NCN Personalization](#perform-ncn-personalization)

If performing a fresh install, execute the **SAT Setup** procedures:

- [SAT Authentication](#sat-authentication)
- [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
- [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)

If performing an upgrade, execute the **upgrade** procedures:

- [SAT Post-Upgrade](#sat-post-upgrade)
