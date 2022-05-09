# Command Prompt Conventions in SAT

The host name in a command prompt indicates where the command must be run. The account that must run the command is
also indicated in the prompt.

- The `root` or super-user account always has the `#` character at the end of the prompt and has the host name of the
  host in the prompt.
- Any non-`root` account is indicated with account@hostname>. A user account that is neither `root` nor `crayadm` is
  referred to as `user`.
- The command prompt inside the SAT container environment is indicated with the string as follows. It also has the "#"
  character at the end of the prompt.

| Command Prompt | Meaning |
|----------------|---------|
| `ncn-m001#` | Run on one of the Kubernetes Manager servers. (**Non-interactive**) |
| `(CONTAINER_ID) sat-container#` | Run the command inside the SAT container environment by first running `sat bash`. (**Interactive**) |

Examples of the `sat status` command used by an administrator:

```screen
ncn-m001# sat status
```

```screen
ncn-m001# sat bash
(CONTAINER_ID) sat-container# sat status
```
