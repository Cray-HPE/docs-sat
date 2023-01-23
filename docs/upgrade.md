# SAT Upgrade

## Upgrade the SAT Product Stream

Describes how to upgrade the System Admin Toolkit (SAT) product stream.

### Prerequisites

- CSM is installed and verified.
- There must be at least 2 gigabytes of free space on the manager NCN on which the
  procedure is run.

### Notes on the Procedures

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `x.y.z` with the version of the SAT product stream
  being upgraded.
- 'manager' and 'master' are used interchangeably in the steps below.

### Pre-Upgrade Procedure

1. Start a typescript and set the shell prompt.

   The typescript will record the commands and the output from this upgrade.
   The prompt is set to include the date and time.

   ```screen
   ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
   ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
   ```

### Upgrade Procedure

1. Copy the release distribution gzipped tar file to `ncn-m001`.

1. Unzip and extract the release distribution.

   ```screen
   ncn-m001# tar -xvzf sat-x.y.z.tar.gz
   ```

1. Change directory to the extracted release distribution directory.

   ```screen
   ncn-m001# cd sat-x.y.z
   ```

1. Run the installer: `install.sh`.

   The script produces a lot of output. A successful upgrade ends with "SAT
   version `x.y.z` has been installed", where `x.y.z` is the SAT product version.

   ```screen
   ncn-m001# ./install.sh
   ====> Installing System Admin Toolkit version x.y.z
   ...
   ====> Waiting 300 seconds for sat-config-import-x.y.z to complete
   ...
   ====> SAT version x.y.z has been installed.
   ```

