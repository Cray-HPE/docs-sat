# System Admin Toolkit Command Overview

Describes the SAT Command Line Utility, lists the key commands found in the System Admin Toolkit man pages, and provides
instruction on the SAT Container Environment.

## SAT Command Line Utility

The primary component of the System Admin Toolkit (SAT) is a command-line utility run from Kubernetes manager nodes
(`ncn-m` nodes).

It is designed to assist administrators with common tasks, such as troubleshooting and querying information about the
HPE Cray EX System and its components, system boot and shutdown, and replacing hardware components. There are
similarities between SAT commands and xt commands used on the Cray XC platform.

## SAT Commands

The top-level SAT man page describes the toolkit, documents the global options affecting all subcommands, documents
configuration file options, and references the man page for each subcommand. SAT consists of many subcommands that each
have their own set of options.

## SAT Container Environment

The `sat` command-line utility runs in a container using podman, a daemonless container runtime. SAT runs on Kubernetes
manager nodes. A few important points about the SAT container environment include the following:

- Using either `sat` or `sat bash` always launches a container.
- The SAT container does not have access to the NCN file system.

There are two ways to run sat.

- **Interactive**: Launching a container using `sat bash`, followed by a `sat` command.
- **Non-interactive**: Running a `sat` command directly on a Kubernetes manager node.

In both of these cases, a container is launched in the background to execute the command. The first option, running
`sat bash` first, gives an interactive shell, at which point `sat` commands can be run. In the second option, the
container is launched, executes the command, and upon the command's completion the container exits. The following two
examples show the same action, checking the system status, using interactive and non-interactive modes.

### Interactive

```screen
ncn-m001# sat bash
(CONTAINER-ID)sat-container# sat status
```

### Non-interactive

```screen
ncn-m001# sat status
```

### Interactive Advantages

Running `sat` using the interactive command prompt gives the ability to read and write local files on ephemeral
container storage. If multiple `sat` commands are being run in succession, then use sat bash to launch the
container beforehand. This will save time because the container does not need to be launched for each `sat` command.

### Non-interactive Advantages

The non-interactive mode is useful if calling `sat` with a script, or when running a single `sat` command as a part of
several steps that need to be executed from a management NCN.

### Man Pages - Interactive and Non-interactive Modes

To view a `sat` man page from a Kubernetes manager node, use `sat-man` on the manager node as shown in the following
example.

```screen
ncn-m001# sat-man status
```

A man page describing the SAT container environment is available on the Kubernetes manager nodes, which can be viewed
either with `man sat` or man `sat-podman` from the manager node.

```screen
ncn-m001# man sat
```

```screen
ncn-m001# man sat-podman
```
