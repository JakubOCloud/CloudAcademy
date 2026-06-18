#!/bin/bash

dnf update -y

dnf install -y postgresql15-server postgresql15

postgresql-setup --initdb

systemctl enable postgresql
systemctl start postgresql

sudo -u postgres psql <<EOF
CREATE USER payments WITH PASSWORD '${postgres_password}';

CREATE DATABASE payments OWNER payments;

GRANT ALL PRIVILEGES
ON DATABASE payments
TO payments;
EOF

sed -i "s/#listen_addresses = 'localhost'/listen_addresses = '*'/" \
/var/lib/pgsql/data/postgresql.conf

echo "host all all 10.0.0.0/16 md5" \
>> /var/lib/pgsql/data/pg_hba.conf

systemctl restart postgresql