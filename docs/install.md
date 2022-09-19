# SAT Installation

## Install the System Admin Toolkit Product Stream

Describes how to install or upgrade the System Admin Toolkit (SAT) product
stream.

### Prerequisites

- CSM is installed and verified.
- cray-product-catalog is running.
- There must be at least 2 gigabytes of free space on the manager NCN on which the
  procedure is run.

### Notes on the Procedures

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `x.y.z` with the version of the SAT product stream
  being installed.
- 'manager' and 'master' are used interchangeably in the steps below.
- To upgrade SAT, execute the pre-installation, installation, and post-installation
  procedures for a newer distribution. The newly installed version will become
  the default.

### Pre-Installation Procedure

1.  Start a typescript and set the shell prompt.

    The typescript will record the commands and the output from this installation.
    The prompt is set to include the date and time.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

### Installation Procedure

1.  Copy the release distribution gzipped tar file to `ncn-m001`.

1.  Unzip and extract the release distribution.

    ```screen
    ncn-m001# tar -xvzf sat-x.y.z.tar.gz
    ```

1.  Change directory to the extracted release distribution directory.

    ```screen
    ncn-m001# cd sat-x.y.z
    ```

1.  Run the installer: `install.sh`.

    The script produces a lot of output. A successful install ends with "SAT
    version `x.y.z` has been installed", where `x.y.z` is the SAT product version.

    ```screen
    ncn-m001# ./install.sh
    ====> Installing System Admin Toolkit version x.y.z
    ...
    ====> Waiting 300 seconds for sat-config-import-x.y.z to complete
    ...
    ====> SAT version x.y.z has been installed.
    ```

