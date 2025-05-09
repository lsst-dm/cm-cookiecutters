#!/bin/sh
# script for launching single BPS workflow
# -----------------------------------------
if [[ $UID -ne 17951 ]];
	then echo "You should be lsstsvc1 before running this script"
	exit 1
fi

export WORKFLOW="bps_M49_CL_CI-stage1.yaml"
export WORKDIR={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}
export BASENAME=$(basename ${WORKFLOW} .yaml)
export LOGPATH=${WORKDIR}/bps_sub_logs
export LOGFILE=${BASENAME}.log

pushd ${WORKDIR}

mkdir -p ${LOGPATH}

# if [ -f ./logrotate.conf ]; then
#     logrotate --state ./logrotate.status -f ./logrotate.conf
# fi

if [ -z "${LSST_VERSION}" ]; then
    echo "setting up LSST environment"
    source ./setup_lsstcam.sh
fi

echo "Using distribution: ${LSST_VERSION}"

echo "setting steps to process"

echo "First step = ${WORKFLOW}"

echo "performing bps submission for ${WORKFLOW}"

time bps submit ${WORKDIR}/${WORKFLOW} 2>&1 | tee ${LOGPATH}/${LOGFILE}

# Loop until the exit code is 0
while true
do
    python ./node_status_parser.py --file ${LOGPATH}/${LOGFILE} | jq -f ./workflow_status.jq
    EC=$?
    case $EC in
        0) break;;
        1) exit 1;;
        9) date; python ./node_status_parser.py --file ${LOGPATH}/${LOGFILE} | jq -f ./node_status.jq;;
        *) echo "Unknown status"; exit 1;;
    esac
    sleep 900
done

read SD QG < <(./node_status_parser.py --file ${LOGPATH}/${LOGFILE} | jq -r '[.bps_submit_directory, .qgraph_file]|join(" ")')
pipetask report embargo ${QG} --force-v2 --full-output-filename ./${BASENAME}.json  &> ${LOGPATH}/pipetask_report_${BASENAME}.log
