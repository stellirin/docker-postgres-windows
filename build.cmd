@echo off
SETLOCAL EnableDelayedExpansion

:: Usage: build.cmd pgValue winValue
    ::    pgValue: specifies a specific PostgreSQL version. One of:
    ::             pg94
    ::             pg95
    ::             pg96
    ::             pg10
    ::             pg11
    ::             pg12
    ::   winValue: specifies a specific Windows base image. One of:
    ::             win1607
    ::             win1709
    ::             win1803
    ::             win1809
    ::             win1903
    ::             win1909
:: If no values are specified then all images are built.

:: Batch file has no concept of a function, only goto
goto :start

:: CALL :image_build TAGNAME COREVER NANOVER EDBVER
:image_build
    set winVer=%~1
    set edbVer=%~2
    set pgVer=%edbVer:~0,-2%

    :: Modern version numbers: 10, 11, 12 etc.
    :: legacy version numbers: 9.4, 9.5, 9.6
    for /f "tokens=1,2,3 delims=." %%a in ("%pgVer%") do (
        if [%%c] == [] (
            set tagVer=%%a
        )
        if NOT [%%c] == [] (
            set tagVer=%%a.%%b
        )
    )

    docker build ^
        --build-arg WIN_VER=%winVer% ^
        --build-arg EDB_VER=%edbVer% ^
        --tag %repoName%:%pgVer%-%winVer% ^
        --tag %repoName%:%tagVer%-%winVer% ^
        .
    docker push %repoName%:%pgVer%-%winVer%
    docker push %repoName%:%tagVer%-%winVer%
EXIT /B 0

:: CALL :postgres_build EDBVER
:postgres_build
    set edbVer=%~1

    if [%win1809%] == [true] (
        call :image_build 1809 %edbVer%
    )
    if [%win1903%] == [true] (
        call :image_build 1903 %edbVer%
    )
    if [%win1909%] == [true] (
        call :image_build 1909 %edbVer%
    )
EXIT /B 0

:: call :manifest_build MANVER
:manifest_build
    set manVer=%~1
    docker manifest create --amend ^
        %repoName%:%manVer% ^
        %repoName%:%manVer%-1809 ^
        %repoName%:%manVer%-1903 ^
        %repoName%:%manVer%-1909
    docker manifest push %repoName%:%manVer%
EXIT /B 0

:: ------------------------------------------------------------
:: ------------------------------------------------------------
:: ------------------------------------------------------------

:start

set repoName=stellirin/postgres-windows

:: Build versions of PostgreSQL supported by EnterpriseDB
set pgValue=%~1
if [%pgValue%] == [] (
    echo Building all PostgreSQL versions
    set pg94=true
    set pg95=true
    set pg96=true
    set pg10=true
    set pg11=true
    set pg12=true
)
if NOT [%pgValue%] == [] (
    set %pgValue%=true
)

:: Build versions based on various Windows 10 base images
set winValue=%~2
if [%winValue%] == [] (
    set win1809=true
    set win1903=true
    set win1909=true
)
if NOT [%winValue%] == [] (
    set %winValue%=true
)

docker pull mcr.microsoft.com/windows/servercore:1809
docker pull mcr.microsoft.com/windows/servercore:1903
docker pull mcr.microsoft.com/windows/servercore:1909

docker pull mcr.microsoft.com/windows/nanoserver:1809
docker pull mcr.microsoft.com/windows/nanoserver:1903
docker pull mcr.microsoft.com/windows/nanoserver:1909

:: ------------------------------------------------------------
:: ------------------------------------------------------------
:: ------------------------------------------------------------

:: PostgreSQL 9.4
if [%pg94%] == [true] (
    call :postgres_build "9.4.24-2"
    if [%winValue%] == [] (
        call :manifest_build "9.4"
        call :manifest_build "9.4.24"
    )
)

:: PostgreSQL 9.5
if [%pg95%] == [true] (
    call :postgres_build "9.15.19-2"
    if [%winValue%] == [] (
        call :manifest_build "9.5"
        call :manifest_build "9.5.19"
    )
)

:: PostgreSQL 9.6
if [%pg96%] == [true] (
    call :postgres_build "9.6.15-2"
    if [%winValue%] == [] (
        call :manifest_build "9.6"
        call :manifest_build "9.6.15"
    )
)

:: PostgreSQL 10
if [%pg10%] == [true] (
    call :postgres_build "10.10-2"
    if [%winValue%] == [] (
        call :manifest_build "10"
        call :manifest_build "10.10"
    )
)

:: PostgreSQL 11
if [%pg11%] == [true] (
    call :postgres_build "11.5-2"
    if [%winValue%] == [] (
        call :manifest_build "11"
        call :manifest_build "11.5"
    )
)

:: PostgreSQL 12
if [%pg12%] == [true] (
    call :postgres_build "12.0-1"
    if [%winValue%] == [] (
        call :manifest_build "12"
        call :manifest_build "12.0"
    )
)
