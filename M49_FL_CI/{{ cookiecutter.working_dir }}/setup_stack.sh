#!/bin/sh
set -e

echo "Running stack setup"
source ./common.sh

if [ -z "${LSST_DISTRIB_DIR}" ]; then
    echo "Executing loadLSST.sh"
    source ${LSST_DISTRIB}/tag/${LSST_VERSION}/loadLSST.sh

    echo "Setting up distribution (lsst_distrib)"
    setup lsst_distrib -t ${LSST_VERSION}
    eups list -s lsst_distrib
fi

export LSST_S3_USE_THREADS=False

echo "End of stack setup"
