#!/bin/bash
export WORKDIR={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}

echo "Running stack setup"
source ${WORKDIR}/common.sh

echo "Executing loadLSST.sh"
source "${LSST_DISTRIB}"/tag/"${LSST_VERSION}"/loadLSST.sh

echo "Setting up distribution (lsst_distrib)"
setup lsst_distrib -t "${LSST_VERSION}"

export LSST_S3_USE_THREADS=False

eups list -s lsst_distrib
echo "End of stack setup"
