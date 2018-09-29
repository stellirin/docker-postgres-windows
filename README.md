## Supported tags and `Dockerfile` links

-   [`11` (11/Dockerfile)](https://github.com/stellirin/docker-postgres-windows/blob/master/11/Dockerfile)
-   [`10.5`, `10`, `latest` (10/Dockerfile)](https://github.com/stellirin/docker-postgres-windows/blob/master/10/Dockerfile)
-   [`9.6`, `9` (9.6/Dockerfile)](https://github.com/stellirin/docker-postgres-windows/blob/master/9.6/Dockerfile)
-   [`9.5` (9.5/Dockerfile)](https://github.com/stellirin/docker-postgres-windows/blob/master/9.5/Dockerfile)
-   [`9.4` (9.4/Dockerfile)](https://github.com/stellirin/docker-postgres-windows/blob/master/9.4/Dockerfile)

## Quick reference

-   **Where to get help**:
    [the Docker Community Forums](https://forums.docker.com/), [the Docker Community Slack](https://blog.docker.com/2016/11/introducing-docker-community-directory-docker-community-slack/), or [Stack Overflow](https://stackoverflow.com/search?tab=newest&q=docker)

-   **Where to file issues**:
    [https://github.com/stellirin/docker-postgres-windows/issues](https://github.com/stellirin/docker-postgres-windows/issues)

-   **Maintained by**:
    [Stellar Iridescence](https://github.com/stellirin)

-   **Supported architectures**: ([more info](https://github.com/docker-library/official-images#architectures-other-than-amd64))
    [`windows-amd64`](https://hub.docker.com/u/winamd64/)

## What is PostgreSQL?

![logo](https://raw.githubusercontent.com/docker-library/docs/master/postgres/logo.png)

## How to use this image

```console
$ docker run --name some-postgres -e POSTGRES_PASSWORD=mysecretpassword -d stellirin/postgres-windows
```

This image includes `EXPOSE 5432` (the postgres port), so standard container linking will make it automatically available to the linked containers. The default `postgres` user and database are created in the entrypoint with `initdb`.

### Extended use

For further details about usage see the [official PostgreSQL container image](https://hub.docker.com/_/postgres/).

## About this container image

A Windows container to run PostgreSQL based on the [BigSQL](http://www.openscg.com/bigsql/about/) distribution, which is one of the two official distributions found on the [PostgeSQL for Windows](https://www.postgresql.org/download/windows/) download page.

This repository builds a Windows based Docker image that is functionaly similar to the official [Linux based Docker image](https://hub.docker.com/_/postgres/).

The BigSQL distribution was chosen over the EnterpriseDB distribution due to its ease of automating the installation with a Dockerfile.

### Testing

The resulting image has been (minimally) tested with a proprietary enterprise Java application. This image accepts typical SQL files, it can use TLS certificates in PEM format, and it allows the Java application to connect securely and process data.

So far, no differences in behaviour have been observed compared to the official Linux based container.

### Motivation

The Linux based Docker iamge cannot run on Windows as a LCOW container. This is due to differences in functionality between the NTFS and EXT4 file systems. Specifically, Linux commands such as `chown` do not work but the PostgreSQL iamges relies on them for security.

(An attempt was made to remove `chown` from the Linux based image, but PostgreSQL *strongly* resists being installed and run as the `root` user.)

### Entrypoint

The entrypoint is written as a batch script because the database is run on `windows/nanoserver`, which doesn't have PowerShell. Writing the entrypoint script was challenging due to batch script limitations, but this gives us a base image of less than `650MB` versus `5.25GB` when `microsoft/windowsservercore` is used.

The `Dockerfile` and the `docker-entrypoint.cmd` were strongly inspired by the equivalent files for the official Linux based Docker images. There are some minor deviations, but this is mostly to work around differences in Batch script behaviour.

### Licence

The files here are under the MIT licence, the same as the regular [docker-library/postgres](https://github.com/docker-library/postgres) docker files. Just like `docker-library/postges`, the licence here covers *only* the files in this repository. It doesn't cover the PostgreSQL distribution, which may have its own licence.
