#!/bin/sh

echo "Running setup_lsstcam.sh"

export LSST_DISTRIB_DIR={{ cookiecutter.lsst_distrib_dir }}
export LSST_VERSION=$(ls -1dt $LSST_DISTRIB/[dw]_latest | head -n 1)
export LSST_VERSION=$(readlink -nf $LSST_VERSION | xargs -- basename)

echo "Executing loadLSST.sh"
source ${LSST_DISTRIB_DIR}/${LSST_VERSION}/loadLSST.sh

echo "Setting up distribution (lsst_distrib)"
setup lsst_distrib -t ${LSST_VERSION}
setup -j -r /sdf/data/rubin/shared/campaigns/LSSTCam-Interim-Nightly-Validation/drp_pipe
eups list -s lsst_distrib

export LSST_S3_USE_THREADS=False

echo "End of setup_lsstcam.sh"
