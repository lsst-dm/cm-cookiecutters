#!/bin/sh

echo "Running setup_lsstcam.sh"

export SCREENRC={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}/etc/screenrc
export LSST_DISTRIB_DIR={{ cookiecutter.lsst_distrib_dir }}
export OUT_COLLECTION=LSSTCam/runs/M49-FL-CI/${LSST_VERSION}/{{ cookiecutter.jira_ticket_number }}

if [ -f .lsst-version ]; then
export LSST_VERSION=$(cat .lsst-version)
else
export LSST_VERSION=$(ls -1dt $LSST_DISTRIB/[dw]_latest | head -n 1)
export LSST_VERSION=$(readlink -nf $LSST_VERSION | xargs -- basename)
echo $LSST_VERSION > .lsst-version
fi

echo "Executing loadLSST.sh"
source ${LSST_DISTRIB_DIR}/tag/${LSST_VERSION}/loadLSST.sh

echo "Setting up distribution (lsst_distrib)"
setup lsst_distrib -t ${LSST_VERSION}
eups list -s lsst_distrib

export LSST_S3_USE_THREADS=False

echo "End of setup_lsstcam.sh"
