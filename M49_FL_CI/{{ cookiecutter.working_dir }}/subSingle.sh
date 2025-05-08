#!/bin/sh
# script for launching single BPS workflow
# -----------------------------------------
if [[ $UID -ne 17951 ]];
	then echo "You should be lsstsvc1 before running this script"
	exit 1
fi

subdir={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}
pushd ${subdir}

mkdir -p ${subdir}/bps_sub_logs

if [ -f ./logrotate.conf ]; then
    logrotate --state ./logrotate.status -f ./logrotate.conf
fi

echo "setting up environment"
source ./setup_lsstcam.sh

echo "Using distribution: ${LSST_VERSION}"

echo "setting steps to process"
export WORKFLOW="bps_NV_1-3_x2.yaml"

echo "First step = ${WORKFLOW}"

echo "performing bps submission for ${WORKFLOW}"
# comment out to recover from first step timeout
time bps submit ${subdir}/${WORKFLOW} 2>&1 | tee ${subdir}/bps_sub_logs/$(basename ${WORKFLOW} .yaml).log