1. **Optional:** Stop the typescript.

   **Note:** This step can be skipped if you wish to use the same typescript
   for the remainder of the SAT upgrade (see [Next Steps](#next-steps)).

   ```screen
   ncn-m001# exit
   ```

SAT version `x.y.z` is now upgraded, meaning the SAT `x.y.z` release
has been loaded into the system software repository.

- SAT configuration content for this release has been uploaded to VCS.
- SAT content for this release has been uploaded to the CSM product catalog.
- SAT content for this release has been uploaded to Nexus repositories.
- The `sat` command won't be available until the [NCN Personalization](#perform-ncn-personalization)
  procedure has been executed.

### Next Steps

If other HPE Cray EX software products are being upgraded in conjunction
with SAT, refer to the [*HPE Cray EX System Software Getting Started Guide
(S-8000)*](https://www.hpe.com/support/ex-S-8000) to determine which step to
execute next.

If no other HPE Cray EX software products are being upgraded at this time,
proceed to the sections listed below.

- [Perform NCN Personalization](#perform-ncn-personalization)
- [SAT Post-Upgrade](#sat-post-upgrade)

## Perform NCN Personalization

A new CFS configuration layer must be added to the CFS configuration used on
management NCNs. It is required following an upgrade, and this procedure describes how to add that layer.

### Prerequisites

- The [Upgrade the SAT Product Stream](#upgrade-the-sat-product-stream)
  procedure has been successfully completed.

### Notes on the Procedure

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `x.y.z` with the version of the SAT product stream
  being upgraded.
- 'manager' and 'master' are used interchangeably in the steps below.
- The existing configuration will likely include other Cray EX product
  entries. Update the SAT entry as described in this procedure. The [*HPE Cray EX System
  Software Getting Started Guide (S-8000)*](https://www.hpe.com/support/ex-S-8000)
  provides guidance on how and when to update the entries for the other products.

### Pre-NCN-Personalization Procedure

1. Start a typescript if not already using one, and set the shell prompt.

   The typescript will record the commands and the output from this upgrade.
   The prompt is set to include the date and time.

   ```screen
   ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
   ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
   ```

### Procedure to Update CFS Configuration

The SAT release distribution includes a script, `update-mgmt-ncn-cfs-config.sh`,
that updates a CFS configuration to include the SAT layer required to
upgrade and configure SAT on the management NCNs.

The script supports modifying a named CFS configuration in CFS, a CFS
configuration defined in a JSON file, or the CFS configuration
currently applied to particular components in CFS.

The script also includes options for specifying:

- how the modified CFS configuration should be saved.
- the git commit hash or branch specified in the SAT layer.

This procedure is split into three alternatives, which cover common use cases:

- [Update Active CFS Configuration](#update-active-cfs-configuration)
- [Update CFS Configuration in a JSON File](#update-cfs-configuration-in-a-json-file)
- [Update Existing CFS Configuration by Name](#update-existing-cfs-configuration-by-name)

If none of these alternatives fit your use case, see [Advanced Options for
Updating CFS Configurations](#advanced-options-for-updating-cfs-configurations).

#### Update Active CFS Configuration

Use this alternative if there is already a CFS configuration assigned to the
management NCNs and you would like to update it in place for the new version of
SAT.

1. Run the script with the following options:

   ```screen
   ncn-m001# ./update-mgmt-ncn-cfs-config.sh --base-query role=Management,type=Node --save
   ```

1. Examine the output to ensure the CFS configuration was updated.

   For example, if there is a single CFS configuration that applies to NCNs, and if
   that configuration does not have a layer yet for any version of SAT, the
   output will look like this:

   ```screen
   ====> Updating CFS configuration(s)
   INFO: Querying CFS configurations for the following NCNs: x3000c0s1b0n0, ..., x3000c0s9b0n0
   INFO: Found configuration "management-23.03" for component x3000c0s1b0n0
   ...
   INFO: Found configuration "management-23.03" for component x3000c0s9b0n0
   ...
   INFO: No layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml found.
   INFO: Adding a layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml to the end.
   INFO: Successfully saved CFS configuration "management-23.03"
   INFO: Successfully saved 1 changed CFS configurations.
   ====> Completed CFS configuration(s)
   ====> Cleaning up install dependencies
   ```

   Alternatively, if the CFS configuration already contains a layer for
   SAT that just needs to be updated, the output will look like this:

   ```screen
   ====> Updating CFS configuration(s)
   INFO: Querying CFS configurations for the following NCNs: x3000c0s1b0n0, ..., x3000c0s9b0n0
   INFO: Found configuration "management-23.03" for component x3000c0s1b0n0
   ...
   INFO: Found configuration "management-23.03" for component x3000c0s9b0n0
   ...
   INFO: Updating existing layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml
   INFO: Property "commit" of layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml updated from 01ae28c92b9b4740e9e0e01ae01216c6c2d89a65 to bcbd6db0803cc4137c7558df9546b0faab303cbd
   INFO: Property "name" of layer with repo path /vcs/cray/sat-config-management.git and playbook sat-ncn.yml updated from sat-2.2.16 to sat-sat-ncn-bcbd6db-20220608T170152
   INFO: Successfully saved CFS configuration "management-23.03"
   INFO: Successfully saved 1 changed CFS configurations.
   ====> Completed CFS configuration(s)
   ====> Cleaning up install dependencies
   ```

#### Update CFS Configuration in a JSON File

Use this alternative if you are constructing a new CFS configuration for
management NCNs in a JSON file.

1. Run the script with the following options, where `JSON_FILE` is an
   environment variable set to the path of the JSON file to modify:

   ```screen
   ncn-m001# ./update-mgmt-ncn-cfs-config.sh --base-file $JSON_FILE --save
   ```

1. Examine the output to ensure the JSON file was updated.

   For example, if the configuration defined in the JSON file does not have a layer yet for any
   version of SAT, the output will look like this:

   ```screen
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
upgrade of multiple products.

1. Run the script with the following options, where `CFS_CONFIG_NAME` is an
   environment variable set to the name of the CFS configuration to update.

   ```screen
   ncn-m001# ./update-mgmt-ncn-cfs-config.sh --base-config $CFS_CONFIG_NAME --save
   ```

1. Examine the output to ensure the CFS configuration was updated.

   For example, if the CFS configuration does not have a layer yet for any version of SAT,
   the output will look like this:

   ```screen
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

1. Set an environment variable that refers to the name of the CFS configuration
   to be applied to the management NCNs.

   ```screen
   ncn-m001# export CFS_CONFIG_NAME="management-23.03"
   ```

   **Note:** If the [Update Active CFS Configuration](#update-active-cfs-configuration)
   section was followed above, the name of the updated CFS configuration will
   have been logged in the following format. If multiple CFS configurations
   were modified, any one of them can be used in this procedure.

   ```screen
   INFO: Successfully saved CFS configuration "management-23.03"
   ```

1. Obtain the name of the CFS configuration layer for SAT and save it in an
   environment variable:

   ```screen
   ncn-m001# export SAT_LAYER_NAME=$(cray cfs configurations describe $CFS_CONFIG_NAME --format json \
       | jq -r '.layers | map(select(.cloneUrl | contains("sat-config-management.git")))[0].name')
   ```

1. Create a CFS session that executes only the SAT layer of the given CFS
   configuration.

   The `--configuration-limit` option limits the configuration session to run
   only the SAT layer of the configuration.

   ```screen
   ncn-m001# cray cfs sessions create --name "sat-session-${CFS_CONFIG_NAME}" --configuration-name \
       "${CFS_CONFIG_NAME}" --configuration-limit "${SAT_LAYER_NAME}"
   ```

1. Monitor the progress of the CFS session.

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

   Ansible plays, which are run by the CFS session, will upgrade SAT on all the
   master management NCNs on the system. A summary of results can be found at
   the end of the log output. The following example shows a successful session.

   ```screen
   ...
   PLAY RECAP *********************************************************************
   x3000c0s1b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   x3000c0s3b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   x3000c0s5b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```

   **Note:** Ensure that the PLAY RECAPs for each session show successes for all
   manager NCNs before proceeding.

1. Verify that SAT was successfully configured.

   If `sat` is configured, the `--version` command will indicate which version
   is installed. If `sat` is not properly configured, the command will fail.

   **Note:** This version number will differ from the version number of the SAT
   release distribution. This is the semantic version of the `sat` Python package,
   which is different from the version number of the overall SAT release distribution.

   ```screen
   ncn-m001# sat --version
   sat 3.7.0
   ```

   **Note:** Upon first running `sat`, you may see additional output while the `sat`
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

1. Stop the typescript.

   ```screen
   ncn-m001# exit
   ```

SAT version `x.y.z` is now upgraded and configured:

- The SAT RPM package is installed on the associated NCNs.

#### Note on Procedure to Apply CFS Configuration

The previous procedure is not always necessary because the CFS Batcher service
automatically detects configuration changes and will automatically create new
sessions to apply configuration changes according to certain rules. For more
information on these rules, refer to **Configuration Management with
the CFS Batcher** in the [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).

The main scenario in which the CFS batcher will not automatically re-apply the
SAT layer is when the commit hash of the sat-config-management git repository
has not changed between SAT versions. The previous procedure ensures the
configuration is re-applied in all cases, and it is harmless if the batcher has
already applied an updated configuration.

### Next Steps

At this point, the release distribution files can be removed from the system as
described in [Post-Upgrade Cleanup Procedure](#post-upgrade-cleanup-procedure).

If other HPE Cray EX software products are being upgraded in conjunction
with SAT, refer to the [*HPE Cray EX System Software Getting Started Guide
(S-8000)*](https://www.hpe.com/support/ex-S-8000) to determine which step
to execute next.

If no other HPE Cray EX software products
are being upgraded at this time, proceed to the remaining **SAT Post-Upgrade**
procedures:

- [Remove obsolete configuration file sections](#remove-obsolete-configuration-file-sections)
- [SAT Logging](#sat-logging)
- [Set System Revision Information](#set-system-revision-information)

**Note:** The **Set System Revision Information** procedure is **not required** after upgrading from SAT 2.1 or later.

### Post-Upgrade Cleanup Procedure

1. **Optional:** Remove the SAT release distribution tar file and extracted directory.

   ```screen
   ncn-m001# rm sat-x.y.z.tar.gz
   ncn-m001# rm -rf sat-x.y.z/
   ```

## SAT Post-Upgrade

### Remove Obsolete Configuration File Sections

#### Prerequisites

- The [Upgrade the SAT Product Stream](#upgrade-the-sat-product-stream)
  procedure has been successfully completed.
- The [Perform NCN Personalization](#perform-ncn-personalization) procedure has been successfully completed.

#### Procedure

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

### SAT Logging

As of SAT version 2.2, some command output that was previously printed to `stdout`
is now logged to `stderr`. These messages are logged at the `INFO` level. The
default logging threshold was changed from `WARNING` to `INFO` to accommodate
this logging change. Additionally, some messages previously logged at the `INFO`
are now logged at the `DEBUG` level.

These changes take effect automatically. However, if the default output threshold
has been manually set in `~/.config/sat/sat.toml`, it should be changed to ensure
that important output is shown in the terminal.

#### Update Configuration

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
behavior. However, it may be helpful to set its value to `INFO` as a reminder of
the new default behavior.

#### Affected Commands

The following commands trigger messages that have been changed from `stdout`
print calls to `INFO`-level (or `WARNING`- or `ERROR`-level) log messages:

- `sat bootsys --stage shutdown --stage session-checks`
- `sat sensors`

The following commands trigger messages that have been changed from `INFO`-level
log messages to `DEBUG`-level log messages:

- `sat nid2xname`
- `sat xname2nid`
- `sat swap`

### Set System Revision Information

HPE service representatives use system revision information data to identify
systems in support cases.

#### Prerequisites

- SAT authentication has been set up during installation. See [SAT Authentication](install.md#sat-authentication).
- S3 credentials have been generated during installation. See [Generate SAT S3 Credentials](install.md#generate-sat-s3-credentials).

#### Notes on the Procedure

This procedure is **not required** if SAT was upgraded from 2.1 (Shasta v1.5)
or later. It **is required** if SAT was upgraded from 2.0 (Shasta v1.4) or
earlier.

#### Procedure

1. Set System Revision Information.

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

   **TIP**: For "System type", a system with *any* liquid-cooled components should be
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

1. Verify System Revision Information.

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
