#!/bin/bash

function addProperty() {
    local path=$1
    local key=$2
    local value=$3
    crudini --set $path "" $key $value
}

function configure() {
    local path=$1
    local envPrefix=$2

    echo "Configuring $1"
    for c in `printenv | perl -sne 'print "$1 " if m/^${envPrefix}_(.+?)=.*/' -- -envPrefix=$envPrefix`; do
        name=`echo ${c} | perl -pe 's/___/-/g; s/__/_/g; s/_/./g' | perl -ne 'print lc'`
        var="${envPrefix}_${c}"
        value=${!var}
        echo " - Setting $name=$value"
        addProperty $path $name "$value"
    done
}

# Generating new ID to the new presto node
export NODE_CONF_NODE_ID=`uuidgen`

configure /opt/presto/etc/config.properties CONFIG_CONF
configure /opt/presto/etc/log.properties LOG_CONF
configure /opt/presto/etc/node.properties NODE_CONF
configure /opt/presto/etc/catalog/hive.properties HIVE_CONF
dockerize -template /opt/presto/etc/jvm.config.template:/opt/presto/etc/jvm.config

echo "/opt/presto/etc/config.properties:"
cat /opt/presto/etc/config.properties

echo "/opt/presto/etc/node.properties:"
cat /opt/presto/etc/node.properties

echo "/opt/presto/etc/catalog/hive.properties:"
cat /opt/presto/etc/catalog/hive.properties

echo "/opt/presto/etc/jvm.properties:"
cat /opt/presto/etc/jvm.properties

exec $@
