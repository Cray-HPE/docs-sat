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

## Generate SAT S3 Credentials

Generate S3 credentials and write them to a local file so the SAT user can access S3 storage. In order to use the SAT
S3 bucket, the System Administrator must generate the S3 access key and secret keys and write them to a local file.
This must be done on every Kubernetes master node where SAT commands are run.

SAT uses S3 storage for several purposes, most importantly to store the site-specific information set with `sat setrev`
(see: [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)).

**NOTE:** This procedure is only required after initially installing SAT. It is not
required after upgrading SAT.

### Prerequisites

- The SAT CLI has been installed following [Install The System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
- The SAT configuration file has been created (See [SAT Authentication](#sat-authentication)).
- CSM has been installed and verified.

### Procedure

1. Ensure the files are readable only by `root`.

    ```screen
    ncn-m001# touch /root/.config/sat/s3_access_key \
        /root/.config/sat/s3_secret_key
    ```

    ```screen
    ncn-m001# chmod 600 /root/.config/sat/s3_access_key \
        /root/.config/sat/s3_secret_key
    ```

2. Write the credentials to local files using `kubectl`.

    ```screen
    ncn-m001# kubectl get secret sat-s3-credentials -o json -o \
        jsonpath='{.data.access_key}' | base64 -d > \
        /root/.config/sat/s3_access_key
    ```

    ```screen
    ncn-m001# kubectl get secret sat-s3-credentials -o json -o \
        jsonpath='{.data.secret_key}' | base64 -d > \
        /root/.config/sat/s3_secret_key
    ```

3. Verify the S3 endpoint specified in the SAT configuration file is correct.

    1. Get the SAT configuration file's endpoint value.

        **NOTE:** If the command's output is commented out, indicated by an initial #
        character, the SAT configuration will take the default value – `"https://rgw-vip.nmn"`.

        ```screen
        ncn-m001# grep endpoint ~/.config/sat/sat.toml
        # endpoint = "https://rgw-vip.nmn"
        ```

    2. Get the `sat-s3-credentials` secret's endpoint value.

        ```screen
        ncn-m001# kubectl get secret sat-s3-credentials -o json -o \
            jsonpath='{.data.s3_endpoint}' | base64 -d | xargs
        https://rgw-vip.nmn
        ```

    3. Compare the two endpoint values.

        If the values differ, change the SAT configuration file's endpoint value to match the secret's.

4. Copy SAT configurations to each manager node on the system.

    ```screen
    ncn-m001# for i in ncn-m002 ncn-m003; do echo $i; ssh ${i} \
        mkdir -p /root/.config/sat; \
        scp -pr /root/.config/sat ${i}:/root/.config; done
    ```

    **NOTE**: Depending on how many manager nodes are on the system, the list of manager nodes may
    be different. This example assumes three manager nodes, where the configuration files must be
    copied from ncn-m001 to ncn-m002 and ncn-m003. Therefore, the list of hosts above is ncn-m002
    and ncn-m003.
