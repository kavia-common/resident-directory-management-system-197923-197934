#!/bin/bash
set -euo pipefail

# Simple, repeatable migration runner for resident_db.
# Applies SQL files in resident_db/sql/ in lexicographic order and records applied files.

DB_NAME="${DB_NAME:-myapp}"
DB_USER="${DB_USER:-appuser}"
DB_PASSWORD="${DB_PASSWORD:-dbuser123}"
DB_PORT="${DB_PORT:-5000}"

PG_VERSION=$(ls /usr/lib/postgresql/ | head -1)
PG_BIN="/usr/lib/postgresql/${PG_VERSION}/bin"

SQL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sql"

if [ ! -d "${SQL_DIR}" ]; then
  echo "No sql directory found at ${SQL_DIR}; skipping migrations."
  exit 0
fi

echo "Running migrations from ${SQL_DIR} ..."

# Ensure migrations bookkeeping table exists
PGPASSWORD="${DB_PASSWORD}" ${PG_BIN}/psql -h localhost -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 -c \
"CREATE TABLE IF NOT EXISTS schema_migrations (filename TEXT PRIMARY KEY, applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW());"

# Apply each migration exactly once
for f in "${SQL_DIR}"/*.sql; do
  [ -e "$f" ] || continue
  base="$(basename "$f")"

  already_applied=$(
    PGPASSWORD="${DB_PASSWORD}" ${PG_BIN}/psql -h localhost -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -tA -c \
    "SELECT 1 FROM schema_migrations WHERE filename='${base}' LIMIT 1;"
  )

  if [ "${already_applied}" = "1" ]; then
    echo "✓ Skipping ${base} (already applied)"
    continue
  fi

  echo "→ Applying ${base}"
  PGPASSWORD="${DB_PASSWORD}" ${PG_BIN}/psql -h localhost -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 -f "$f"
  PGPASSWORD="${DB_PASSWORD}" ${PG_BIN}/psql -h localhost -p "${DB_PORT}" -U "${DB_USER}" -d "${DB_NAME}" -v ON_ERROR_STOP=1 -c \
  "INSERT INTO schema_migrations(filename) VALUES('${base}');"

  echo "✓ Applied ${base}"
done

echo "Migrations complete."
