#!/bin/bash

echo "running end-to-end-test against $URL"
echo "user is $TEST_USER_CREDS"
echo testing versions:
cat ./*-version.txt > test-results.txt
