###
### PostgreSQL in Windows
###
FROM microsoft/windowsservercore:1803

# Use PowerShell for the installation
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Required for BigSQL
ENV PYTHONIOENCODING="UTF-8" \
    PSQL_VER="pg10" \
    PGC_VER="3.3.7" \
    PGC_REPO="https://s3.amazonaws.com/pgcentral" \
    PGC_CMD="C:\\bigsql\\pgc"

### Download PostgreSQL
### https://www.postgresql.org/download/windows/
### https://www.openscg.com/bigsql/package-manager.jsp/
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Invoke-WebRequest $('{0}/bigsql-pgc-{1}.zip' -f $Env:PGC_REPO,$Env:PGC_VER) -OutFile 'C:\\bigsql.zip' ; \
    Expand-Archive 'C:\\bigsql.zip' -DestinationPath 'C:\\' ; \
    Remove-Item -Path 'C:\\bigsql.zip'

### Install PostgreSQL
RUN Invoke-Expression -Command $('{0} set GLOBAL REPO {1}' -f $Env:PGC_CMD,$Env:PGC_REPO) ; \
    Invoke-Expression -Command $('{0} update --silent' -f $Env:PGC_CMD) ; \
    Invoke-Expression -Command $('{0} install --silent {1}' -f $Env:PGC_CMD,$Env:PSQL_VER)

# Switch back to the default shell
SHELL ["cmd", "/S", "/C"]

# In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator
RUN setx /M PATH "C:\\bigsql\\%PSQL_VER%\\bin;%PATH%"
USER ContainerUser

COPY docker-entrypoint.cmd "C:\\"
ENTRYPOINT ["C:\\docker-entrypoint.cmd"]

EXPOSE 5432
CMD ["postgres"]
