#!/bin/bash
export WORKDIR={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}

echo "Running stack setup"
source ${WORKDIR}/common.sh

echo "Executing loadLSST.sh"
#source "${LSST_DISTRIB}"/tag/"${LSST_VERSION}"/loadLSST.sh
#source /cvmfs/sw.lsst.eu/almalinux-x86_64/lsst_distrib/${LSST_VERSION}/loadLSST.bash
source "${LSST_DISTRIB}"/"${LSST_VERSION}"/loadLSST.bash

echo "Setting up distribution (lsst_distrib)"
setup lsst_distrib -t "${LSST_VERSION}"

#setup -j -r /sdf/home/c/cslater/drp_pipe
setup -j -r /sdf/data/rubin/user/homer/drp_pipe

export LSST_S3_USE_THREADS=False

eups list -s lsst_distrib
echo "End of stack setup"
