# SAT Bootprep

SAT provides an automated solution for creating CFS configurations, building
and configuring images in IMS, and creating BOS session templates based on a
given input file which defines how those configurations, images, and session
templates should be created.

This automated process centers around the `sat bootprep` command. Man page
documentation for `sat bootprep` can be viewed similarly to other SAT commands.

```screen
ncn-m001# sat-man sat-bootprep
```

## SAT Bootprep vs SAT Bootsys

`sat bootprep` is used to create CFS configurations, build and
rename IMS images, and create BOS session templates which tie the
configurations and images together during a BOS session.

`sat bootsys` automates several portions of the boot and shutdown processes,
including (but not limited to) performing BOS operations (such as creating BOS
sessions), powering on and off cabinets, and checking the state of the system
prior to shutdown.

## Editing a Bootprep Input File

The input file provided to `sat bootprep` is a YAML-formatted file containing
information which CFS, IMS, and BOS use to create configurations, images, and
BOS session templates respectively. Writing and modifying these input files is
the main task associated with using `sat bootprep`. An input file is composed of
three main sections, one each for configurations, images, and session templates.
These sections may be specified in any order, and any of the sections may be
omitted if desired.

### Providing a Schema Version

The `sat bootprep` input file is validated against a versioned schema
definition. The input file should specify the version of the schema with which
it is compatible under a `schema_version` key. For example:

```yaml
---
schema_version: 1.0.2
```

The current `sat bootprep` input file schema version can be viewed with the
following command:

```screen
ncn-m001# sat bootprep view-schema | grep '^version:'
version: '1.0.2'
```