1.  **Optional:** Stop the typescript.

    **NOTE**: This step can be skipped if you wish to use the same typescript
    for the remainder of the SAT install. See [Next Steps](#next-steps).

    ```screen
    ncn-m001# exit
    ```

SAT version `x.y.z` is now installed/upgraded, meaning the SAT `x.y.z` release
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

**NOTE:** The **NCN Personalization** procedure **is required** both when
installing and upgrading SAT. The setup procedures in **SAT Setup**, however,
are are only required during the first installation of SAT.

Execute the **NCN Personalization** procedure:

- [Perform NCN Personalization](#perform-ncn-personalization)

If performing a fresh install, execute the **SAT Setup** procedures:

- [SAT Authentication](#sat-authentication)
- [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
- [Set System Revision Information](#set-system-revision-information)

If performing an upgrade, execute the **SAT Post-Upgrade** procedures:

- [Remove obsolete configuration file sections](#remove-obsolete-configuration-file-sections)
- [SAT Logging](#sat-logging)
- [Set System Revision Information](#set-system-revision-information)

**NOTE:** The **Set System Revision Information** procedure is **not required** after upgrading from SAT 2.1 or later.

## Perform NCN Personalization

To configure the installed version of SAT, a new CFS configuration layer must be added to the CFS configuration used on management NCNs. This procedure describes how to add that layer. It is required to complete SAT installation and configuration.

### Prerequisites

- The [Install the System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
  procedure has been successfully completed.

### Notes on the Procedure

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `x.y.z` with the version of the SAT product stream
  being installed.
- 'manager' and 'master' are used interchangeably in the steps below.
- If upgrading SAT, the existing configuration will likely include other Cray EX product
  entries. Update the SAT entry as described in this procedure. The *HPE Cray EX System
  Software Getting Started Guide* provides guidance on how and when to update the
  entries for the other products.

### Pre-NCN-Personalization Procedure

1.  Start a typescript if not already using one, and set the shell prompt.

    The typescript will record the commands and the output from this installation.
    The prompt is set to include the date and time.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

### Procedure to Update CFS Configuration

The SAT release distribution includes a script, `update-mgmt-ncn-cfs-config.sh`,
that updates a CFS configuration to include the SAT layer required to
install and configure SAT on the management NCNs.

The script supports modifying a named CFS configuration in CFS, a CFS
configuration defined in a JSON file, or the CFS configuration
currently applied to particular components in CFS.

The script also includes options for specifying:

- how the modified CFS configuration should be saved
- the git commit hash or branch specified in the SAT layer

This procedure is split into three alternatives, which cover common use cases:

- [Update Active CFS Configuration](#update-active-cfs-configuration)
- [Update CFS Configuration in a JSON File](#update-cfs-configuration-in-a-json-file)
- [Update Existing CFS Configuration by Name](#update-existing-cfs-configuration-by-name)

If none of these alternatives fit your use case, see:

- [Advanced Options for Updating CFS Configurations](#advanced-options-for-updating-cfs-configurations)

#### Update Active CFS Configuration

Use this alternative if there is already a CFS configuration assigned to the
management NCNs and you would like to update it in place for the new version of
SAT.

1.  Run the script with the following options:

    ```screen
    ncn-m001# ./update-mgmt-ncn-cfs-config.sh --base-query role=Management,type=Node --save
    ```

1.  Examine the output to ensure the CFS configuration was updated.

    For example, if there is a single CFS configuration that applies to NCNs, and if
    that configuration does not have a layer yet for any version of SAT, the
    output will look like this:

    ```screen
    ====> Updating CFS configuration(s)
    INFO: Querying CFS configurations for the following NCNs: x3000c0s1b0n0, ..., x3000c0s9b0n0
    INFO: Found configuration "ncn-personalization" for component x3000c0s1b0n0
    ...
    INFO: Found configuration "ncn-personalization" for component x3000c0s9b0n0
    ...
    INFO: No layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml found.
    INFO: Adding a layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml to the end.
    INFO: Successfully saved CFS configuration "ncn-personalization"
    INFO: Successfully saved 1 changed CFS configurations.
    ====> Completed CFS configuration(s)
    ====> Cleaning up install dependencies
    ```

    Alternatively, if the CFS configuration already contains a layer for
    SAT that just needs to be updated, the output will look like this:

    ```screen
    ====> Updating CFS configuration(s)
    INFO: Querying CFS configurations for the following NCNs: x3000c0s1b0n0, ..., x3000c0s9b0n0
    INFO: Found configuration "ncn-personalization" for component x3000c0s1b0n0
    ...
    INFO: Found configuration "ncn-personalization" for component x3000c0s9b0n0
    ...
    INFO: Updating existing layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml
    INFO: Property "commit" of layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml updated from 01ae28c92b9b4740e9e0e01ae01216c6c2d89a65 to bcbd6db0803cc4137c7558df9546b0faab303cbd
    INFO: Property "name" of layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml updated from sat-2.2.16 to sat-sat-ncn-bcbd6db-20220608T170152
    INFO: Successfully saved CFS configuration "ncn-personalization"
    INFO: Successfully saved 1 changed CFS configurations.
    ====> Completed CFS configuration(s)
    ====> Cleaning up install dependencies
    ```

#### Update CFS Configuration in a JSON File

Use this alternative if you are constructing a new CFS configuration for
management NCNs in a JSON file.

1.  Run the script with the following options, where `JSON_FILE` is an
    environment variable set to the path of the JSON file to modify:

    ```screen
    ncn-m001# ./update-mgmt-ncn-cfs-config.sh --base-file $JSON_FILE --save
    ```

1.  Examine the output to ensure the JSON file was updated.

    For example, if the configuration defined in the JSON file does not have a layer yet for any
    version of SAT, the output will look like this:

    ```
    ====> Updating CFS configuration(s)
    INFO: No layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml found.
    INFO: Adding a layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml to the end.
    INFO: Successfully saved 1 changed CFS configurations.
    ====> Completed CFS configuration(s)
    ====> Cleaning up install dependencies
    ```

#### Update Existing CFS Configuration by Name

Use this alternative if you are updating a specific named CFS configuration.
This may be the case if you are constructing a new CFS configuration during an
install or upgrade of multiple products.

1.  Run the script with the following options, where `CFS_CONFIG_NAME` is an
    environment variable set to the name of the CFS configuration to update.

    ```screen
    ncn-m001# ./update-mgmt-ncn-cfs-config.sh --base-config $CFS_CONFIG_NAME --save
    ```

1.  Examine the output to ensure the CFS configuration was updated.

    For example, if the CFS configuration does not have a layer yet for any version of SAT,
    the output will look like this:

    ```
    ====> Updating CFS configuration(s)
    INFO: No layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml found.
    INFO: Adding a layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml to the end.
    INFO: Successfully saved CFS configuration "CFS_CONFIG_NAME"
    INFO: Successfully saved 1 changed CFS configurations.
    ====> Completed CFS configuration(s)
    ====> Cleaning up install dependencies
    ```

#### Advanced Options for Updating CFS Configurations

If none of the alternatives described in the previous sections apply, view the
full description of the options accepted by the `update-mgmt-ncn-cfs-config.sh`
script by invoking it with the `--help` option.

```screen
ncn-m001# ./update-mgmt-ncn-cfs-config.sh --help
```

### Procedure to Apply CFS Configuration

After the CFS configuration that applies to management NCNs has been updated as
described in the [Procedure to Update CFS Configuration](#procedure-to-update-cfs-configuration),
execute the following steps to ensure the modified CFS configuration is re-applied to the management NCNs.

1.  Set an environment variable that refers to the name of the CFS configuration
    to be applied to the management NCNs.

    ```screen
    ncn-m001# export CFS_CONFIG_NAME="ncn-personalization"
    ```

    Note: If the [Update Active CFS Configuration](#update-active-cfs-configuration)
    section was followed above, the name of the updated CFS configuration will
    have been logged in the following format. If multiple CFS configurations
    were modified, any one of them can be used in this procedure.

    ```screen
    INFO: Successfully saved CFS configuration "ncn-personalization"
    ```

1.  Obtain the name of the CFS configuration layer for SAT and save it in an
    environment variable:

    ```screen
    ncn-m001# export SAT_LAYER_NAME=$(cray cfs configurations describe $CFS_CONFIG_NAME --format json \
        | jq -r '.layers | map(select(.cloneUrl | contains("sat-config-management.git")))[0].name')
    ```

1.  Create a CFS session that executes only the SAT layer of the given CFS
    configuration.

    The `--configuration-limit` option limits the configuration session to run
    only the SAT layer of the configuration.

    ```screen
    ncn-m001# cray cfs sessions create --name "sat-session-${CFS_CONFIG_NAME}" --configuration-name \
        "${CFS_CONFIG_NAME}" --configuration-limit "${SAT_LAYER_NAME}"
    ```

1.  Monitor the progress of the CFS session.

    Set an environment variable to name of the Ansible container within the pod
    for the CFS session:

    ```screen
    ncn-m001# export ANSIBLE_CONTAINER=$(kubectl get pod -n services \
        --selector=cfsession=sat-session-${CFS_CONFIG_NAME} -o json \
        -o json | jq -r '.items[0].spec.containers | map(select(.name | contains("ansible"))) | .[0].name')
    ```

    Next, get the logs for the Ansible container.

    ```screen
    ncn-m001# kubectl logs -c $ANSIBLE_CONTAINER --tail 100 -f -n services \
        --selector=cfsession=sat-session-${CFS_CONFIG_NAME}
    ```

    Ansible plays, which are run by the CFS session, will install SAT on all the
    master management NCNs on the system. A summary of results can be found at
    the end of the log output. The following example shows a successful session.

    ```screen
    ...
    PLAY RECAP *********************************************************************
    x3000c0s1b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    x3000c0s3b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    x3000c0s5b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

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

SAT version `x.y.z` is now installed and configured:

- The SAT RPM package is installed on the associated NCNs.

#### Note on Procedure to Apply CFS Configuration

The previous procedure is not always necessary because the CFS Batcher service
automatically detects configuration changes and will automatically create new
sessions to apply configuration changes according to certain rules. See
[Configuration Management with the CFS Batcher](https://github.com/Cray-HPE/docs-csm/blob/main/operations/configuration_management/Configuration_Management_with_the_CFS_Batcher.md)
in the CSM documentation for more information about these rules.

The main scenario in which the CFS batcher will not automatically re-apply the
SAT layer is when the commit hash of the sat-config-management git repository
has not changed between SAT versions. The previous procedure ensures the
configuration is re-applied in all cases, and it is harmless if the batcher has
already applied an updated configuration.

### Next Steps

At this point, the release distribution files can be removed from the system as
described in [Post-Installation Cleanup Procedure](#post-installation-cleanup-procedure).

If other HPE Cray EX software products are being installed or upgraded in conjunction
with SAT, refer to the [*HPE Cray EX System Software Getting Started Guide*](https://www.hpe.com/support/ex-gsg)
to determine which step to execute next.

If no other HPE Cray EX software products are being installed or upgraded at this time,
proceed to the remaining **SAT Setup** or **SAT Post-Upgrade** procedures.

If performing a fresh install, execute the **SAT Setup** procedures:

- [SAT Authentication](#sat-authentication)
- [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
- [Set System Revision Information](#set-system-revision-information)

If performing an upgrade, execute the **SAT Post-Upgrade** procedures:

- [Remove obsolete configuration file sections](#remove-obsolete-configuration-file-sections)
- [SAT Logging](#sat-logging)
- [Set System Revision Information](#set-system-revision-information)

**NOTE:** The **Set System Revision Information** procedure is **not required** after upgrading from SAT 2.1 or later.

### Post-Installation Cleanup Procedure

1.  **Optional:** Remove the SAT release distribution tar file and extracted directory.

    ```screen
    ncn-m001# rm sat-x.y.z.tar.gz
    ncn-m001# rm -rf sat-x.y.z/
    ```

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
|`sat bootprep`|Requires authentication to the API gateway. Requires Kubernetes configuration and authentication, which is done on `ncn-m001` during the install.|`sat-bootprep`|Prepare to boot nodes with images and configurations.|
|`sat bootsys`|Requires authentication to the API gateway. Requires Kubernetes configuration and authentication, which is configured on `ncn-m001` during the install. Some stages require passwordless SSH to be configured to all other NCNs. Requires S3 to be configured for some stages.|`sat-bootsys`|Boot or shutdown the system, including compute nodes, application nodes, and non-compute nodes (NCNs) running the management software.|
|`sat diag`|Requires authentication to the API gateway.|`sat-diag`|Launch diagnostics on the HSN switches and generate a report.|
|`sat firmware`|Requires authentication to the API gateway.|`sat-firmware`|Report firmware version.|
|`sat hwhist`|Requires authentication to the API gateway.|`sat-hwhist`|Report hardware component history.|
|`sat hwinv`|Requires authentication to the API gateway.|`sat-hwinv`|Give a listing of the hardware of the HPE Cray EX system.|
|`sat hwmatch`|Requires authentication to the API gateway.|`sat-hwmatch`|Report hardware mismatches.|
|`sat init`|None|`sat-init`|Create a default SAT configuration file.|
|`sat k8s`|Requires Kubernetes configuration and authentication, which is automatically configured on `ncn-m001` during the install.|`sat-k8s`|Report on Kubernetes replica sets that have co-located \(on the same node\) replicas.|
|`sat linkhealth`|||**This command has been deprecated.**|
|`sat nid2xname`|Requires authentication to the API gateway.|`sat-nid2xname`|Translate node IDs to node XNames.|
|`sat sensors`|Requires authentication to the API gateway.|`sat-sensors`|Report current sensor data.|
|`sat setrev`|Requires S3 to be configured for site information such as system name, serial number, install date, and site name.|`sat-setrev`|Set HPE Cray EX system revision information.|
|`sat showrev`|Requires API gateway authentication in order to query the Interconnect from HSM. Requires S3 to be configured for site information such as system name, serial number, install date, and site name.|`sat-showrev`|Print revision information for the HPE Cray EX system.|
|`sat slscheck`|Requires authentication to the API gateway.|`sat-slscheck`|Perform a cross-check between SLS and HSM.|
|`sat status`|Requires authentication to the API gateway.|`sat-status`|Report node status across the HPE Cray EX system.|
|`sat swap`|Requires authentication to the API gateway.|`sat-swap`|Prepare HSN switch or cable for replacement and bring HSN switch or cable into service.|
|`sat xname2nid`|Requires authentication to the API gateway.|`sat-xname2nid`|Translate node and node BMC XNames to node IDs.|
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

1.  Generate a default SAT configuration file, if one does not exist.

    ```screen
    ncn-m001# sat init
    Configuration file "/root/.config/sat/sat.toml" generated.
    ```

    **Note:** If the config file already exists, it will print out an error:

    ```screen
    ERROR: Configuration file "/root/.config/sat/sat.toml" already exists.
    Not generating configuration file.
    ```

1.  Edit `~/.config/sat/sat.toml` and set the username option in the `api_gateway` section of the config file. For
    example:

    ```screen
    username = "crayadmin"
    ```

1.  Run `sat auth`. Enter your password when prompted. For example:

    ```screen
    ncn-m001# sat auth
    Password for crayadmin:
    Succeeded!
    ```

1.  Other `sat` commands are now authenticated to make requests to the API gateway. For example:

    ```screen
    ncn-m001# sat status
    ```

## Generate SAT S3 Credentials

Generate S3 credentials and write them to a local file so the SAT user can access S3 storage. In order to use the SAT
S3 bucket, the System Administrator must generate the S3 access key and secret keys and write them to a local file.
This must be done on every Kubernetes master node where SAT commands are run.

SAT uses S3 storage for several purposes, most importantly to store the site-specific information set with `sat setrev`
(see: [Set System Revision Information](#set-system-revision-information)).

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

1.  Write the credentials to local files using `kubectl`.

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

1.  Verify the S3 endpoint specified in the SAT configuration file is correct.

    1.  Get the SAT configuration file's endpoint value.

        **NOTE:** If the command's output is commented out, indicated by an initial `#`
        character, the SAT configuration will take the default value – `"https://rgw-vip.nmn"`.

        ```screen
        ncn-m001# grep endpoint ~/.config/sat/sat.toml
        # endpoint = "https://rgw-vip.nmn"
        ```

    1.  Get the `sat-s3-credentials` secret's endpoint value.

        ```screen
        ncn-m001# kubectl get secret sat-s3-credentials -o json -o \
            jsonpath='{.data.s3_endpoint}' | base64 -d | xargs
        https://rgw-vip.nmn
        ```

    1.  Compare the two endpoint values.

        If the values differ, change the SAT configuration file's endpoint value to match the secret's.

1.  Copy SAT configurations to each manager node on the system.

    ```screen
    ncn-m001# for i in ncn-m002 ncn-m003; do echo $i; ssh ${i} \
        mkdir -p /root/.config/sat; \
        scp -pr /root/.config/sat ${i}:/root/.config; done
    ```

    **NOTE**: Depending on how many manager nodes are on the system, the list of manager nodes may
    be different. This example assumes three manager nodes, where the configuration files must be
    copied from `ncn-m001` to `ncn-m002` and `ncn-m003`. Therefore, the list of hosts above is
    `ncn-m002` and `ncn-m003`.

## Set System Revision Information

HPE service representatives use system revision information data to identify
systems in support cases.

### Prerequisites

- S3 credentials have been generated. See [Generate SAT S3 Credentials](#generate-sat-s3-credentials).
- SAT authentication has been set up. See [SAT Authentication](#sat-authentication).

### Notes on the Procedure

- This procedure **is required** after a fresh install of SAT.
- After an upgrade of SAT, this procedure is **not required** if SAT was upgraded
  from 2.1 (Shasta v1.5) or later. It **is required** if SAT was upgraded from
  2.0 (Shasta v1.4) or earlier.

### Procedure

1.  Set System Revision Information.

    Run `sat setrev` and follow the prompts to set the following site-specific values:

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
    considered a liquid-cooled system. In other words, "System type" is EX-1C.

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

1.  Verify System Revision Information.

    Run `sat showrev` and verify the output shown in the "System Revision Information table."

    The following example shows sample table output.

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

## Remove Obsolete Configuration File Sections

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
default logging threshold was changed from `WARNING` to `INFO` to accommodate
this logging change. Additionally, some messages previously logged at the `INFO`
are now logged at the `DEBUG` level.

These changes take effect automatically. However, if the default output threshold
has been manually set in `~/.config/sat/sat.toml`, it should be changed to ensure
that important output is shown in the terminal.

### Update Configuration

In the following example, the `stderr` log level, `logging.stderr_level`, is set to
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

- Only versions 2.2 or newer of SAT can be uninstalled with `prodmgr`. Older versions must be uninstalled manually.
- CSM version 1.2 or newer must be installed, so that the `prodmgr` command is available.

### Procedure

1.  Use `sat showrev` to list versions of SAT.

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

1.  Use `prodmgr` to uninstall a version of SAT.

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

1.  Use `sat showrev` to list versions of SAT.

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

1.  Use `prodmgr` to activate a different version of SAT.

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

1.  Verify that the chosen version is marked as active.

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

1.  Apply the modified CFS configuration to the management NCNs.

    At this point, Nexus package repositories have been modified to set a
    particular package repository as active, but the SAT package may not have
    been updated on management NCNs.

    To ensure that management NCNs have been updated to use the active SAT
    version, follow the [Procedure to Apply CFS Configuration](#procedure-to-apply-cfs-configuration).
    Refer to the output from the `prodmgr activate` command to find the name of
    the modified CFS configuration. If more than one CFS configuration was
    modified, use the first one.

## Optional: Installing and Configuring SAT on an External System

SAT can optionally be installed and configured on an external system to interact with CSM over the CAN.

### Limitations

Most SAT subcommands work by accessing APIs which are reachable via the CAN. However, certain SAT commands depend on
host-based functionality on the management NCNs and will not work from an external system. This includes the following:

- The `platform-services` and `ncn-power` stages of `sat bootsys`
- The local host information displayed by the `--local` option of `sat showrev`

Installing SAT on an external system is not an officially supported configuration. These instructions are provided
"as-is" with the hope that they can useful for users who desire additional flexibility.

Certain additional steps may need to be taken to install and configure SAT depending on the configuration of the
external system in use. These additional steps may include provisioning virtual machines, installing packages, or
configuring TLS certificates, and these steps are outside the scope of this documentation. This section covers only the
steps needed to configure SAT to use externally-accessible API endpoints exposed by CSM.

### Prerequisites

- The external system must be on the Customer Access Network (CAN).
- Python 3.7 or newer is installed on the system.
- `kubectl`, `openssh`, `git`, and `curl` are installed on the external system.
- The root CA certificates used when installing CSM have been added to the external system's trust store such that
  authenticated TLS connections can be made to the CSM REST API gateway. See the [Certificate
  Authority](https://cray-hpe.github.io/docs-csm/en-12/background/certificate_authority/) section of the CSM
  documentation for more information.

### Procedure

1.  Create a Python virtual environment.

    ```screen
    $ SAT_VENV_PATH="$(pwd)/venv"
    $ python3 -m venv ${SAT_VENV_PATH}
    $ . ${SAT_VENV_PATH}/bin/activate
    ```

1.  Install the SAT Python package in the virtual environment.

    ```screen
    (venv) $ export PIP_EXTRA_INDEX_URL="https://artifactory.algol60.net/artifactory/csm-python-modules/simple"
    (venv) $ git clone --branch=release/3.17 https://github.com/Cray-HPE/sat.git
    (venv) $ pip install -r sat/requirements.lock.txt
    ...
    (venv) $ pip install ./sat
    ...
    ```

1.  Optional: Add the `sat` virtual environment to the user's `PATH` environment variable.

    If a shell other than `bash` is in use, replace `~/.bash_profile` with the appropriate profile path.

    If the virtual environment is not added to the user's `PATH` environment variable, then
    `source ${SAT_VENV_PATH}/bin/activate` will need to be run before running any SAT commands.

    ```screen
    (venv) $ deactivate
    $ echo export PATH=\"${SAT_VENV_PATH}/bin:${PATH}\" >> ~/.bash_profile
    $ source ~/.bash_profile
    ```

1.  Copy the file `/etc/kubernetes/admin.conf` from `ncn-m001` to `~/.kube/config` on the external system.

    Note that this file contains credentials to authenticate against the Kubernetes API as the administrative user, so
    it should be treated as sensitive.

    ```screen
    $ mkdir -p ~/.kube
    $ scp ncn-m001:/etc/kubernetes/admin.conf ~/.kube/config
    admin.conf                                       100% 5566   3.0MB/s   00:00
    ```

1.  Add a new entry for the hostname `kubernetes` to the external system's `/etc/hosts` file.

    The `kubernetes` hostname should correspond to the CAN IP address on `ncn-m001`. On CSM 1.2, this can be determined
    by querying the IP address of the `bond0.cmn0` interface.

    ```screen
    $ ssh ncn-m001 ip addr show bond0.cmn0
    13: bond0.cmn0@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether b8:59:9f:1d:d9:0e brd ff:ff:ff:ff:ff:ff
    inet 10.102.1.11/24 brd 10.102.1.255 scope global vlan007
       valid_lft forever preferred_lft forever
    inet6 fe80::ba59:9fff:fe1d:d90e/64 scope link
       valid_lft forever preferred_lft forever
    $ IP_ADDRESS=10.102.1.11
    ```

    On CSM versions prior to 1.2, the CAN IP can be determined by querying the IP address of the `vlan007` interface.

    ```screen
    $ ssh ncn-m001 ip addr show vlan007
    13: vlan007@bond0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether b8:59:9f:1d:d9:0e brd ff:ff:ff:ff:ff:ff
    inet 10.102.1.10/24 brd 10.102.1.255 scope global vlan007
       valid_lft forever preferred_lft forever
    inet6 fe80::ba59:9fff:fe1d:d90e/64 scope link
       valid_lft forever preferred_lft forever
    $ IP_ADDRESS=10.102.1.10
    ```

    Once the IP address is determined, add an entry to `/etc/hosts` mapping the IP address to the hostname `kubernetes`.

    ```screen
    $ echo "${IP_ADDRESS} kubernetes" | sudo tee -a /etc/hosts
    10.102.1.11 kubernetes
    ```

1.  Modify `~/.kube/config` to set the cluster server address.

    The value of the `server` key for the `kubernetes` cluster under the `clusters` section should be set to
    `https://kubernetes:6443`.

    ```yaml
    ---
    clusters:
    - cluster:
        certificate-authority-data: REDACTED
        server: https://kubernetes:6443
      name: kubernetes
    ...
    ```

1.  Confirm that `kubectl` can access the CSM Kubernetes cluster.

    ```screen
    $ kubectl get nodes
    NAME       STATUS   ROLES    AGE    VERSION
    ncn-m001   Ready    master   135d   v1.19.9
    ncn-m002   Ready    master   136d   v1.19.9
    ncn-m003   Ready    master   136d   v1.19.9
    ncn-w001   Ready    <none>   136d   v1.19.9
    ncn-w002   Ready    <none>   136d   v1.19.9
    ncn-w003   Ready    <none>   136d   v1.19.9
    ```

1.  Use `sat init` to create a configuration file for SAT.

    ```screen
    $ sat init
    INFO: Configuration file "/home/user/.config/sat/sat.toml" generated.
    ```

1.  Copy the platform CA certificates from the management NCN and configure the certificates for use with SAT.

    If a shell other than `bash` is in use, replace `~/.bash_profile` with the appropriate profile path.

    ```screen
    $ scp ncn-m001:/etc/pki/trust/anchors/platform-ca-certs.crt .
    $ echo export REQUESTS_CA_BUNDLE=\"$(realpath platform-ca-certs.crt)\" >> ~/.bash_profile
    $ source ~/.bash_profile
    ```

1.  Edit the SAT configuration file to set the API and S3 hostnames.

    Externally available API endpoints are given domain names in PowerDNS, so the endpoints in the configuration file
    should each be set to `subdomain.system-name.site-domain`, where `system-name` and `site-domain` are replaced with
    the values specified during `csi config init`, and `subdomain` is the DNS name for the externally available service.
    See [Externally Exposed Services](https://cray-hpe.github.io/docs-csm/en-12/operations/network/customer_accessible_networks/externally_exposed_services/)
    in the CSM documentation for more information.

    The API gateway has the subdomain `api`, and S3 has the subdomain `s3`. The S3 endpoint runs on port 8080. The
    following options should be set in the SAT configuration file:

    ```toml
    [api_gateway]
    host = "api.system-name.site-domain"

    [s3]
    endpoint = "http://s3.system-name.site-domain:8080"
    ```

1.  Edit the SAT configuration file to specify the Keycloak user which will be accessing the REST API.

    ```toml
    [api_gateway]
    username = "user"
    ```

1.  Authenticate against the API gateway with `sat auth`.

    See [SAT Authentication](#sat-authentication).

1.  Generate S3 credentials.

    See [Generate SAT S3 Credentials](#generate-sat-s3-credentials).
