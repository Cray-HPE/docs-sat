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

## Perform NCN Personalization

Describes how to perform NCN personalization using CFS. This personalization process
will configure the System Admin Toolkit (SAT) product stream.

### Prerequisites

- The [Install the System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
  procedure has been successfully completed.
- The names of the CFS configurations created or updated during installation
  were recorded.

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

1. Start a typescript if not already using one.

    The typescript will capture the commands and the output from this installation procedure.

    ```screen
    ncn-m001# script -af product-sat.$(date +%Y-%m-%d).txt
    ncn-m001# export PS1='\u@\H \D{%Y-%m-%d} \t \w # '
    ```

1. Invoke each CFS configuration that was created or updated during installation.

    The CFS configurations that were created or updated during installation are
    noted in the log output from `install.sh` and should have been recorded during
    the installation process. The subsequent instructions assume that the CFS
    configuration names were saved in the file `/tmp/sat-ncn-cfs-configurations.txt`
    during the installation process.

    This step will create a CFS session for each given configuration and install
    SAT on the associated manager NCNs.

    The `--configuration-limit` option causes only the `sat-ncn` layer of the configuration,
    `ncn-personalization`, to run.

    You should see a representation of the CFS session in the output.

    ```screen
    ncn-m001# for cfs_configuration in $(cat /tmp/sat-ncn-cfs-configurations.txt);
    do cray cfs sessions create --name "sat-session-${cfs_configuration}" --configuration-name \
        "${cfs_configuration}" --configuration-limit sat-ncn;
    done

    name="sat-session-ncn-personalization"

    [ansible]
    ...
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

1. Verify that SAT was successfully configured.

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

1. Stop the typescript.

    ```screen
    ncn-m001# exit
    ```

SAT version `2.2.x` is now configured:

- The SAT RPM package is installed on the associated NCNs.

### Next Steps

If other HPE Cray EX software products are being installed or upgraded in conjunction
with SAT, refer to the [*HPE Cray EX System Software Getting Started Guide*](https://www.hpe.com/support/ex-gsg)
to determine which step to execute next.

If no other HPE Cray EX software products are being installed or upgraded at this time,
proceed to the remaining **SAT Setup** or **SAT Post-Upgrade** procedures.

If performing a fresh install, execute the **SAT Setup** procedures:

- [SAT Authentication](#sat-authentication)
- [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
- [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)

If performing an upgrade, execute the **SAT Post-Upgrade** procedures:

- [SAT Post-Upgrade](#sat-post-upgrade)
