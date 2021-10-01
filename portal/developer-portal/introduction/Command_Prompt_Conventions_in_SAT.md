[//]: # ((C) Copyright 2021 Hewlett Packard Enterprise Development LP)

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

## Command Prompt Conventions in SAT

The host name in a command prompt indicates where the command must be run. The account that must run the command is
also indicated in the prompt.

- The `root` or super-user account always has the `#` character at the end of the prompt and has the host name of the
    host in the prompt.
- Any non-`root` account is indicated with account@hostname\>. A user account that is neither `root` nor `crayadm` is
    referred to as `user`.
- The command prompt inside the SAT container environment is indicated with the string as follows. It also has the "#"
    character at the end of the prompt.

| Command Prompt                  | Meaning                                                                                             |
| ------------------------------- | --------------------------------------------------------------------------------------------------- |
| `ncn-m001#`                     | Run on one of the Kubernetes Manager servers. (**Non-interactive**)                                 |
| `(CONTAINER_ID) sat-container#` | Run the command inside the SAT container environment by first running `sat bash`. (**Interactive**) |

Examples of the `sat status` command used by an administrator:

```screen
ncn-m001# sat status
```

```screen
ncn-m001# sat bash
(CONTAINER_ID) sat-container# sat status
```