The `sat bootprep run` command validates the schema version specified
in the input file. The command also makes sure that the schema version
of the input file is compatible with the schema version understood by the
current version of `sat bootprep`. For more information on schema version
validation, refer to the `schema_version` property description in the bootprep
input file schema. For more information on viewing the bootprep input file
schema in either raw form or user-friendly HTML form, see [Viewing the Exact
Schema Specification](#viewing-the-exact-schema-specification) or
[Generating User-Friendly Documentation](#generating-user-friendly-documentation).

The default `sat bootprep` input files provided by the `hpc-csm-software-recipe`
release distribution already contain the correct schema version.

### Defining CFS Configurations

The CFS configurations are defined under a `configurations` key. Under this
key, you can list one or more configurations to create. For each
configuration, give a name in addition to the list of layers that
comprise the configuration.

Each layer can be defined by a product name and optionally a version number,
commit hash, or branch in the product's configuration repository. If this
method is used, the layer is created in CFS by looking up relevant configuration
information (including the configuration repository and commit information) from
the cray-product-catalog Kubernetes ConfigMap as necessary. A version may be
supplied. However, if it is absent, the version is assumed to be the latest
version found in the cray-product-catalog.

Alternatively, a configuration layer can be defined by explicitly referencing
the desired configuration repository. You must then specify the intended version
of the Ansible playbooks by providing a branch name or commit hash with `branch`
or `commit`.

The following example shows a CFS configuration with two layers. The first
layer is defined in terms of a product name and version, and the second layer
is defined in terms of a Git clone URL and branch:

```yaml
---
configurations:
- name: example-configuration
  layers:
  - name: example-product
    playbook: example.yml
    product:
      name: example
      version: 1.2.3
  - name: another-example-product
    playbook: another-example.yml
    git:
      url: "https://vcs.local/vcs/another-example-config-management.git"
      branch: main
```

When `sat bootprep` is run against an input file, a CFS configuration is created
corresponding to each configuration in the `configurations` section. For
example, the configuration created from an input file with the layers listed
above might look something like the following:

```screen
{
    "lastUpdated": "2022-02-07T21:47:49Z",
    "layers": [
        {
            "cloneUrl": "https://vcs.local/vcs/example-config-management.git",
            "commit": "<commit hash>",
            "name": "example product",
            "playbook": "example.yml"
        },
        {
            "cloneUrl": "https://vcs.local/vcs/another-example-config-management.git",
            "commit": "<commit hash>",
            "name": "another example product",
            "playbook": "another-example.yml"
        }
    ],
    "name": "example-configuration"
}
```

### Defining IMS Images

The IMS images are defined under an `images` key. Under the `images` key, the
user may define one or more images to be created in a list. Each element of the
list defines a separate IMS image to be built and/or configured. Images must
contain a `name` key and a `base` key.

The `name` key defines the name of the resulting IMS image. The `base` key
defines the base image to be configured or the base recipe to be built and
optionally configured. One of the following keys must be present under the
`base` key:

- Use an `ims` key to specify an existing image or recipe in IMS.
- Use a `product` key to specify an image or recipe provided by a
  particular version of a product. Note that this is only possible if the
  product provides a single image or recipe.
- Use an `image_ref` key to specify another image from the input file
  using its `ref_name`.

Images may also contain the following keys:

- Use a `configuration` key to specify a CFS configuration with which to
  customize the built image. If a configuration is specified, then configuration
  groups must also be specified using the `configuration_group_names` key.
- Use a `ref_name` key to specify a unique name that can refer to this image
  within the input file in other images or in session templates. The `ref_name`
  key allows references to images from the input file that have dynamically
  generated names as described in
  [Dynamic Variable Substitutions](#dynamic-variable-substitutions).
- Use a `description` key to describe the image in the bootprep input file.
  Note that this key is not currently used.

Here is an example of an image using an existing IMS recipe as its base. This
example builds an IMS image from that recipe. It then configures it with
a CFS configuration named `example-compute-config`. The `example-compute-config`
CFS configuration can be defined under the `configurations` key in the same
input file, or it can be an existing CFS configuration. Running `sat bootprep`
against this input file results in an image named `example-compute-image`.

```yaml
images:
- name: example-compute-image
  description: >
    An example compute node image built from an existing IMS recipe.
  base:
    ims:
      name: example-compute-image-recipe
      type: recipe
  configuration: example-compute-config
  configuration_group_names:
  - Compute
```

Here is an example showing the definition of two images. The first image is
built from a recipe provided by the `cos` product. The second image uses the
first image as a base and configures it with a configuration named
`example-compute-config`. The value of the first image's `ref_name` key is used
in the second image's `base.image_ref` key to specify it as a dependency.
Running `sat bootprep` against this input file results in two images, the
first named `example-cos-image` and the second named `example-compute-image`.

```yaml
images:
- name: example-cos-image
  ref_name: example-cos-image
  description: >
    An example image built from a recipe provided by the COS product.
  base:
    product:
      name: cos
      version: 2.3.101
      type: recipe
- name: example-compute-image
  description: >
    An example image built from a recipe provided by the COS product.
  base:
    image_ref: example-cos-image
  configuration: example-compute-config
  configuration_group_names:
  - Compute
```

### Defining BOS Session Templates

The BOS session templates are defined under the `session_templates` key. Each
session template must provide values for the `name`, `image`, `configuration`,
and `bos_parameters` keys. The `name` key defines the name of the resulting BOS
session template.  The `image` key defines the image to use in the BOS session
template. One of the following keys must be present under the `image` key:

- Use an `ims` key to specify an existing image or recipe in IMS.
- Use an `image_ref` key to specify another image from the input file
  using its `ref_name`.

The `configuration` key defines the CFS configuration specified
in the BOS session template.

The `bos_parameters` key defines parameters that are passed through directly to
the BOS session template. The `bos_parameters` key should contain a `boot_sets`
key, and each boot set in the session template should be specified under
`boot_sets`. Each boot set can contain the following keys, all of
which are optional:

- Use a `kernel_parameters` key to specify the parameters passed to the kernel on the command line.
- Use a `network` key to specify the network over which the nodes boot.
- Use a `node_list` key to specify the nodes to add to the boot set.
- Use a `node_roles_groups` key to specify the HSM roles to add to the boot set.
- Use a `node_groups` key to specify the HSM groups to add to the boot set.
- Use a `rootfs_provider` key to specify the root file system provider.
- Use a `rootfs_provider_passthrough` key to specify the parameters to add to the `rootfs=`
  kernel parameter.

As mentioned above, the parameters under `bos_parameters` are passed through
directly to BOS. For more information on the properties of a BOS boot set,
refer to **BOS Session Templates** in the [*Cray
System Management Documentation*](https://cray-hpe.github.io/docs-csm/).

Here is an example of a BOS session template that refers to an existing IMS
image by name:

```yaml
session_templates:
- name: example-session-template
  image:
    ims:
      name: example-image
  configuration: example-configuration
  bos_parameters:
    boot_sets:
      example_boot_set:
        kernel_parameters: ip=dhcp quiet
        node_roles_groups:
        - Compute
        rootfs_provider: cpss3
        rootfs_provider_passthrough: dvs:api-gw-service-nmn.local:300:nmn0
```

Here is an example of a BOS session template that refers to an image from the
input file by its `ref_name`. This requires that an image defined in the input
file specifies `example-image` as the value of its `ref_name` key.

```yaml
session_templates:
- name: example-session-template
  image:
    image_ref: example-image
  configuration: example-configuration
  bos_parameters:
    boot_sets:
      example_boot_set:
        kernel_parameters: ip=dhcp quiet
        node_roles_groups:
        - Compute
        rootfs_provider: cpss3
        rootfs_provider_passthrough: dvs:api-gw-service-nmn.local:300:nmn0
```

### HPC CSM Software Recipe Variable Substitutions

The HPC CSM Software Recipe provides a manifest defining the versions of each
HPC software product included in the recipe. These product versions can be used
in the `sat bootprep` input file with Jinja2 template syntax.

#### Selecting an HPC CSM Software Recipe Version

By default, the `sat bootprep` command uses the product versions from the
latest installed version of the HPC CSM Software Recipe. However, you can
override this with the `--recipe-version` command line argument to `sat bootprep
run`.

For example, to explicitly select the `22.11.0` version of the HPC CSM Software
Recipe, specify `--recipe-version 22.11.0`:

```screen
ncn-m001# sat bootprep run --recipe-version 22.11.0 compute-and-uan-bootprep.yaml
```

#### Values Supporting Jinja2 Template Rendering

The entire `sat bootprep` input file is not rendered by the Jinja2 template
engine. Jinja2 template rendering of the input file is performed individually
for each supported value. The values of the following keys support rendering as
a Jinja2 template:

- The `name` key of each configuration under the `configurations` key.
- The following keys of each layer under the `layers` key in a
  configuration:
  - `name`
  - `git.branch`
  - `product.version`
  - `product.branch`
- The following keys of each image under the `images` key:
  - `name`
  - `base.product.version`
  - `configuration`
- The following keys of each session template under the
  `session_templates` key:
  - `name`
  - `configuration`

You can use Jinja2 built-in filters in values of any of the keys listed above.
In addition, Python string methods can be called on the string variables.

#### Viewing HPC CSM Software Recipe Variables

HPC CSM Software Recipe variables are available, and you can use them in the values
of the keys listed above. View these variables by cloning the `hpc-csm-software-recipe`
repository from VCS and accessing the `product_vars.yaml` file on the branch that
corresponds to the targeted version of the HPC CSM Software Recipe.

1. Set up a shell script to access the password for the `crayvcs` user:

   ```screen
   ncn-m001# cat > vcs-creds-helper.sh <<EOF
   #!/bin/bash
   kubectl get secret -n services vcs-user-credentials -o jsonpath={.data.vcs_password} | base64 -d
   EOF
   ```

1. Ensure `vcs-creds-helper.sh` is executable:

   ```screen
   ncn-m001# chmod u+x vcs-creds-helper.sh
   ```

1. Set the `GIT_ASKPASS` environment variable to the path to the
   `vcs-creds-helper.sh` script:

   ```screen
   ncn-m001# export GIT_ASKPASS="$PWD/vcs-creds-helper.sh"
   ```

1. Clone the `hpc-csm-software-recipe` repository:

   ```screen
   ncn-m001# git clone https://crayvcs@api-gw-service-nmn.local/vcs/cray/hpc-csm-software-recipe.git
   ```

1. Change the directory to the `hpc-csm-software-recipe` repository:

   ```screen
   ncn-m001# cd hpc-csm-software-recipe
   ```

1. View the versions of the HPC CSM Software Recipe on the system:

   ```screen
   ncn-m001# git branch -r
   ```

1. Check out the branch of the `hpc-csm-software-recipe` repository that corresponds to
   the targeted HPC CSM Software Recipe version. For example, for recipe version
   22.11.0:

   ```screen
   ncn-m001# git checkout cray/hpc-csm-software-recipe/22.11.0
   ```

1. View the contents of the file `product_vars.yaml` in the clone of the
   repository:

   ```screen
   ncn-m001# cat product_vars.yaml
   ```

The variables defined in the `product_vars.yaml` file can be used in the values
that support Jinja2 templates. A variable is specified by a dot-separated path,
with each component of the path representing a key in the YAML file. For
example, a version of the COS product appears as follows in the
`product_vars.yaml` file:

```yaml
cos:
  version: 2.4.76
```

This COS version can be used by specifying `cos.version` within a value in the
input file.

#### HPC CSM Software Recipe Variable Substitution Example

The following example bootprep input file shows how a COS version can be
used in a bootprep input file that creates a CFS configuration for computes.
Only one layer is shown for brevity.

```yaml
---
configurations:
- name: compute-{{recipe.version}}
  layers:
  - name: cos-compute-integration-{{cos.version}}
    playbook: cos-compute.yaml
    product:
      name: cos
      version: "{{cos.version}}"
      branch: integration-{{cos.version}}
```

**Note:** When the value of a key in the bootprep input file is a Jinja2
expression, it must be quoted to pass YAML syntax checking.

Jinja2 expressions can also use filters and Python's built-in string methods to
manipulate the variable values. For example, suppose only the major and minor
components of a COS version are to be used in the branch name for the COS
layer of the CFS configuration. You can use the `split` string method to
achieve this as follows:

```yaml
---
configurations:
- name: compute-{{recipe.version}}
  layers:
  - name: cos-compute-integration-{{cos.version}}
    playbook: cos-compute.yaml
    product:
      name: cos
      version: "{{cos.version}}"
      branch: integration-{{cos.version.split('.')[0]}}-{{cos.version.split('.')[1]}}
```

### Dynamic Variable Substitutions

Additional variables are available besides the product version variables
provided by the HPC CSM Software Recipe. (For more information, see [HPC
CSM Software Recipe Variable Substitutions](#hpc-csm-software-recipe-variable-substitutions).)
These additional variables are dynamic because their values are
determined at run-time based on the context in which they appear. Available
dynamic variables include the following:

- The variable `base.name` can be used in the `name` of an image under the
  `images` key. The value of this variable is the name of the IMS image or
  recipe used as the base of this image.
- The variable `image.name` can be used in the `name` of a session template
  under the `session_templates` key. The value of this variable is the name of
  the IMS image used in this session template.

These variables reduce the need to duplicate values throughout the `sat
bootprep` input file and make the following use cases possible:

- You want to build an image from a recipe provided by a product and use the
  name of the recipe in the name of the resulting image.
- You want to use the name of the image in the name of a session template, and
  the image is generated as described in the previous use case.

## Example Bootprep Input Files

This section provides an example bootprep input file. It also gives
instructions for obtaining the default bootprep input files delivered
with a release of the HPC CSM Software Recipe.

### Example Bootprep Input File

The following bootprep input file provides an example of using most of the
features described in previous sections. It is not intended to be a complete
bootprep file for the entire CSM product.

```yaml
---
configurations:
- name: compute-{{recipe.version}}
  layers:
  - name: cos-compute-integration-{{cos.version}}
    playbook: site.yml
    product:
      name: cos
      version: "{{cos.version}}"
      branch: integration-{{cos.version}}
  - name: cpe-pe_deploy-integration-{{cpe.version}}
    playbook: pe_deploy.yml
    product:
      name: cpe
      version: "{{cpe.version}}"
      branch: integration-{{cpe.version}}

images:
- name: "{{base.name}}"
  ref_name: base_cos_image
  base:
    product:
      name: cos
      type: recipe
      version: "{{cos.version}}"

- name: compute-{{base.name}}
  ref_name: compute_image
  base:
    image_ref: base_cos_image
  configuration: compute-{{recipe.version}}
  configuration_group_names:
  - Compute

session_templates:
- name: compute-{{recipe.version}}
  image:
    image_ref: compute_image
  configuration: compute-{{recipe.version}}
  bos_parameters:
    boot_sets:
      compute:
        kernel_parameters: ip=dhcp quiet spire_join_token=${SPIRE_JOIN_TOKEN}
        node_roles_groups:
        - Compute
        rootfs_provider_passthrough: "dvs:api-gw-service-nmn.local:300:hsn0,nmn0:0"
```

### Accessing Default Bootprep Input Files

Default bootprep input files are delivered by the HPC CSM Software Recipe
product. You can access these files by cloning the `hpc-csm-software-recipe`
repository.

To do this, follow steps 1-7 of the procedure in [Viewing HPC CSM Software Recipe
Variables](#viewing-hpc-csm-software-recipe-variables). Then, access the files in the
`bootprep` directory of that repository:

```screen
ncn-m001# ls bootprep/
```

### Generating an Example Bootprep Input File

The `sat bootprep generate-example` command was not updated for
recent bootprep schema changes. It is recommended that you instead use the
default bootprep input files described in [Accessing Default Bootprep Input
Files](#accessing-default-bootprep-input-files). The `sat bootprep
generate-example` command will be updated in a future release of SAT.

## Editing HPC CSM Software Recipe Defaults

You might need to edit the default bootprep input files delivered by the HPC
CSM Software Recipe for your system. Here are some examples of how to edit
the files.

### Editing Default Branch Names

Before running `sat bootprep`, HPE recommends reading the bootprep input files
and paying specific attention to the `branch` parameters. Some HPE Cray EX
products require system-specific changes on a working branch of VCS. For these
products, the default bootprep input files assume certain naming conventions for
the VCS branches. The files refer to a particular branch of a product's
configuration management repository.

Thus, it is important to confirm that the bootprep input files delivered by the
HPC CSM Software Recipe match the actual system branch names. For example, the
COS product's CFS configuration layer is defined as follows in the default
`management-bootprep.yaml` bootprep input file.

```yaml
- name: cos-ncn-integration-{{cos.version}}
  playbook: ncn.yml
  product:
    name: cos
    version: "{{cos.version}}"
    branch: integration-{{cos.version}}
```

The default file is assuming that system-specific Ansible configuration changes
for the COS product in VCS are stored in a branch named
`integration-{{cos.version}}`. If the version being installed is COS 2.4.99,
`sat bootprep` looks for a branch named `integration-2.4.99` from which to
create CFS configuration layers.

You can create VCS working branches that are not the default bootprep input file
branch names. A simple example of this is using `cne-install` to update working
VCS branches. If you use `cne-install` to update working VCS branches, (namely in
the `update_working_branches` stage), you create or update the branches specified
by the `-B WORKING_BRANCH` command line option. For example, consider the
following `cne-install` command.

```screen
ncn-m001# ./cne-install install \
    -B integration \
    -s deploy_products \
    -e update_working_branches
```

Products installed with this `cne-install` example use the working branch
`integration` for system-specific changes to VCS. The branch specified by the
`-B` option must match the branch specified in the bootprep input file.

In another example, to use the branch `integration` for COS instead of
`integration-{{cos.version}}`, edit the bootprep input file so it reads as
follows.

```yaml
- name: cos-ncn-integration-{{cos.version}}
  playbook: ncn.yml
  product:
    name: cos
    version: "{{cos.version}}"
    branch: integration
```

### Editing Default Management CFS Configuration Names

The default bootprep input file for management CFS configurations
(`management-bootprep.yaml`) creates configurations that have names specified
within the input file. For example, in the bootprep input files included in the
``22.11`` HPC CSM Software Recipe, the following configurations are named:

- `ncn-personalization`
- `ncn-image-customization`

These default management CFS configuration names might be acceptable for your
system. However, it is possible to create other names. `sat bootprep` creates
whatever configurations are specified in the input file. For example, to
create a NCN node personalization configuration named
`ncn-personalization-test`, edit the file as follows.

```yaml
configurations:
- name: ncn-personalization-test
  layers:
  ...
```

For management configurations, use `sat status` to identify the current
desired configuration for each of the management nodes.

```screen
ncn-m001# sat status --fields xname,role,subrole,desiredconfig --filter role=management
+----------------+------------+---------+---------------------+
| xname          | Role       | SubRole | Desired Config      |
+----------------+------------+---------+---------------------+
| x3000c0s1b0n0  | Management | Master  | ncn-personalization |
| x3000c0s3b0n0  | Management | Master  | ncn-personalization |
| x3000c0s5b0n0  | Management | Master  | ncn-personalization |
| x3000c0s7b0n0  | Management | Worker  | ncn-personalization |
| x3000c0s9b0n0  | Management | Worker  | ncn-personalization |
| x3000c0s11b0n0 | Management | Worker  | ncn-personalization |
| x3000c0s13b0n0 | Management | Worker  | ncn-personalization |
| x3000c0s17b0n0 | Management | Storage | ncn-personalization |
| x3000c0s19b0n0 | Management | Storage | ncn-personalization |
| x3000c0s21b0n0 | Management | Storage | ncn-personalization |
| x3000c0s25b0n0 | Management | Worker  | ncn-personalization |
+----------------+------------+---------+---------------------+
```

To overwrite the desired configuration using `sat bootprep`, ensure the bootprep
input file specifies to create a configuration with the same name
(`ncn-personalization` in the example above). To create a different configuration,
ensure the bootprep input file specifies to create a configuration with a
different name than the desired configuration (different than `ncn-personalization`
in the example above).

### Upgrading a Single Product and Overriding its Default Version

When working with a given HPC CSM Software Recipe, it might be necessary to
upgrade a single HPE Cray EX product past the default version given in the
recipe. However, you might still want to use the other default product versions
contained in that recipe. To do this, first upgrade the single product. For
more information, refer to the upgrade instructions in that product's
documentation.

After the product is upgraded, you must override its default version in subsequent
runs of `sat bootprep`. The following process explains how to do this. In this
example, all the default product versions from the `22.11` software recipe are
used except for COS. The COS default product version is overridden to version
`2.4.199` instead, and the CFS configurations in `management-bootprep.yaml` are
created.

1. Ensure you have a local copy of the default bootprep input files.

   For more information, see [Accessing Default Bootprep Input
   Files](#accessing-default-bootprep-input-files).

1. Edit the `product_vars.yaml` file to change the default product version.

   ```screen
   ncn-m001# vim product_vars.yaml
   ```

1. Confirm the new product version in the edited `product_vars.yaml` file.

   ```screen
   ncn-m001# grep -A1 cos: `product_vars.yaml`:
   cos:
     version: 2.4.199
   ```

1. Use the `--vars-file` option when running `sat bootprep` to override the
   default product version.

   You must run this command from the directory containing the `product_vars.yaml`
   file. The `product_vars.yaml` file must also be specified when using the
   `--vars-file` option. It is not sufficient to just edit the file.

   ```screen
   ncn-m001# sat bootprep run --vars-file product_vars.yaml bootprep/management-bootprep.yaml
   ```

   **Note:** This example is specific to creating the configurations defined in
   `management-bootprep.yaml`. Review what configurations, images, or session templates
   you intend to create by viewing the input file.

## Viewing Built-in Generated Documentation

The contents of the YAML input files described above must conform to a schema
which defines the structure of the data. The schema definition is written using
the JSON Schema format. (Although the format is named "JSON Schema", the schema
itself is written in YAML as well.) More information, including introductory
materials and a formal specification of the JSON Schema metaschema, can be found
[on the JSON Schema website](https://json-schema.org/specification.html).

### Viewing the Exact Schema Specification

To view the exact schema specification, run `sat bootprep view-schema`.

```screen
ncn-m001# sat bootprep view-schema
---
$schema: "https://json-schema.org/draft/2020-12/schema"
...
title: Bootprep Input File
description: >
  A description of the set of CFS configurations to create, the set of IMS
  images to create and optionally customize with the defined CFS configurations,
  and the set of BOS session templates to create that reference the defined
  images and configurations.
type: object
additionalProperties: false
properties:
  ...
```

### Generating User-Friendly Documentation

The raw schema definition can be difficult to understand without experience
working with JSON Schema specifications. For this reason, a feature is included
that generates user-friendly HTML documentation for the input file schema. This
HTML documentation can be browsed with your preferred web browser.

1. Create a documentation tarball using `sat bootprep`.

   ```screen
   ncn-m001# sat bootprep generate-docs
   INFO: Wrote input schema documentation to /root/bootprep-schema-docs.tar.gz
   ```

   An alternate output directory can be specified with the `--output-dir`
   option. The generated tarball is always named `bootprep-schema-docs.tar.gz`.

   ```screen
   ncn-m001# sat bootprep generate-docs --output-dir /tmp
   INFO: Wrote input schema documentation to /tmp/bootprep-schema-docs.tar.gz
   ```

1. From another machine, copy the tarball to a local directory.

   ```screen
   another-machine$ scp root@ncn-m001:bootprep-schema-docs.tar.gz .
   ```

1. Extract the contents of the tarball and open the contained `index.html`.

   ```screen
   another-machine$ tar xzvf bootprep-schema-docs.tar.gz
   x bootprep-schema-docs/
   x bootprep-schema-docs/index.html
   x bootprep-schema-docs/schema_doc.css
   x bootprep-schema-docs/schema_doc.min.js
   another-machine$ open bootprep-schema-docs/index.html
   ```
