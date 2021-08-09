## Install the System Admin Toolkit Product Stream

Describes the steps needed to install the System Admin Toolkit (SAT) product stream.

### Prerequisites

- CSM is installed and verified.
- cray-product-catalog is running.
- There must be at least 2 gigabytes of free space on the manager NCN on which the procedure is run.

### Procedure

1. Start a typescript to capture the commands and output from this installation.

   ```screen
   ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
   ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
   ```

2. Copy the release distribution gzipped tar file to `ncn-m001`. In the examples below, replace
   `2.1.x` with the version of the SAT product stream being installed.

3. Unzip and extract the release distribution.

   ```screen
   ncn-m001# tar -xvzf sat-2.1.x.tar.gz
   ```

4. Change directory to the extracted release distribution directory.

   ```screen
   ncn-m001# cd sat-2.1.x
   ```

5. Run the installer, **install.sh**.

   The script results in a lot of output, and the last several lines are included
   below for reference. Omitted lines are indicated with an ellipsis (`...`) below.

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

   It is recommended to check the return code of the installer, which should be zero.

   ```screen
   ncn-m001# echo $?
   0
   ```

6. Ensure that the environment variable `SAT_TAG` is not being set in the `~/.bashrc` file
   on any of the management NCNs. **NOTE**: This step should only be required when updating from
   Shasta 1.4.1 or Shasta 1.4.2.

   The example below assumes three management NCNs (`ncn-m001`, `ncn-m002`, and `ncn-m003`) and shows output from
   a system in which no further action is needed.

   ```screen
   ncn-m001# pdsh -w ncn-m00[1-3] cat ~/.bashrc
   ncn-m001: source <(kubectl completion bash)
   ncn-m003: source <(kubectl completion bash)
   ncn-m002: source <(kubectl completion bash)
   ```

   In the following example, `SAT_TAG` is being set in `~/.bashrc` on `ncn-m002`. This line should be removed
   from the `~/.bashrc` file on `ncn-m002`.

   ```screen
   ncn-m001# pdsh -w ncn-m00[1-3] cat ~/.bashrc
   ncn-m001: source <(kubectl completion bash)
   ncn-m002: source <(kubectl completion bash)
   ncn-m002: export SAT_TAG=3.5.0
   ncn-m003: source <(kubectl completion bash)
   ```

7. Check the progress of the SAT configuration import Kubernetes job, which is initiated by `install.sh`.
   Replace `2.1.x` with the version of the SAT product being installed.

   Check the status of the job. If the "Pods Statuses" appear as "Succeeded", then the job has completed
   successfully. The job usually takes between 30 seconds and 2 minutes.

   ```screen
   ncn-m001# kubectl describe job sat-config-import-2.1.x -n services
   ...
   Pods Statuses:  0 Running / 1 Succeeded / 0 Failed
   ...
   ```

   If desired, monitor the progress of the job using `kubectl logs`. The example below includes the final
   log lines from a successful configuration import Kubernetes job.

   ```screen
   ncn-m001# kubectl logs -f -n services --selector job-name=sat-config-import-2.1.x --all-containers
   ...
   ConfigMap update attempt=1
   Resting 1s before reading ConfigMap
   ConfigMap data updates exist; Exiting.
   2021-08-04T21:50:10.275886Z  info    Agent has successfully terminated
   2021-08-04T21:50:10.276118Z  warning envoy main  caught SIGTERM
   # Completed on Wed Aug  4 21:49:44 2021
   ```

   The following error may appear in this log and can be ignored:

   ```bash
   error accept tcp [::]:15020: use of closed network connection
   ```

8. Once the SAT configuration import Kubernetes job completed, obtain the git commit ID for the
   branch matching the version of SAT being installed. This represents a revision of Ansible
   configuration content stored in VCS, and in this example is
   `82537e59c24dd5607d5f5d6f92cdff971bd9c615`.

   ```screen
   ncn-m001# VCS_PASS=$(kubectl get secret -n services vcs-user-credentials --template={{.data.vcs_password}} | base64 --decode)
   ```

   ```screen
   ncn-m001# git ls-remote https://crayvcs:$VCS_PASS@api-gw-service-nmn.local/vcs/cray/sat-config-management.git refs/heads/cray/sat/*
   82537e59c24dd5607d5f5d6f92cdff971bd9c615    refs/heads/cray/sat/2.1.x
   ```

9. Add a `sat` layer to the `ncn-personalization` CFS configuration. First, get the current ncn-personalization
   configuration layers and save this data to a local file:

   ```screen
   ncn-m001# cray cfs configurations describe ncn-personalization --format json | jq ". | {layers}" > ncn-personalization.json
   ```

   **NOTE**: If the `ncn-personalization` configuration does not yet exist, you may see the following error:

   ```screen
   Error: Configuration could not found.: Configuration ncn-personalization could not be found
   ```

   If this is the case, simply proceed by creating a new `ncn-personalization.json` file with just a single layer.

   For more on NCN personalization, please refer to "Managing Configuration with CFS" in the CSM product documentation.

