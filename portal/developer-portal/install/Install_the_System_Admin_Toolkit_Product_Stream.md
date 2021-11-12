## Install the System Admin Toolkit Product Stream

Describes how to install the System Admin Toolkit (SAT) product stream.

### Prerequisites

- CSM is installed and verified.
- cray-product-catalog is running.
- There must be at least 2 gigabytes of free space on the manager NCN on which the
    procedure is run.

### Notes on the Procedures

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `2.1.x` with the version of the SAT product stream
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

2. Unzip and extract the release distribution, `2.1.x`.

    ```screen
    ncn-m001# tar -xvzf sat-2.1.x.tar.gz
    ```

3. Change directory to the extracted release distribution directory.

    ```screen
    ncn-m001# cd sat-2.1.x
    ```

4. Run the installer: **install.sh**.

    The script produces a lot of output. The last several lines are included
    below for reference.

    ```screen
    ncn-m001# ./install.sh
    ...
    ConfigMap data updates exist; Exiting.
    + clean-install-deps
    + for image in "${vendor_images[@]}"
    + podman rmi -f docker.io/library/cray-nexus-setup:sat-2.1.x-20210804163905-8dbb87d
    Untagged: docker.io/library/cray-nexus-setup:sat-2.1.x-20210804163905-8dbb87d
    Deleted: 2c196c0c6364d9a1699d83dc98550880dc491cc3433a015d35f6cab1987dd6da
    + for image in "${vendor_images[@]}"
    + podman rmi -f docker.io/library/skopeo:sat-2.1.x-20210804163905-8dbb87d
    Untagged: docker.io/library/skopeo:sat-2.1.x-20210804163905-8dbb87d
    Deleted: 1b38b7600f146503e246e753cd9df801e18409a176b3dbb07b0564e6bc27144c
    ```

    Check the return code of the installer. Zero indicates a successful installation.

    ```screen
    ncn-m001# echo $?
    0
    ```

5. Ensure that the environment variable `SAT_TAG` is not set in the `~/.bashrc` file
    on any of the management NCNs.

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

6. Check the progress of the SAT configuration import Kubernetes job, which is
    initiated by `install.sh`.

    If the "Pods Statuses" appear as "Succeeded", the job has completed
    successfully. The job usually takes between 30 seconds and 2 minutes.

    ```screen
    ncn-m001# kubectl describe job sat-config-import-2.1.x -n services
    ...
    Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
    ...
    ```

    The job's progress may be monitored using `kubectl logs`. The example below includes
    the final log lines from a successful configuration import Kubernetes job.

    ```screen
    ncn-m001# kubectl logs -f -n services --selector \
        job-name=sat-config-import-2.1.x --all-containers
    ...
    ConfigMap update attempt=1
    Resting 1s before reading ConfigMap
    ConfigMap data updates exist; Exiting.
    2021-08-04T21:50:10.275886Z  info    Agent has successfully terminated
    2021-08-04T21:50:10.276118Z  warning envoy main  caught SIGTERM
    # Completed on Wed Aug  4 21:49:44 2021
    ```

    The following error may appear in this log, but it can be ignored.

    ```screen
    error accept tcp [::]:15020: use of closed network connection
    ```

### Post-Installation Procedure

1. Stop the typescript.

    ```screen
    ncn-m001# exit
    ```

2. **Optional:** Remove the SAT release distribution tar file and extracted directory.

    ```screen
    ncn-m001# rm sat-2.1.x.tar.gz
    ncn-m001# rm -rf sat-2.1.x/
    ```

3. **Optional:** Remove old versions after an upgrade.

    After upgrading from a previous version of SAT, the old version of the `cray/cray-sat`
    container image will remain in the registry on the system. It is **not** removed
    automatically, but it will **not** be the default version.

    The admin can remove the older version of the `cray/cray-sat` container image.

    The `cray-product-catalog` Kubernetes configuration map will also show all versions
    of SAT that are installed. The command `sat showrev --products` will display these
    versions. See the example:

    ```screen
    ncn-m001# sat showrev --products
    ###############################################################################
    Product Revision Information
    ###############################################################################
    +--------------+-----------------+--------------------+-----------------------+
    | product_name | product_version | images             | image_recipes         |
    +--------------+-----------------+--------------------+-----------------------+
    ...
    | sat          | 2.1.3           | -                  | -                     |
    | sat          | 2.0.4           | -                  | -                     |
    ...
    +--------------+-----------------+--------------------+-----------------------+
    ```

SAT version `2.1.x` is now installed/upgraded:

- SAT configuration content for this release has been uploaded to VCS.
- SAT content for this release has been uploaded to the CSM product catalog.
- SAT content for this release has been uploaded to Nexus repositories.

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

Execute the **SAT Setup** procedures:

- [SAT Authentication](#sat-authentication)
- [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
- [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)
