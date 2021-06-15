## Run sat setrev to Set System Information

**Prerequisites**

- S3 credentials have been generated. See [Generate SAT S3 Credentials](#generate-sat-s3-credentials)
- SAT authentication has been set up. See [SAT Authentication](#sat-authentication).

**Procedure**

1.  Run sat setrev to set System Revision Information. Follow the on-screen prompts.

    ```screen
    ncn-m001# sat setrev
    --------------------------------------------------------------------------------
    Setting:        Serial number
    Purpose:        System identification. This will affect how snapshots are
                    identified in the HPE backend services.
    Description:    This is the top-level serial number which uniquely identifies
                    the system. It can be requested from an HPE representative.
    Valid values:   Alpha-numeric string, 4 - 20 characters.
    Type:           <class 'str'>
    Default:        None
    Current value:  None
    --------------------------------------------------------------------------------
    Please do one of the following to set the value of the above setting:
      - Input a new value
      - Press CTRL-C to exit
    ...
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
    | Company name        | HPE           |
    | Country code        | US            |
    | Interconnect        | Sling         |
    | Product number      | R4K98A        |
    | Serial number       | 12345         |
    | Site name           | HPE           |
    | Slurm version       | slurm 20.02.5 |
    | System description  | Test System   |
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
