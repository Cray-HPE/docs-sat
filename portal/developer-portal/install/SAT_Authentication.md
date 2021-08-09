## SAT Authentication

Initially, as part of the installation and configuration, SAT authentication is set up so sat commands can be used in
later steps of the install process. The admin account used to authenticate with `sat auth` must be enabled in
Keycloak and must have its *assigned role* set to *admin*. For instructions on editing *Role Mappings* see
_Create Internal User Accounts in the Keycloak Shasta Realm_ in the CSM product documentation.
For additional information on SAT authentication, see _System Security and Authentication_ in the CSM
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
    ERROR: Configuration file "/root/.config/sat/sat.toml" already exists.  Not generating configuration file.
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
