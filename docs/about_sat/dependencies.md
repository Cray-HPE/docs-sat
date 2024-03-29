# SAT Dependencies

Most `sat` subcommands depend on services or components from other products in the
HPE Cray EX software stack. The following list shows these dependencies for each
subcommand. Each service or component is listed under the product it belongs to.

## `sat auth`

### CSM

- Keycloak

## `sat bmccreds`

### CSM

- System Configuration Service (SCSD)

## `sat bootprep`

### CSM

- Boot Orchestration Service (BOS)
- Configuration Framework Service (CFS)
- Image Management Service (IMS)
- Version Control Service (VCS)
- Kubernetes
- S3

## `sat bootsys`

### CSM

- Boot Orchestration Service (BOS)
- Cray Advanced Platform Monitoring and Control (CAPMC)
- Ceph
- Etcd
- Firmware Action Service (FAS)
- Hardware State Manager (HSM)
- Kubernetes
- S3

### HPE Cray Supercomputing User Services Software (USS)

- Node Memory Dump (NMD)

## `sat diag`

### CSM

- Hardware State Manager (HSM)

### CSM-Diags

- Fox

## `sat firmware`

### CSM

- Firmware Action Service (FAS)

## `sat hwhist`

### CSM

- Hardware State Manager (HSM)

## `sat hwinv`

### CSM

- Hardware State Manager (HSM)

## `sat hwmatch`

### CSM

- Hardware State Manager (HSM)

## `sat init`

None

## `sat jobstat`

### PBS

- HPE State Checker

## `sat k8s`

### CSM

- Kubernetes

## `sat nid2xname`

### CSM

- Hardware State Manager (HSM)

## `sat sensors`

### CSM

- Hardware State Manager (HSM)
- HM Collector

### SMA

- Telemetry API

## `sat setrev`

### CSM

- S3

## `sat showrev`

### CSM

- Hardware State Manager (HSM)
- Kubernetes
- S3

## `sat slscheck`

### CSM

- Hardware State Manager (HSM)
- System Layout Service (SLS)

## `sat status`

### CSM

- Boot Orchestration Service (BOS)
- Configuration Framework Service (CFS)
- Hardware State Manager (HSM)
- Image Management Service (IMS)
- System Layout Service (SLS)

## `sat swap`

### Slingshot

- Fabric Manager

## `sat switch`

*Deprecated*: See `sat swap`

## `sat xname2nid`

### CSM

- Hardware State Manager (HSM)
