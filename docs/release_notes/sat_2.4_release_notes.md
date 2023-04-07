# Changes in SAT 2.4

The 2.4.13 version of the SAT product includes:

- Version 3.19.3 of the `sat` python package and CLI.
- Version 2.0.0-1 of the `sat-podman` wrapper script.
- Version 1.5.5 of the `sat-install-utility` container image.
- Version 3.3.1 of the `cfs-config-util` container image.

Because of installation refactoring efforts, the following two components
are no longer delivered with SAT:

- `sat-cfs-install` container image
- `sat-cfs-install` Helm chart

## Inclusion of SAT in CSM

A version of the `cray-sat` container image is now included in CSM. For more
information, see [SAT in CSM](../introduction.md#sat-in-csm).

## SAT Installation Improvements

The SAT `install.sh` script no longer uses a `sat-cfs-install` Helm chart and
container image to upload its Ansible content to the `sat-config-management`
repository in VCS. Instead, it uses Podman to run the `cf-gitea-import` container
directly. Some of the benefits of this change include the following:

- Fewer container images that need to be managed by the SAT product
- Simplified SAT installation without Helm charts or Loftsman manifests
- Reduced SAT installation time
- [Decoupling of `cray-sat` container image and `cray-sat-podman` package](#decoupling-of-cray-sat-container-image-and-cray-sat-podman-package)

## Decoupling of `cray-sat` Container Image and `cray-sat-podman` Package

In older SAT releases, the `sat` wrapper script that was provided by the
`cray-sat-podman` package installed on Kubernetes master NCNs included a
hard-coded version of the `cray-sat` container image. As a result, every new
version of the `cray-sat` image required a corresponding new version of the
`cray-sat-podman` package.

In this release, this tight coupling of the `cray-sat-podman` package and the
`cray-sat` container image was removed. The `sat` wrapper script provided
by the `cray-sat-podman` package now looks for the version of the `cray-sat`
container image in the `/opt/cray/etc/sat/version` file. This file is populated
with the correct version of the `cray-sat` container image by the SAT layer of
the CFS configuration that is applied to management NCNs. If the `version` file
does not exist, the wrapper script defaults to the version of the `cray-sat`
container image delivered with the latest version of CSM installed on the system.

## Improved NCN Personalization Automation

The steps for performing NCN personalization as part of the SAT installation
were moved out of the `install.sh` script and into a new
`update-mgmt-ncn-cfs-config.sh` script that is provided in the SAT release
distribution. The new script provides additional flexibility in how it modifies
the NCN personalization CFS configuration for SAT. It can modify an existing CFS
configuration by name, a CFS configuration being built in a JSON file, or an
existing CFS configuration that applies to certain components.

## New `sat bootprep` Features

The following new features were added to the `sat bootprep` command:

- Variable substitutions using Jinja2 templates in certain fields of the
  `sat bootprep` input file

  For more information, see
  [HPC CSM Software Recipe Variable Substitutions](../usage/sat_bootprep.md#hpc-csm-software-recipe-variable-substitutions)
  and [Dynamic Variable Substitutions](../usage/sat_bootprep.md#dynamic-variable-substitutions).

- Schema version validation in the `sat bootprep` input files

  For more information, see
  [Provide a Schema Version](../usage/sat_bootprep.md#provide-a-schema-version).

- Ability to look up images and recipes provided by products

  For more information, see
  [Define IMS Images](../usage/sat_bootprep.md#define-ims-images).

The schema of the `sat bootprep` input files was also changed to support these
new features:

- The base recipe or image used by an image in the input file should now be
  specified under a `base` key instead of under an `ims` key. The old `ims`
  key is deprecated.
- To specify an image that depends on another image in the input file, the
  dependent image should specify the dependency under `base.image_ref`.
  You should no longer use the IMS name of the image on which it depends.
- The image used by a session template should now be specified under
  `image.ims.name`, `image.ims.id`, or `image.image_ref`. Specifying a string
  value directly under the `image` key is deprecated.

For more information on defining IMS images and BOS session templates in the
`sat bootprep` input file, see [Define IMS Images](../usage/sat_bootprep.md#define-ims-images)
and [Define BOS Session Templates](../usage/sat_bootprep.md#define-bos-session-templates).

## Added Blade Swap Support to `sat swap`

The `sat swap` command was updated to support swapping compute and UAN blades
with `sat swap blade`. This functionality is described in the following processes
of the [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm):

- **Adding a Liquid-cooled blade to a System Using SAT**
- **Removing a Liquid-cooled blade from a System Using SAT**
- **Replace a Compute Blade Using SAT**
- **Swap a Compute Blade with a Different System Using SAT**

## Support for BOS `v2`

A new `v2` version of the Boot Orchestration Service (BOS) is available in CSM
1.3.0. SAT has added support for BOS `v2`. This impacts the following commands
that interact with BOS:

- `sat bootprep`
- `sat bootsys`
- `sat status`

By default, SAT uses BOS `v1`. However, you can choose the BOS version you want
to use. For more information, see [Change the BOS Version](../usage/change_bos_version.md).

## Added BOS Fields to `sat status`

When using BOS `v2`, `sat status` outputs additional fields. These fields show
the most recent BOS session, session template, booted image, and boot status for
each node. An additional `--bos-fields` option was added to limit the output of
`sat status` to these fields. The fields are not displayed when using BOS `v1`.

## Open Source Repositories

This is the first release of SAT built from open source code repositories.
As a result, build infrastructure was changed to use an external Jenkins instance,
and artifacts are now published to an external Artifactory instance. These
changes should not impact the functionality of the SAT product in any way.

## Security

### CVE Mitigation

- The `paramiko` Python package version was updated from 2.9.2 to 2.10.1 to
  mitigate CVE-2022-24302.
- The `oauthlib` Python package version was updated from 3.2.0 to 3.2.1 to
  mitigate CVE-2022-36087.

### Restricted Permissions on SAT Config Files and Directories

SAT stores information used to authenticate to the API gateway with Keycloak.
Token files are stored in the `~/.config/sat/tokens/` directory. Those files
have always had permissions appropriately set to restrict them to be readable
only by the user.

Keycloak usernames used to authenticate to the API gateway are stored in the
SAT config file at `/.config/sat/sat.toml`. Keycloak usernames are also used in
the file names of tokens stored in `/.config/sat/tokens`. As an additional
security measure, SAT now restricts the permissions of the SAT config file
to be readable and writable only by the user. It also restricts the tokens
directory and the entire SAT config directory `~/.config/sat` to be accessible
only by the user. This prevents other users on the system from viewing
Keycloak usernames used to authenticate to the API gateway.

## Bug Fixes

- Fixed an issue where `sat init` did not print a message confirming a new
  configuration file was created.
- Fixed an issue where `sat showrev` exited with a traceback if the file
  `/opt/cray/etc/site_info.yaml` existed but was empty. This could occur if the
  user exited `sat setrev` with `Ctrl-C`.
- Fixed outdated information in the `sat bootsys` man page, and added a
  description of the command stages.
