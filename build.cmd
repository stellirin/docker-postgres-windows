@echo off
SETLOCAL EnableDelayedExpansion

:: Build versions of PostgreSQL supported by BigSQL

set value=%~1
if [%value%] == [] (
    set pg94=true
    set pg95=true
    set pg96=true
    set pg10=true
    set pg11=true
)
if NOT [%value%] == [] (
    set %value%=true
)

:: PostgeSQL 9.4
if [%pg94%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=9.4.23-2 ^
        --tag stellirin/postgres-windows:9.4.23 ^
        --tag stellirin/postgres-windows:9.4 ^
        .
    docker push stellirin/postgres-windows:9.4.23
    docker push stellirin/postgres-windows:9.4
)

:: PostgeSQL 9.5
if [%pg95%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=9.5.18-2 ^
        --tag stellirin/postgres-windows:9.5.18 ^
        --tag stellirin/postgres-windows:9.5 ^
        .
    docker push stellirin/postgres-windows:9.5.18
    docker push stellirin/postgres-windows:9.5
)

:: PostgeSQL 9.6
if [%pg96%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=9.6.14-2 ^
        --tag stellirin/postgres-windows:9.6.14 ^
        --tag stellirin/postgres-windows:9.6 ^
        .
    docker push stellirin/postgres-windows:9.6.14
    docker push stellirin/postgres-windows:9.6
)

:: PostgeSQL 10
if [%pg10%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=10.9-2 ^
        --tag stellirin/postgres-windows:10.9 ^
        --tag stellirin/postgres-windows:10 ^
        .
    docker push stellirin/postgres-windows:10.9
    docker push stellirin/postgres-windows:10
)

:: PostgeSQL 11
if [%pg11%] == [true] (
    docker build ^
        --pull ^
        --build-arg EDB_VER=11.4-2 ^
        --tag stellirin/postgres-windows:11.4 ^
        --tag stellirin/postgres-windows:11 ^
        --tag stellirin/postgres-windows:latest ^
        .
    docker push stellirin/postgres-windows:11.4
    docker push stellirin/postgres-windows:11
    docker push stellirin/postgres-windows:latest
)
