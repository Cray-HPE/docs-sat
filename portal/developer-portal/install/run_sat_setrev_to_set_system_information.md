# Run sat setrev to Set System Information

## Prerequisites

- S3 credentials have been generated. See Generate SAT S3 Credentials.
- SAT authentication has been set up. See SAT Authentication.

## About this task

**ROLE**
- System Administrator

**OBJECTIVE**
- Use sat setrev to set system-wide information like site name, and serial number.

**LIMITATIONS**
- None

## Procedure

1.  Run sat setrev to set System Revision Information.

    ```screen
    ncn-m001# sat setrev
    Serial number : 12345
    Site name : HPE
    System name : eniac
    System install date (YYYY-mm-dd, empty for today) :
    System type : Shasta
    ```

2.  Run sat showrev to verify System Revision Information.
    The following tables contain example information.

    ```screen
    ncn-m001# sat showrev
    ################################################################################
    System Revision Information
    ################################################################################
    +---------------------+---------------+
    | component           | data          |
    +---------------------+---------------+
    | Interconnect        | Sling         |
    | Serial number       | 12345         |
    | Site name           | HPE           |
    | Slurm version       | slurm 20.02.5 |
    | System install date | 2021-01-29    |
    | System name         | eniac         |
    | System type         | Shasta        |
    +---------------------+---------------+
    ################################################################################
    Product Revision Information
    ################################################################################
    +--------------+-----------------+------------------------------+------------------------------+
    | product_name | product_version | images                       | image_recipes                |
    +--------------+-----------------+------------------------------+------------------------------+
    | csm          | 0.8.14          | cray-shasta-csm-sles15sp1... | cray-shasta-csm-sles15sp1... |
    | sat          | 2.0.1           | -                            | -                            |
    | sdu          | 1.0.8           | -                            | -                            |
    | slingshot    | 0.8.0           | -                            | -                            |
    | sma          | 1.4.12          | -                            | -                            |
    +--------------+-----------------+------------------------------+------------------------------+
    ################################################################################
    Local Host Operating System
    ################################################################################
    +-----------+----------------------+
    | component | version              |
    +-----------+----------------------+
    | Kernel    | 5.3.18-24.15-default |
    | SLES      | SLES 15-SP2          |
    +-----------+----------------------+
    ```
