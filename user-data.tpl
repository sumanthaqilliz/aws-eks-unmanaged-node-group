#!/bin/bash

set -o xtrace
/etc/eks/bootstrap.sh ${CLUSTER_NAME} ${BOOTSTRAP_ARGS}

${ADDITIONAL_USER_DATA}
