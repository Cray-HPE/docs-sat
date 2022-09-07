# SAT Upgrade with CNE Installer

## Upgrade the System Admin Toolkit Product Stream

Describes how to upgrade the System Admin Toolkit (SAT) product
stream by using the Compute Node Environment (CNE) installer (`cne-install`).

The CNE installer can only upgrade the SAT product stream for this release. See [Install the System Admin Toolkit Product Stream](install.md) for installation instructions.

Upgrading SAT with `cne-install` is recommended because the process is both automated and logged to help you save time. The CNE installer can be used to upgrade SAT alone or with other supported products. Refer to the [*HPE Cray EX System Software Getting Started Guide (S-8000)*](https://www.hpe.com/support/ex-S-8000) for detailed information about `cne-install` and its options.

### Prerequisites

- CSM is installed and verified.
- cray-product-catalog is running.
- There must be at least 2 gigabytes of free space on the manager NCN on which the
  procedure is run.

### Notes on the Procedures

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `x.y.z` with the version of the SAT product stream
  being upgraded.
- 'manager' and 'master' are used interchangeably in the steps below.

### Pre-Upgrade Procedure

1.  Start a typescript and set the shell prompt.

    The typescript will record the commands and the output from this upgrade.
    The prompt is set to include the date and time.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

### Upgrade Procedure

1.  Copy the release distribution gzipped tar file to `ncn-m001`.

    Whether you are upgrading SAT alone or with other supported products, copy the file in the same media directory as all other supported products.

1.  Run the CNE installer.

    - If you are upgrading SAT along with other supported products, run the following command.

        ```screen
        ncn-m001# cne-install -m MEDIA_DIR install -B WORKING_BRANCH -bpc BOOTPREP_CONFIG_CN -bpn BOOTPREP_CONFIG_NCN
        ```

        The `cne-install` command will use the provided `BOOTPREP_CONFIG_CN` and `BOOTPREP_CONFIG_NCN` files for the run.

    - If you are upgrading SAT alone, run the following command.

        ```screen
        ncn-m001# cne-install -m MEDIA_DIR install -B WORKING_BRANCH
        ```

1.  **Optional:** Stop the typescript.

    **NOTE**: This step can be skipped if you wish to use the same typescript
    for the remainder of the SAT upgrade. See [Next Steps](#next-steps).

    ```screen
    ncn-m001# exit
    ```

SAT version `x.y.z` is now upgraded, meaning the SAT `x.y.z` release
has been loaded into the system software repository.

- SAT configuration content for this release has been uploaded to VCS.
- SAT content for this release has been uploaded to the CSM product catalog.
- SAT content for this release has been uploaded to Nexus repositories.
- The `sat` command is available.

### Next Steps

At this point, the release distribution files can be removed from the system as
described in [Post-Upgrade Cleanup Procedure](#post-upgrade-cleanup-procedure).

If other HPE Cray EX software products are being upgraded in conjunction
with SAT, refer to the [*HPE Cray EX System Software Getting Started Guide (S-8000)*](https://www.hpe.com/support/ex-S-8000)
to determine which step to execute next.

If no other HPE Cray EX software products are being upgraded at this time,
execute the **SAT Post-Upgrade** procedures:

- [Remove obsolete configuration file sections](#remove-obsolete-configuration-file-sections)
- [SAT Logging](#sat-logging)

## Post-Upgrade Cleanup Procedure

1.  **Optional:** Remove the SAT release distribution tar file and extracted directory.

    ```screen
    ncn-m001# rm sat-x.y.z.tar.gz
    ncn-m001# rm -rf sat-x.y.z/
    ```

## Remove Obsolete Configuration File Sections

### Prerequisites

- The [Upgrade the System Admin Toolkit Product Stream](#upgrade-the-system-admin-toolkit-product-stream)
  procedure has been successfully completed.

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
