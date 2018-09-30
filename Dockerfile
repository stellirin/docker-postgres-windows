####
#### Pretty Good Command Line Interface (PGCLI)
####
FROM microsoft/windowsservercore:1803 as prepare

# Set the variables for PGCLI
ENV PGC_VER 3.3.7
ENV PGC_REPO https://s3.amazonaws.com/pgcentral

##### Use PowerShell for the installation
SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

### Required for PGCLI
ENV PYTHONIOENCODING UTF-8

### Download PGCLI
### The loop is because the S3 connection is quite unreliable
RUN [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; \
    Import-Module BitsTransfer ; \
    Start-BitsTransfer \
        -Source $('{0}/bigsql-pgc-{1}.zip' -f $env:PGC_REPO,$env:PGC_VER) \
        -Destination 'C:\\BigSQL.zip' \
        -DisplayName 'BigSQL' \
        -Asynchronous ; \
    $Job = Get-BitsTransfer 'BigSQL' ; \
    $LastStatus = $Job.JobState ; \
    Do { \
        If ($LastStatus -ne $Job.JobState) { \
            $LastStatus = $Job.JobState ; \
            $Job \
        } \
    } \
    While ($LastStatus -ne 'Transferring') ; \
    $Job ; \
    Do { \
        Write-Host (Get-Date -Format s) $Job.BytesTransferred $Job.BytesTotal ($Job.BytesTransferred/$job.BytesTotal*100) ; \
        Start-Sleep -s 10 \
    } \
    While ($Job.BytesTransferred -lt $Job.BytesTotal) ; \
    Write-Host (Get-Date -Format s) $Job.BytesTransferred $Job.BytesTotal ($Job.BytesTransferred/$Job.BytesTotal*100) ; \
    Complete-BitsTransfer $Job ; \
    Expand-Archive 'C:\\BigSQL.zip' -DestinationPath 'C:\\' ; \
    Remove-Item -Path 'C:\\BigSQL.zip'

### Update PGCLI
RUN Invoke-Expression -Command $('C:\\bigsql\\pgc set GLOBAL REPO {0}' -f$env:PGC_REPO) ; \
    Invoke-Expression -Command   'C:\\bigsql\\pgc update --silent' ; \
    Remove-Item -Path 'C:\\bigsql\\conf\\pgc.pid'

####
#### Download PostgreSQL
####
FROM prepare as download

### Set the PostgreSQL version we will install
### This is set here to allow us to reuse the abover layers
ARG PGC_DB
ENV PGC_DB ${PGC_DB}

### Download PostgreSQL
RUN Invoke-Expression -Command $('C:\\bigsql\\pgc install --silent {0}' -f $env:PGC_DB) ; \
    Invoke-Expression -Command   'C:\\bigsql\\pgc clean' ; \
    Remove-Item -Path 'C:\\bigsql\\conf\\pgc.pid'

### Make the sample config easier to munge (and "correct by default")
RUN $SAMPLE_FILE = $('C:\\bigsql\\{0}\\share\\postgresql\\postgresql.conf.sample' -f $env:PGC_DB) ; \
    $SAMPLE_CONF = Get-Content $SAMPLE_FILE ; \
    $SAMPLE_CONF = $SAMPLE_CONF -Replace '#listen_addresses = ''localhost''','listen_addresses = ''*''' ; \
    $SAMPLE_CONF | Set-Content $SAMPLE_FILE

####
#### PostgreSQL on Windows Nano Server
####
FROM microsoft/nanoserver:1803

RUN mkdir "C:\\docker-entrypoint-initdb.d"

#### Copy over the PGCLI
COPY --from=prepare "C:\\bigsql" "C:\\bigsql"

### Set the PostgreSQL version we will install
### This is set here to allow us to reuse the abover layers
ARG PGC_DB
ENV PGC_DB ${PGC_DB}

### Required for PGCLI
ENV PYTHONIOENCODING="UTF-8" \
    PYTHONPATH="C:\\bigsql\\${PGC_DB}\\python\\site-packages" \
    GDAL_DATA="C:\\bigsql\\${PGC_DB}\\share\\gdal"

#### Copy over PostgeSQL
COPY --from=download "C:\\bigsql\\${PGC_DB}" "C:\\bigsql\\${PGC_DB}"

#### In order to set system PATH, ContainerAdministrator must be used
USER ContainerAdministrator
RUN setx /M PATH "C:\\bigsql\\%PGC_DB%\\bin;%PATH%"
USER ContainerUser
ENV PGDATA "C:\\bigsql\\data\\${PGC_DB}"
RUN mkdir "%PGDATA%"

COPY docker-entrypoint.cmd "C:\\"
ENTRYPOINT ["C:\\docker-entrypoint.cmd"]

EXPOSE 5432
CMD ["postgres"]
