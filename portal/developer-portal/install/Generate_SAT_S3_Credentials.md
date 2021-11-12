## Generate SAT S3 Credentials

Generate S3 credentials and write them to a local file so the SAT user can access S3 storage. In order to use the SAT
S3 bucket, the System Administrator must generate the S3 access key and secret keys and write them to a local file.
This must be done on every Kubernetes master node where SAT commands are run.

SAT uses S3 storage for several purposes, most importantly to store the site-specific information set with `sat setrev`
(see: [Run Sat Setrev to Set System Information](#run-sat-setrev-to-set-system-information)).

**NOTE:** This procedure is only required after initially installing SAT. It is not
required after upgrading SAT.

### Prerequisites

- The `sat` CLI has been installed following [Install The System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream).
- The `sat` configuration file has been created (See [SAT Authentication](#sat-authentication)).
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

    1. Get the SAT configuration file's endpoint valie.

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

        If the values differ, modify the SAT configuration file's endpoint value to match the secret's.

4. Copy SAT configurations to every manager node on the system.

    ```screen
    ncn-m001# for i in ncn-m002 ncn-m003; do echo $i; ssh ${i} \
        mkdir -p /root/.config/sat; \
        scp -pr /root/.config/sat ${i}:/root/.config; done
    ```

    **NOTE**: Depending on how many manager nodes are on the system, the list of manager nodes may
    be different. This example assumes three manager nodes, where the configuration files must be
    copied from ncn-m001 to ncn-m002 and ncn-m003. Therefore, the list of hosts above is ncn-m002
    and ncn-m003.
