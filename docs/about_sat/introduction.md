# Introduction to SAT

## About System Admin Toolkit (SAT)

The System Admin Toolkit (SAT) is designed to assist administrators with common tasks, such as troubleshooting and
querying information about the HPE Cray EX System and its components, system boot and shutdown, and replacing hardware
components.

SAT offers a command line utility which uses subcommands. There are similarities between SAT commands and `xt` commands
used on the Cray XC platform. For more information on SAT commands, see [SAT Command Overview](#sat-command-overview).

In CSM 1.3 and newer, the `sat` command is automatically available on all the
Kubernetes control plane. For more information, see [SAT in CSM](sat_in_csm.md). Older
versions of CSM do not have the `sat` command automatically available, and SAT
must be installed as a separate product.

## SAT Command Overview

Describes the SAT Command Line Utility, lists the key commands found in the System Admin Toolkit man pages, and provides
instruction on the SAT Container Environment.

### SAT Command Line Utility

The primary component of the System Admin Toolkit (SAT) is a command-line utility run from Kubernetes control plane nodes
(`ncn-m` nodes).

It is designed to assist administrators with common tasks, such as troubleshooting and querying information about the
HPE Cray EX System and its components, system boot and shutdown, and replacing hardware components. There are
similarities between SAT commands and `xt` commands used on the Cray XC platform.

### SAT Commands

The top-level SAT man page describes the toolkit, documents the global options affecting all subcommands, documents
configuration file options, and references the man page for each subcommand. SAT consists of many subcommands that each
have their own set of options.

### SAT Container Environment

The `sat` command-line utility runs in a container using Podman, a daemonless container runtime. SAT runs on
Kubernetes control plane nodes. A few important points about the SAT container environment include the following:

- Using either `sat` or `sat bash` always launches a container.
- The SAT container does not have access to the NCN file system.

There are two ways to run `sat`.

- **Interactive**: Launching a container using `sat bash`, followed by a `sat` command.
- **Non-interactive**: Running a `sat` command directly on a Kubernetes control plane node.

In both of these cases, a container is launched in the background to execute the command. The first option, running
`sat bash` first, gives an interactive shell, at which point `sat` commands can be run. In the second option, the
container is launched, executes the command, and upon the command's completion the container exits. The following two
examples show the same action, checking the system status, using both modes.

(`ncn-m001#`) Here is an example using interactive mode:

```bash
sat bash
```

(`(CONTAINER_ID) sat-container#`) Example `sat` command after a container is launched:

```bash
sat status
```

(`ncn-m001#`) Here is an example using non-interactive mode:

```bash
sat status
```

#### Interactive Advantages

Running `sat` using the interactive command prompt gives the ability to read and write local files on ephemeral
container storage. If multiple `sat` commands are being run in succession, use `sat bash` to launch the
container beforehand. This will save time because the container does not need to be launched for each `sat` command.

#### Non-interactive Advantages

The non-interactive mode is useful if calling `sat` with a script, or when running a single `sat` command as a part of
several steps that need to be executed from a management NCN.

#### Man Pages - Interactive and Non-interactive Modes

To view a `sat` man page from a Kubernetes control plane node, use `sat-man` on the manager node.

(`ncn-m001#`) Here is an example:

```bash
sat-man status
```

A man page describing the SAT container environment is available on the Kubernetes control plane nodes, which can be viewed
either with `man sat` or man `sat-podman` from the manager node.

(`ncn-m001#`) Here are examples:

```bash
man sat
```

```bash
man sat-podman
```

## Command Prompt Conventions in SAT

The host name in a command prompt indicates where the command must be run. The
user account that must run the command is also indicated in the prompt.

- The `root` or super-user account always has host name in the prompt and the
  `#` character at the end of the prompt.
- Any non-root account is indicated with `account@hostname>`. A non-privileged
  account is referred to as user.
- The command prompt inside the SAT container environment is indicated with the
  string as follows. It also has the `#` character at the end of the prompt.

| Command Prompt | Meaning |
|----------------|---------|
| `ncn-m001#` | Run the command as `root` on the specific Kubernetes control plane server which has this hostname (`ncn-m001` in this example). (**Non-interactive**) |
| `user@hostname>` | Run the command as any non-`root` user on the specified hostname. (**Non-interactive**) |
| `(venv) user@hostname>` | Run the command as any non-`root` user within a Python virtual environment on the specified hostname. (**Non-interactive**) |
| `(CONTAINER_ID) sat-container#` | Run the command inside the SAT container environment by first running `sat bash`. (**Interactive**) |

These command prompts should be inserted into text before the fenced code block
instead of inside of it. This is a change from the documentation of SAT 2.5 and
earlier. Here is an example of the new use of the command prompt:

1. (`ncn-m001#`) Example first step.

   ```bash
   yes >/dev/null
   ```
