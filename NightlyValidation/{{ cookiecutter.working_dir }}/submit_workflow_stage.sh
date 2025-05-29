#!/bin/bash
set -eo pipefail

# script for launching single BPS workflow
# Arguments:
#  <bps_workflow_yaml>
#    Default: bps_Nightly-Validation-stage1.yaml
# -----------------------------------------
if [[ $UID -ne 17951 ]]; then
	echo "You should be lsstsvc1 before running this script"
	exit 1
fi

source ./common.sh

export WORKFLOW="${1}"

if [[ -z "${WORKFLOW}" ]]; then
    exit 0
fi

BASENAME=$(basename "${WORKFLOW}" .yaml)
export BASENAME
export LOGFILE=${BASENAME}.log
export JSONFILE=${BASENAME}.json

pushd ${WORKDIR}

if [[ -z "${LSST_VERSION}" ]]; then
    echo "setting up LSST environment"
    source ./setup_stack.sh
fi

echo "Using distribution: ${LSST_VERSION}"

# This allows script reentry if the workflow has already been built and submitted
# so has an active log file. To retrigger the BPS command, remove the stage's
# logfile (preferably by rotating it.) AND the pipetask report JSON file if there is one
if [[ (! -s "${LOGPATH}/${LOGFILE}") && (! -s "${WORKDIR}/${JSONFILE}") ]]; then
    echo "Submitting BPS Workflow ${WORKFLOW}"
    time bps submit "${WORKDIR}/${WORKFLOW}" 2>&1 | tee "${LOGPATH}/${LOGFILE}"
    MESSAGE="Nightly Validation - ${LSST_VERSION} Workflow ${BASENAME} Submitted."
    notify
fi

# Loop until the exit code is 0
set +e
while true
do
    test -s "${LOGPATH}/${LOGFILE}" || { sleep 60; continue; }
    python ./node_status_parser.py --file "${LOGPATH}/${LOGFILE}" | jq -e -f ./workflow_status.jq
    EC=$?
    case $EC in
        0) break;;
        1) continue;;  # ignore workflow failures
        9) date; python ./node_status_parser.py --file "${LOGPATH}/${LOGFILE}" | jq -f ./node_status.jq;;
        *) echo "Unknown status"; exit 1;;
    esac
    sleep 900
done
set -e

# show the workflow summary post-success
WORKFLOW_STATUS=$(python ./node_status_parser.py --file "${LOGPATH}/${LOGFILE}")
echo "$WORKFLOW_STATUS" | jq .

if [[ (! -s ${WORKDIR}/${BASENAME}.json) ]]; then
    echo "Running pipetask report for ${BASENAME}"
    read -r SD QG < <(echo "$WORKFLOW_STATUS" | jq -r '[.bps_submit_directory, .qgraph_file]|join(" ")')
    test -n "${QG}" || { echo "ERROR: No QG file could be inferred from submit directory ${SD}"; exit 1; }
    set +e
    pipetask report embargo "${QG}" --force-v2 --full-output-filename "./${JSONFILE}" &> "${LOGPATH}/pipetask_report_${BASENAME}.log"
    EC=$?
    test $EC -eq 0 || echo "WARNING: ${BASENAME} pipetask report exited with code ${EC}"
    set -e
    MESSAGE="Nightly Validation - ${LSST_VERSION} Workflow ${BASENAME} Finished."
    notify
fi

echo "$MESSAGE"
