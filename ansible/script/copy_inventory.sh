#!/bin/bash
if [ $# -ne 1 ]; then
  echo "Error: must take only one argument"
  echo "  please specify destination:"
  echo "    ./copy_inventory.sh [destination]"
  exit 1
fi
if [ -d $1 ]; then
    echo "already exists: $1"
    echo "delete or backup before copy"
else
    mkdir -p $1
    mkdir -p $1/root
    mkdir -p $1/user
    cp -r playbook/root/inventory $1/root/inventory
    cp -r playbook/user/inventory $1/user/inventory
fi
