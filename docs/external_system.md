# SAT on an External System

SAT can optionally be installed and configured on an external system to interact with CSM over the CAN.

## Limitations

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

## Install and Configure SAT

### Prerequisites

- The external system must be on the Customer Access Network (CAN).
- Python 3.7 or newer is installed on the system.
- `kubectl`, `openssh`, `git`, and `curl` are installed on the external system.
- The root CA certificates used when installing CSM have been added to the external system's trust store such that
  authenticated TLS connections can be made to the CSM REST API gateway. For more information, refer to **Certificate
  Authority** in the [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).

### Procedure

1. Create a Python virtual environment.

   ```screen
   $ SAT_VENV_PATH="$(pwd)/venv"
   $ python3 -m venv ${SAT_VENV_PATH}
   $ . ${SAT_VENV_PATH}/bin/activate
   ```

1. Clone the SAT source code.

   **Note:** To use SAT version 3.19, this example clones the `release/3.19` branch of
   `Cray-HPE/sat`. However, for better clarity, these instructions include steps that apply only to
   versions newer than 3.19. Specifically, the instructions include references to the
   `csm-api-client` package, which was not a dependency of SAT in version 3.19.

   ```screen
   (venv) $ git clone --branch=release/3.19 https://github.com/Cray-HPE/sat.git
   ```

1. Set up the SAT CSM Python dependencies to be installed from their source code.

   SAT CSM Python dependency packages are not currently distributed publicly as
   source packages or binary distributions. They must be installed from
   their source code hosted on GitHub. Also, to install the `cray-product-catalog`
   Python package, you must first clone it locally. Use the following steps to
   modify the SAT CSM Python dependencies so they can be installed from their source code.

   1. Clone the source code for `cray-product-catalog`.

      ```screen
      (venv) $ git clone --branch v1.6.0 https://github.com/Cray-HPE/cray-product-catalog
      ```

   1. In the `cray-product-catalog` directory, create a file named `.version`
      that contains the version of `cray-product-catalog`.

      ```screen
      (venv) $ echo 1.6.0 > cray-product-catalog/.version
      ```

   1. Open the "locked" requirements file in a text editor.

      ```screen
      (venv) $ vim sat/requirements.lock.txt
      ```

   1. Update the line containing `cray-product-catalog` so that it reflects the local path
      to `cray-product-catalog`.

      It should read as follows:

      ```screen
      ./cray-product-catalog
      ```

   1. For versions of SAT newer than 3.19, change the line containing `csm-api-client` to
      read as follows:

      ```screen
      csm-api-client@git+https://github.com/Cray-HPE/python-csm-api-client@release/1.1
      ```

   1. (Optional) Confirm that `requirements.lock.txt` is modified as expected.

      **Note:** For versions newer than 3.19, you will see both `cray-product-catalog` and `csm-api-client`.
      For version 3.19 and older, you will only see `cray-product-catalog`.

      ```screen
      (venv) $ grep -E 'cray-product-catalog|csm-api-client' sat/requirements.lock.txt
      ./cray-product-catalog
      csm-api-client@git+https://github.com/Cray-HPE/python-csm-api-client@release/1.1
      ```

1. Install the modified SAT dependencies.

   ```screen
   (venv) $ pip install -r sat/requirements.lock.txt
   ...
   ```

1. Install the SAT Python package.

   ```screen
   (venv) $ pip install ./sat
   ...
   ```

1. Optional: Add the `sat` virtual environment to the user's `PATH` environment variable.

   If a shell other than `bash` is in use, replace `~/.bash_profile` with the appropriate profile path.

   If the virtual environment is not added to the user's `PATH` environment variable, then
   `source ${SAT_VENV_PATH}/bin/activate` will need to be run before running any SAT commands.

   ```screen
   (venv) $ deactivate
   $ echo export PATH=\"${SAT_VENV_PATH}/bin:${PATH}\" >> ~/.bash_profile
   $ source ~/.bash_profile
   ```

1. Copy the file `/etc/kubernetes/admin.conf` from `ncn-m001` to `~/.kube/config` on the external system.

   Note that this file contains credentials to authenticate against the Kubernetes API as the administrative user, so
   it should be treated as sensitive.

   ```screen
   $ mkdir -p ~/.kube
   $ scp ncn-m001:/etc/kubernetes/admin.conf ~/.kube/config
   admin.conf                                       100% 5566   3.0MB/s   00:00
   ```

