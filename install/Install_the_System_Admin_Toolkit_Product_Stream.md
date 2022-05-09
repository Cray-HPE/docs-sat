# Install the System Admin Toolkit Product Stream

Describes how to install the System Admin Toolkit (SAT) product stream.

## Prerequisites

- CSM is installed and verified.
- cray-product-catalog is running.
- There must be at least 2 gigabytes of free space on the manager NCN on which the
  procedure is run.

## Notes on the Procedures

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `2.2.x` with the version of the SAT product stream
  being installed.
- 'manager' and 'master' are used interchangeably in the steps below.
- To upgrade SAT, execute the pre-installation, installation, and post-installation
  procedures for a newer distribution. The newly installed version will become
  the default.

## Pre-Installation Procedure

1.  Start a typescript.

    The typescript will record the commands and the output from this installation.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

## Installation Procedure

1.  Copy the release distribution gzipped tar file to `ncn-m001`.

1.  Unzip and extract the release distribution, `2.2.x`.

    ```screen
    ncn-m001# tar -xvzf sat-2.2.x.tar.gz
    ```

1.  Change directory to the extracted release distribution directory.

    ```screen
    ncn-m001# cd sat-2.2.x
    ```

1.  Run the installer: **install.sh**.

    The script produces a lot of output. A successful install ends with "SAT
    version 2.2.x has been installed".

    ```screen
    ncn-m001# ./install.sh
    ...
    ====> Updating active CFS configurations
    ...
    ====> SAT version 2.2.x has been installed.
    ```

1.  **Upgrade only**: Record the names of the CFS configuration or
    configurations modified by `install.sh`.

    The `install.sh` script attempts to modify any CFS configurations that apply
    to the master management NCNs. During an upgrade, `install.sh` will log
    messages indicating the CFS configuration or configurations that were
    modified. For example, if there are three master nodes all using the same
    CFS configuration named "ncn-personalization", the output would look like
    this:

    ```screen
    ====> Updating active CFS configurations
    INFO: Querying CFS configurations for the following NCNs: x3000c0s1b0n0, x3000c0s3b0n0, x3000c0s5b0n0
    INFO: Found configuration "ncn-personalization" for component x3000c0s1b0n0
    INFO: Found configuration "ncn-personalization" for component x3000c0s3b0n0
    INFO: Found configuration "ncn-personalization" for component x3000c0s5b0n0
    INFO: Updating CFS configuration "ncn-personalization"
    INFO: Updating existing layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml in configuration "ncn-personalization".
    INFO: Key "name" in layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml updated from sat-ncn to sat-2.2.16
    INFO: Successfully updated layers in configuration "ncn-personalization"
    ```

    Save the name of each CFS configuration updated by the installer. In the
    previous example, a single configuration named "ncn-personalization" was
    updated, so that name is saved to a temporary file.

    ```screen
    ncn-m001# echo ncn-personalization >> /tmp/sat-ncn-cfs-configurations.txt
    ```

    Repeat the previous command for each CFS configuration that was updated.

1.  **Upgrade only**: Save the new name of the SAT CFS configuration layer.

    In the example `install.sh` output above, the new layer name is
    `sat-2.2.16`. Save this value to a file to be used later.

    ```screen
    ncn-m001# echo sat-2.2.16 > /tmp/sat-layer-name.txt
    ```


1.  **Fresh install only**: Save the CFS configuration layer for SAT to a file
    for later use.

    The `install.sh` script attempts to modify any CFS configurations that apply
    to the master management NCNs. During a fresh install, no such CFS
    configurations will be found, and it will instead log the SAT configuration
    layer that must be added to the CFS configuration that will be created. Here
    is an example of the output in that case:

    ```screen
    ====> Updating active CFS configurations
    INFO: Querying CFS configurations for the following NCNs: x3000c0s1b0n0, x3000c0s3b0n0, x3000c0s5b0n0
    WARNING: No CFS configurations found that apply to components with role Management and subrole Master.
    INFO: The following sat layer should be used in the CFS configuration that will be applied to NCNs with role Management and subrole Master.
    {
        "name": "sat-2.2.15",
        "commit": "9a74b8f5ba499af6fbcecfd2518a40e081312933",
        "cloneUrl": "https://api-gw-service-nmn.local/vcs/cray/sat-config-management.git",
        "playbook": "sat-ncn.yml"
    }
    ```

    Save the JSON output to a file for later use. For example:

    ```screen
    ncn-m001# cat > /tmp/sat-layer.json <<EOF
    > {
    >     "name": "sat-2.2.15",
    >     "commit": "9a74b8f5ba499af6fbcecfd2518a40e081312933",
    >     "cloneUrl": "https://api-gw-service-nmn.local/vcs/cray/sat-config-management.git",
    >     "playbook": "sat-ncn.yml"
    > }
    > EOF
    ```

    Do not copy the previous command verbatim. Use the JSON output from the
    `install.sh` script.

## Post-Installation Procedure

1.  **Optional:** Remove the SAT release distribution tar file and extracted directory.

    ```screen
    ncn-m001# rm sat-2.2.x.tar.gz
    ncn-m001# rm -rf sat-2.2.x/
    ```

1.  **Upgrade only**: Ensure that the environment variable `SAT_TAG` is not set
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

1.  Stop the typescript.

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

## Next Steps

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
