#!/bin/sh
# script for launching single BPS workflow
# -----------------------------------------
if [[ $UID -ne 17951 ]];
	then echo "You should be lsstsvc1 before running this script"
	exit 1
fi

WORKDIR={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}
pushd ${WORKDIR}

mkdir -p ${WORKDIR}/bps_sub_logs

if [ -f ./logrotate.conf ]; then
    logrotate --state ./logrotate.status -f ./logrotate.conf
fi

echo "setting up environment"
source ./setup_lsstcam.sh

echo "Using distribution: ${LSST_VERSION}"

echo "setting steps to process"
export WORKFLOW="bps_NV_1-3_x2.yaml"
export BASENAME=$(basename ${WORKFLOW} .yaml)
export LOGPATH=${WORKDIR}/bps_sub_logs
export LOGFILE=${BASENAME}.log

echo "First step = ${WORKFLOW}"

echo "performing bps submission for ${WORKFLOW}"

time bps submit ${WORKDIR}/${WORKFLOW} 2>&1 | tee ${LOGPATH}/${LOGFILE}

# WAIT

# read SD QG < <(./node_status_parser.py --file ${LOGPATH}/${LOGFILE} | jq -r '[.bps_submit_directory, .qgraph_file]|join(" ")')
# pipetask report embargo ${QG} --force-v2 --full-output-filename ./${BASENAME}.json  &> pipetask_report_${BASENAME}.log
