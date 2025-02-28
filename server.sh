#!/bin/bash

CONFIG_FILE="settings.ini"
NEW_SERVER_NAME=$1

sed -i "s/^server_name = .*/server_name = $NEW_SERVER_NAME/" "$CONFIG_FILE"

echo "Updated server_name to $NEW_SERVER_NAME"
