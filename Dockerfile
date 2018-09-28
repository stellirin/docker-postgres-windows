###
### PostgreSQL on Windows
###
FROM microsoft/windowsservercore:1803

# Set the variables for BigSQL
ENV PGC_REPO=https://s3.amazonaws.com/pgcentral \
    PGC_VER=3.3.7 \
    PGC_DB=pg10

##### Use PowerShell for the installation
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

### Required for BigSQL
ENV PYTHONIOENCODING="UTF-8" \
    PYTHONPATH="C:\\bigsql\\${PGC_DB}\\python\\site-packages" \
    GDAL_DATA="C:\\bigsql\\${PGC_DB}\\share\\gdal"

RUN New-Item -ItemType Directory -Path "C:\\docker-entrypoint-initdb.d" ; \
    New-Item -ItemType Directory -Path "C:\\docker-certificates.d"

### Download PostgreSQL
### https://www.postgresql.org/download/windows/
### https://www.openscg.com/bigsql/package-manager.jsp/
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Invoke-WebRequest $('{0}/bigsql-pgc-{1}.zip' -f $env:PGC_REPO,$env:PGC_VER) -OutFile 'C:\\bigsql.zip' ; \
    Expand-Archive 'C:\\bigsql.zip' -DestinationPath 'C:\\' ; \
    Remove-Item -Path 'C:\\bigsql.zip'

### Install PostgreSQL
RUN Invoke-Expression -Command $('C:\\bigsql\\pgc set GLOBAL REPO {0}' -f$ebv:PGC_REPO) ; \
    Invoke-Expression -Command   'C:\\bigsql\\pgc update --silent' ; \
    Invoke-Expression -Command $('C:\\bigsql\\pgc install --silent {0}' -f $env:PGC_DB)

#### make the sample config easier to munge (and "correct by default")
COPY docker-postgresql.conf.ps1 "C:\\bigsql\\hub\\scripts\\"
RUN  Invoke-Expression -Command 'C:\\bigsql\\hub\\scripts\\docker-postgresql.conf.ps1'

##### Switch back to the default shell
SHELL ["cmd", "/S", "/C"]

#### In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator
RUN setx /M PATH "C:\\bigsql\\%PGC_DB%\\bin;%PATH%"
USER ContainerUser

### Set regular variables for PSQL
ENV PGHOME="C:\\bigsql\\${PGC_DB}" \
    PGDATA="C:\\bigsql\\data\\${PGC_DB}" \
    PGLOGS="C:\\bigsql\\logs\\${PGC_DB}" \
    PGPORT=5432

### Create required directories
RUN mkdir %PGDATA% \
    mkdir %APPDATA%\postgresql

COPY docker-entrypoint.cmd "C:\\"
ENTRYPOINT ["C:\\docker-entrypoint.cmd"]

EXPOSE 5432
CMD ["postgres"]
