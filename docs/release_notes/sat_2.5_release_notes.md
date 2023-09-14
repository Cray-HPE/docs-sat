# Changes in SAT 2.5

The 2.5.17 version of the SAT product includes:

- Version 3.21.4 of the `sat` python package and CLI.
- Version 2.0.0-1 of the `sat-podman` wrapper script.
- Version 1.6.0 of the `sat-install-utility` container image.
- Version 3.3.1 of the `cfs-config-util` container image.

## New `sat` Commands

`sat jobstat` allows access to application and job data through the command
line. It provides a table summarizing information for all jobs on the system.

## Changes to `sat bootprep`

- A `list-vars` subcommand was added to `sat bootprep`.

  It lists the variables available for use in bootprep input files at runtime.

- A `--limit` option was added to `sat bootprep run`.

  It restricts the creation of CFS configurations, IMS images, and BOS session
  templates into separate stages. For more information, see
  [Limit SAT Bootprep Run into Stages](../usage/sat_and_iuf.md#limit-sat-bootprep-run-into-stages).

- `sat bootprep` now prompts individually for each CFS configuration that
  already exists.

- `sat bootprep` can now filter images provided by a product by using a prefix.

  This is useful when specifying the base of an image in a bootprep input
  file. For more information, see
  [Define IMS Images](../usage/sat_bootprep.md#define-ims-images).

- To support product names with hyphens, `sat bootprep` now converts hyphens to
  underscores within variables.

  For more information, see
  [Hyphens in HPC CSM Software Recipe Variables](../usage/sat_bootprep.md#hyphens-in-hpc-csm-software-recipe-variables).

- In `sat bootprep` input files, the value of the `playbook` property of CFS
  configuration layers can now be rendered with Jinja2 templates.

  For more information, see
  [Values Supporting Jinja2 Template Rendering](../usage/sat_bootprep.md#values-supporting-jinja2-template-rendering).

- Output was added to `sat bootprep run` that summarizes the CFS configurations,
  IMS images, and BOS session templates created.

  For more information, see
  [Summary of SAT Bootprep Results](../usage/sat_bootprep.md#summary-of-sat-bootprep-results).

- Improvements were made to the `sat bootprep` output when CFS configuration
  and BOS session templates are created.

## Changes to `sat bootsys`

- A `reboot` subcommand was added to `sat bootsys`. It uses BOS to reboot
  nodes in the `bos-operations` stage.
- The `--staged-session` option was added to `sat bootsys`. It can be used to
  create staged BOS sessions. For more information, refer to **Staging Changes
  with BOS** in the [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).

## Changes to Other `sat` Commands

- When switching SAT versions with `prodmgr`, a version is no longer set as
  "active" in the product catalog. The "active" field was also removed from the
  output of `sat showrev`.
- Improvements were made to the performance of `sat status` when using BOS
  version two.

## New Install and Upgrade Framework

The new Install and Upgrade Framework (IUF) provides commands which install,
upgrade, and deploy products with the help of `sat bootprep` on HPE Cray EX
systems managed by Cray System Management (CSM). IUF capabilities are described
in detail in the [IUF section](https://cray-hpe.github.io/docs-csm/en-14/operations/iuf/iuf/)
of the [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/).
The initial install and upgrade workflows described in the
[*HPE Cray EX System Software Stack Installation and Upgrade Guide for CSM
(S-8052)*](https://www.hpe.com/support/ex-S-8052) detail when and how to use
IUF with a new release of SAT or any other HPE Cray EX product.

Because IUF now handles NCN personalization, information about this process was
removed from the SAT documentation. Other sections in the documentation were
also revised to support the new Install and Upgrade Framework. For example, the
[SAT Installation](../install.md) and [SAT Upgrade](../upgrade.md) sections of this
guide now provide details on software and configuration content specific to SAT.
The [*Cray System Management Documentation*](https://cray-hpe.github.io/docs-csm/)
will indicate when these sections should be referred to for detailed information.

For more information on the relationship between `sat bootprep` and IUF, see
[SAT and IUF](../usage/sat_and_iuf.md).

## New Default BOS Version

By default, SAT now uses version two of the Boot Orchestration Service (BOS).
This change to BOS `v2` impacts the following commands that interact with BOS:

- `sat bootprep`
- `sat bootsys`
- `sat status`

To change the default to a different BOS version, see
[Change the BOS Version](../usage/change_bos_version.md).

## Security

- Updated the version of certifi in the `sat` python package and CLI from
  2021.10.8 to 2022.12.7 to resolve CVE-2022-23491.
- Updated the version of certifi in the `sat-install-utility` container image
  from 2021.5.30 to 2022.12.7 to resolve CVE-2022-23491.
- Updated the version of oauthlib from 3.2.1 to 3.2.2 to resolve CVE-2022-36087.
- Updated the version of cryptography from 36.0.1 to 39.0.1 to resolve
  CVE-2023-23931.

## Bug Fixes

- Fixed a bug that prevented `sat init` from creating a configuration file in
  the current directory when not prefixed with `./`.
- Fixed a bug in which `sat status` failed with a traceback when using BOS
  version two and reported components whose most recent image did not exist.
- Fixed a build issue where the `sat` container could contain a different
  version of `kubectl` than the version found in CSM.
- Fixed error handling and improved command messages for `sat bootprep` and
  `sat swap blade`.
