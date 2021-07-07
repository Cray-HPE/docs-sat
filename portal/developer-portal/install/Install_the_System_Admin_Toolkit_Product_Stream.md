## Install the System Admin Toolkit Product Stream

Describes the steps needed to install the System Admin Toolkit (SAT) product stream.

### Prerequisites

- CSM is installed and verified.
- cray-product-catalog is running.

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

   ```screen
   ncn-m001# ./install.sh
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

7. Check the progress of the SAT configuration import Kubernetes job.

   First, check the status of the job:

   ```screen
   ncn-m001# kubectl describe job sat-config-import -n services
   ```

   Next, check the logs from the job:

   ```screen
   ncn-m001# kubectl logs -n services --selector job-name=sat-config-import --all-containers
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

    ```screen
      ncn-m001# cray cfs configurations update ncn-personalization --file ncn-personalization.json --format json
    ```

12. Optional: remove the local file from the previous step.

    ```screen
    ncn-m001# rm ncn-personalization.json
    ```

13. Use `cray cfs` to invoke the configuration, which will install SAT on the manager NCNs. This command uses the
    `--configuration-limit` option to only run the `sat-ncn` layer of `ncn-personalization`, so that it does not run
    any other product's configuration.

    ```screen
    ncn-m001# cray cfs sessions create --name sat-session --configuration-name ncn-personalization --configuration-limit sat-ncn
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

16. Finish the typescript file started at the beginning of this procedure.

    ```screen
    ncn-m001# exit
    ```

17. Complete installation by running the following procedures to set up SAT:
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
