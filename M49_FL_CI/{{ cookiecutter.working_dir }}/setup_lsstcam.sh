#!/bin/sh

echo "Running setup_lsstcam.sh"
source ./common.sh

echo "Executing loadLSST.sh"
source ${LSST_DISTRIB}/tag/${LSST_VERSION}/loadLSST.sh

echo "Setting up distribution (lsst_distrib)"
setup lsst_distrib -t ${LSST_VERSION}
eups list -s lsst_distrib

export LSST_S3_USE_THREADS=False

echo "End of setup_lsstcam.sh"
