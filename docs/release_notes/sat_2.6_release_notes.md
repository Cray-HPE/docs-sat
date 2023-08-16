# Changes in SAT 2.6

The 2.6.5 version of the SAT product includes:

- Version 3.25.0 of the `sat` python package and CLI.
- Version 2.0.0-1 of the `sat-podman` wrapper script.
- Version 1.6.1 of the `sat-install-utility` container image.

## New `sat` Commands

No new `sat` commands were added in SAT 2.6.

## Changes to `sat bootsys`

- Functionality was added to the `platform-services` and `cabinet-power`
  stages of `sat bootsys boot`. This allows SAT to automatically recreate
  Kubernetes CronJobs that may have become stuck during shutdown, boot, or
  reboot.

- `sat bootsys boot` more reliably determines if the `hms-discovery` CronJob
  was scheduled during the `cabinet-power` stage.

- SAT now uses the BatchV1 Kubernetes API to manipulate CronJobs instead of the
  BatchV1Beta1 API.

- `sat bootsys` now logs the ID of all BOS sessions when performing BOS
  operations. A warning is logged for any BOS sessions with failed
  components.

- Support for the Compute Rolling Upgrade Service (CRUS) has been removed,
  and the `sat bootsys` command will no longer interact with CRUS.

- The `bos-operations` stage of `sat bootsys` no longer checks whether BOS
  session templates need any operations to be performed before creating a BOS
  session. BOS instead determines whether the session will need to boot or
  shut down any nodes to reach the desired state.

## Changes to `sat bootprep`

- Wildcard matching was added for images in `sat bootprep` input files. Use
  wildcards similar to how prefix filters were used in older versions of SAT.
  For more information, see [Define IMS Images](../usage/sat_bootprep.md#define-ims-images).

- Support for multiple architectures was added to `sat bootprep`. You can
  filter base IMS images and recipes from products based on their target
  architecture. You can also specify target architectures in boot sets of BOS
  session templates. For more information, see
  [Filter Base Images or Recipes from a Product](../usage/sat_bootprep.md#filter-base-images-or-recipes-from-a-product)
  and
  [Define BOS Session Templates](../usage/sat_bootprep.md#define-bos-session-templates).

- You can combine multiple image or recipe filters when specifying a base
  image or recipe from a product. If you specify multiple filters, the unique
  base image or recipe that satisfies all of the given filters is selected. An
  error occurs if either no images or recipes match the given filters or if
  more than one image or recipe matches the given filters.

- In CFS configuration layers, support was added for the new `imsRequireDkms`
  field under the `specialParameters` section. CFS configurations in bootprep
  input files can specify an `ims_require_dkms` field in a new, optional
  `special_parameters` section for each layer.

## Other SAT Changes

- You can add a new `s3.cert_verify` option to the SAT configuration file that
  controls whether certificate verification is performed when accessing S3.

- Log messages spanning multiple lines now print the log level on each line
  instead of only at the beginning of the message.

- When certificate verification is disabled for CSM API requests, only a single
  warning now prints at the beginning of SAT's invocation instead of for
  each request.

- `sat swap blade` more reliably determines if the `hms-discovery` CronJob was
  scheduled when enabling a blade following a hardware swap.

- `sat swap blade` will use the BatchV1 Kubernetes API to manipulate CronJobs,
  instead of the BatchV1Beta1 API as previously.

- Command prompts in this guide are now inserted into text before the
  fenced code block instead of inside of it. This is a change from the
  documentation of SAT 2.5 and earlier. In addition, two new command prompts
  were added for better clarity. For more information, see
  [Command Prompt Conventions in SAT](../about_sat/introduction.md#command-prompt-conventions-in-sat).

## Multi-tenancy Support

SAT 2.6 supports supplying tenant information to CSM services in order to allow
tenant admins to use SAT within their tenant. For more information, see
[Configure multi-tenancy](../usage/multi-tenancy.md).

## Security

- Updated the version of cryptography from 36.0.1 to 41.0.0 to resolve
  CVE-2023-2650.

- Updated the version of requests from 2.27.1 to 2.31.0 to resolve
  CVE-2023-32681.

- Updated the version of curl/libcurl from 7.80.0-r6 to 8.1.2-r0 to address
  CVE-2023-27536.

## Bug Fixes

- Improved extreme slowness in the `platform-services` stage of
  `sat bootsys shutdown` in cases where a large `known_hosts` file is used on
  the host where SAT is running.

- Fixed a bug that caused the wrong container name to be logged when CFS
  configuration sessions failed on newer CSM systems.
