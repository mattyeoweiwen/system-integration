<!---
.. ===============LICENSE_START=======================================================
.. Acumos CC-BY-4.0
.. ===================================================================================
.. Copyright (C) 2018 AT&T Intellectual Property & Tech Mahindra. All rights reserved.
.. ===================================================================================
.. This Acumos documentation file is distributed by AT&T and Tech Mahindra
.. under the Creative Commons Attribution 4.0 International License (the "License");
.. you may not use this file except in compliance with the License.
.. You may obtain a copy of the License at
..
..      http://creativecommons.org/licenses/by/4.0
..
.. This file is distributed on an "AS IS" BASIS,
.. WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
.. See the License for the specific language governing permissions and
.. limitations under the License.
.. ===============LICENSE_END=========================================================
-->

# START HERE

For those unfamiliar with Acumos and by extension `z2a`, this is a quick intro.
If you are here, you may know what Acumos is but you probably don't know:

* what is `z2a`?
* where do I start with `z2a`?

## What is `z2a`

`Zero-to-Acumos` (`z2a`) is a collection of Linux shell scripts that have been assembled to perform a simple set of tasks:  install and (where possible) configure Acumos.

`z2a` is composed of two (2) distinct process flows; Flow-1 and Flow-2. In each flow scenario, installation of additional Acumos plugins is optional as a follow-on procedure.

## What is `z2a` Flow-1

`z2a` Flow-1 (default) performs an Acumos installation including:

* end-user environment creation;
* VM Operating System preparation;
* `z2a` dependency installation;
* Kubernetes cluster creation; and,
* deployment of Acumos noncore and core components on a single VM.

`z2a` Flow-1 is based on the original `z2a` process flow targeting development/test environments where a Kubernetes cluster is built and Acumos is installed from scratch on a single VM.

>NOTE: `z2a` (Flow-1) should not be used as a production environment deployment tool at this time.  `z2a` (Flow-1) has been primarily designed for development and/or test environment installations.  Currently, a key component of `z2a` (Flow-1), `kind` -  Kubernetes in Docker - is not recommended for production installation or production workloads.

## What is `z2a` Flow-2

`z2a` Flow-2 performs an Acumos installation including:

* end-user environment creation;
* `z2a` dependency installation;
* deployment of Acumos noncore and core components on an existing Kubernetes cluster.

The second process flow is a new `z2a` process flow targeting pre-built Kubernetes cluster environments. (i.e. BYOC - Bring Your Own Cluster)

## Where do I start with `z2a`

If you just want to start installing Acumos, refer to the TL;DR sections of the INSTALL.md document. The TL;DR sections provide abbreviated installation guides for Acumos and Acumos plugins.

Please refer to the following documents for additional information:

>CONFIG.md       - Acumos configuration information document (in progress)
>
>DIR-Listing.md  - Directory Listing document
>
>FAQ.md          - Frequently Asked Questions document
>
>HOWTO.md        - Acumos task document (in progress)
>
>INSTALL.md      - Acumos installation document (in progress)
>
>README-PLUGINS-SETUP.md - Acumos Plugin setup guidance document (in progress)
>
>README-PROXY.md - proxy configuration guidance (in progress)
>
>README-VALUES.md - changing values for various subsystems (in progress)
>
>README.md        - project README file (in progress)
>
>START-HERE.md   - brief Acumos introduction document (this document - in progress)
>
>TL-DR.md        - Too Long; Didn't Read (extracted from INSTALL.md)

```sh
// Created: 2020/06/23
// Last modified: 2020/10/21
```
