# Brokenspoke-analyzer

[![ci](https://github.com/PeopleForBikes/brokenspoke-analyzer/actions/workflows/ci.yaml/badge.svg)](https://github.com/PeopleForBikes/brokenspoke-analyzer/actions/workflows/ci.yaml)
[![Latest Version](https://img.shields.io/github/v/tag/PeopleForBikes/brokenspoke-analyzer?sort=semver&label=version)](https://github.com/PeopleForBikes/brokenspoke-analyzer/)
[![License](https://img.shields.io/badge/license-mit-blue.svg)](https://github.com/PeopleForBikes/brokenspoke-analyzer/blob/main/LICENSE)
[![Code of Conduct](https://img.shields.io/badge/code_of_conduct-🌐-ff69b4.svg?logoColor=white)](https://github.com/PeopleForBikes/brokenspoke-analyzer/blob/main/code-of-conduct.md)

The Brokenspoke Analyzer is a tool allowing the user to run “Bicycle Network
Analysis” locally.

## Requirements

- **docker**: [get started](https://www.docker.com/get-started/)
- **osmium**: [official page](https://osmcode.org/osmium-tool/)

### Build the Azavea docker image

Azavea provides the code to build the Docker image that is used to run an
analysis. There is no Image directly available at the time, thus it will
necessary to build it manually.

```bash
git clone git@github.com:azavea/pfb-network-connectivity.git
cd pfb-network-connectivity/src/
DOCKER_BUILDKIT=1 docker build -t azavea/analyzer:13-3.1 -f analysis/Dockerfile .
```

## Install

Install the tool from GitHub directly:

```bash
pip install git+https://github.com/PeopleForBikes/brokenspoke-analyzer
```

This will add a new command named `bna`.

## Quickstart

To run an analysis, the tools needs 2 parameters:

- The name of the country or dataset where the city is located.
- The name of the city.

Then simply run the tool, and all the steps will be performed automatically:

```bash
$ bna run arizona flagstaff
[17:00:55] Boundary files ready.
Downloaded Protobuf data 'arizona-latest.osm.pbf' (204.86 MB) to:
'data/arizona-latest.osm.pbf'
[17:07:21] OSM Region file downloaded.
           OSM file for flagstaff ready.
           Analysis for flagstaff complete.
```
