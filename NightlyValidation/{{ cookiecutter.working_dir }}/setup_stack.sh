#!/bin/bash
export WORKDIR={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}

echo "Running stack setup"
source ${WORKDIR}/common.sh

if [ -z "${LSST_DISTRIB_DIR}" ]; then
    echo "Executing loadLSST.sh"
    source "${LSST_DISTRIB}"/tag/"${LSST_VERSION}"/loadLSST.sh

    echo "Setting up distribution (lsst_distrib)"
    setup lsst_distrib -t "${LSST_VERSION}"
else
    echo "Stack already or partially set up."
fi

export LSST_S3_USE_THREADS=False

eups list -s lsst_distrib
echo "End of stack setup"
