# SAT Installation

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

## Post-Installation Procedures

After installing SAT with IUF, complete the following SAT configuration
procedures before using SAT:

- [Authenticate SAT Commands](#authenticate-sat-commands)
- [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
- [(Optional) Configure Multi-tenancy](#optional-configure-multi-tenancy)
- [Set System Revision Information](#set-system-revision-information)

### Notes on the Procedures

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `x.y.z` with the version of the SAT product stream
  being installed.
- 'manager' and 'master' are used interchangeably in the steps below.

### Authenticate SAT Commands

To run SAT commands on the manager NCNs, first set up authentication
to the API gateway. For more information on authentication types and
authentication credentials, see [SAT Command
Authentication](about_sat/command_authentication.md).

The admin account used to authenticate with `sat auth` must be enabled in
Keycloak and must have its *assigned role* set to *admin*. For more information
on Keycloak accounts and changing *Role Mappings*, refer to both *Configure Keycloak
Account* and *Create Internal User Accounts in the Keycloak Shasta Realm* in
the [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).

#### Prerequisites

- The `sat` CLI has been installed following the [IUF
  section](https://cray-hpe.github.io/docs-csm/en-14/operations/iuf/iuf/) of the
  [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).

#### Procedure

The following is the procedure to globally configure the username used by SAT and
authenticate to the API gateway.

1. (`ncn-m001#`) Generate a default SAT configuration file if one does not exist.

   ```bash
   sat init
   ```

   Example output:

   ```text
   Configuration file "/root/.config/sat/sat.toml" generated.
   ```

   **Note:** If the configuration file already exists, it will print out the
   following error.

   ```text
   ERROR: Configuration file "/root/.config/sat/sat.toml" already exists.
   Not generating configuration file.
   ```

1. Edit `~/.config/sat/sat.toml` and set the username option in the `api_gateway`
   section of the configuration file.

   ```toml
   username = "crayadmin"
   ```

1. (`ncn-m001#`) Run `sat auth`. Enter the password when prompted.

   ```bash
   sat auth
   ```

   Example output:

   ```text
   Password for crayadmin:
   Succeeded!
   ```

1. (`ncn-m001#`) Other `sat` commands are now authenticated to make requests to the API gateway.

   ```bash
   sat status
   ```

### Generate SAT S3 Credentials

Generate S3 credentials and write them to a local file so the SAT user can access
S3 storage. In order to use the SAT S3 bucket, the System Administrator must
generate the S3 access key and secret keys and write them to a local file. This
must be done on every Kubernetes control plane node where SAT commands are run.

SAT uses S3 storage for several purposes, most importantly to store the
site-specific information set with `sat setrev` (see [Set System Revision
Information](#set-system-revision-information)).

#### Prerequisites

- The SAT CLI has been installed following the [IUF
  section](https://cray-hpe.github.io/docs-csm/en-14/operations/iuf/iuf/) of the
  [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).
- The SAT configuration file has been created (See [Authenticate SAT
  Commands](#authenticate-sat-commands)).
- CSM has been installed and verified.

#### Procedure

1. (`ncn-m001#`) Ensure the files are readable only by `root`.

    ```bash
    touch /root/.config/sat/s3_access_key \
        /root/.config/sat/s3_secret_key
    ```

    ```bash
    chmod 600 /root/.config/sat/s3_access_key \
        /root/.config/sat/s3_secret_key
    ```

1. (`ncn-m001#`) Write the credentials to local files using `kubectl`.

   ```bash
   kubectl get secret sat-s3-credentials -o json -o \
       jsonpath='{.data.access_key}' | base64 -d > \
       /root/.config/sat/s3_access_key
   ```

   ```bash
   kubectl get secret sat-s3-credentials -o json -o \
       jsonpath='{.data.secret_key}' | base64 -d > \
       /root/.config/sat/s3_secret_key
   ```

1. Verify the S3 endpoint specified in the SAT configuration file is correct.

   1. (`ncn-m001#`) Get the SAT configuration file's endpoint value.

      **Note:** If the command's output is commented out, indicated by an initial `#`
      character, the SAT configuration will take the default value – `"https://rgw-vip.nmn"`.

      ```bash
      grep endpoint ~/.config/sat/sat.toml
      ```

      Example output:

      ```text
      # endpoint = "https://rgw-vip.nmn"
      ```

   1. (`ncn-m001#`) Get the `sat-s3-credentials` secret's endpoint value.

      ```bash
      kubectl get secret sat-s3-credentials -o json -o \
          jsonpath='{.data.s3_endpoint}' | base64 -d | xargs
      ```

      Example output:

      ```text
      https://rgw-vip.nmn
      ```

   1. Compare the two endpoint values.

      If the values differ, change the SAT configuration file's endpoint value to
      match the secret's.

1. (`ncn-m001#`) Copy SAT configurations to each manager node on the system.

   ```bash
   for i in ncn-m002 ncn-m003; do echo $i; ssh ${i} \
       mkdir -p /root/.config/sat; \
       scp -pr /root/.config/sat ${i}:/root/.config; done
   ```

   **Note:** Depending on how many manager nodes are on the system, the list of
   manager nodes may be different. This example assumes three manager nodes, where
   the configuration files must be copied from `ncn-m001` to `ncn-m002` and
   `ncn-m003`. Therefore, the list of hosts above is `ncn-m002` and `ncn-m003`.

### (Optional) Configure Multi-tenancy

If installing SAT on a multi-tenant system, the tenant name can be configured
at this point. For more information, see [Configure multi-tenancy](usage/multi-tenancy.md).

### Set System Revision Information

HPE service representatives use system revision information data to identify
systems in support cases.

#### Prerequisites

- SAT authentication has been set up. See [Authenticate SAT Commands](#authenticate-sat-commands).
- S3 credentials have been generated. See [Generate SAT S3 Credentials](#generate-sat-s3-credentials).

#### Procedure

1. (`ncn-m001#`) Set System Revision Information.

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

   ```bash
   sat showrev
   ```

   Example table output:

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
