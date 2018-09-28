# PostgreSQL as a Windows container

A Windows container to run PostgreSQL based on the [BigSQL](http://www.openscg.com/bigsql/about/) distribution, which is one of the two official distributions found on the [PostgeSQL for Windows](https://www.postgresql.org/download/windows/) download page.

## Overview

This repository builds a Windows based Docker image that is functionaly similar to the official [Linux based Docker image](https://hub.docker.com/_/postgres/).

The BigSQL distribution was chosen over the EnterpriseDB distribution due to its ease of automating the installation with a Dockerfile.

## Testing

The resulting image has been (minimally) tested with a proprietary enterprise Java application. This image accepts typical SQL files, it can use TLS certificates in PEM format, and it allows the Java application to connect securely and process data.

So far, no differences in behaviour have been observed compared to the official Linux based container.

## Motivation

The Linux based Docker iamge cannot run on Windows as a LCOW container. This is due to differences in functionality between the NTFS and EXT4 file systems. Specifically, Linux commands such as `chown` do not work but the PostgreSQL iamges relies on them for security.

(An attempt was made to remove `chown` from the Linux based image, but PostgreSQL *strongly* resists being installed and run as the `root` user.)

## Entrypoint

The entrypoint is written as a batch script because the database is run on `windows/nanoserver`, which doesn't have PowerShell. Writing the entrypoint script was challenging due to batch script limitations, but this gives us a base image of less than `650MB` versus `5.25GB` when `microsoft/windowsservercore` is used.

The `Dockerfile` and the `docker-entrypoint.cmd` were strongly inspired by the equivalent files for the official Linux based Docker images. There are some minor deviations, but this is mostly to work around differences in Batch script behaviour.

## Licence

The files here are under the MIT licence, the same as the regular [docker-library/postgres](https://github.com/docker-library/postgres) docker files. Just like `docker-library/postges`, the licence here covers *only* the files in this repository. It doesn't cover the PostgreSQL distribution, which may have its own licence.
