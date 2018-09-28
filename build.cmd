:: Build all version of PostgreSQL supported by BigSQL

:: PostgeSQL 11
docker build ^
    --build-arg PGC_DB=pg11 ^
    --tag stellirin/postgres-windows:11 ^
    .
    
:: PostgeSQL 10
docker build ^
    --build-arg PGC_DB=pg10 ^
    --tag stellirin/postgres-windows:10 ^
    .

:: PostgeSQL 9.6
docker build ^
    --build-arg PGC_DB=pg96 ^
    --tag stellirin/postgres-windows:9.6 ^
    .

:: PostgeSQL 9.5
docker build ^
    --build-arg PGC_DB=pg95 ^
    --tag stellirin/postgres-windows:9.5 ^
    .

:: PostgeSQL 9.4
docker build ^
    --build-arg PGC_DB=pg94 ^
    --tag stellirin/postgres-windows:9.4 ^
    .
