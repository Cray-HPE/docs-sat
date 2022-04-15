[//]: # ((C) Copyright 2021-2022 Hewlett Packard Enterprise Development LP)

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

## Run sat setrev to Set System Information

**NOTE:** This procedure is only required after initially installing SAT. It is not
required after upgrading SAT.

### Prerequisites

- S3 credentials have been generated. See [Generate SAT S3 Credentials](#generate-sat-s3-credentials).
- SAT authentication has been set up. See [SAT Authentication](#sat-authentication).

### Procedure

1. Run `sat setrev` to set System Revision Information. Follow the on-screen prompts to set
   the following site-specific values:

   - Serial number
   - System name
   - System type
   - System description
   - Product number
   - Company name
   - Site name
   - Country code
   - System install date

    **TIP**: For "System type", a system with _any_ liquid-cooled components should be
    considered a liquid-cooled system. I.e., "System type" is EX-1C.

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

1. Run `sat showrev` to verify System Revision Information. The following tables contain example information.

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
