# System Admin Toolkit Offline Documentation

The SAT documentation can be found online at the following link:
[SAT Documentation](https://cray-hpe.github.io/docs-sat).
It is also available offline as markdown, which can be viewed with a markdown
viewer or with a text editor.

The offline documentation is available in the `docs/` directory of the SAT
release distribution as well as in RPM package format. The RPM package is
installed as a part of the Ansible plays launched by the Configuration
Framework Service (CFS). Its files are installed to `/usr/share/doc/sat`.

## Check for the Latest Documentation

You can find the latest documentation in the most recent RPM package. This
package may include updates, corrections, and enhancements that were not
available until after the software release.

1. Check the version of the currently installed SAT documentation.

   This RPM will only be installed if the SAT CFS configuration layer has been
   applied.

   ```bash
   rpm -q docs-sat
   ```

2. Download and upgrade to the latest SAT documentation RPM.

   ```bash
   rpm -Uvh https://release.algol60.net/sat/docs-sat/docs-sat-latest.noarch.rpm
   ```

   If the system does not have direct internet access, you must externally
   download this RPM and copy it to the system. The following example copies it
   to `ncn-m001`.

   ```bash
   wget https://release.algol60.net/sat/docs-sat/docs-sat-latest.noarch.rpm -O docs-sat-latest.noarch.rpm
   scp -p docs-sat-latest.noarch.rpm ncn-m001:/root
   ssh ncn-m001
   rpm -Uvh docs-sat-latest.noarch.rpm
   ```