1. Add a new entry for the hostname `kubernetes` to the external system's `/etc/hosts` file.

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

1. Modify `~/.kube/config` to set the cluster server address.

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

1. Confirm that `kubectl` can access the CSM Kubernetes cluster.

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

1. Use `sat init` to create a configuration file for SAT.

   ```screen
   $ sat init
   INFO: Configuration file "/home/user/.config/sat/sat.toml" generated.
   ```

1. Copy the platform CA certificates from the management NCN and configure the certificates for use with SAT.

   If a shell other than `bash` is in use, replace `~/.bash_profile` with the appropriate profile path.

   ```screen
   $ scp ncn-m001:/etc/pki/trust/anchors/platform-ca-certs.crt .
   $ echo export REQUESTS_CA_BUNDLE=\"$(realpath platform-ca-certs.crt)\" >> ~/.bash_profile
   $ source ~/.bash_profile
   ```

1. Edit the SAT configuration file to set the API and S3 hostnames.

   Externally available API endpoints are given domain names in PowerDNS, so the endpoints in the configuration file
   should each be set to `subdomain.system-name.site-domain`, where `system-name` and `site-domain` are replaced with
   the values specified during `csi config init`, and `subdomain` is the DNS name for the externally available service.
   For more information, refer to **Externally Exposed Services** in the [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).

   The API gateway has the subdomain `api`, and S3 has the subdomain `s3`. The S3 endpoint runs on port 8080. The
   following options should be set in the SAT configuration file:

   ```toml
   [api_gateway]
   host = "api.system-name.site-domain"

   [s3]
   endpoint = "http://s3.system-name.site-domain:8080"
   ```

1. Edit the SAT configuration file to specify the Keycloak user which will be accessing the REST API.

   ```toml
   [api_gateway]
   username = "user"
   ```

## SAT Authentication

Initially, as part of the installation and configuration, SAT authentication is set up so SAT commands can be used in
later steps of the install process. The admin account used to authenticate with `sat auth` must be enabled in
Keycloak and must have its *assigned role* set to *admin*. For instructions on editing *Role Mappings* see
*Create Internal User Accounts in the Keycloak Shasta Realm* in the CSM product documentation.
For additional information on SAT authentication, see *System Security and Authentication* in the CSM
documentation.

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
|`sat jobstat`|Requires authentication to the API gateway.|`sat-jobstat`|Check the status of jobs and applications.|
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

- The `sat` CLI has been installed following [Install and Configure SAT](#install-and-configure-sat).

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

1. Edit `~/.config/sat/sat.toml` and set the username option in the `api_gateway` section of the config file. For
   example:

   ```screen
   username = "crayadmin"
   ```

1. Run `sat auth`. Enter your password when prompted. For example:

   ```screen
   ncn-m001# sat auth
   Password for crayadmin:
   Succeeded!
   ```

1. Other `sat` commands are now authenticated to make requests to the API gateway. For example:

   ```screen
   ncn-m001# sat status
   ```

## Generate SAT S3 Credentials

Generate S3 credentials and write them to a local file so the SAT user can access S3 storage. In order to use the SAT
S3 bucket, the System Administrator must generate the S3 access key and secret keys and write them to a local file.
This must be done on every Kubernetes master node where SAT commands are run.

SAT uses S3 storage for several purposes, most importantly to store the site-specific information set with `sat setrev`
(see: [Set System Revision Information](install.md#set-system-revision-information)).

### Prerequisites

- The SAT CLI has been installed following [Install and Configure SAT](#install-and-configure-sat).
- The SAT configuration file has been created following [SAT Authentication](#sat-authentication)).
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

      **Note:** If the command's output is commented out, indicated by an initial `#`
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

   **Note:** Depending on how many manager nodes are on the system, the list of manager nodes may
   be different. This example assumes three manager nodes, where the configuration files must be
   copied from `ncn-m001` to `ncn-m002` and `ncn-m003`. Therefore, the list of hosts above is
   `ncn-m002` and `ncn-m003`.
