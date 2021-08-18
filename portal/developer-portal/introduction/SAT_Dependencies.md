## SAT Dependencies

SAT has dependencies on other products for some of its functionality. The following table shows the dependencies that
each `sat` subcommand has on other products in the HPE Cray EX (Shasta) software stack. It shows the products as well
as the specific services or components of those products on which the given `sat` command depends.

+-----------------+---------------------------------------------------------+
| SAT Subcommand  | Product Dependencies                                    |
+=================+=========================================================+
| `sat auth`      | **CSM**                                                 |
|                 |                                                         |
|                 | * Keycloak                                              |
+-----------------+---------------------------------------------------------+
| `sat bmccreds`  | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
|                 | * System Configuration Service (SCSD)                   |
|                 |                                                         |
+-----------------+---------------------------------------------------------+
| `sat bootsys`   | **CSM**                                                 |
|                 |                                                         |
|                 | * Boot Orchestration Service (BOS)                      |
|                 | * Cray Advanced Platform Monitoring and Control (CAPMC) |
|                 | * Ceph                                                  |
|                 | * Compute Rolling Upgrade Service (CRUS)                |
|                 | * Etcd                                                  |
|                 | * Firmware Action Service (FAS)                         |
|                 | * Hardware State Manager (HSM)                          |
|                 | * Kubernetes                                            |
|                 | * S3                                                    |
|                 |                                                         |
|                 | **COS**                                                 |
|                 |                                                         |
|                 | * Node Memory Dump (NMD)                                |
+-----------------+---------------------------------------------------------+
| `sat diag`      | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
|                 |                                                         |
|                 | **CSM-Diag**                                            |
|                 |                                                         |
|                 | * Fox                                                   |
+-----------------+---------------------------------------------------------+
| `sat firmware`  | **CSM**                                                 |
|                 |                                                         |
|                 | * Firmware Action Service (FAS)                         |
+-----------------+---------------------------------------------------------+
| `sat hwinv`     | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
+-----------------+---------------------------------------------------------+
| `sat hwmatch`   | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
+-----------------+---------------------------------------------------------+
| `sat init`      | None                                                    |
+-----------------+---------------------------------------------------------+
| `sat k8s`       | **CSM**                                                 |
|                 |                                                         |
|                 | * Kubernetes                                            |
+-----------------+---------------------------------------------------------+
| `sat nid2xname` | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
+-----------------+---------------------------------------------------------+
| `sat sensors`   | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
|                 | * HM Collector                                          |
|                 |                                                         |
|                 | **SMA**                                                 |
|                 |                                                         |
|                 | * Telemetry API                                         |
+-----------------+---------------------------------------------------------+
| `sat setrev`    | **CSM**                                                 |
|                 |                                                         |
|                 | * S3                                                    |
+-----------------+---------------------------------------------------------+
| `sat showrev`   | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
|                 | * Kubernetes                                            |
|                 | * S3                                                    |
+-----------------+---------------------------------------------------------+
| `sat status`    | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
+-----------------+---------------------------------------------------------+
| `sat swap`      | **Slingshot**                                           |
|                 |                                                         |
|                 | * Fabric Manager                                        |
+-----------------+---------------------------------------------------------+
| `sat switch`    | **Deprecated**: See `sat swap`                          |
+-----------------+---------------------------------------------------------+
| `sat xname2nid` | **CSM**                                                 |
|                 |                                                         |
|                 | * Hardware State Manager (HSM)                          |
+-----------------+---------------------------------------------------------+
