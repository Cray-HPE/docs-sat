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
| `sat bootprep`  | **CSM**                                                 |
|                 |                                                         |
|                 | * Boot Orchestration Service (BOS)                      |
|                 | * Configuration Framework Service (CFS)                 |
|                 | * Image Management Service (IMS)                        |
|                 | * Version Control Service (VCS)                         |
|                 | * Kubernetes                                            |
|                 | * S3                                                    |
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
