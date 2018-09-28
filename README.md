# PostgreSQL as a Windows container

A Windows container to run PostgreSQL based on the [BigSQL](http://www.openscg.com/bigsql/about/) distribution, which is one of the two official distributions found on the [PostgeSQL for Windows](https://www.postgresql.org/download/windows/) download page.

## Intent

This repository should build a Windows based Docker image that has functionality similar to the official [Linux based Docker image](https://hub.docker.com/_/postgres/).

BigSQL was chosen over the EnterpriseDB distribution due to its ease of installation in a container.

## Motivation

The Linux based Docker iamge cannot run on Windows as a LCOW container. This is due to the difference in functionality between the NTFS and EXT4 file systems. Specifically, Linux commands such as `chown` do not work.

(An attempt was made to remove `chown` from the Linux based image, but PostgreSQL strongly resists being installed and run as the `root` user.)

## Entrypoint

The entrypoint is written as a batch script because we run this on `windows/nanoserver`, which doesn't have PowerShell. While writing the entrypoint script was challenging due to batch scripts limitations, this gives us a base image of less than `650MB` versus `5.25GB` when `microsoft/windowsservercore` is used.

## Licence

The files here are under a liberal licence. The licence here covers *only* the files in this repository. It doesn't cover the PostgreSQL distribution, which has its own licence. The licence is subject to change without notice.
