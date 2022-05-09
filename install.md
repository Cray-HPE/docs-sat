# SAT Installation

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

5.  Check the return code of the installer. Zero indicates a successful installation.

    ```screen
    ncn-m001# echo $?
    0
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

1. **Optional:** Remove the SAT release distribution tar file and extracted directory.

    ```screen
    ncn-m001# rm sat-2.2.x.tar.gz
    ncn-m001# rm -rf sat-2.2.x/
    ```

2. **Upgrade only**: Ensure that the environment variable `SAT_TAG` is not set
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

3. Stop the typescript.

   **NOTE**: This step can be skipped if you wish to use the same typescript
   for the remainder of the SAT install. See [Next Steps](#next-steps).

    ```screen
    ncn-m001# exit
    ```

SAT version `2.1.x` is now installed/upgraded, meaning the SAT `2.1.x` release
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

- [Optional: Remove old versions after an upgrade](#optional-remove-old-versions-after-an-upgrade)
- [Remove obsolete configuration file sections](#remove-obsolete-configuration-file-sections)

## Perform NCN Personalization

Describes how to perform NCN personalization using CFS. This personalization process
will configure the System Admin Toolkit (SAT) product stream.

### Prerequisites

- The [Install the System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
    procedure has been successfully completed.

### Notes on the Procedure

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `2.1.x` with the version of the SAT product stream
    being installed.
- 'manager' and 'master' are used interchangeably in the steps below.
- If upgrading SAT, the existing configuration will likely include other Cray EX product
    entries. Update the SAT entry as described in this procedure. The *HPE Cray EX System
    Software Getting Started Guide* provides guidance on how and when to update the
    entries for the other products.

### Procedure

1. Start a typescript if not already using one.

    The typescript will capture the commands and the output from this installation procedure.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

2. Get the git commit ID for the branch with a version number matching the version of SAT.

    This represents a revision of Ansible configuration content stored in VCS.

    Get and store the VCS password (required to access the remote VCS repo).

    ```screen
    ncn-m001# VCS_PASS=$(kubectl get secret -n services vcs-user-credentials \
        --template={{.data.vcs_password}} | base64 --decode)
    ```

    In this example, the git commit ID is `82537e59c24dd5607d5f5d6f92cdff971bd9c615`,
    and the version number is `2.1.x`.

    ```screen
    ncn-m001# git ls-remote \
        https://crayvcs:$VCS_PASS@api-gw-service-nmn.local/vcs/cray/sat-config-management.git \
        refs/heads/cray/sat/*
    ...
    82537e59c24dd5607d5f5d6f92cdff971bd9c615 refs/heads/cray/sat/2.1.x
    ```

3. Add a `sat` layer to the CFS configuration(s) associated with the manager NCNs.
    1. Get the name(s) of the CFS configuration(s).

        **NOTE:** Each manager NCN uses a single CFS configuration. An individual CFS configuration
        may be used by any number of manage NCNs, i.e., three manager NCNs might use one,
        two, or three CFS configurations.

        In the following example, all three manager NCNs use the same CFS configuration – `ncn-personalization`.

        ```screen
        ncn-m001:~ # for component in $(cray hsm state components list \
            --role Management --subrole Master --format json | jq -r \
            '.Components | .[].ID'); do cray cfs components describe $component \
            --format json | jq -r '.desiredConfig'; done
        ncn-personalization
        ncn-personalization
        ncn-personalization
        ```

        In the following example, the three manager NCNs all use different configurations,
        each with a unique name.

        ```
        ncn-personalization-m001
        ncn-personalization-m002
        ncn-personalization-m003
        ```

        Execute the following sub-steps (3.2 through 3.5) once for each unique CFS
        configuration name.

        **NOTE:** Examples in the following sub-steps assume that all manager NCNs use the
        CFS configuration `ncn-personalization`.

    2. Get the current configuration layers for each CFS configuration, and save the
        data to a local JSON file.

        The JSON file created in this sub-step will serve as a template for updating
        an existing CFS configuration, or creating a new one.

        ```screen
        ncn-m001# cray cfs configurations describe ncn-personalization --format \
            json | jq '{ layers }' > ncn-personalization.json
        ```

        If the configuration does not exist yet, you may see the following error.
        In this case, create a new JSON file for that CFS configuration, e.g., `ncn-personalization.json`.

        ```screen
        Error: Configuration could not found.: Configuration ncn-personalization could not be found
        ```

        **NOTE:** For more on CFS configuration management, refer to "Manage a Configuration
        with CFS" in the CSM product documentation.

    3. Append a `sat` layer to the end of the JSON file's list of layers.

        If the file already contains a `sat` layer entry, update it.

        If the configuration data could not be found in the previous sub-step, the JSON file
        will be empty. In this case, copy the `ncn-personalization.json` example below,
        paste it into the JSON file, delete the ellipsis, and make appropriate changes to
        the `sat` layer entry.

        Use the git commit ID from step 8, e.g. `82537e59c24dd5607d5f5d6f92cdff971bd9c615`.

        **NOTE:** The `name` value in the example below may be changed, but the installation
        procedure uses the example value, `sat-ncn`. If an alternate value is used, some
        of the following examples must be updated accordingly before they are executed.

        ```screen
        ncn-m001# vim ncn-personalization.json
        ...
        ncn-m001# cat ncn-personalization.json
        {
            "layers": [
                ...
                {
                    "cloneUrl": "https://api-gw-service-nmn.local/vcs/cray/sat-config-management.git",
                    "commit": "82537e59c24dd5607d5f5d6f92cdff971bd9c615",
                    "name": "sat-ncn",
                    "playbook": "sat-ncn.yml"
                }
            ]
        }
        ```

    4. Update the existing CFS configuration, or create a new one.

        The command should output a JSON-formatted representation of the CFS configuration,
        which will look like the JSON file, but with `lastUpdated` and `name` fields.

        ```screen
        ncn-m001# cray cfs configurations update ncn-personalization --file \
            ncn-personalization.json --format json
        {
            "lastUpdated": "2021-08-05T16:38:53Z",
            "layers": {
                ...
            },
            "name": "ncn-personalization"
        }
        ```

    5. **Optional:** Delete the JSON file.

        **NOTE:** There is no reason to keep the file. If you keep it, verify that
        it is up-to-date with the actual CFS configuration before using it again.

        ```screen
        ncn-m001# rm ncn-personalization.json
        ```

4. Invoke the CFS configurations that you created or updated in the previous step.

    This step will create a CFS session based on the given configuration and install
    SAT on the associated manager NCNs.

    The `--configuration-limit` option causes only the `sat-ncn` layer of the configuration,
    `ncn-personalization`, to run.

    **CAUTION:** In this example, the session `--name` is `sat-session`. That value
    is only an example. Declare a unique name for each configuration session.

    You should see a representation of the CFS session in the output.

    ```screen
    ncn-m001# cray cfs sessions create --name sat-session --configuration-name \
        ncn-personalization --configuration-limit sat-ncn
    name="sat-session"

    [ansible]
    ...
    ```

    Execute this step once for each unique CFS configuration that you created or
    updated in the previous step.

5. Monitor the progress of each CFS session.

    First, list all containers associated with the CFS session:

    ```screen
    ncn-m001# kubectl get pod -n services --selector=cfsession=sat-session \
        -o json | jq '.items[0].spec.containers[] | .name'
    "inventory"
    "ansible-1"
    "istio-proxy"
    ```

    Next, get the logs for the `ansible-1` container.

    **NOTE:** the trailing digit might differ from "1". It is the zero-based
    index of the `sat-ncn` layer within the configuration's layers.

    ```screen
    ncn-m001# kubectl logs -c ansible-1 --tail 100 -f -n services \
        --selector=cfsession=sat-session
    ```

    Ansible plays, which are run by the CFS session, will install SAT on all the
    manager NCNs on the system. Successful results for all of the manager NCN xnames
    can be found at the end of the container log. For example:

    ```screen
    ...
    PLAY RECAP *********************************************************************
    x3000c0s1b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    x3000c0s3b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    x3000c0s5b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

    Execute this step for each unique CFS configuration.

    **NOTE:** Ensure that the PLAY RECAPs for each session show successes for all
    manager NCNs before proceeding.

6. Verify that SAT was successfully configured.

    If `sat` is configured, the `--version` command will indicate which version
    is installed. If `sat` is not properly configured, the command will fail.

    **NOTE:** This version number will differ from the version number of the SAT
    release distribution. This is the semantic version of the `sat` Python package,
    which is different from the version number of the overall SAT release distribution.

    ```screen
    ncn-m001# sat --version
    sat 3.7.0
    ```

    **NOTE**: Upon first running `sat`, you may see additional output while the `sat`
    container image is downloaded. This will occur the first time `sat` is run on
    each manager NCN. For example, if you run `sat` for the first time on `ncn-m001`
    and then for the first time on `ncn-m002`, you will see this additional output
    both times.

    ```screen
    Trying to pull registry.local/cray/cray-sat:3.7.0-20210514024359_9fed037...
    Getting image source signatures
    Copying blob da64e8df3afc done
    Copying blob 0f36fd81d583 done
    Copying blob 12527cf455ba done
    ...
    sat 3.7.0
    ```

7. Stop the typescript.

    ```screen
    ncn-m001# exit
    ```

SAT version `2.1.x` is now configured:

- The SAT RPM package is installed on the associated NCNs.

### Next Steps

If other HPE Cray EX software products are being installed or upgraded in conjunction
with SAT, refer to the [*HPE Cray EX System Software Getting Started Guide*](https://www.hpe.com/support/ex-gsg)
to determine which step to execute next.

If no other HPE Cray EX software products are being installed or upgraded at this time,
proceed to the remaining **SAT Setup** or **SAT Post-Upgrade** procedures.

If performing a fresh install, execute the **SAT Setup** procedures:

- [SAT Authentication](#sat-authentication)
- [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
- [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)

If performing an upgrade, execute the **SAT Post-Upgrade** procedures:

- [Optional: Remove old versions after an upgrade](#optional-remove-old-versions-after-an-upgrade)
- [Remove obsolete configuration file sections](#remove-obsolete-configuration-file-sections)

## SAT Authentication

Initially, as part of the installation and configuration, SAT authentication is set up so sat commands can be used in
later steps of the install process. The admin account used to authenticate with `sat auth` must be enabled in
Keycloak and must have its *assigned role* set to *admin*. For instructions on editing *Role Mappings* see
_Create Internal User Accounts in the Keycloak Shasta Realm_ in the CSM product documentation.
For additional information on SAT authentication, see _System Security and Authentication_ in the CSM
documentation.

**NOTE:** This procedure is only required after initially installing SAT. It is not
required after upgrading SAT.

### Description of SAT Command Authentication Types

Some SAT subcommands make requests to the Shasta services through the API gateway and thus require authentication to
the API gateway in order to function. Other SAT subcommands use the Kubernetes API. Some `sat` commands require S3 to
be configured (see: [Generate SAT S3 Credentials](#generate-sat-s3-credentials)). In order to use the SAT S3 bucket,
the System Administrator must generate the S3 access key and secret keys and write them to a local file. This must be
done on every Kubernetes manager node where SAT commands are run.

Below is a table describing SAT commands and the types of authentication they require.

|SAT Subcommand|Authentication/Credentials Required|Man Page|Description|
|--------------|-----------------------------------|--------|-----------|
|`sat auth`|Responsible for authenticating to the API gateway and storing a token.|`sat-auth`|Authenticate to the API gateway and save the token.|
|`sat bootsys`|Requires authentication to the API gateway. Requires kubernetes configuration and authentication, which is configured on `ncn-m001` during the install. Some stages require passwordless SSH to be configured to all other NCNs. Requires S3 to be configured for some stages.|`sat-bootsys`|Boot or shutdown the system, including compute nodes, application nodes, and non-compute nodes (NCNs) running the management software.|
|`sat diag`|Requires authentication to the API gateway.|`sat-diag`|Launch diagnostics on the HSN switches and generate a report.|
|`sat firmware`|Requires authentication to the API gateway.|`sat-firmware`|Report firmware version.|
|`sat hwinv`|Requires authentication to the API gateway.|`sat-hwinv`|Give a listing of the hardware of the HPE Cray EX system.|
|`sat hwmatch`|Requires authentication to the API gateway.|`sat-hwmatch`|Report hardware mismatches.|
|`sat init`|None|`sat-init`|Create a default SAT configuration file.|
|`sat k8s`|Requires kubernetes configuration and authentication, which is automatically configured on ncn-w001 during the install.|`sat-k8s`|Report on kubernetes replicasets that have co-located replicas \(i.e. replicas on the same node\).|
|`sat linkhealth`|||**This command has been deprecated.**|
|`sat nid2xname`|Requires authentication to the API gateway.|`sat-nid2xname`|Translate node IDs to node xnames.|
|`sat sensors`|Requires authentication to the API gateway.|`sat-sensors`|Report current sensor data.|
|`sat setrev`|Requires S3 to be configured for site information such as system name, serial number, install date, and site name.|`sat-setrev`|Set HPE Cray EX system revision information.|
|`sat showrev`|Requires API gateway authentication in order to query the Interconnect from HSM. Requires S3 to be configured for site information such as system name, serial number, install date, and site name.|`sat-showrev`|Print revision information for the HPE Cray EX system.|
|`sat status`|Requires authentication to the API gateway.|`sat-status`|Report node status across the HPE Cray EX system.|
|`sat swap`|Requires authentication to the API gateway.|`sat-swap`|Prepare HSN switch or cable for replacement and bring HSN switch or cable into service.|
|`sat xname2nid`|Requires authentication to the API gateway.|`sat-xname2nid`|Translate node and node BMC xnames to node IDs.|
|`sat switch`|**This command has been deprecated.** It has been replaced by `sat swap`.|

In order to authenticate to the API gateway, you must run the `sat auth` command. This command will prompt for a password
on the command line. The username value is obtained from the following locations, in order of higher precedence to lower
precedence:

- The `--username` global command-line option.
- The `username` option in the `api_gateway` section of the config file at `~/.config/sat/sat.toml`.
- The name of currently logged in user running the `sat` command.

If credentials are entered correctly when prompted by `sat auth`, a token file will be obtained and saved to
`~/.config/sat/tokens`. Subsequent sat commands will determine the username the same way as `sat auth` described above,
and will use the token for that username if it has been obtained and saved by `sat auth`.

### Prerequisites

- The `sat` CLI has been installed following [Install The System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream).

### Procedure

The following is the procedure to globally configure the username used by SAT and authenticate to the API gateway:

1. Generate a default SAT configuration file, if one does not exist.

    ```screen
    ncn-m001# sat init
    Configuration file "/root/.config/sat/sat.toml" generated.
    ```

    **Note:** If the config file already exists, it will print out an error:

    ```screen
    ERROR: Configuration file "/root/.config/sat/sat.toml" already exists.
    Not generating configuration file.
    ```

2. Edit `~/.config/sat/sat.toml` and set the username option in the `api_gateway` section of the config file. E.g.:

    ```screen
    username = "crayadmin"
    ```

3. Run `sat auth`. Enter your password when prompted. E.g.:

    ```screen
    ncn-m001# sat auth
    Password for crayadmin:
    Succeeded!
    ```

4. Other `sat` commands are now authenticated to make requests to the API gateway. E.g.:

    ```screen
    ncn-m001# sat status
    ```

## Generate SAT S3 Credentials

Generate S3 credentials and write them to a local file so the SAT user can access S3 storage. In order to use the SAT
S3 bucket, the System Administrator must generate the S3 access key and secret keys and write them to a local file.
This must be done on every Kubernetes master node where SAT commands are run.

SAT uses S3 storage for several purposes, most importantly to store the site-specific information set with `sat setrev`
(see: [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)).

**NOTE:** This procedure is only required after initially installing SAT. It is not
required after upgrading SAT.

### Prerequisites

- The `sat` CLI has been installed following [Install The System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream).
- The `sat` configuration file has been created (See [SAT Authentication](#sat-authentication)).
- CSM has been installed and verified.

### Procedure

1. Ensure the files are readable only by `root`.

    ```screen
    ncn-m001# touch /root/.config/sat/s3_access_key \
        /root/.config/sat/s3_secret_key
    ```

    ```screen
    ncn-m001# chmod 600 /root/.config/sat/s3_access_key \
        /root/.config/sat/s3_secret_key
    ```

2. Write the credentials to local files using `kubectl`.

    ```screen
    ncn-m001# kubectl get secret sat-s3-credentials -o json -o \
        jsonpath='{.data.access_key}' | base64 -d > \
        /root/.config/sat/s3_access_key
    ```

    ```screen
    ncn-m001# kubectl get secret sat-s3-credentials -o json -o \
        jsonpath='{.data.secret_key}' | base64 -d > \
        /root/.config/sat/s3_secret_key
    ```

3. Verify the S3 endpoint specified in the SAT configuration file is correct.

    1. Get the SAT configuration file's endpoint valie.

        **NOTE:** If the command's output is commented out, indicated by an initial #
        character, the SAT configuration will take the default value – `"https://rgw-vip.nmn"`.

        ```screen
        ncn-m001# grep endpoint ~/.config/sat/sat.toml
        # endpoint = "https://rgw-vip.nmn"
        ```

    2. Get the `sat-s3-credentials` secret's endpoint value.

        ```screen
        ncn-m001# kubectl get secret sat-s3-credentials -o json -o \
            jsonpath='{.data.s3_endpoint}' | base64 -d | xargs
        https://rgw-vip.nmn
        ```

    3. Compare the two endpoint values.

        If the values differ, modify the SAT configuration file's endpoint value to match the secret's.

4. Copy SAT configurations to every manager node on the system.

    ```screen
    ncn-m001# for i in ncn-m002 ncn-m003; do echo $i; ssh ${i} \
        mkdir -p /root/.config/sat; \
        scp -pr /root/.config/sat ${i}:/root/.config; done
    ```

    **NOTE**: Depending on how many manager nodes are on the system, the list of manager nodes may
    be different. This example assumes three manager nodes, where the configuration files must be
    copied from ncn-m001 to ncn-m002 and ncn-m003. Therefore, the list of hosts above is ncn-m002
    and ncn-m003.

## Run sat setrev to Set System Information

**NOTE:** This procedure is only required after initially installing SAT. It is not
required after upgrading SAT.

### Prerequisites

- S3 credentials have been generated. See [Generate SAT S3 Credentials](#generate-sat-s3-credentials).
- SAT authentication has been set up. See [SAT Authentication](#sat-authentication).

### Procedure

1. Run `sat setrev` to set System Revision Information. Follow the on-screen prompts.

    ```screen
    ncn-m001# sat setrev
    --------------------------------------------------------------------------------
    Setting:        Serial number
    Purpose:        System identification. This will affect how snapshots are
                    identified in the HPE backend services.
    Description:    This is the top-level serial number which uniquely identifies
                    the system. It can be requested from an HPE representative.
    Valid values:   Alpha-numeric string, 4 - 20 characters.
    Type:           <class 'str'>
    Default:        None
    Current value:  None
    --------------------------------------------------------------------------------
    Please do one of the following to set the value of the above setting:
        - Input a new value
        - Press CTRL-C to exit
    ...
    ```

2. Run `sat showrev` to verify System Revision Information. The following tables contain example information.

    ```screen
    ncn-m001# sat showrev
    ################################################################################
    System Revision Information
    ################################################################################
    +---------------------+---------------+
    | component           | data          |
    +---------------------+---------------+
    | Company name        | HPE           |
    | Country code        | US            |
    | Interconnect        | Sling         |
    | Product number      | R4K98A        |
    | Serial number       | 12345         |
    | Site name           | HPE           |
    | Slurm version       | slurm 20.02.5 |
    | System description  | Test System   |
    | System install date | 2021-01-29    |
    | System name         | eniac         |
    | System type         | Shasta        |
    +---------------------+---------------+
    ################################################################################
    Product Revision Information
    ################################################################################
    +--------------+-----------------+------------------------------+------------------------------+
    | product_name | product_version | images                       | image_recipes                |
    +--------------+-----------------+------------------------------+------------------------------+
    | csm          | 0.8.14          | cray-shasta-csm-sles15sp1... | cray-shasta-csm-sles15sp1... |
    | sat          | 2.0.1           | -                            | -                            |
    | sdu          | 1.0.8           | -                            | -                            |
    | slingshot    | 0.8.0           | -                            | -                            |
    | sma          | 1.4.12          | -                            | -                            |
    +--------------+-----------------+------------------------------+------------------------------+
    ################################################################################
    Local Host Operating System
    ################################################################################
    +-----------+----------------------+
    | component | version              |
    +-----------+----------------------+
    | Kernel    | 5.3.18-24.15-default |
    | SLES      | SLES 15-SP2          |
    +-----------+----------------------+
    ```

## Optional: Remove old versions after an upgrade

### Prerequisites

- The [Install the System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
    procedure has been successfully completed.
- The [Perform NCN Personalization](#perform-ncn-personalization) procedure has been successfully completed.

### Procedure

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

## Remove obsolete configuration file sections

### Prerequisites

- The [Install the System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
    procedure has been successfully completed.
- The [Perform NCN Personalization](#perform-ncn-personalization) procedure has been successfully completed.

### Procedure

After upgrading SAT, if using the configuration file from a previous version, there may be
configuration file sections no longer used in the new version. For example, when upgrading
from Shasta 1.4 to Shasta 1.5, the `[redfish]` configuration file section is no longer used.
In that case, the following warning may appear upon running `sat` commands.

```screen
WARNING: Ignoring unknown section 'redfish' in config file.
```

Remove the `[redfish]` section from `/root/.config/sat/sat.toml` to resolve the warning.

```screen
[redfish]
username = "admin"
password = "adminpass"
```

Repeat this process for any configuration file sections for which there are "unknown section" warnings.
