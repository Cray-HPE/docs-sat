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

## Editing a bootprep input file

The input file provided to `sat bootprep` is a YAML-formatted file containing
information which CFS, IMS, and BOS use to create configurations, images, and
BOS session templates respectively. Writing and modifying these input files is
the main task associated with using `sat bootprep`. An input file is composed of
three main sections, one each for configurations, images, and session templates.
These sections may be specified in any order, and any of the sections may be
omitted if desired.

### Creating CFS configurations

The `configurations` section begins with a `configurations:` key.

```screen
---
configurations:
```

Under this key, the user can list one or more configurations to create. For
each configuration, a name should be given, in addition to the list of layers
which comprise the configuration. Each layer can be defined by a product name
and optionally a version number, or commit hash or branch in the product's
configuration repository. Alternatively, a layer can be defined by a Git
repository URL directly, along with an associated branch or commit hash.

When a configuration layer is specified in terms of a product name, the layer
is created in CFS by looking up relevant configuration information (including
the configuration repository and commit information) from the
cray-product-catalog Kubernetes ConfigMap as necessary. A version may be
supplied, but if it is absent, the version is assumed to be the latest version
found in the cray-product-catalog.

```screen
---
configurations:
- name: example-configuration
  layers:
  - name: example product
    playbook: example.yml
    product:
      name: example
      version: 1.2.3
```

Alternatively, a configuration layer may be specified by explicitly referencing
the desired configuration repository, along with the branch containing the
intended version of the Ansible playbooks. A commit hash may be specified by replacing
`branch` with `commit`.

```screen
  ...
  - name: another example product
    playbook: another-example.yml
    git:
      url: "https://vcs.local/vcs/another-example-config-management.git"
      branch: main
  ...
```

When `sat bootprep` is run against an input file, a CFS configuration will be
created corresponding to each configuration in the `configurations` section. For
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

### Creating IMS images

After specifying configurations, the user may add images to the input file
which are to be built by IMS. To add an `images` section, the user should add
an `images` key.

```screen
---
configurations:
  ... (omitted for brevity)
images:
```

Under the `images` key, the user may define one or more images to be created in
a list. Each element of the list defines a separate IMS image to be built and/or
configured. Images must contain a name, as well as an `ims` section containing a
definition of the image to be built and/or configured. Images may be defined by
an image recipe, or by a pre-built image. Recipes and pre-built images are
referred to by their names or IDs in IMS. The `ims` section should also contain
an `is_recipe` property, which indicates whether the name or ID refers to an
image recipe or a pre-built image. Images may also optionally provide a text
description of the image. This description is not stored or used by `sat
bootprep` or any CSM services, but is useful for documenting images in the input
file.

```screen
---
configurations:
  ... (omitted for brevity)
images:
- name: example-compute-image
  description: >
    An example compute node image for illustrative purposes.
  ims:
    name: example-compute-image-recipe
    is_recipe: true
- name: another-example-compute-image
  description: >
    Another example compute node image.
  ims:
    id: <IMS image UUID>
    is_recipe: false
```

Images may also contain a `configuration` property in their definition, which
specifies a configuration with which to customize the built image prior to
booting. If a configuration is specified, then configuration groups must also
be specified using the `configuration_group_names` property.

```screen
---
configurations:
  ... (omitted for brevity)
images:
- name: example-compute-image
  description: >
    An example compute node image for illustrative purposes.
  ims:
    name: example-compute-image-recipe
    is_recipe: true
  configuration: example configuration
  configuration_group_names:
  - Compute
```

### Creating BOS session templates

BOS session templates are the final section of the input file, and are defined
under the `session_templates` key.

```screen
---
configurations:
  ... (omitted for brevity)
images:
  ... (omitted for brevity)
session_templates:
```

Each session template is defined in terms of its name, an image, a
configuration, and a set of parameters which can be used to configure the
session. The name, image, and configuration are specified with their respective
`name`, `image`, and `configuration` keys. `bos_parameters` may also be
specified; currently, the only setting under `bos_parameters` that is supported
is `boot_sets`, which can be used to define boot sets in the BOS session
template. Each boot set is defined under its own property under `boot_sets`, and
the value of each boot set can contain the following properties, all of
which are optional:

