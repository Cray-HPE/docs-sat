[//]: # ((C) Copyright 2022 Hewlett Packard Enterprise Development LP)

[//]: # (Permission is hereby granted, free of charge, to any person obtaining a)
[//]: # (copy of this software and associated documentation files (the "Software"),)
[//]: # (to deal in the Software without restriction, including without limitation)
[//]: # (the rights to use, copy, modify, merge, publish, distribute, sublicense,)
[//]: # (and/or sell copies of the Software, and to permit persons to whom the)
[//]: # (Software is furnished to do so, subject to the following conditions:)

[//]: # (The above copyright notice and this permission notice shall be included)
[//]: # (in all copies or substantial portions of the Software.)

[//]: # (THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR)
[//]: # (IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,)
[//]: # (FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL)
[//]: # (THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR)
[//]: # (OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,)
[//]: # (ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR)
[//]: # (OTHER DEALINGS IN THE SOFTWARE.)

## SAT Logging

As of SAT version 2.2, some command output that was previously printed to `stdout`
is now logged to `stderr`. These messages are logged at the `INFO` level. The
default logging threshold was changed from `WARNING` to `INFO` to accomodate
this logging change. Additionally, some messages previously logged at the `INFO`
are now logged at the `DEBUG` level.

These changes take effect automatically. However, if the default output threshold
has been manually set in `~/.config/sat/sat.toml`, it should be changed to ensure
that important output is shown in the terminal.

### Update Configuration

In the following example, the stderr log level, `logging.stderr_level`, is set to
`WARNING`, which will exclude `INFO`-level logging from terminal output.

```screen
ncn-m001:~ # grep -A 3 logging ~/.config/sat/sat.toml
[logging]
...
stderr_level = "WARNING"
```

To enable the new default behavior, comment this line out, delete it, or set
the value to "INFO".

If `logging.stderr_level` is commented out, its value will not affect logging
behavior. However, it may be helpful set its value to `INFO` as a reminder of
the new default behavior.

### Affected Commands

The following commands trigger messages that have been changed from `stdout`
print calls to `INFO`-level (or `WARNING`- or `ERROR`-level) log messages:

```
sat bootsys --stage shutdown --stage session-checks
sat sensors
```

The following commands trigger messages that have been changed from `INFO`-level
log messages to `DEBUG`-level log messages:

```
sat nid2xname
sat xname2nid
sat swap
```
