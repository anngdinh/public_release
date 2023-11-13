# OpenTelemetry Collector Contrib

## Set up mysql

### Install mysql ubuntu

```bash
sudo apt update
sudo apt install mysql-server
sudo systemctl start mysql.service
```

### Change bind address

```bash
vi /etc/mysql/mysql.conf.d/mysqld.cnf
# change bind address 127.0.0.1 -> 0.0.0.0
sudo systemctl restart mysql.service
```

### Create user

```mysql=
CREATE USER 'annd2'@'localhost' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'annd2'@'localhost' WITH GRANT OPTION;
CREATE USER 'annd2'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON *.* TO 'annd2'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
```

### Change config mysql

```bash
nano /etc/mysql/my.cnf

[mysqld]
performance_schema=ON
max_digest_length=4096
performance_schema_max_digest_length=4096
performance_schema_max_sql_text_length=4096
performance-schema-consumer-events-statements-current=ON
performance-schema-consumer-events-waits-current=ON
performance-schema-consumer-events-statements-history-long=ON
performance-schema-consumer-events-statements-history=ON

sudo systemctl restart mysql.service
```

### Add vmonitor schema and procedure explain

```mysql=
create schema vmonitor;

DELIMITER $$
CREATE PROCEDURE <YOUR_SCHEMA>.explain_statement(IN query TEXT)
    SQL SECURITY DEFINER
BEGIN
    SET @explain := CONCAT('EXPLAIN FORMAT=json ', query);
    PREPARE stmt FROM @explain;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
END $$
DELIMITER ;
```

### Update runtime consume

```mysql!
UPDATE performance_schema.setup_consumers SET enabled='YES' WHERE name LIKE 'events_statements_%';
UPDATE performance_schema.setup_consumers SET enabled='YES' WHERE name = 'events_waits_current';
```

## Install agent

### 1. Run install command

```bash
V_USER=aaaaaaa \
V_PASS=aaaaaaa \
V_HOST=aaaaaaa \
V_PORT=aaaaaaa \
bash -c "$(curl -L https://raw.githubusercontent.com/anngdinh/public_release/main/vmonitor-agent/install.sh)"
```

Setup DB with tool

```sh
/etc/vmonitor-agent/setup user password localhost:3306
```

### 2. Create log project and download cert

* Create log project [vMonitor Logs](https://hcm-3.console.vngcloud.vn/vmonitor/quota-usage/usage/usage-log)
* Download cert of the project and put in `/etc/vmonitor-agent/`

### 3. Change config

```bash
vi /etc/vmonitor-agent/vmonitor-agent.conf
```

```bash
systemctl restart vmonitor-agent
```

### 4. Check it out

```bash
systemctl status vmonitor-agent.service
journalctl -xeu vmonitor-agent.service
```

### Remove agent (Optional)

```bash
systemctl stop vmonitor-agent
apt purge vmonitor-agent -y
```

## Note

[./go.mod](./go.mod)

[./versions.yaml](./versions.yaml)

[./cmd/otelcontribcol/builder-config.yaml](./cmd/otelcontribcol/builder-config.yaml)

[./cmd/otelcontribcol/components.go](./cmd/otelcontribcol/components.go)

[./cmd/otelcontribcol/go.mod](./cmd/otelcontribcol/go.mod)
