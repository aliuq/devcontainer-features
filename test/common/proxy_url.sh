#!/bin/bash

set -e

source dev-container-features-test-lib

# zoxide
check "zoxide installed" zoxide --version

reportResults
