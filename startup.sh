#!/bin/bash
set -e

# Wait for DB
echo "🕒 Waiting for DB..."
/opt/netbox/netbox/docker/docker-entrypoint.sh wait

# Run migrations
echo "⚙️ Running database migrations..."
python /opt/netbox/netbox/manage.py migrate

# Collect static files
echo "🎨 Collecting static files..."
python /opt/netbox/netbox/manage.py collectstatic --no-input

# Start NetBox
echo "🚀 Launching NetBox..."
exec /opt/netbox/venv/bin/gunicorn netbox.wsgi --config /opt/netbox/gunicorn.py
