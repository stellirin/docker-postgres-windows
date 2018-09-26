@echo off

set PGC_PASS=Passw0rd
set PGC_ROOT=C:\bigsql\pg10
set PGC_DATA=C:\bigsql\data\pg10

:: look specifically for PG_VERSION, as it is expected in the DB dir
if NOT exist "%PGC_DATA%\PG_VERSION" (

    echo %PGC_PASS%> "%PGC_ROOT%\.pgpass"

    echo Creating a new database...
    call pgc init pg10
    call %PGC_ROOT%\pg10-env.bat

    :: internal start of server in order to allow set-up using psql-client
    :: does not listen on external TCP/IP and waits until start finishes
    echo Starting database for inital setup...
    call pgc start
    timeout /t 5
    call pgc status

    :: Execute any SQL scripts for this new DB
    for %%f in (C:\docker-entrypoint-initdb.d\*.sql) do (
        echo psql: running %%f
        call psql -v ON_ERROR_STOP=1 ^
            --no-password ^
            -f "%%f"
    )

    :: Shut down the server, DB is now ready
    echo Stopping database after inital setup...
    call pgc stop

    echo PostgreSQL init process complete; ready for start up.
)

:: Load the environment variables
echo Load the environment variables
call %PGC_ROOT%\pg10-env.bat

:: start the database
echo Start the database
call %*
