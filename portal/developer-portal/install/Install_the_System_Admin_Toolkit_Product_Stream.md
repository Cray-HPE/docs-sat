## Install the System Admin Toolkit Product Stream

Describes the steps to install the System Admin Toolkit (SAT) product stream.

### Prerequisites

- CSM is installed and verified.
- cray-product-catalog is running.
- There must be at least 2 gigabytes of free space on the manager NCN on which the procedure is run.

### Notes on the Procedure

- Ellipses (`...`) in shell output indicate omitted lines.
- In the examples below, replace `2.1.x` with the version of the SAT product stream being installed.
- 'manager' and 'master' are used interchangeably in the steps below.

### Procedure

1. Start a typescript to capture the commands and output from this installation.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

2. Copy the release distribution gzipped tar file to `ncn-m001`.

3. Unzip and extract the release distribution.

    ```screen
    ncn-m001# tar -xvzf sat-2.1.x.tar.gz
    ```

4. Change directory to the extracted release distribution directory.

    ```screen
    ncn-m001# cd sat-2.1.x
    ```

5. Run the installer, **install.sh**.

    The script produces a lot of output. The last several lines are included
    below for reference.

    ```screen
    ncn-m001# ./install.sh
    ...
    ConfigMap data updates exist; Exiting.
    + clean-install-deps
    + for image in "${vendor_images[@]}"
    + podman rmi -f docker.io/library/cray-nexus-setup:sat-2.1.x-20210804163905-8dbb87d
    Untagged: docker.io/library/cray-nexus-setup:sat-2.1.x-20210804163905-8dbb87d
    Deleted: 2c196c0c6364d9a1699d83dc98550880dc491cc3433a015d35f6cab1987dd6da
    + for image in "${vendor_images[@]}"
    + podman rmi -f docker.io/library/skopeo:sat-2.1.x-20210804163905-8dbb87d
    Untagged: docker.io/library/skopeo:sat-2.1.x-20210804163905-8dbb87d
    Deleted: 1b38b7600f146503e246e753cd9df801e18409a176b3dbb07b0564e6bc27144c
    ```

    Check the return code of the installer. Zero indicates a successful installation.

    ```screen
    ncn-m001# echo $?
    0
    ```

6. Ensure that the environment variable `SAT_TAG` is not set in the `~/.bashrc` file
    on any of the management NCNs.

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

    The following example shows that `SAT_TAG` is set in `~/.bashrc` on `ncn-m002`. Remove that line
    from the `~/.bashrc` file on `ncn-m002`.

    ```screen
    ncn-m001# pdsh -w ncn-m00[1-3] cat ~/.bashrc
    ncn-m001: source <(kubectl completion bash)
    ncn-m002: source <(kubectl completion bash)
    ncn-m002: export SAT_TAG=3.5.0
    ncn-m003: source <(kubectl completion bash)
    ```

7. Check the progress of the SAT configuration import Kubernetes job, which is initiated by `install.sh`.

    If the "Pods Statuses" appear as "Succeeded", the job has completed
    successfully. The job usually takes between 30 seconds and 2 minutes.

    ```screen
    ncn-m001# kubectl describe job sat-config-import-2.1.x -n services
    ...
    Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
    ...
    ```

    The job's progress may be monitored using `kubectl logs`. The example below includes the final
    log lines from a successful configuration import Kubernetes job.

    ```screen
    ncn-m001# kubectl logs -f -n services --selector \
        job-name=sat-config-import-2.1.x --all-containers
    ...
    ConfigMap update attempt=1
    Resting 1s before reading ConfigMap
    ConfigMap data updates exist; Exiting.
    2021-08-04T21:50:10.275886Z  info    Agent has successfully terminated
    2021-08-04T21:50:10.276118Z  warning envoy main  caught SIGTERM
    # Completed on Wed Aug  4 21:49:44 2021
    ```

    The following error may appear in this log and can be ignored.

    ```screen
    error accept tcp [::]:15020: use of closed network connection
    ```

