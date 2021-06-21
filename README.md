# SAT Documentation

## About this repository

This repository is based on docs-as-code: https://stash.us.cray.com/projects/SHASTADOCS/repos/docs-as-code/browse

## Build documentation

The recommended way of viewing SAT documentation is HTML.

```
$ cd portal/developer-portal/
```

### Make HTML documentation

```
$ make html
$ open docs/html/sat.html
```

### Make a PDF of the documentation

```
$ make pdf
$ open docs/pdf/sat.pdf
```

### Create a tar archive of PDF and HTML documentation

```
$ make tar
$ open docs/pdfhtml.tar
```
