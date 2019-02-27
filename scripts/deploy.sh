#!/bin/bash

ls
echo "deploying $(cat "$1-version.txt")"
echo "$1" deployed
