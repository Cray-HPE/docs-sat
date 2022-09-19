# System Admin Toolkit Offline Documentation

The SAT documentation can be found online at the following URL:
https://cray-hpe.github.io/docs-sat

It is also available offline as markdown, which may be viewed with a markdown
viewer or with a text editor. A table of contents can be found below.

The offline documentation is available in the `docs/` directory of the SAT
release distribution as well as in RPM package format. The RPM package is
installed as a part of the Ansible plays launched by the Configuration
Framework Service (CFS). Its files are installed to `/usr/share/doc/sat`.

## Check for Latest Documentation

Acquire the latest documentation RPM. This may include updates, corrections,
and enhancements that were not available until after the software release.

1. Check the version of the currently installed SAT documentation.

   This RPM will only be installed if the SAT CFS configuration layer has been
   applied.

   ```
   rpm -q docs-sat
   ```

2. Download and upgrade the latest documentation RPM.

   For example, to download and upgrade to the latest SAT 2.4 documentation RPM:

   ```
   rpm -Uvh https://artifactory.algol60.net/artifactory/sat-rpms/hpe/stable/sle-15sp3/docs-sat/2.4/noarch/docs-sat-latest.noarch.rpm
   ```

   If this machine does not have direct internet access, then this RPM will
   need to be externally downloaded and copied to the system. The following
   example copies it to `ncn-m001`.

   ```
   wget https://artifactory.algol60.net/artifactory/sat-rpms/hpe/stable/sle-15sp3/docs-sat/2.4/noarch/docs-sat-latest.noarch.rpm -O docs-sat-latest.noarch.rpm
   scp -p docs-sat-latest.noarch.rpm ncn-m001:/root
   ssh ncn-m001
   rpm -Uvh docs-sat-latest.noarch.rpm
   ```
