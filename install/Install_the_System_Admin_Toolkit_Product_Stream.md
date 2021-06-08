---
category: Cray Software Preview System Installation Guide numbered
---

# Install the System Admin Toolkit Product Stream

Describes the steps needed to install the System Admin Toolkit \(SAT\) product stream.

-   CSM is installed and verified.
-   cray-product-catalog is running.

-   **ROLE**
    -   System Administrator
-   **OBJECTIVE**

    Install the SAT \(System Admin Toolkit\) product stream which now has its own independent release distribution and installer.

-   **LIMITATIONS**

    None

-   **NEW IN THIS RELEASE**

    This entire procedure is new with this release. The SAT release distribution, or release artifact, is a gzipped tar file that includes the SAT content and the installation script and libraries required to install it.


1.  Start a typescript to capture the commands and output from this installation.

    ```screen
    ncn-m001# script -af product-sat.$\(date +%Y-%m-%d\).txt 
    ncn-m001# export PS1='\\u@\\H \\D\{%Y-%m-%d\} \\t \\w \# '
    ```

2.  Copy the release distribution gzipped tar file, e.g. sat-2.0.x.tar.gz, to ncn-m001.

3.  Unzip and extract the release distribution.

    ```screen
    ncn-m001# tar -xvzf sat-2.0.x.tar.gz
    ```

4.  Change directory to the extracted release distribution directory.

    ```screen
    ncn-m001# cd sat-2.0.x
    ```

5.  Run the installer, **install.sh**.

    ```screen
    ncn-m001# ./install.sh
    ```

6.  Verify that SAT is successfully installed by running the following command to confirm the expected version.

    ```screen
    ncn-m001# sat --version
    sat 3.4.0
    ```

7.  Finish the typescript file started at the beginning of this procedure.

    ```screen
    ncn-m001# exit
    ```


**Related information**  


[About the HPE Cray EX Installation and Configuration Guide](About_the_Shasta_Installation_and_Configuration_Guide.md)

[Related Documentation and Software Versions](Related_Documentation_and_Software_Versions.md)

[Introduction to Software Installation on a HPE Cray EX System](Introduction_to_Software_Installation_on_a_HPE_Cray_EX_System.md)

[Prepare for a 1.4 Install](Prepare_for_a_1.4_Install.md)

[Apply the CSM Patch](Apply_the_CSM_Patch.md)

[Install LiveCD](Install_LiveCD.md)

[Apply the UAN Patch](Apply_the_UAN_Patch.md)

[Install CSM](Install_NCNs.md)

[Install System Dump Utility \(SDU\) Product Stream](Install_System_Dump_Utility_SDU_Product_Stream.md)

[Install the System Monitoring Application Product Stream](Install_the_System_Monitoring_Application_Product_Stream.md)

[Install Slingshot](Install_Slingshot.md)

[Install OS](Install_OS.md)

[Install and Configure the Cray Operating System \(COS\)](Install_and_Configure_the_Cray_Operating_System_COS.md)

[Prepare for UAN Product Installation](Prepare_for_UAN_Product_Installation.md)

[Install the UAN Product Stream](Install_the_UAN_Product_Stream.md)

[Create UAN Boot Images](Create_UAN_Boot_Images.md)

[Boot UANs](Boot_UANs.md)

[Install Slurm](Install_Slurm.md)

[Install PBS](Install_PBS.md)

[Install and Configure LDMS on the Compute Node Image](Install_and_Configure_LDMS_on_the_Compute_Node_Image.md)

[Install the Analytics Product Stream](Install_the_Analytics_Product_Stream.md)

[Procedures that Support Installation](Procedures_that_Support_Installation.md)

[Slingshot Post-Installation Tasks](Slingshot_Post-installation_tasks.md)

[1.4.1 Patch Upgrade](1.4.1_Patch_Upgrade.md)

[1.4.2 Patch Upgrade](1.4.2_Patch_Upgrade.md)

