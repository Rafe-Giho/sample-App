#!/bin/sh
set -e

if [ -n "$POD_NAME" ]; then
  VHOST_SERVER_NAME="$POD_NAME"
else
  : "${VHOST_SERVER_NAME:=web}"
fi

: "${TOMCAT_UPSTREAM_HOST:=http://localhost}"
: "${TOMCAT_UPSTREAM_PORT:=8080}"
: "${ALLOWED_PROXY_IP:=http://localhost}"

envsubst '
  $VHOST_SERVER_NAME
  $TOMCAT_UPSTREAM_HOST
  $TOMCAT_UPSTREAM_PORT
  $ALLOWED_PROXY_IP
' < /usr/local/apache2/conf/httpd.conf.template \
  > /usr/local/apache2/conf/httpd.conf

exec httpd-foreground

