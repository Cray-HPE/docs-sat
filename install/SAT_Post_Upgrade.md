# Optional: Remove old versions after an upgrade

## Prerequisites

- The [Install the System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
    procedure has been successfully completed.
- The [Perform NCN Personalization](#perform-ncn-personalization) procedure has been successfully completed.

## Procedure

After upgrading from a previous version of SAT, the old version of the `cray/cray-sat`
container image will remain in the registry on the system. It is **not** removed
automatically, but it will **not** be the default version.

The admin can remove the older version of the `cray/cray-sat` container image.

The `cray-product-catalog` Kubernetes configuration map will also show all versions
of SAT that are installed. The command `sat showrev --products` will display these
versions. See the example:

```screen
ncn-m001# sat showrev --products
##############################################################################
Product Revision Information
##############################################################################
+--------------+-----------------+--------------------+-----------------------+
| product_name | product_version | images             | image_recipes         |
+--------------+-----------------+--------------------+-----------------------+
...
| sat          | 2.1.3           | -                  | -                     |
| sat          | 2.0.4           | -                  | -                     |
...
+--------------+-----------------+--------------------+-----------------------+
```

# Remove obsolete configuration file sections

## Prerequisites

- The [Install the System Admin Toolkit Product Stream](#install-the-system-admin-toolkit-product-stream)
    procedure has been successfully completed.
- The [Perform NCN Personalization](#perform-ncn-personalization) procedure has been successfully completed.

## Procedure

After upgrading SAT, if using the configuration file from a previous version, there may be
configuration file sections no longer used in the new version. For example, when upgrading
from Shasta 1.4 to Shasta 1.5, the `[redfish]` configuration file section is no longer used.
In that case, the following warning may appear upon running `sat` commands.

```screen
WARNING: Ignoring unknown section 'redfish' in config file.
```

Remove the `[redfish]` section from `/root/.config/sat/sat.toml` to resolve the warning.

```screen
[redfish]
username = "admin"
password = "adminpass"
```

Repeat this process for any configuration file sections for which there are "unknown section" warnings.
