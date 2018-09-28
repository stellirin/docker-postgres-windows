###
### PostgreSQL on Windows
###
FROM microsoft/windowsservercore:1803 as install

# Set the variables for BigSQL
ENV PGC_REPO=https://s3.amazonaws.com/pgcentral \
    PGC_VER=3.3.7

##### Use PowerShell for the installation
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

### Required for BigSQL
ENV PYTHONIOENCODING="UTF-8"

### Download PostgreSQL
### https://www.postgresql.org/download/windows/
### https://www.openscg.com/bigsql/package-manager.jsp/
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Invoke-WebRequest $('{0}/bigsql-pgc-{1}.zip' -f $env:PGC_REPO,$env:PGC_VER) -OutFile 'C:\\bigsql.zip' ; \
    Expand-Archive 'C:\\bigsql.zip' -DestinationPath 'C:\\' ; \
    Remove-Item -Path 'C:\\bigsql.zip'

### Update BigSQL
RUN Invoke-Expression -Command $('C:\\bigsql\\pgc set GLOBAL REPO {0}' -f$env:PGC_REPO) ; \
    Invoke-Expression -Command   'C:\\bigsql\\pgc update --silent'

### Set the PostgreSQL version we will install
### This is set here to allow us to reuse the abover layers
ARG PGC_DB
ENV PGC_DB=${PGC_DB}

### Install PostgreSQL
RUN Invoke-Expression -Command $('C:\\bigsql\\pgc install --silent {0}' -f $env:PGC_DB)

#### make the sample config easier to munge (and "correct by default")
COPY docker-postgresql.conf.ps1 "C:\\bigsql\\hub\\scripts\\"
RUN  Invoke-Expression -Command 'C:\\bigsql\\hub\\scripts\\docker-postgresql.conf.ps1'

###
### PostgreSQL on Windows Nano Server
###
FROM microsoft/nanoserver:1803

### Required for BigSQL
ARG PGC_DB
ENV PGC_DB=${PGC_DB} \
    PYTHONIOENCODING="UTF-8" \
    PYTHONPATH="C:\\bigsql\\${PGC_DB}\\python\\site-packages" \
    GDAL_DATA="C:\\bigsql\\${PGC_DB}\\share\\gdal"

#### Copy over the prepared BigSQL installation
COPY --from=install "C:\\bigsql" "C:\\bigsql"

#### In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator
RUN setx /M PATH "C:\\bigsql\\%PGC_DB%\\bin;%PATH%"
USER ContainerUser

### Set regular variables for PSQL
ENV PGHOME="C:\\bigsql\\${PGC_DB}" \
    PGDATA="C:\\bigsql\\data\\${PGC_DB}" \
    PGLOGS="C:\\bigsql\\logs\\${PGC_DB}" \
    PGPORT="5432"

### Create required directories
RUN mkdir "%PGDATA%" \
    mkdir "%PGLOGS%" \
    mkdir "%APPDATA%\\postgresql" \
    mkdir "C:\\docker-entrypoint-initdb.d" \
    mkdir "C:\\docker-certificates.d"

COPY docker-entrypoint.cmd "C:\\"
ENTRYPOINT ["C:\\docker-entrypoint.cmd"]

EXPOSE 5432
CMD ["postgres"]
