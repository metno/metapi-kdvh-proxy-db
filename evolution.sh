#!/bin/bash
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# met-metapi
#
# Copyright (C) 2016 met.no
#
#  Contact information:
#  Norwegian Meteorological Institute
#  Box 43 Blindern
#  0313 OSLO
#  NORWAY
#  E-mail: metapi@met.no
#
#  This is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# This is a simple database evolution script for the metapi-kdvg proxy
# database in psql 

DEFAULT_DATABASE=$USER
DEFAULT_USER=$USER
DEFAULT_PORT=5432
DEFAULT_PATH="."

SCRIPT_USER=$USER
SCRIPT_VERSION="0.1"
SCRIPT_USAGE="Usage: $0 [OPTION]

This script install the metapi-kdvh proxy database in Postgresql.

Database          (default: $DEFAULT_DATABASE)
User              (default: $DEFAULT_USER)
Port              (default: $DEFAULT_PORT)
Script Path       (default: $DEFAULT_PATH)

If the named database does not exist, the install script creates the
database. If the database exists, the install script will upgrade the
database, if necessary.

Options:

-d NAME, --database=NAME
                   install to database <NAME>

-u USER, --user=USER
                   install as user <NAME>

-p PORT, --port=PORT
                   install on port <PORT>

-i PATH, --import=PATH
                   use scripts installed in <PATH>

--help             display this help and exit

--version          output version information and exit
"

# Parse command line
while test -n "$1"; do
    case "$1" in
  --database=*)
      DATABASE_NAME=`echo $1 | sed 's/--database=//'`
      shift
      continue;;
  -d)
      shift
      DATABASE_NAME=$1
      shift
      continue;;
  --user=*)
      DATABASE_USER=`echo $1 | sed 's/--user=//'`
      shift
      continue;;
  -u)
      shift
      DATABASE_USER=$1
      shift
      continue;;
  --port=*)
      DATABASE_PORT=`echo $1 | sed 's/--port=//'`
      shift
      continue;;
  -p)
      shift
      DATABASE_PORT=$1
      shift
      continue;;
  --import=*)
      DATABASE_PATH=`echo $1 | sed 's/--import=//'`
      shift
      continue;;
  -i)
      shift
      DATABASE_PATH=$1
      shift
      continue;;
  --help)
      echo "$SCRIPT_USAGE"; exit 0;;
  --version)
      echo "$0 $SCRIPT_VERSION"; exit 0;;
  *)
      shift
      continue;;
    esac
done

# Set defaults variables
# DATABASE_NAME
if test -z "$DATABASE_NAME"; then
    DATABASE_NAME=$DEFAULT_DATABASE
fi

# DATABASE_USER
if test -z "$DATABASE_USER"; then
  DATABASE_USER=$DEFAULT_USER
fi

# DATABASE_PORT
if test -z "$DATABASE_PORT"; then
  DATABASE_PORT=$DEFAULT_PORT
fi

# DATABASE_PATH
if test -z "$DATABASE_PATH"; then
  DATABASE_PATH=$DEFAULT_PATH
fi

# Start Installation
echo "---- database evolution ----"

# Verify that Postmaster is running
echo -n "checking that postgres is running... "
PID=`ps aux | grep postgres | grep -v grep`
if test -n "$PID"; then
    echo "yes"
else
    echo "no"
    echo "Error: could not find postgres. Check that your postgres installation is set up correctly and that postgres is running"
    exit 1
fi

# Install evolution + baseline (0.sql)
DATABASE_SQLDIR=$DATABASE_PATH/share/sql
DATABASE_BASELINE=$DATABASE_SQLDIR/0.sql
# Check for sql source files
echo -n "checking for the presence of sql source file... "
if test -f $DATABASE_BASELINE ; then
    echo "ok"
else
    echo "not found"
    echo "Error: could not find $DATABASE_BASELINE. The sql source files must be installed for the installation to work."
    exit 1
fi

echo -n "installing baseline schema (!exists)... "
psql $DATABASE_NAME -tAc "SELECT 1 FROM information_schema.tables WHERE table_schema='public' AND table_name='configuration'" | grep -q 1 || psql -U $DATABASE_USER -p $DATABASE_PORT $DATABASE_NAME -f $DATABASE_BASELINE
if [ 0 != $? ]; then
  echo "ERROR: Installation of $DATABASE_BASELINE failed"
  exit 1
fi
psql -U $DATABASE_USER -p $DATABASE_PORT $DATABASE_NAME -c "INSERT INTO configuration (configuration_id, applied_at, apply_script,revert_script) SELECT 0, now(), '$DATABASE_BASELINE', NULL WHERE NOT EXISTS (SELECT 1 FROM configuration WHERE configuration_id = 0);"
echo "done"

# Init Evolution
echo -n "current schema version of kdvh-proxy... "
CURRENT_VERSION=`psql -U $DATABASE_USER -p $DATABASE_PORT -d $DATABASE_NAME -l -c "select max(configuration_id) from public.configuration LIMIT 1;" -q | sed -e '1,2d' | sed -e '2,$d' | sed 's/^[ ]//g'`
if test -z "$CURRENT_VERSION"; then
  CURRENT_VERSION=-1
fi
echo $CURRENT_VERSION

# Evolutions
CURRENT_VERSION=`expr $CURRENT_VERSION + 1`
VN=$(printf "%d" "$CURRENT_VERSION")
UPGRADE_FILE=$DATABASE_SQLDIR/$VN.sql
while [ -f $UPGRADE_FILE ]
do
  echo -n "installing database schema version $CURRENT_VERSION... "
  psql -U $DATABASE_USER -p $DATABASE_PORT -d $DATABASE_NAME -f $UPGRADE_FILE
  if [ 0 != $? ]; then
    echo "ERROR: Installation of $UPGRADE_FILE failed"
    exit 1
  fi
  psql -U $DATABASE_USER -p $DATABASE_PORT $DATABASE_NAME -c "INSERT INTO configuration VALUES ($VN, now(), '$UPGRADE_FILE', NULL);"
  echo "done"
  CURRENT_VERSION=`expr $CURRENT_VERSION + 1`
  VN=$(printf "%d" "$CURRENT_VERSION")
  UPGRADE_FILE=$DATABASE_SQLDIR/$VN.sql
done

echo "---- database evolution completed ----"
exit 0
