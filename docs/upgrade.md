# SAT Upgrade

## Install and Upgrade Framework

The Install and Upgrade Framework (IUF) provides commands which install,
upgrade, and deploy products on systems managed by CSM. IUF capabilities are
described in detail in the [IUF
section](https://cray-hpe.github.io/docs-csm/en-14/operations/iuf/iuf/) of the
[*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).
The initial install and upgrade workflows described in the
[*HPE Cray EX System Software Stack Installation and Upgrade Guide for CSM
(S-8052)*](https://www.hpe.com/support/ex-S-8052) detail when and how to use
IUF with a new release of SAT or any other HPE Cray EX product.

This document **does not** replicate install, upgrade, or deployment procedures
detailed in the [*Cray System Management
Documentation*](https://cray-hpe.github.io/docs-csm/). This document provides
details regarding software and configuration content specific to SAT which is
needed when installing, upgrading, or deploying a SAT release. The [*Cray
System Management Documentation*](https://cray-hpe.github.io/docs-csm/) will
indicate when sections of this document should be referred to for detailed
information.

IUF will perform the following tasks for a release of SAT.

- IUF `deliver-product` stage:
  - Uploads SAT configuration content to VCS
  - Uploads SAT information to the CSM product catalog
  - Uploads SAT content to Nexus repositories
- IUF `update-vcs-config` stage:
  - Updates the VCS integration branch with new SAT configuration content if a
    working branch is specified
- IUF `update-cfs-config` stage:
  - Creates a new CFS configuration for management nodes with new SAT configuration content
- IUF `prepare-images` stage:
  - Creates updated management NCN and managed node images with new SAT content
- IUF `management-nodes-rollout` stage:
  - Boots management NCNs with an image containing new SAT content

IUF uses a variety of CSM and SAT tools when performing these tasks. The [IUF
section](https://cray-hpe.github.io/docs-csm/en-14/operations/iuf/iuf/) of the
[*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/)
describes how to use these tools directly if it is desirable to use them
instead of IUF.

## IUF Stage Details for SAT

This section describes SAT details that an administrator must be aware of
before running IUF stages. Entries are prefixed with **Information** if no
administrative action is required or **Action** if an administrator needs
to perform tasks outside of IUF.

### update-vcs-config

**Information**: This stage is only run if a VCS working branch is specified for
SAT. By default, SAT does not create or specify a VCS working branch.

### update-cfs-config

**Information**: This stage only applies to the management configuration and
not to the managed configuration.

### prepare-images

**Information**: This stage only applies to management images and not to
managed images.

## Post-Upgrade Procedures

After upgrading SAT with IUF, it is recommended that you complete the following
procedures before using SAT:

- [Remove Obsolete Configuration File Sections](#remove-obsolete-configuration-file-sections)
- [Update SAT Logging](#update-sat-logging)
- [Set System Revision Information](#set-system-revision-information)

### Notes on the Procedures

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `x.y.z` with the version of the SAT product stream
  being upgraded.
- 'manager' and 'master' are used interchangeably in the steps below.

### Remove Obsolete Configuration File Sections

After upgrading SAT, if using the configuration file from a previous version, there may be
configuration file sections no longer used in the new version. For example, when upgrading
from Shasta 1.4 to Shasta 1.5, the `[redfish]` configuration file section is no longer used.

(`ncn-m001#`) In that case, the following warning may appear upon running `sat` commands.

```text
WARNING: Ignoring unknown section 'redfish' in config file.
```

Remove the `[redfish]` section from `/root/.config/sat/sat.toml` to resolve the warning.

```toml
[redfish]
username = "admin"
password = "adminpass"
```

Repeat this process for any configuration file sections for which there are "unknown section" warnings.

### Update SAT Logging

As of SAT version 2.2, some command output that was previously printed to `stdout`
is now logged to `stderr`. These messages are logged at the `INFO` level. The
default logging threshold was changed from `WARNING` to `INFO` to accommodate
this logging change. Additionally, some messages previously logged at the `INFO`
are now logged at the `DEBUG` level.

These changes take effect automatically. However, if the default output threshold
has been manually set in `~/.config/sat/sat.toml`, it should be changed to ensure
that important output is shown in the terminal.

#### Update Configuration

(`ncn-m001#`) In the following example, the `stderr` log level, `logging.stderr_level`, is set to
`WARNING`, which will exclude `INFO`-level logging from terminal output.

```bash
grep -A 3 logging ~/.config/sat/sat.toml
```

Example output:

```text
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

- SAT authentication has been set up during installation. See [Authenticate SAT Commands](install.md#authenticate-sat-commands).
- S3 credentials have been generated during installation. See [Generate SAT S3 Credentials](install.md#generate-sat-s3-credentials).

#### Notes on the Procedure

This procedure is **not required** if SAT was upgraded from 2.1 (Shasta v1.5)
or later. It **is required** if SAT was upgraded from 2.0 (Shasta v1.4) or
earlier.

#### Procedure

1. Set System Revision Information.

   (`ncn-m001#`) Run `sat setrev` and follow the prompts to set the following site-specific values:

   - Serial number
   - System name
   - System type
   - System description
   - Product number
   - Company name
   - Site name
   - Country code
   - System install date

   **Tip**: For "System type", a system with *any* liquid-cooled components should be
   considered a liquid-cooled system. In other words, "System type" is EX-1C.

   ```bash
   sat setrev
   ```

   Example output:

   ```text
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

   (`ncn-m001#`) Run `sat showrev` and verify the output shown in the "System Revision Information table."

   The following example shows sample table output.

   ```bash
   sat showrev
   ```

   Example output:

   ```text
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
