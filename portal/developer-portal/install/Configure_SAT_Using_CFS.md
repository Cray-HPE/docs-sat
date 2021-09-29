## Configure SAT Using CFS

Describes how to configure the System Admin Toolkit (SAT) product stream using CFS.

### Prerequisites

- SAT is installed.

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

1. Start a typescript.

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
    and the version number is `2.2.x`.

    ```screen
    ncn-m001# git ls-remote \
        https://crayvcs:$VCS_PASS@api-gw-service-nmn.local/vcs/cray/sat-config-management.git \
        refs/heads/cray/sat/*
    ...
    82537e59c24dd5607d5f5d6f92cdff971bd9c615 refs/heads/cray/sat/2.2.x
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

SAT version `2.2.x` is now configured:

- The SAT RPM package is installed on the associated NCNs.

### Next Steps

If other HPE Cray EX software products are being installed or upgraded in conjunction
with SAT, refer to the *HPE Cray EX System Software Getting Started Guide* to determine
which step to execute next.

If no other HPE Cray EX software products are being installed or upgraded at this time,
proceed to the remaining initial setup procedures.

**NOTE:** The setup procedures are **not** required when upgrading SAT.
