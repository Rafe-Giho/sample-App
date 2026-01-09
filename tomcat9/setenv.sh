#!/bin/sh

if [ -n "$HTTP_PROXY_HOST" ] && [ -n "$HTTP_PROXY_PORT" ]; then
  export CATALINA_OPTS="$CATALINA_OPTS -Dhttp.proxyHost=${HTTP_PROXY_HOST} -Dhttp.proxyPort=${HTTP_PROXY_PORT}"
  export http_proxy="http://${HTTP_PROXY_HOST}:${HTTP_PROXY_PORT}"
fi

if [ -n "$HTTPS_PROXY_HOST" ] && [ -n "$HTTPS_PROXY_PORT" ]; then
  export CATALINA_OPTS="$CATALINA_OPTS -Dhttps.proxyHost=${HTTPS_PROXY_HOST} -Dhttps.proxyPort=${HTTPS_PROXY_PORT}"
  export https_proxy="http://${HTTPS_PROXY_HOST}:${HTTPS_PROXY_PORT}"
fi

