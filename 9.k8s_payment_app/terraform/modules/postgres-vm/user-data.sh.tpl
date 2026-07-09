#!/bin/bash

dnf update -y

dnf install -y postgresql15-server postgresql15 cronie

postgresql-setup --initdb

systemctl enable postgresql
systemctl start postgresql

sudo -u postgres psql <<EOF
CREATE USER payments WITH PASSWORD '${postgres_password}';
CREATE DATABASE payments OWNER payments;
GRANT ALL PRIVILEGES ON DATABASE payments TO payments;
EOF

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" \
/var/lib/pgsql/data/postgresql.conf

echo "host all all 10.0.0.0/16 md5" \
>> /var/lib/pgsql/data/pg_hba.conf

sed -i 's/^host\s\+all\s\+all\s\+127\.0\.0\.1\/32\s\+ident/host all all 127.0.0.1\/32 md5/' \
/var/lib/pgsql/data/pg_hba.conf

sed -i 's/^host\s\+all\s\+all\s\+::1\/128\s\+ident/host all all ::1\/128 md5/' \
/var/lib/pgsql/data/pg_hba.conf

systemctl restart postgresql

mkdir -p /var/backups/postgresql

cat > /usr/local/bin/db-backup.sh <<EOF
#!/bin/bash

BACKUP_DIR="/var/backups/postgresql"
TIMESTAMP=\$(date +"%Y-%m-%d_%H-%M-%S")

mkdir -p "\$BACKUP_DIR"

PGPASSWORD='${postgres_password}' pg_dump \
  -h 127.0.0.1 \
  -U payments \
  -d payments \
  > "\$BACKUP_DIR/payments-\$TIMESTAMP.sql"

find "\$BACKUP_DIR" -type f -mtime +7 -delete
EOF

chmod +x /usr/local/bin/db-backup.sh

cat > /etc/cron.d/postgres-backup <<EOF
0 2 * * * root /usr/local/bin/db-backup.sh
EOF

chmod 644 /etc/cron.d/postgres-backup

systemctl enable crond
systemctl start crond