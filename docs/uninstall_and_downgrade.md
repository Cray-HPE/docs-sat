# SAT Uninstall and Downgrade

## Uninstall: Remove a Version of SAT

This procedure can be used to uninstall a version of SAT.

### Prerequisites

- Only versions 2.2 or newer of SAT can be uninstalled with `prodmgr`. Older versions must be uninstalled manually.
- CSM version 1.2 or newer must be installed, so that the `prodmgr` command is available.

### Procedure

1. Use `sat showrev` to list versions of SAT.

   ```screen
   ncn-m001# sat showrev --products --filter product_name=sat
   ###############################################################################
   Product Revision Information
   ###############################################################################
   +--------------+-----------------+-------------------+-----------------------+
   | product_name | product_version | images            | image_recipes         |
   +--------------+-----------------+-------------------+-----------------------+
   | sat          | 2.3.3           | -                 | -                     |
   | sat          | 2.2.10          | -                 | -                     |
   +--------------+-----------------+-------------------+-----------------------+
   ```

1. Use `prodmgr` to uninstall a version of SAT.

   This command will do three things:

   - Remove all hosted-type package repositories associated with the given version of SAT. Group-type
     repositories are not removed.
   - Remove all container images associated with the given version of SAT.
   - Remove SAT from the `cray-product-catalog` Kubernetes ConfigMap, so that it will no longer show up
     in the output of `sat showrev`.

   ```screen
   ncn-m001# prodmgr uninstall sat 2.2.10
   Repository sat-2.2.10-sle-15sp2 has been removed.
   Removed Docker image cray/cray-sat:3.9.0
   Removed Docker image cray/sat-cfs-install:1.0.2
   Removed Docker image cray/sat-install-utility:1.4.0
   Deleted sat-2.2.10 from product catalog.
   ```

## Downgrade: Switch Between SAT Versions

This procedure can be used to downgrade the active version of SAT.

### Prerequisites

- Only versions 2.2 or newer of SAT can be switched. Older versions must be switched manually.
- CSM version 1.2 or newer must be installed, so that the `prodmgr` command is available.

### Procedure

1. Use `sat showrev` to list versions of SAT.

   ```screen
   ncn-m001# sat showrev --products --filter product_name=sat
   ###############################################################################
   Product Revision Information
   ###############################################################################
   +--------------+-----------------+--------------------+-----------------------+
   | product_name | product_version | images             | image_recipes         |
   +--------------+-----------------+--------------------+-----------------------+
   | sat          | 2.3.3           | -                  | -                     |
   | sat          | 2.2.10          | -                  | -                     |
   +--------------+-----------------+--------------------+-----------------------+
   ```

1. Use `prodmgr` to switch to a different version of SAT.

   This command will do two things:

   - For all hosted-type package repositories associated with this version of SAT, set them as the sole member
     of their corresponding group-type repository. For example, switching to SAT version `2.2.10`
     sets the repository `sat-2.2.10-sle-15sp2` as the only member of the `sat-sle-15sp2` group.
   - Ensure that the SAT CFS configuration content exists as a layer in all CFS configurations that are
     associated with NCNs with the role "Management" and subrole "Master" (for example, the CFS configuration
     `management-23.4.0`). Specifically, it will ensure that the layer refers to the version of SAT CFS
     configuration content associated with the version of SAT to which you are switching.

   ```screen
   ncn-m001# prodmgr activate sat 2.5.15
   Repository sat-2.5.15-sle-15sp4 is now the default in sat-sle-15sp4.
   Updated CFS configurations: [management-23.4.0]
   ```

1. Apply the modified CFS configuration to the management NCNs.

   At this point, Nexus package repositories have been modified to set a
   particular package repository as active, but the SAT package may not have
   been updated on management NCNs.

   To ensure that management NCNs have been updated to use the active SAT
   version, follow the [Procedure to Apply CFS Configuration](#procedure-to-apply-cfs-configuration).

### Procedure to Apply CFS Configuration

1. Set an environment variable that refers to the name of the CFS configuration
   to be applied to the management NCNs.

   ```screen
   ncn-m001# export CFS_CONFIG_NAME="management-23.4.0"
   ```

   **Note:** Refer to the output from the `prodmgr activate` command to find
   the name of the modified CFS configuration. If more than one CFS configuration
   was modified, use the first one.

   ```screen
   INFO: Successfully saved CFS configuration "management-23.4.0"
   ```

1. Obtain the name of the CFS configuration layer for SAT and save it in an
   environment variable:

   ```screen
   ncn-m001# export SAT_LAYER_NAME=$(cray cfs configurations describe $CFS_CONFIG_NAME --format json \
       | jq -r '.layers | map(select(.cloneUrl | contains("sat-config-management.git")))[0].name')
   ```

1. Create a CFS session that executes only the SAT layer of the given CFS
   configuration.

   The `--configuration-limit` option limits the configuration session to run
   only the SAT layer of the configuration.

   ```screen
   ncn-m001# cray cfs sessions create --name "sat-session-${CFS_CONFIG_NAME}" --configuration-name \
       "${CFS_CONFIG_NAME}" --configuration-limit "${SAT_LAYER_NAME}"
   ```

1. Monitor the progress of the CFS session.

   Set an environment variable to name of the Ansible container within the pod
   for the CFS session:

   ```screen
   ncn-m001# export ANSIBLE_CONTAINER=$(kubectl get pod -n services \
       --selector=cfsession=sat-session-${CFS_CONFIG_NAME} -o json \
       -o json | jq -r '.items[0].spec.containers | map(select(.name | contains("ansible"))) | .[0].name')
   ```

   Next, get the logs for the Ansible container.

   ```screen
   ncn-m001# kubectl logs -c $ANSIBLE_CONTAINER --tail 100 -f -n services \
       --selector=cfsession=sat-session-${CFS_CONFIG_NAME}
   ```

   Ansible plays, which are run by the CFS session, will install SAT on all the
   master management NCNs on the system. A summary of results can be found at
   the end of the log output. The following example shows a successful session.

   ```screen
   ...
   PLAY RECAP *********************************************************************
   x3000c0s1b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   x3000c0s3b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   x3000c0s5b0n0              : ok=3    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
   ```

   **Note:** Ensure that the PLAY RECAPs for each session show successes for all
   manager NCNs before proceeding.

1. Verify that SAT was successfully configured.

   If `sat` is configured, the `--version` command will indicate which version
   is installed. If `sat` is not properly configured, the command will fail.

   **Note:** This version number will differ from the version number of the SAT
   release distribution. This is the semantic version of the `sat` Python package,
   which is different from the version number of the overall SAT release distribution.

   ```screen
   ncn-m001# sat --version
   sat 3.7.0
   ```

   **Note:** Upon first running `sat`, you may see additional output while the `sat`
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

1. Stop the typescript.

   ```screen
   ncn-m001# exit
   ```

SAT version `x.y.z` is now installed and configured:

- The SAT RPM package is installed on the associated NCNs.

#### Note on Procedure to Apply CFS Configuration

The previous procedure is not always necessary because the CFS Batcher service
automatically detects configuration changes and will automatically create new
sessions to apply configuration changes according to certain rules. For more
information on these rules, refer to **Configuration Management with
the CFS Batcher** in the [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).

The main scenario in which the CFS batcher will not automatically re-apply the
SAT layer is when the commit hash of the sat-config-management git repository
has not changed between SAT versions. The previous procedure ensures the
configuration is re-applied in all cases, and it is harmless if the batcher has
already applied an updated configuration.
