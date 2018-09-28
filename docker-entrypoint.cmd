@echo off

:: Batch file has no concept of a function, only goto
goto :start

:: usage: CALL :file_env VARIABLE [DEFAULT]
::    ie: CALL :file_env 'XYZ_DB_PASSWORD' 'example'
::       (will allow for "%XYZ_DB_PASSWORD_FILE%" to fill in the value of
::       "%XYZ_DB_PASSWORD%" from a file, especially for Docker's secrets feature)
:file_env
SETLOCAL EnableDelayedExpansion
set cmdVar=%~1
set fileVar=%cmdVar%_FILE
set default=%~2
:: No concept of AND in batch scripts
:: Instead we use nested if
if NOT [!%cmdVar%!] == [] (
    if NOT [!%fileVar%!] == [] (
        :: Instead of exiting, just use the environment value
        echo Warning: both %cmdVar% and %fileVar% are set, %fileVar% will be ignored
    )
)
:: set as the default value
set value=%default%
if NOT [!%cmdVar%!] == [] (
    :: override with the environment value
    set value=!%cmdVar%!
)
:: No concept of ELIF in batch scripts
:: we use nested if with opposite test
if [!%cmdVar%!] == [] (
    if NOT [!%fileVar%!] == [] (
        :: override with the file value
        set /p value=<!%fileVar%!
    )
)
ENDLOCAL & (
    set %cmdVar%=%value%
)
EXIT /B 0

:: ------------------------------------------------------------
:: ------------------------------------------------------------
:: ------------------------------------------------------------

:start

:: Ensure the directories exist with correct permissions
if NOT exist %PGDATA% (
    mkdir %PGDATA%
)
call icacls "%PGDATA%" /grant "%USERNAME%":(OI)(CI)F > NUL
if NOT exist %PGLOGS% (
    mkdir %PGLOGS%
)
call icacls "%PGLOGS%" /grant "%USERNAME%":(OI)(CI)F > NUL

:: look specifically for PG_VERSION, as it is expected in the DB dir
if NOT exist "%PGC_DATA%\PG_VERSION" (

    CALL :file_env POSTGRES_USER, postgres
    CALL :file_env POSTGRES_PASSWORD

    :: TODO: find out why setting POSTGRES_PASSWORD as env works on Linux
    echo %POSTGRES_PASSWORD%> "%PGHOME%\.pgpass"

    CALL :file_env POSTGRES_INITDB_ARGS
    if NOT [%POSTGRES_INITDB_WALDIR%] == [] (
        set POSTGRES_INITDB_ARGS=%POSTGRES_INITDB_ARGS% --waldir %POSTGRES_INITDB_WALDIR%
    )
    call initdb -U "%POSTGRES_USER%" -A md5 -E UTF8 --no-locale -D "%PGDATA%" --pwfile="%PGHOME%\.pgpass" %$POSTGRES_INITDB_ARGS% > "%PGLOGS%\install.log" 2>&1

    :: Set a valid password file and delete the temporary password file
    echo localhost:%PGPORT%:*:%POSTGRES_USER%:%POSTGRES_PASSWORD%> %APPDATA%\postgresql\pgpass.conf
    echo 127.0.0.1:%PGPORT%:*:%POSTGRES_USER%:%POSTGRES_PASSWORD%>> %APPDATA%\postgresql\pgpass.conf
    copy %PGHOME%\init\pg_hba.conf %PGDATA%\pg_hba.conf > NUL
    call del "%PGHOME%\.pgpass"

    :: Set the initial connection environment
    set PGUSER=%POSTGRES_USER%
    set PGDATABASE=postgres
    set PGPASSFILE=%APPDATA%\postgresql\pgpass.conf

    :: internal start of server in order to allow set-up using psql-client
    :: does not listen on external TCP/IP and waits until start finishes
	call pg_ctl -D "%PGDATA%" -w start

    set psqlOpt=^-v ON_ERROR_STOP=1

    if NOT [%POSTGRES_USER%] == [postgres] (
        echo CREATE DATABASE :"db"; | call psql %psqlOpt% --dbname postgres --set db="%POSTGRES_USER%"
        set PGDATABASE=%POSTGRES_USER%
    )
    set psqlOpt=^-v ON_ERROR_STOP=1 --dbname "%PGDATABASE%"

    :: Execute any SQL scripts for this new DB
    for %%f in (C:\docker-entrypoint-initdb.d\*.sql) do (
        echo psql: running %%f
        call psql %psqlOpt% -f "%%f"
    )

    pg_ctl -D "%PGDATA%" -m fast -w stop

    echo PostgreSQL init process complete; ready for start up.
)

:: Set the connection environment
set PGUSER=%POSTGRES_USER%
set PGDATABASE=%POSTGRES_USER%
set PGPASSFILE=%APPDATA%\postgresql\pgpass.conf

:: start the database
call %*
