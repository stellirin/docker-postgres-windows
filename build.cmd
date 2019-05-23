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
        --build-arg EDB_VER=9.4.22-1 ^
        --tag stellirin/postgres-windows:9.4.22 ^
        --tag stellirin/postgres-windows:9.4 ^
        .
    docker push stellirin/postgres-windows:9.4.22
    docker push stellirin/postgres-windows:9.4
)

:: PostgeSQL 9.5
if [%pg95%] == [true] (
    docker build ^
        --build-arg EDB_VER=9.5.17-1 ^
        --tag stellirin/postgres-windows:9.5.17 ^
        --tag stellirin/postgres-windows:9.5 ^
        .
    docker push stellirin/postgres-windows:9.5.17
    docker push stellirin/postgres-windows:9.5
)

:: PostgeSQL 9.6
if [%pg96%] == [true] (
    docker build ^
        --build-arg EDB_VER=9.6.13-1 ^
        --tag stellirin/postgres-windows:9.6.13 ^
        --tag stellirin/postgres-windows:9.6 ^
        .
    docker push stellirin/postgres-windows:9.6.13
    docker push stellirin/postgres-windows:9.6
)

:: PostgeSQL 10
if [%pg10%] == [true] (
    docker build ^
        --build-arg EDB_VER=10.8-1 ^
        --tag stellirin/postgres-windows:10.8 ^
        --tag stellirin/postgres-windows:10 ^
        .
    docker push stellirin/postgres-windows:10.8
    docker push stellirin/postgres-windows:10
)

:: PostgeSQL 11
if [%pg11%] == [true] (
    docker build ^
        --build-arg EDB_VER=11.3-1 ^
        --tag stellirin/postgres-windows:11.3 ^
        --tag stellirin/postgres-windows:11 ^
        --tag stellirin/postgres-windows:latest ^
        .
    docker push stellirin/postgres-windows:11.3
    docker push stellirin/postgres-windows:11
    docker push stellirin/postgres-windows:latest
)
