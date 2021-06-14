---
category: numbered
---

## Command Prompt Conventions in SAT

Describes how to use command prompts in SAT.

### Command Prompt Conventions

**Host name and account in command prompt**

The host name in a command prompt indicates where the command must be run. The account that must run the command is also indicated in the prompt.

-   The `root` or super-user account always has the `#` character at the end of the prompt and has the host name of the host in the prompt.
-   Any non-`root` account is indicated with account@hostname\>. A user account that is neither `root` nor `crayadm` is referred to as `user`.
-   The command prompt inside the SAT container environment is indicated with the string as follows. It also has the "\#" character at the end of the prompt.

|`ncn-m001#`|Run on one of the Kubernetes Manager servers.|
|`(CONTAINER_ID) sat-container#`|Run the command inside the SAT container environment by first running sat bash.|

Examples of this command used by an administrator:

```screen
ncn-m001# `sat status`
```

```screen
ncn-m001# `sat bash
(CONTAINER_ID) sat-container# sat status`
```

**Parent topic:**[System Admin Toolkit Command Overview](System_Admin_Toolkit_Command_Overview.md)

