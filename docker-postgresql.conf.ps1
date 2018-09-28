$FILE = $('C:\bigsql\{0}\share\postgresql\postgresql.conf.sample' -f $env:PGC_DB)
$CONF = Get-Content $FILE

# Taken from update_postgresql_conf() in C:\bigsql\hub\scripts\util.py
$CONF = $CONF -Replace '#listen_addresses = ''localhost''','listen_addresses = ''*'''
$CONF = $CONF -Replace '#port = 5432','port = 5432'
$CONF = $CONF -Replace '#logging_collector = off','logging_collector = on'
$CONF = $CONF -Replace '#log_directory = ''log''', $('log_directory = ''C:/bigsql/data/logs/{0}''' -f $env:PGC_DB)
$CONF = $CONF -Replace '#log_filename = ''.*?''','log_filename = ''postgresql-%a.log'''
$CONF = $CONF -Replace '#log_line_prefix = ''.*?''','log_line_prefix =  ''%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '''
$CONF = $CONF -Replace '#log_truncate_on_rotation = off','log_truncate_on_rotation = on'
$CONF = $CONF -Replace '#log_checkpoints = off','log_checkpoints = on'
$CONF = $CONF -Replace '#log_autovacuum_min_duration = -1','log_autovacuum_min_duration = 0'
$CONF = $CONF -Replace '#log_temp_files = -1','log_temp_files = 0'
$CONF = $CONF -Replace '#log_lock_waits = off','log_lock_waits = on'
$CONF = $CONF -Replace '#checkpoint_segments = 3','checkpoint_segments = 16'
$CONF = $CONF -Replace '#maintenance_work_mem = 64MB','maintenance_work_mem = 64MB'
$CONF = $CONF -Replace '#max_wal_senders = 10','max_wal_senders = 5'
$CONF = $CONF -Replace '#track_io_timing = off','track_io_timing = on'
$CONF = $CONF -Replace '#wal_keep_segments = 0','wal_keep_segments = 32'
$CONF = $CONF -Replace '#max_replication_slots = 10','max_replication_slots = 5'
$CONF = $CONF -Replace '#wal_level = replica','wal_level = hot_standby'
$CONF = $CONF -Replace '#update_process_title = on','update_process_title = off'

$CONF | Set-Content $FILE
