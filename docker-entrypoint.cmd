@echo off

set PGC_PASS=Passw0rd
set PGC_ROOT=C:\bigsql\%PSQL_VER%
set PGC_DATA=C:\bigsql\data\%PSQL_VER%

:: look specifically for PG_VERSION, as it is expected in the DB dir
if NOT exist "%PGC_DATA%\PG_VERSION" (

    echo %PGC_PASS%> "%PGC_ROOT%\.pgpass"

    echo Creating a new database...
    call %PGC_CMD% init %PSQL_VER%

    :: internal start of server in order to allow set-up using psql
    echo Starting database for inital setup...
    call %PGC_ROOT%\%PSQL_VER%-env.bat
    call %PGC_CMD% start
    timeout /t 5 /nobreak
    call %PGC_CMD% status

    :: Execute any SQL scripts for this new DB
    for %%f in (C:\docker-entrypoint-initdb.d\*.sql) do (
        echo psql: running %%f
        call psql -v ON_ERROR_STOP=1 --no-password -f "%%f"
    )

    :: Shut down the server, DB is now ready
    echo Stopping database after inital setup...
    call %PGC_CMD% stop
    timeout /t 5 /nobreak
    call %PGC_CMD% status

    echo PostgreSQL init process complete; ready for start up.
)

:: Load the environment variables
echo Loading the environment variables...
call %PGC_ROOT%\%PSQL_VER%-env.bat

:: start the database
echo Starting the database...
call %*
