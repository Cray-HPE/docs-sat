---
category: Cray Software Preview System Installation Guide numbered
---

# Install the System Admin Toolkit Product Stream Update

Describes the steps needed to install the System Admin Toolkit \(SAT\) product stream update for the 1.4.1 patch.

-   CSM is installed and verified.
-   cray-product-catalog is running.

-   **ROLE**
    -   System administrator
-   **OBJECTIVE**

    Update the SAT \(System Admin Toolkit\) product stream.


1.  Start a typescript to capture the commands and output from this installation update.

    ```screen
    ncn-m001# script -af product-sat.$\(date +%Y-%m-%d\).txt 
    ncn-m001# export PS1='\\u@\\H \\D\{%Y-%m-%d\} \\t \\w \# '
    ```

2.  Copy the release distribution gzipped tar file, e.g. sat-2.0.4.tar.gz, to ncn-m001.

3.  Unzip and extract the release distribution.

    ```screen
    ncn-m001# tar -xvzf sat-2.0.4.tar.gz
    ```

4.  Change directory to the extracted release distribution directory.

    ```screen
    ncn-m001# cd sat-2.0.4
    ```

5.  Run the installer, **install.sh**.

    ```screen
    ncn-m001# ./install.sh
    ```

6.  Export the environment variable SAT\_TAG to the value 3.5.0 to ensure that the sat and sat-man commands use the latest version of the cray/cray-sat container image.

    ```screen
    ncn-m001# export SAT\_TAG=3.5.0
    ```

    This should be added to the ~/.bashrc or ~/.bash\_profile file of each master node where sat commands are run.

    ```screen
    ncn-m001# pdsh -w ncn-m00\[1-3\] cat ~/.bashrc
    ncn-m001: source <(kubectl completion bash)
    ncn-m003: source <(kubectl completion bash)
    ncn-m002: source <(kubectl completion bash)
    ncn-m001 # pdsh -w ncn-m00[1-3] 'echo "export SAT_TAG=3.5.0" >> ~/.bashrc'
    ncn-m001 # pdsh -w ncn-m00[1-3] cat ~/.bashrc
    ncn-m001: source <(kubectl completion bash)
    ncn-m001: export SAT_TAG=3.5.0
    ncn-m003: source <(kubectl completion bash)
    ncn-m003: export SAT_TAG=3.5.0
    ncn-m002: source <(kubectl completion bash)
    ncn-m002: export SAT_TAG=3.5.0
    ```

    **Note:** If any of the master nodes reboot and perform a PXE boot, this change will be undone and will need to be reapplied on that node.

7.  Verify that SAT is successfully installed by running the following command to confirm the expected version.

    ```screen
    ncn-m001# sat --version
    sat 3.5.0
    ```

    **Note:** The first time a sat command is run with this new version set on a master NCN, it displays output indicating the container image is downloading.

    ```screen
    ncn-m001# sat --version
    Trying to pull registry.local/cray/cray-sat:3.5.0...
    Getting image source signatures
    Copying blob 62694d7552cc skipped: already exists
    Copying blob df20fa9351a1 skipped: already exists
    Copying blob 3ab6766f6281 skipped: already exists
    Copying blob e85fc7b6b56d done
    Copying blob a77f87103e92 done
    Copying blob ec64268fe629 done
    Copying blob 07e514e84853 done
    Copying blob 815a8c980572 done
    Copying blob b663030eddc2 done
    Copying blob 454709382513 done
    Copying blob 0784bc5c53fd done
    Copying blob 9271bf9dcea7 done
    Copying blob 8eecb6a00f44 done
    Copying blob ba5f1233ceee done
    Copying blob 0297d65b5e58 done
    Copying blob e1770111f399 done
    Copying blob ba5f1233ceee done
    Copying config 9355e546f4 done
    Writing manifest to image destination
    Storing signatures
    sat 3.5.0
    ```

8.  Finish the typescript file started at the beginning of this procedure.

    ```screen
    ncn-m001# exit
    ```


**Note:** If ONLY a SAT product stream update is occuring, no other steps in the *HPE Cray EX System Installation and Configuration Guide S-8000* need to be executed to install the 2.0.4 version of the SAT product stream in the v1.4.1 patch. Specifically, it is NOT necessary for the admin to configure SAT authentication, s3 credentials, and run sat setrev again. If they are configured again, it will cause no harm.

If CSM is also being updated, it is likely that the admin should also configure SAT authentication, s3 credentials, and run sat setrev.

**==OPTIONAL==**

The old version of the cray/cray-sat container image will still be present in the registry on the system, and if the environment variable SAT\_TAG is not set to 3.5.0, it will default to using the old version. If desired, the admin may remove the older version of the cray/cray-sat container image in the nexus registry. It is **not** removed by default.

The cray-product-catalog will also show both versions of sat that are installed. This is viewed with the command sat showrev --products as shown in the following example.

```screen
ncn-m001# sat showrev --products
###############################################################################
Product Revision Information
###############################################################################
+--------------+-----------------+--------------------+-----------------------+
| product_name | product_version | images             | image_recipes         |
+--------------+-----------------+--------------------+-----------------------+
...
| sat          | 2.0.3           | -                  | -                     |
| sat          | 2.0.4           | -                  | -                     |
...
+--------------+-----------------+--------------------+-----------------------+
```

**Parent topic:**[1.4.1 Patch Upgrade](1.4.1_Patch_Upgrade.md)

