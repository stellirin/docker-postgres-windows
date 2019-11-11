@echo off
SETLOCAL EnableDelayedExpansion

set tagVer=1809

docker pull mcr.microsoft.com/windows/servercore:%tagVer%
docker pull mcr.microsoft.com/windows/nanoserver:%tagVer%

:: Build versions of PostgreSQL supported by EnterpriseDB

set value=%~1
if [%value%] == [] (
    set pg94=true
    set pg95=true
    set pg96=true
    set pg10=true
    set pg11=true
    set pg12=true
)
if NOT [%value%] == [] (
    set %value%=true
)

:: PostgeSQL 9.4
if [%pg94%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=9.4.24-2 ^
        --build-arg TAG_VER=%tagVer% ^
        --tag stellirin/postgres-windows:9.4.24 ^
        --tag stellirin/postgres-windows:9.4 ^
        .
    docker push stellirin/postgres-windows:9.4.24
    docker push stellirin/postgres-windows:9.4
)

:: PostgeSQL 9.5
if [%pg95%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=9.5.19-2 ^
        --build-arg TAG_VER=%tagVer% ^
        --tag stellirin/postgres-windows:9.5.19 ^
        --tag stellirin/postgres-windows:9.5 ^
        .
    docker push stellirin/postgres-windows:9.5.19
    docker push stellirin/postgres-windows:9.5
)

:: PostgeSQL 9.6
if [%pg96%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=9.6.15-2 ^
        --build-arg TAG_VER=%tagVer% ^
        --tag stellirin/postgres-windows:9.6.15 ^
        --tag stellirin/postgres-windows:9.6 ^
        .
    docker push stellirin/postgres-windows:9.6.15
    docker push stellirin/postgres-windows:9.6
)

:: PostgeSQL 10
if [%pg10%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=10.10-2 ^
        --build-arg TAG_VER=%tagVer% ^
        --tag stellirin/postgres-windows:10.10 ^
        --tag stellirin/postgres-windows:10 ^
        .
    docker push stellirin/postgres-windows:10.10
    docker push stellirin/postgres-windows:10
)

:: PostgeSQL 11
if [%pg11%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=11.5-2 ^
        --build-arg TAG_VER=%tagVer% ^
        --tag stellirin/postgres-windows:11.5 ^
        --tag stellirin/postgres-windows:11 ^
        .
    docker push stellirin/postgres-windows:11.5
    docker push stellirin/postgres-windows:11
)

:: PostgeSQL 12
if [%pg12%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=12.0-1 ^
        --build-arg TAG_VER=%tagVer% ^
        --tag stellirin/postgres-windows:12.0 ^
        --tag stellirin/postgres-windows:12 ^
        --tag stellirin/postgres-windows:latest ^
        .
    docker push stellirin/postgres-windows:12.0
    docker push stellirin/postgres-windows:12
    docker push stellirin/postgres-windows:latest
)
