#!/bin/bash
set -eo pipefail

# script for launching single BPS workflow
# Arguments:
#  <bps_workflow_yaml>
#    Default: bps_M49_CL_CI-stage1.yaml
# -----------------------------------------
if [[ $UID -ne 17951 ]];
	then echo "You should be lsstsvc1 before running this script"
	exit 1
fi

source ./common.sh

export WORKFLOW="${1}"

if [[ -z "${WORKFLOW}" ]];
    exit 0
fi

export BASENAME=$(basename ${WORKFLOW} .yaml)
export LOGFILE=${BASENAME}.log

pushd ${WORKDIR}

# if [ -f ./etc/logrotate.conf ]; then
#     logrotate --state ./logrotate.status -f ./logrotate.conf
# fi

if [ -z "${LSST_VERSION}" ]; then
    echo "setting up LSST environment"
    source ./setup_lsstcam.sh
fi

echo "Using distribution: ${LSST_VERSION}"

if [ ! -s ${LOGPATH}/${LOGFILE} ]; then
    echo "Submitting BPS Workflow ${WORKFLOW}"
    time bps submit ${WORKDIR}/${WORKFLOW} 2>&1 | tee ${LOGPATH}/${LOGFILE}
fi

# Loop until the exit code is 0
set +e
while true
do
    test -s ${LOGPATH}/${LOGFILE} || { sleep 60; continue; }
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
set -e

# show the workflow summary post-success
WORKFLOW_STATUS=$(python ./node_status_parser.py --file ${LOGPATH}/${LOGFILE})
echo $WORKFLOW_STATUS | jq .

echo "Running pipetask report for ${BASENAME}"
read SD QG < <(echo $WORKFLOW_STATUS | jq -r '[.bps_submit_directory, .qgraph_file]|join(" ")')
pipetask report embargo ${QG} --force-v2 --full-output-filename ./${BASENAME}.json &> ${LOGPATH}/pipetask_report_${BASENAME}.log
EC=$?
test $EC -eq 0 || echo "WARNING: ${BASENAME} pipetask report exited with code ${EC}"

echo "Workflow ${BASENAME} Finished.
