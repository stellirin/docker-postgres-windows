###
### PostgreSQL in Windows
###
FROM microsoft/windowsservercore:1803

##### Use PowerShell for the installation
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

### Required for BigSQL
ENV PYTHONIOENCODING="UTF-8" \
    PYTHONPATH="C:\\bigsql\\pg10\\python\\site-packages" \
    GDAL_DATA="C:\\bigsql\\pg10\\share\\gdal"

RUN New-Item -ItemType Directory -Path "C:\\docker-entrypoint-initdb.d"

### Download PostgreSQL
### https://www.postgresql.org/download/windows/
### https://www.openscg.com/bigsql/package-manager.jsp/
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Invoke-WebRequest 'https://s3.amazonaws.com/pgcentral/bigsql-pgc-3.3.7.zip' -OutFile 'C:\\bigsql.zip' ; \
    Expand-Archive 'C:\\bigsql.zip' -DestinationPath 'C:\\' ; \
    Remove-Item -Path 'C:\\bigsql.zip'

### Install PostgreSQL
RUN Invoke-Expression -Command 'C:\\bigsql\\pgc set GLOBAL REPO https://s3.amazonaws.com/pgcentral' ; \
    Invoke-Expression -Command 'C:\\bigsql\\pgc update --silent' ; \
    Invoke-Expression -Command 'C:\\bigsql\\pgc install --silent pg10'

##### Switch back to the default shell
SHELL ["cmd", "/S", "/C"]

#### In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator
RUN setx /M PATH "C:\\bigsql\\pg10\\bin;%PATH%"
USER ContainerUser
ENV PGHOME="C:\\bigsql\\pg10" \
    PGDATA="C:\\bigsql\\data\\pg10" \
    PGLOGS="C:\\bigsql\\logs\\pg10" \
    PGPORT=5432

# Create required directories
RUN mkdir %PGDATA% \
    mkdir %APPDATA%\postgresql

COPY docker-entrypoint.cmd "C:\\"
ENTRYPOINT ["C:\\docker-entrypoint.cmd"]

EXPOSE 5432
CMD ["postgres"]