10. Add a `sat` layer to the local file. **If COS is present, then COS must remain the first entry in the list.**
    Use the git commit ID from step 8, e.g. `82537e59c24dd5607d5f5d6f92cdff971bd9c615`. The `name` and `playbook`
    fields must also match the example below.

    ```screen
    ncn-m001# vim ncn-personalization.json
    ...
    ncn-m001# cat ncn-personalization.json
    {
      "layers": [
        {
          "cloneUrl": "https://api-gw-service-nmn.local/vcs/cray/cos-config-management.git",
          "commit": "b21074092b44a3f8ddb67ee2b021d9ee0f18bff9",
          "name": "cos-integration-2.0.27",
          "playbook": "ncn.yml"
        },
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

11. Update the `ncn-personalization` CFS configuration using the local file from the previous step.

    The command should output a JSON-formatted representation of the `ncn-personalization` CFS configuration,
    which will look like `ncn-personalization.json`, but with `lastUpdated` and `name` fields (output below
    is truncated for brevity).

    ```screen
    ncn-m001# cray cfs configurations update ncn-personalization --file ncn-personalization.json --format json
    {
      "lastUpdated": "2021-08-05T16:38:53Z",
      "layers": {
        ...
      },
      "name": "ncn-personalization"
    }
    ```

12. Optional: remove the local file from the previous step.

    ```screen
    ncn-m001# rm ncn-personalization.json
    ```

13. Use `cray cfs` to invoke the configuration, which will install SAT on the manager NCNs. This command uses the
    `--configuration-limit` option to only run the `sat-ncn` layer of `ncn-personalization`, so that it does not run
    any other product's configuration. This command will output a representation of the CFS session.

    ```screen
    ncn-m001# cray cfs sessions create --name sat-session --configuration-name ncn-personalization --configuration-limit sat-ncn
    name = "sat-session"

    [ansible]
    ...
    ```

14. Monitor the progress of the CFS configuration. First, list all containers associated with the CFS session:

    ```screen
    ncn-m001# kubectl get pod -n services --selector=cfsession=sat-session -o json | jq '.items[0].spec.containers[] | .name'
    "inventory"
    "ansible-1"
    "istio-proxy"
    ```

    Next, monitor logs for the `ansible-1` container. Note that the trailing digit may not be "1", it is the zero-based
    index of the `sat-ncn` layer within the `ncn-personalization` layers.

    ```screen
    ncn-m001# kubectl logs -c ansible-1 --tail 100 -f -n services --selector=cfsession=sat-session
    ```

    The CFS configuration session will run Ansible plays that install SAT on all the manager NCNs on the system.
    You should expect to find successful results for all of the manager NCN xnames at the end of the container
    log, for example:

    ```
    ...
    PLAY RECAP *********************************************************************
    x3000c0s1b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    x3000c0s3b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    x3000c0s5b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
    ```

15. Verify that SAT is successfully installed by running the following command to confirm the expected version.
    This version number will be different than the version number of the SAT release distribution. This is the
    semantic version of the `sat` Python package, which is different from the version number of the overall SAT
    release distribution.

    ```screen
    ncn-m001# sat --version
    sat 3.7.0
    ```

    **NOTE**: Upon first running `sat`, you may see additional output while the `sat` container image is downloaded:

    ```screen
    Trying to pull registry.local/cray/cray-sat:3.7.0-20210514024359_9fed037...
    Getting image source signatures
    Copying blob da64e8df3afc done
    Copying blob 0f36fd81d583 done
    Copying blob 12527cf455ba done
    ...
    sat 3.7.0
    ```

    This will occur the first time `sat` is run on each manager NCN. For example, if you run `sat` for the first
    time on `ncn-m001` and then for the first time on `ncn-m002`, you will see this additional output both times.

16. Optional: Remove the SAT release distribution tar file and extracted directory.

    ```screen
    ncn-m001# rm sat-2.1.x.tar.gz
    ncn-m001# rm -rf sat-2.1.x/
    ```

17. Finish the typescript file started at the beginning of this procedure.

    ```screen
    ncn-m001# exit
    ```

18. Complete installation by running the following procedures to set up SAT:
    - [SAT Authentication](#sat-authentication)
    - [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
    - [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)

#### Optional: Remove Old Versions After Upgrade

If upgrading from a previous version of SAT, The old version of the `cray/cray-sat` container image will still be
present in the registry on the system, although it will not be the default. If desired, the admin may remove the older
version of the `cray/cray-sat` container image. It is **not** removed by default.

The `cray-product-catalog` Kubernetes configuration map  will also show both versions of SAT that are installed. This
is viewed with the command `sat showrev --products` as shown in the following example.

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
