#!/bin/sh
set -e

python manage.py migrate --noinput
python manage.py collectstatic --noinput

PORT="${PORT:-8000}"
WORKERS="${WEB_CONCURRENCY:-3}"

exec gunicorn config.wsgi:application --bind "0.0.0.0:${PORT}" --workers "${WORKERS}" --timeout 120
