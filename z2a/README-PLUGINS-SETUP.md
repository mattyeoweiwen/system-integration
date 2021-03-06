# README - Acumos plugins-setup scripts

## Prerequisites

## Setting up the environment

To run (execute) the `z2a plugins-setup` scripts in a standalone manner (i.e.
from a Linux CLI session), you must execute the `0-kind/0a-env.sh` script
before you run any of the these scripts.

> Assumption:
>
> The Acumos `system-integration` repository has been cloned into: `$HOME/src`

To setup the environment, execute the following commands:

```sh
cd $HOME/src/system-integration/z2a
./0-kind/0-env.sh
```

## ACUMOS_GLOBAL_VALUE

For the scripts in the `plugins-setup` directory to run stand-alone (i.e.
outside the `z2a` Flow-1 or Flow-2 context), the `ACUMOS_GLOBAL_VALUE`
environment variable MUST be set BEFORE executing `make` to install or
configure any of the defined targets in the `noncore-config/Makefile`.

If you have downloaded the Acumos `system-integration` repository from
`gerrit.acumos.org` then the following command would set the
`ACUMOS_GLOBAL_VALUE` environment variable:

```sh
export ACUMOS_GLOBAL_VALUE=$HOME/src/system-integration/helm-charts/global_value.yaml
```

## Installing and Configuring Plugins

> NOTE:  At the time of this writing, only MLWB and it's dependencies
(CouchDB, JupyterHub and NiFi) are included in the `plugins-setup` directory.

#### Installing and Configuring - CouchDB (MLWB Dependency)

Execute `./deploy.sh couchdb` will install (and configure based on the
target script) CouchDB.

#### Installing and Configuring - JupyterHub (MLWB Dependency)

Execute `./deploy.sh jupyterhub` will install (and configure based on the
target script) JupyterHub.

#### Installing and Configuring - NiFi (MLWB Dependency)

Execute `./deploy.sh nifi` will install (and configure based on the target
script) NiFi.

### Installing and Configuring - MLWB (ML WorkBench)

NOTE: The three (3) MLWB dependencies (CouchDB, JupyterHub, NiFi) should be
installed prior to the installation of MLWB.

Execute `./deploy.sh mlwb` will install (and configure based on the target
script) MLWB.

```bash
// Created: 2020/04/28
// Last Edited: 2020/08/11
```
