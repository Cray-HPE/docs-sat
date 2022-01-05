[//]: # ((C) Copyright 2021 Hewlett Packard Enterprise Development LP)

[//]: # (Permission is hereby granted, free of charge, to any person obtaining a)
[//]: # (copy of this software and associated documentation files (the "Software"),)
[//]: # (to deal in the Software without restriction, including without limitation)
[//]: # (the rights to use, copy, modify, merge, publish, distribute, sublicense,)
[//]: # (and/or sell copies of the Software, and to permit persons to whom the)
[//]: # (Software is furnished to do so, subject to the following conditions:)

[//]: # (The above copyright notice and this permission notice shall be included)
[//]: # (in all copies or substantial portions of the Software.)

[//]: # (THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR)
[//]: # (IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,)
[//]: # (FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL)
[//]: # (THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR)
[//]: # (OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,)
[//]: # (ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR)
[//]: # (OTHER DEALINGS IN THE SOFTWARE.)

This section contains two procedures:

- **Uninstall**: Remove a version of SAT.
- **Activate**: Switch between installed versions of SAT. Activate can be used to downgrade the version of SAT.

## Uninstall: Removing a Version of SAT

### Prerequisites

- Only versions 2.2 or newer of SAT can be uninstalled with `prodmgr`. Older versions must be uninstalled manually.
- CSM version 1.2 or newer must be installed, so that the `prodmgr` command is available.

### Procedure

1. Use `sat showrev` to list versions of SAT.

    **NOTE**: It is not recommended to uninstall a version designated as "active".
    If the active version is uninstalled, then the activate procedure must be executed
    on a remaining version.

    ```screen
    ncn-m001# sat showrev --products --filter product_name=sat
    ###############################################################################
    Product Revision Information
    ###############################################################################
    +--------------+-----------------+--------+-------------------+-----------------------+
    | product_name | product_version | active | images            | image_recipes         |
    +--------------+-----------------+--------+-------------------+-----------------------+
    | sat          | 2.3.3           | True   | -                 | -                     |
    | sat          | 2.2.10          | False  | -                 | -                     |
    +--------------+-----------------+--------+-------------------+-----------------------+
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

## Activate: Switching Between Versions

This procedure can be used to downgrade the active version of SAT.

### Prerequisites

- Only versions 2.2 or newer of SAT can be activated. Older versions must be activated manually.
- CSM version 1.2 or newer must be installed, so that the `prodmgr` command is available.

### Procedure

1. Use `sat showrev` to list versions of SAT.

    ```screen
    ncn-m001# sat showrev --products --filter product_name=sat
    ###############################################################################
    Product Revision Information
    ###############################################################################
    +--------------+-----------------+--------+--------------------+-----------------------+
    | product_name | product_version | active | images             | image_recipes         |
    +--------------+-----------------+--------+--------------------+-----------------------+
    | sat          | 2.3.3           | True   | -                  | -                     |
    | sat          | 2.2.10          | False  | -                  | -                     |
    +--------------+-----------------+--------+--------------------+-----------------------+
    ```

1. Use `prodmgr` to activate a different version of SAT.

    This command will do three things:
    - For all hosted-type package repositories associated with this version of SAT, set them as the sole member
      of their corresponding group-type repository. For example, activating SAT version `2.2.10`
      sets the repository `sat-2.2.10-sle-15sp2` as the only member of the `sat-sle-15sp2` group.
    - Set the version `2.2.10` as active within the product catalog, so that it appears active in the output of
      `sat showrev`.
    - Ensure that the SAT CFS configuration content exists as a layer in all CFS configurations that are
      associated with NCNs with the role "Management" and subrole "Master" (for example, the CFS configuration
      `ncn-personalization`). Specifically, it will ensure that the layer refers to the version of SAT CFS
      configuration content associated with the version of SAT being activated.

    ```screen
    ncn-m001# prodmgr activate sat 2.2.10
    Repository sat-2.2.10-sle-15sp2 is now the default in sat-sle-15sp2.
    Set sat-2.2.10 as active in product catalog.
    Updated CFS configurations: [ncn-personalization]
    ```

1. Verify that the chosen version is marked as active.

    ```screen
    ncn-m001# sat showrev --products --filter product_name=sat
    ###############################################################################
    Product Revision Information
    ###############################################################################
    +--------------+-----------------+--------+--------------------+-----------------------+
    | product_name | product_version | active | images             | image_recipes         |
    +--------------+-----------------+--------+--------------------+-----------------------+
    | sat          | 2.3.3           | False  | -                  | -                     |
    | sat          | 2.2.10          | True   | -                  | -                     |
    +--------------+-----------------+--------+--------------------+-----------------------+
    ```

1. Run NCN Personalization.

    At this point, the command has modified Nexus package repositories to set a particular package repository
    as active, but no packages on the NCNs have been changed. In order to complete the activation process,
    NCN Personalization must be executed to change the `cray-sat-podman` package version on the manager NCNs.

    **NOTE**: Refer to the command output from step 2 for the names of *all* CFS configurations that were updated,
    which may not necessarily be just `ncn-personalization`. If multiple configurations were updated in step 2, then
    a `cray cfs sessions create` command should be run for each of them. This example assumes a single configuration
    named `ncn-personalization` was updated. If multiple were updated, set `cfs_configurations` to a space-separated
    list below.

    ```screen
    ncn-m001# cfs_configurations="ncn-personalization"
    ncn-m001# for cfs_configuration in ${cfs_configurations}
    do cray cfs sessions create --name "sat-session-${cfs_configuration}" --configuration-name \
        "${cfs_configuration}" --configuration-limit sat-ncn;
    done
    ```

1. Monitor the progress of each CFS session.

    This step assumes a single session named `sat-session-ncn-personalization` was created in the previous step.

    First, list all containers associated with the CFS session:

    ```screen
    ncn-m001# kubectl get pod -n services --selector=cfsession=sat-session-ncn-personalization \
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
        --selector=cfsession=sat-session-ncn-personalization
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

1. Verify the new version of the SAT CLI.

    **NOTE:** This version number will differ from the version number of the SAT
    release distribution. This is the semantic version of the `sat` Python package,
    which is different from the version number of the overall SAT release distribution.

    ```screen
    ncn-m001# sat --version
    3.9.0
    ```