- `kernel_parameters`: the parameters passed to the kernel on the command line
- `network`: the network over which the nodes will boot
- `node_list`: nodes to add to the boot set
- `node_roles_groups`: HSM roles to add to the boot set
- `node_groups`: HSM groups to add to the boot set
- `rootfs_provider`: the root file system provider
- `rootfs_provider_passthrough`: parameters to add to the `rootfs=` kernel
    parameter

The properties listed previously are the same as the parameters that can be
specified directly through BOS boot sets. More information can be found in the
[CSM documentation on session
templates](https://cray-hpe.github.io/docs-csm/en-10/operations/boot_orchestration/session_templates/).
Additional properties not listed are passed through to the BOS session template
as written.
  
An example session template might look like the following:

```screen
configurations:
  ... (omitted for brevity)
images:
  ... (omitted for brevity)
session_templates:
- name: example-session-template
  image: example-image
  configuration: example-configuration
  bos_parameters:
    boot_sets:
      example_boot_set:
        kernel_parameters: ip=dhcp quiet
        node_list: []
        rootfs_provider: cpss3
        rootfs_provider_passthrough: dvs:api-gw-service-nmn.local:300:nmn0
```

## Example bootprep input files

Putting together all of the previous input file sections, an example bootprep input
file might look something like the following.

```screen
---
configurations:
- name: cos-config
  layers:
  - name: cos-integration-2.2.87
    playbook: site.yml
    product:
      name: cos
      version: 2.2.87
      branch: integration
  - name: cpe-integration-21.12.3
    playbook: pe_deploy.yml
    product:
      name: cpe
      version: 21.12.3
      branch: integration
  - name: slurm-master-1.1.1
    playbook: site.yml
    product:
      name: slurm
      version: 1.1.1
      branch: master
images:
- name: cray-shasta-compute-sles15sp3.x86_64-2.2.35
  ims:
    is_recipe: true
    name: cray-shasta-compute-sles15sp3.x86_64-2.2.35
  configuration: cos-config
  configuration_group_names:
  - Compute
session_templates:
- name: cray-shasta-compute-sles15sp3.x86_64-2.2.35
  image: cray-shasta-compute-sles15sp3.x86_64-2.2.35
  configuration: cos-config
  bos_parameters:
    boot_sets:
      compute:
        kernel_parameters: ip=dhcp quiet spire_join_token=${SPIRE_JOIN_TOKEN}
        node_roles_groups:
        - Compute
```

### Creating a pre-populated example bootprep input file

It is possible to create an example bootprep input file using values from the
system's product catalog using the `sat bootprep generate-example` command.

```screen
ncn-m001# sat bootprep generate-example
INFO: Using latest version (2.3.24-20220113160653) of product cos
INFO: Using latest version (21.11.4) of product cpe
INFO: Using latest version (1.0.7) of product slurm
INFO: Using latest version (1.1.24) of product analytics
INFO: Using latest version (2.1.5) of product uan
INFO: Using latest version (21.11.4) of product cpe
INFO: Using latest version (1.0.7) of product slurm
INFO: Using latest version (1.1.24) of product analytics
INFO: Using latest version (2.3.24-20220113160653) of product cos
INFO: Using latest version (2.1.5) of product uan
INFO: Wrote example bootprep input file to ./example-bootprep-input.yaml.
```

This file should be reviewed and edited to match the desired parameters of the
configurations, images, and session templates.

## Viewing built-in generated documentation

The contents of the YAML input files described above must conform to a schema
which defines the structure of the data. The schema definition is written using
the JSON Schema format. (Although the format is named "JSON Schema", the schema
itself is written in YAML as well.) More information, including introductory
materials and a formal specification of the JSON Schema metaschema, can be found
[on the JSON Schema website](https://json-schema.org/specification.html).

### Viewing the exact schema specification

To view the exact schema specification, run `sat bootprep view-schema`.

```screen
ncn-m001# sat bootprep view-schema
---
$schema: "https://json-schema.org/draft-07/schema"
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

### Generating user-friendly documentation

The raw schema definition can be difficult to understand without experience
working with JSON Schema specifications. For this reason, a feature was included
which can generate user-friendly HTML documentation for the input file schema
which can be browsed with the user's preferred web browser. 

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
