# Change the BOS Version

By default, SAT uses BOS `v1`. You can select the BOS version to use for
individual commands with the `--bos-version` option. For more information on
this option, see the man page for a specific command.

You can also configure the BOS version to use in the SAT config file.
Do this under the `api_version` setting in the `bos` section of the
config file.

1. Find the SAT config file at `~/.config/sat/sat.toml`, and look for a section
   like this:

   ```screen
   [bos]
   # api_version = "v1"
   ```

   In this example, SAT is using BOS version `"v1"`.

2. Change the line specifying the `api_version` to the BOS version desired (for
   example, `"v2"`).

   ```screen
   [bos]
   # api_version = "v2"
   ```

If the system is using an existing SAT config file from an older version of
SAT, the `bos` section might not exist. Instead, you should add the `bos`
section with the BOS version desired in the `api_version` setting.
