#!/bin/bash

# Install cloudera manager agent and related daemons.
yum install -y cloudera-manager-daemons cloudera-manager-agent
yum clean all