8. Obtain the git commit ID for the branch that matches the version of SAT being
    installed. This represents a revision of Ansible configuration content stored in VCS.

    In this example, the git commit ID is `82537e59c24dd5607d5f5d6f92cdff971bd9c615`.

    ```screen
    ncn-m001# VCS_PASS=$(kubectl get secret -n services vcs-user-credentials \
        --template={{.data.vcs_password}} | base64 --decode)
    ```

    ```screen
    ncn-m001# git ls-remote \
        https://crayvcs:$VCS_PASS@api-gw-service-nmn.local/vcs/cray/sat-config-management.git \
        refs/heads/cray/sat/*
    82537e59c24dd5607d5f5d6f92cdff971bd9c615 refs/heads/cray/sat/2.1.x
    ```

9. Add a `sat` layer to the CFS configuration(s) associated with the manager NCNs.
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

        Execute the following sub-steps (9.2 through 9.5) once for each unique CFS
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
        The `name` and `playbook` fields must also match the example below.

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

    5. Delete the JSON file.

        **NOTE:** This step is optional, but there is no reason to keep the file.
        If you keep it, verify that it is up-to-date with the actual CFS
        configuration before using it again.

        ```screen
        ncn-m001# rm ncn-personalization.json
        ```

10. Invoke the CFS configurations that you created or updated in the previous step.

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

11. Monitor the progress of each CFS session.

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

    ```
    ...
    PLAY RECAP *********************************************************************
    x3000c0s1b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    x3000c0s3b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    x3000c0s5b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

    Execute this step for each unique CFS configuration.

    **NOTE:** Ensure that the PLAY RECAPs for each session show successes for all
    manager NCNs before proceeding.

12. Verify that SAT is now installed.

    If `sat` is installed, the `--version` command will indicate which version
    is installed. If `sat` is not installed, the command will fail.

    **NOTE:** This version number will differ from the version number of the SAT
    release distribution. This is the semantic version of the `sat` Python package,
    which is different from the version number of the overall SAT release distribution.

    ```screen
    ncn-m001# sat --version
    sat 3.7.0
    ```

    **NOTE**: Upon first running `sat`, you may see additional output while the `sat`
    container image is downloaded:

    ```screen
    Trying to pull registry.local/cray/cray-sat:3.7.0-20210514024359_9fed037...
    Getting image source signatures
    Copying blob da64e8df3afc done
    Copying blob 0f36fd81d583 done
    Copying blob 12527cf455ba done
    ...
    sat 3.7.0
    ```

    This will occur the first time `sat` is run on each manager NCN. For example,
    if you run `sat` for the first time on `ncn-m001` and then for the first time
    on `ncn-m002`, you will see this additional output both times.

13. Optional: Remove the SAT release distribution tar file and extracted directory.

    ```screen
    ncn-m001# rm sat-2.1.x.tar.gz
    ncn-m001# rm -rf sat-2.1.x/
    ```

14. Finish the typescript file started at the beginning of this procedure.

    ```screen
    ncn-m001# exit
    ```

15. Complete the installation.

    Run the following procedures to set up SAT:
    - [SAT Authentication](#sat-authentication)
    - [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
    - [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)

#### Optional: Remove Old Versions After Upgrade

If upgrading from a previous version of SAT, the old version of the `cray/cray-sat`
container image will remain in the registry on the system, although it will not be
the default. The admin may remove the older version of the `cray/cray-sat` container
image. It is **not** removed by default.

The `cray-product-catalog` Kubernetes configuration map will also show all versions
of SAT that are installed. This is viewed with the command `sat showrev --products`
as shown in the following example.

```screen
ncn-m001# sat showrev --products
###############################################################################
Product Revision Information
###############################################################################
+--------------+-----------------+--------------------+-----------------------+
| product_name | product_version | images             | image_recipes         |
+--------------+-----------------+--------------------+-----------------------+
...
| sat          | 2.1.3           | -                  | -                     |
| sat          | 2.0.4           | -                  | -                     |
...
+--------------+-----------------+--------------------+-----------------------+
```
