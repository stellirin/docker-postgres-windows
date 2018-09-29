@echo off
SETLOCAL EnableDelayedExpansion

:: Build versions of PostgreSQL supported by BigSQL

set value=%~1
if [%value%] == [] (
    set pg11=true
    set pg10=true
    set pg96=true
    set pg95=true
    set pg94=true
)
if NOT [%value%] == [] (
    set %value%=true
)

:: PostgeSQL 11
if [%pg11%] == [true] (
    docker build ^
        --build-arg PGC_DB=pg11 ^
        --tag stellirin/postgres-windows:11 ^
        .
    docker push stellirin/postgres-windows:11
)
    
:: PostgeSQL 10
if [%pg10%] == [true] (
    docker build ^
        --build-arg PGC_DB=pg10 ^
        --tag stellirin/postgres-windows:10.5 ^
        --tag stellirin/postgres-windows:10 ^
        --tag stellirin/postgres-windows:latest ^
        .
    docker push stellirin/postgres-windows:10.5
    docker push stellirin/postgres-windows:10
    docker push stellirin/postgres-windows:latest
)

:: PostgeSQL 9.6
if [%pg96%] == [true] (
    docker build ^
        --build-arg PGC_DB=pg96 ^
        --tag stellirin/postgres-windows:9.6 ^
        --tag stellirin/postgres-windows:9 ^
        .
    docker push stellirin/postgres-windows:9.6
    docker push stellirin/postgres-windows:9
)

:: PostgeSQL 9.5
if [%pg95%] == [true] (
    docker build ^
        --build-arg PGC_DB=pg95 ^
        --tag stellirin/postgres-windows:9.5 ^
        .
    docker push stellirin/postgres-windows:9.5
)

:: PostgeSQL 9.4
if [%pg94%] == [true] (
    docker build ^
        --build-arg PGC_DB=pg94 ^
        --tag stellirin/postgres-windows:9.4 ^
        .
    docker push stellirin/postgres-windows:9.4
)
