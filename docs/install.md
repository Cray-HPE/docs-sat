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
- In the examples below, replace `2.2.x` with the version of the SAT product stream
  being installed.
- 'manager' and 'master' are used interchangeably in the steps below.
- To upgrade SAT, execute the pre-installation, installation, and post-installation
  procedures for a newer distribution. The newly installed version will become
  the default.

### Pre-Installation Procedure

1.  Start a typescript.

    The typescript will record the commands and the output from this installation.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

### Installation Procedure

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

### Post-Installation Procedure

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

- [Remove obsolete configuration file sections](#remove-obsolete-configuration-file-sections)
- [SAT Logging](#sat-logging)

## Perform NCN Personalization

Describes how to perform NCN personalization using CFS. This personalization process
will configure the System Admin Toolkit (SAT) product stream.

### Prerequisites

- The [Install the System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
  procedure has been successfully completed.
- If upgrading, the names of the CFS configurations updated during installation
  were saved to the file `/tmp/sat-ncn-cfs-configurations.txt`.
- If upgrading, the name of the new SAT CFS configuration layer was saved to
  the file `/tmp/sat-layer-name.txt`.
- If performing a fresh install, the SAT CFS configuration layer was saved to
  the file `/tmp/sat-layer.json`.

### Notes on the Procedure

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `2.2.x` with the version of the SAT product stream
  being installed.
- 'manager' and 'master' are used interchangeably in the steps below.
- If upgrading SAT, the existing configuration will likely include other Cray EX product
  entries. Update the SAT entry as described in this procedure. The *HPE Cray EX System
  Software Getting Started Guide* provides guidance on how and when to update the
  entries for the other products.

### Procedure

1.  Start a typescript if not already using one.

    The typescript will capture the commands and the output from this installation procedure.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

1.  **Fresh install only**: Add the SAT layer to the NCN personalization JSON file.

    If the SAT install script, `install.sh`, did not identify and modify the CFS
    configurations that apply to each master management NCN, it will have printed
    the SAT CFS configuration layer in JSON format. This layer must be added to
    the JSON file being used to construct the CFS configuration. For example,
    if the file being used is named `ncn-personalization.json`, and the SAT
    layer was saved to the file `/tmp/sat-layer.json` as described in the
    install instructions, the following `jq` command will append the SAT layer
    and save the result in a new file named `ncn-personalization.json`.

    ```screen
    ncn-m001# jq -s '{layers: (.[0].layers + [.[1]])}' ncn-personalization.json \
        /tmp/sat-layer.json > ncn-personalization.new.json
    ```

    For instructions on how to create a CFS configuration from the previous
    file and how to apply it to the management NCNs, refer to "Perform NCN
    Personalization" in the *HPE Cray System Management Documentation*. After
    the CFS configuration has been created and applied, return to this
    procedure.

1.  **Upgrade only**: Invoke each CFS configuration that was updated during the
    upgrade.

    If the SAT install script, `install.sh`, identified CFS configurations that
    apply to the master management NCNs and modified them in place, invoke each
    CFS configuration that was created or updated during installation.

    This step will create a CFS session for each given configuration and install
    SAT on the associated manager NCNs.

    The `--configuration-limit` option limits the configuration session to run
    only the SAT layer of the configuration.

    You should see a representation of the CFS session in the output.

    ```screen
    ncn-m001# for cfs_configuration in $(cat /tmp/sat-ncn-cfs-configurations.txt);
    do cray cfs sessions create --name "sat-session-${cfs_configuration}" --configuration-name \
        "${cfs_configuration}" --configuration-limit $(cat /tmp/sat-layer-name.txt);
    done

    name="sat-session-ncn-personalization"

    [ansible]
    ...
    ```

1.  **Upgrade only**: Monitor the progress of each CFS session.

    This step assumes a single session named `sat-session-ncn-personalization` was created in the previous step.

    First, list all containers associated with the CFS session:

    ```screen
    ncn-m001# kubectl get pod -n services --selector=cfsession=sat-session-ncn-personalization \
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
        --selector=cfsession=sat-session-ncn-personalization
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

1.  Verify that SAT was successfully configured.

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

1.  Stop the typescript.

    ```screen
    ncn-m001# exit
    ```

SAT version `2.2.x` is now configured:

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

- [Remove obsolete configuration file sections](#remove-obsolete-configuration-file-sections)
- [SAT Logging](#sat-logging)

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
|`sat bmccreds`|Requires authentication to the API gateway.|`sat-bmccreds`|Set BMC passwords.|
|`sat bootprep`|Requires authentication to the API gateway. Requires kubernetes configuration and authentication, which is done on ncn-m001 during the install.|`sat-bootprep`|Prepare to boot nodes with images and configurations.|
|`sat bootsys`|Requires authentication to the API gateway. Requires kubernetes configuration and authentication, which is configured on `ncn-m001` during the install. Some stages require passwordless SSH to be configured to all other NCNs. Requires S3 to be configured for some stages.|`sat-bootsys`|Boot or shutdown the system, including compute nodes, application nodes, and non-compute nodes (NCNs) running the management software.|
|`sat diag`|Requires authentication to the API gateway.|`sat-diag`|Launch diagnostics on the HSN switches and generate a report.|
|`sat firmware`|Requires authentication to the API gateway.|`sat-firmware`|Report firmware version.|
|`sat hwhist`|Requires authentication to the API gateway.|`sat-hwhist`|Report hardware component history.|
|`sat hwinv`|Requires authentication to the API gateway.|`sat-hwinv`|Give a listing of the hardware of the HPE Cray EX system.|
|`sat hwmatch`|Requires authentication to the API gateway.|`sat-hwmatch`|Report hardware mismatches.|
|`sat init`|None|`sat-init`|Create a default SAT configuration file.|
|`sat k8s`|Requires kubernetes configuration and authentication, which is automatically configured on ncn-w001 during the install.|`sat-k8s`|Report on kubernetes replicasets that have co-located replicas \(i.e. replicas on the same node\).|
|`sat linkhealth`|||**This command has been deprecated.**|
|`sat nid2xname`|Requires authentication to the API gateway.|`sat-nid2xname`|Translate node IDs to node xnames.|
|`sat sensors`|Requires authentication to the API gateway.|`sat-sensors`|Report current sensor data.|
|`sat setrev`|Requires S3 to be configured for site information such as system name, serial number, install date, and site name.|`sat-setrev`|Set HPE Cray EX system revision information.|
|`sat showrev`|Requires API gateway authentication in order to query the Interconnect from HSM. Requires S3 to be configured for site information such as system name, serial number, install date, and site name.|`sat-showrev`|Print revision information for the HPE Cray EX system.|
|`sat slscheck`|Requires authentication to the API gateway.|`sat-slscheck`|Perform a cross-check between SLS and HSM.|
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

1. Edit `~/.config/sat/sat.toml` and set the username option in the `api_gateway` section of the config file. E.g.:

    ```screen
    username = "crayadmin"
    ```

1. Run `sat auth`. Enter your password when prompted. E.g.:

    ```screen
    ncn-m001# sat auth
    Password for crayadmin:
    Succeeded!
    ```

1. Other `sat` commands are now authenticated to make requests to the API gateway. E.g.:

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

- The SAT CLI has been installed following [Install The System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
- The SAT configuration file has been created (See [SAT Authentication](#sat-authentication)).
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

1. Write the credentials to local files using `kubectl`.

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

1. Verify the S3 endpoint specified in the SAT configuration file is correct.

    1. Get the SAT configuration file's endpoint value.

        **NOTE:** If the command's output is commented out, indicated by an initial #
        character, the SAT configuration will take the default value – `"https://rgw-vip.nmn"`.

        ```screen
        ncn-m001# grep endpoint ~/.config/sat/sat.toml
        # endpoint = "https://rgw-vip.nmn"
        ```

    1. Get the `sat-s3-credentials` secret's endpoint value.

        ```screen
        ncn-m001# kubectl get secret sat-s3-credentials -o json -o \
            jsonpath='{.data.s3_endpoint}' | base64 -d | xargs
        https://rgw-vip.nmn
        ```

    1. Compare the two endpoint values.

        If the values differ, change the SAT configuration file's endpoint value to match the secret's.

1. Copy SAT configurations to each manager node on the system.

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

1. Run `sat setrev` to set System Revision Information. Follow the on-screen prompts to set
   the following site-specific values:

   - Serial number
   - System name
   - System type
   - System description
   - Product number
   - Company name
   - Site name
   - Country code
   - System install date

    **TIP**: For "System type", a system with _any_ liquid-cooled components should be
    considered a liquid-cooled system. I.e., "System type" is EX-1C.

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

1. Run `sat showrev` to verify System Revision Information. The following tables contain example information.

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
    | System type         | EX-1C         |
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

## SAT Logging

As of SAT version 2.2, some command output that was previously printed to `stdout`
is now logged to `stderr`. These messages are logged at the `INFO` level. The
default logging threshold was changed from `WARNING` to `INFO` to accomodate
this logging change. Additionally, some messages previously logged at the `INFO`
are now logged at the `DEBUG` level.

These changes take effect automatically. However, if the default output threshold
has been manually set in `~/.config/sat/sat.toml`, it should be changed to ensure
that important output is shown in the terminal.

### Update Configuration

In the following example, the stderr log level, `logging.stderr_level`, is set to
`WARNING`, which will exclude `INFO`-level logging from terminal output.

```screen
ncn-m001:~ # grep -A 3 logging ~/.config/sat/sat.toml
[logging]
...
stderr_level = "WARNING"
```

To enable the new default behavior, comment this line out, delete it, or set
the value to "INFO".

If `logging.stderr_level` is commented out, its value will not affect logging
behavior. However, it may be helpful set its value to `INFO` as a reminder of
the new default behavior.

### Affected Commands

The following commands trigger messages that have been changed from `stdout`
print calls to `INFO`-level (or `WARNING`- or `ERROR`-level) log messages:

```
sat bootsys --stage shutdown --stage session-checks
sat sensors
```

The following commands trigger messages that have been changed from `INFO`-level
log messages to `DEBUG`-level log messages:

```
sat nid2xname
sat xname2nid
sat swap
```

## Uninstall: Removing a Version of SAT

### Prerequisites

- Only versions 2.2 or newer of SAT can be uninstalled with `prodmgr`.
- CSM version 1.2 or newer must be installed, so that the `prodmgr` command is available.

### Procedure

1. Use `sat showrev` to list versions of SAT.

    **NOTE**: It is not recommended to uninstall a version designated as "active".
    If the active version is uninstalled, then the activate procedure must be executed
    on a remaining version.

    ```screen
    ncn-m001# sat showrev --products --filter product_name=sat
    ###############################################################################
    Product Revision Information
    ###############################################################################
    +--------------+-----------------+--------+-------------------+-----------------------+
    | product_name | product_version | active | images            | image_recipes         |
    +--------------+-----------------+--------+-------------------+-----------------------+
    | sat          | 2.3.3           | True   | -                 | -                     |
    | sat          | 2.2.10          | False  | -                 | -                     |
    +--------------+-----------------+--------+-------------------+-----------------------+
    ```

1. Use `prodmgr` to uninstall a version of SAT.

    This command will do three things:

    - Remove all hosted-type package repositories associated with the given version of SAT. Group-type
      repositories are not removed.
    - Remove all container images associated with the given version of SAT.
    - Remove SAT from the `cray-product-catalog` Kubernetes ConfigMap, so that it will no longer show up
      in the output of `sat showrev`.

    ```screen
    ncn-m001# prodmgr uninstall sat 2.2.10
    Repository sat-2.2.10-sle-15sp2 has been removed.
    Removed Docker image cray/cray-sat:3.9.0
    Removed Docker image cray/sat-cfs-install:1.0.2
    Removed Docker image cray/sat-install-utility:1.4.0
    Deleted sat-2.2.10 from product catalog.
    ```

## Activate: Switching Between Versions

This procedure can be used to downgrade the active version of SAT.

### Prerequisites

- Only versions 2.2 or newer of SAT can be activated. Older versions must be activated manually.
- CSM version 1.2 or newer must be installed, so that the `prodmgr` command is available.

### Procedure

1. Use `sat showrev` to list versions of SAT.

    ```screen
    ncn-m001# sat showrev --products --filter product_name=sat
    ###############################################################################
    Product Revision Information
    ###############################################################################
    +--------------+-----------------+--------+--------------------+-----------------------+
    | product_name | product_version | active | images             | image_recipes         |
    +--------------+-----------------+--------+--------------------+-----------------------+
    | sat          | 2.3.3           | True   | -                  | -                     |
    | sat          | 2.2.10          | False  | -                  | -                     |
    +--------------+-----------------+--------+--------------------+-----------------------+
    ```

1. Use `prodmgr` to activate a different version of SAT.

    This command will do three things:

    - For all hosted-type package repositories associated with this version of SAT, set them as the sole member
      of their corresponding group-type repository. For example, activating SAT version `2.2.10`
      sets the repository `sat-2.2.10-sle-15sp2` as the only member of the `sat-sle-15sp2` group.
    - Set the version `2.2.10` as active within the product catalog, so that it appears active in the output of
      `sat showrev`.
    - Ensure that the SAT CFS configuration content exists as a layer in all CFS configurations that are
      associated with NCNs with the role "Management" and subrole "Master" (for example, the CFS configuration
      `ncn-personalization`). Specifically, it will ensure that the layer refers to the version of SAT CFS
      configuration content associated with the version of SAT being activated.

    ```screen
    ncn-m001# prodmgr activate sat 2.2.10
    Repository sat-2.2.10-sle-15sp2 is now the default in sat-sle-15sp2.
    Set sat-2.2.10 as active in product catalog.
    Updated CFS configurations: [ncn-personalization]
    ```

1. Verify that the chosen version is marked as active.

    ```screen
    ncn-m001# sat showrev --products --filter product_name=sat
    ###############################################################################
    Product Revision Information
    ###############################################################################
    +--------------+-----------------+--------+--------------------+-----------------------+
    | product_name | product_version | active | images             | image_recipes         |
    +--------------+-----------------+--------+--------------------+-----------------------+
    | sat          | 2.3.3           | False  | -                  | -                     |
    | sat          | 2.2.10          | True   | -                  | -                     |
    +--------------+-----------------+--------+--------------------+-----------------------+
    ```

1. Run NCN Personalization.

    At this point, the command has modified Nexus package repositories to set a particular package repository
    as active, but no packages on the NCNs have been changed. In order to complete the activation process,
    NCN Personalization must be executed to change the `cray-sat-podman` package version on the manager NCNs.

    **NOTE**: Refer to the command output from step 2 for the names of *all* CFS configurations that were updated,
    which may not necessarily be just `ncn-personalization`. If multiple configurations were updated in step 2, then
    a `cray cfs sessions create` command should be run for each of them. This example assumes a single configuration
    named `ncn-personalization` was updated. If multiple were updated, set `cfs_configurations` to a space-separated
    list below.

    ```screen
    ncn-m001# cfs_configurations="ncn-personalization"
    ncn-m001# for cfs_configuration in ${cfs_configurations}
    do cray cfs sessions create --name "sat-session-${cfs_configuration}" --configuration-name \
        "${cfs_configuration}" --configuration-limit sat-ncn;
    done
    ```

1. Monitor the progress of each CFS session.

    This step assumes a single session named `sat-session-ncn-personalization` was created in the previous step.

    First, list all containers associated with the CFS session:

    ```screen
    ncn-m001# kubectl get pod -n services --selector=cfsession=sat-session-ncn-personalization \
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
        --selector=cfsession=sat-session-ncn-personalization
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

1. Verify the new version of the SAT CLI.

    **NOTE:** This version number will differ from the version number of the SAT
    release distribution. This is the semantic version of the SAT Python package,
    which is different from the version number of the overall SAT release distribution.

    ```screen
    ncn-m001# sat --version
    3.9.0
    ```
