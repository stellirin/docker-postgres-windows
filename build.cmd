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
        --build-arg EDB_VER=9.4.21-1 ^
        --tag stellirin/postgres-windows:9.4.21 ^
        --tag stellirin/postgres-windows:9.4 ^
        .
    docker push stellirin/postgres-windows:9.4.21
    docker push stellirin/postgres-windows:9.4
)

:: PostgeSQL 9.5
if [%pg95%] == [true] (
    docker build ^
        --build-arg EDB_VER=9.5.16-1 ^
        --tag stellirin/postgres-windows:9.5.16 ^
        --tag stellirin/postgres-windows:9.5 ^
        .
    docker push stellirin/postgres-windows:9.5.16
    docker push stellirin/postgres-windows:9.5
)

:: PostgeSQL 9.6
if [%pg96%] == [true] (
    docker build ^
        --build-arg EDB_VER=9.6.12-2 ^
        --tag stellirin/postgres-windows:9.6.12 ^
        --tag stellirin/postgres-windows:9.6 ^
        .
    docker push stellirin/postgres-windows:9.6.12
    docker push stellirin/postgres-windows:9.6
)

:: PostgeSQL 10
if [%pg10%] == [true] (
    docker build ^
        --build-arg EDB_VER=10.7-2 ^
        --tag stellirin/postgres-windows:10.7 ^
        --tag stellirin/postgres-windows:10 ^
        .
    docker push stellirin/postgres-windows:10.7
    docker push stellirin/postgres-windows:10
)

:: PostgeSQL 11
if [%pg11%] == [true] (
    docker build ^
        --build-arg EDB_VER=11.2-2 ^
        --tag stellirin/postgres-windows:11.2 ^
        --tag stellirin/postgres-windows:11 ^
        --tag stellirin/postgres-windows:latest ^
        .
    docker push stellirin/postgres-windows:11.2
    docker push stellirin/postgres-windows:11
    docker push stellirin/postgres-windows:latest
)
