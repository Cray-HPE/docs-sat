---
category: numbered
---

# SAT Authentication

Explains the authentication and credentials requires for SAT authentication.

**SAT Authentication**

Initially, as part of the installation and configuration, SAT authentication is set up so sat commands can be used in later steps of the install process. The account used to authenticate with sat auth must be enabled in keycloak and must have the "admin" role assigned in the "shasta" client role. For instructions on editing *Role Mappings* see section, [Create Internal User Accounts in the Keycloak Shasta Realm](Create_Internal_User_Accounts_in_the_Keycloak_Shasta_Realm.md) in the *HPE Cray EX System Administration Guide S-8001*. For additional information on SAT authentication, see section, [System Security and Authentication](System_Security_and_Authentication.md) in the *HPE Cray EX System Administration Guide S-8001*.

Some sat subcommands make requests to the Shasta services through the API gateway and thus require authentication to the API gateway in order to function. Other sat subcommands make requests directly to the Redfish endpoints in the system, and as a result, they require Redfish credentials. The table of SAT subcommands below details which subcommands require which type of credentials.

|SAT Subcommand|Authentication/Credentials Required|Man Page|Description|
|--------------|-----------------------------------|--------|-----------|
|**IMPORTANT:** Runsat auth first before running other commands. It is required for authentication.|
|sat auth|Responsible for authenticating to the API gateway and storing a token.|sat-auth|Authenticate to the API gateway and save the token.|
|sat bootsys|Requires authentication to the API gateway. Requires kubernetes configuration and authentication, which is automatically configured on ncn-w001 during the install. Some stages require passwordless SSH to be configured to all other NCNs. Requires S3 to be configured for some stages.|sat-bootsys|Boot or shutdown the system, including compute nodes, application nodes, and non-compute nodes \(NCNs\) running the management software.|
|sat diag|Requires Redfish credentials for all xnames being targeted.|sat-diag|Launch diagnostics on the HSN switches and generate a report.|
|sat firmware|Requires authentication to the API gateway.|sat-firmware|Report firmware version.|
|sat hwinv|Requires authentication to the API gateway.|sat-hwinv|Give a listing of the hardware of the HPE Cray EX system.|
|sat hwmatch|Requires authentication to the API gateway.|sat-hwmatch|Report hardware mismatches.|
|sat init|None|sat-init|Create a default SAT configuration file.|
|sat k8s|Requires kubernetes configuration and authentication, which is automatically configured on ncn-w001 during the install.|sat-k8s|Report on kubernetes replicasets that have co-located replicas \(i.e. replicas on the same node\).|
|sat linkhealth|Requires Redfish credentials for all switch controllers being queried. Requires API gateway authentication in order to query available switch controller redfish endpoints. If not authenticated to API gateway, it will still work with explicitly specified xnames.|sat-linkhealth|Report HSN link health.|
|sat nid2xname|Requires authentication to the API gateway.|sat-nid2xname|Translate node IDs to node xnames.|
|sat sensors|Requires Redfish credentials for all xnames being targeted. Requires API gateway authentication in order to query available redfish endpoints. If not authenticated to API gateway, it will still work with explicitly specified xnames.|sat-sensors|Report current sensor data.|
|sat setrev|Requires S3 to be configured for site information such as system name, serial number, install date, and site name.|sat-setrev|Set HPE Cray EX system revision information.|
|sat showrev|Requires API gateway authentication in order to query the Interconnect from HSM. Requires S3 to be configured for site information such as system name, serial number, install date, and site name.|sat-showrev|Print revision information for the HPE Cray EX system.|
|sat status|Requires authentication to the API gateway.|sat-status|Report node status across the HPE Cray EX system.|
|sat swap|Requires authentication to the API gateway.|sat-swap|Prepare HSN switch or cable for replacement and bring HSN switch or cable into service.|
|sat xname2nid|Requires authentication to the API gateway.|sat-xname2nid|Translate node and node BMC xnames to node IDs.|
|sat switch| | |**This command has been deprecated.** It has been replaced by sat swap.|

In order to authenticate to the API gateway, you must run the sat auth command. This command will prompt for a password on the command line. The username value is obtained from the following locations, in order of higher precedence to lower precedence:

-   The --username global command-line option.
-   The username option in the api\_gateway section of the config file at ~/.config/sat/sat.toml.
-   The name of currently logged in user running the sat command.

If credentials are entered correctly when prompted by sat auth, a token file will be obtained and saved to ~/.config/sat/tokens. Subsequent sat commands will determine the username the same way as sat auth described above, and will use the token for that username if it has been obtained and saved by sat auth.

The following is the procedure to globally configure the username used by SAT and authenticate to the API gateway:

1.  Generate a default SAT configuration file, if one does not exist.

    ```
    ncn-m001# sat init
    Configuration file "/root/.config/sat/sat.toml" generated.
    ```

    **Note:** If the config file already exists, it will print out an error:

    ```
    ERROR: Configuration file "/root/.config/sat/sat.toml" already exists.  Not generating configuration file.
    ```

2.  Edit ~/.config/sat/sat.toml and set the username option in the api\_gateway section of the config file. E.g.:

    ```
    username = "crayadmin"
    ```

3.  Run sat auth. Enter your password when prompted. E.g.:

    ```
    ncn-m001# sat auth
    Password for crayadmin:
    Succeeded!
    ```

4.  Other sat commands are now authenticated to make requests to the API gateway. E.g.:

    ```
    ncn-m001# sat status
    ```


-   **[Generate SAT S3 Credentials](Generate_SAT_S3_Credentials.md)**  
Describes how a System Administrator generates S3 credentials and writes them to a local file for the SAT user. This enables the user to run SAT subcommands that use S3 storage.

**Parent topic:**[System Admin Toolkit Command Overview](System_Admin_Toolkit_Command_Overview.md)

