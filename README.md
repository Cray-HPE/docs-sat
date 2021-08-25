# About Docs as Code

Documentation as Code (Docs as Code) is a methodology for creating
documentation using the same tools used for creating and releasing code to downstream consumers.

This document is intended as a guide to getting started with a new docs as
code project, and as the plan of record for the set of agreed
upon requirements which allow the resulting documentation to be published externally.

This is a living document and a work in progress.

## Overview

### Why

When software documentation uses the same version control, change tracking,
workflow, and release management practices as the software it describes,
it can be tightly coupled with the software releases, bringing
all aspects of product quality under similar control structure.

This approach recognizes that documentation is a fundamental component of the software release, and must develop in lock step with feature changes.

### How

Documentation is developed in markdown, stored in source control system.
Using principles of continuous integration, development, testing,
it is transformed into a format required for publishing.
The process used follows the same CICD/DevOps process used to produce
and store binary artifacts, or release candidates.

### Roles and Tasks

In a team structure, roles can be fluid between software engineers,
knowledge developers/writers, and DevOps engineers, depending on skillsets,
priorities, and maturity of the product.
Things work more smoothly if responsibility for the overall product
is shared, and roles are a bit fluid.

These roles can be shared:

* Content creation - Developers often write first drafts.
* Content editing
* Knowledge structure (outlines, website navigation, etc.)
* Pipeline development
* Pipeline stability
* Pipeline process

### Good candidates for this approach

YES: Product documentation that is rapidly evolving with a rapidly
evolving software product is a good candidate for this approach.
This includes installation, configuration, administration,
reference material for CLIs and APIs.

NO: Documentation which requires translation into other languages,
as this complexity significantly lengthens and delays the process.

NO: Content which is likely to be widely shared and embedded within
other products is not a good candidate, as it increases inter-product dependencies.

## Doc Creation 

### GIT source migrates to XML for HPE DITA/XML 

Documentation is created in GIT workflow, and is authoritative source.  
KM periodically that migrates to DITA/XML. Docs are created in KM authoring
environment and published via KM.

- Firmware Update Service

### Docs published from GIT Repo pipeline 

Source documentation is created in GIT workflow. Docs are created 
in build pipeline.  Docs are published via KM.

- Slingshot Docs

#### Publishing from GIT Repo 

##### Build artifacts

The build pipeline may produce the following artifacts as required by product management:

* RPMs, if the docs are to be installed on a system with the software,
or integrated into UIs.

* tar, to deliver to publishing pipleline.
The .tar should contain docs to be delivered to publishing process (hpe.support.com).

##### Identification

Version/Product information is meta-data about the document.
Meta-data exists in the form of package names, file names, document titles, and document contents, but may
also exist in the form of auxiliary files containing .json. Required meta-data for direct publishing needs
to be discussed:

* Artifact name should contain enough information to link that artifact
to a specific product build/version/git hash.
You should be able to identify exactly which version(s) of a repository contributed to that document.

* The name of a file within a release artifact should reflect the title of the document.

* Version information within document itself, visible to the reader,
should include product release version in enough granularity to associate
that document with a specific release using that product's versioning
strategy, usually semantic versioning, represented by major.minor.bugfix.
If to be published as a standalone pdf or html, the title of the
document should include the product name.

* Extra meta-data files

##### Notification

The publishing process, owned by the KM team, requires notice
when a particular package is available for publishing.

## Challenges

Certain challenges to a docs as code implementation reflect 
general release management challenges.

* Coordination between product releases.
Process to coordinate the availability of products at various levels.
This is a release management function.
This information is disseminated through a documentation type
(release notes, for example) separate from the product documentation itself.

* Uniformity in product versioning strategies.
This is a release Management function.

Other challenges are unique to a docs-as-code project that integrates
documentation from many product releases.

* Uniformity in style, formatting, quality.
There is an HPE style guide.  It must be adhered to.
This is a Knowledge Management function.

* Super structure that accomodates multiple products, and multiple versions 
of the products.  For example, suppose there is a bucket for system commands,
and various products contribute different system commands, which must all 
be located under the same system command headers.  A comprehensive 
information model, correctly applied, allows all information to be correctly labeled and 
retrieved.


## Local Examples

`https://stash.us.cray.com/projects/SHASTADOCS/repos/shasta-rest-site/browse`

`https://stash.us.cray.com/projects/SSHOT/repos/slingshot_docs/browse`

## More Reading

### Methodology

`https://www.writethedocs.org/guide/docs-as-code/`

### Editing/Linting

To lint this document, download `mdl`, and run `mdl README.md`.

`https://github.com/markdownlint/markdownlint`

`https://vim.fandom.com/wiki/Remove_unwanted_spaces`

### Markdown Editors

Macdown (MAC only)

Typora

# Migration to Docs-as-Code

## Create JIRA story to track this initial setup 

Story includes phases, which are child JIRAs:  

- Setup JIRA completion is marked when you are able to build a document in this repo, locally, and through
build pipeline, if required.  JIRA completion for initial setup implies that document is ready to be created using repo, not that the
document is complete or ready to be exposed to customers.  Subsequent JIRAs

- Initial Integration completion - source material is integrated.

## Consider these questions and tasks with dev before you get started.

- Where will this repo live?  Project/Repo?
The document correlates to source code.
Does this body of documentation correlate to one or many source repos? Which one(s)?  
If many repos feed into this, create a separate repos for docs.  If one source repo, 
locate docs within the source repo.

- Is there already a docs repo?  Is it correctly situated?

- Source material.  Confluence pages?  Existing docs git repo?  DITA - Existing Documentation.  Look at sources and
identify what is still valid going forward, and what is not.  Dev and Writer should agree on
validity of source material.

## Identify Name(s) of Customer Facing Document(s)

How many documents?  Names?  Does not have to be final/approved - just agree on names for now.

## Pipeline creation of customer facing document(s)

Yes, pipeline to produce html/pdf?  Or no pipeline - readers will rely on stash/github rendering of markdown.
How many documents? 

## Create Outline for new docs repo 

Collaboration between writer and dev. Writer integrates existing valid source material
into outline for each document to be produced. Can propose/edit outline in JIRA/Confluence.
See CASMHMS-4676 and [this confluence page](https://connect.us.cray.com/confluence/display/~nrockersho/1.5+FAS+Documentation+Plan)
for example of outline negotiation process.

## Set up REPO

Move docs-as-code template repo into newly created/identified docs location.

### Determine file structure. Divide into 2-4 major categories depending on outlines.  
For example, install, configure, admin, troubleshoot.

### Add skeletal .mds files.  Each .mds file corresponds to a document.  
Add "_include filename" to .mds files.

### Start building .md content, to be included in .mds files

## Set up Jenkins job to build docs, if necessary.

