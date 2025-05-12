#!/bin/bash
set -eo pipefail

# script for generating raster HiPS maps
# -----------------------------------------

source ./common.sh

pushd $WORKDIR/hips

################################################################################
# First get the survey segments (pixels) or use the FIXED_PIXELS list for M49
# build-high-resolution-hips-qg segment -b embargo -p 01_pipeline_hips_warp.yaml -i "$COLLECTION" -o 1

################################################################################
# Build the graph
echo "BUILDING HiPS Warp Graph"
LOGFILE=m49_fl_ci_hips-build-warp.log
if [[ ! -s "$HIPS_QGRAPH_FILE" ]]; then
    build-high-resolution-hips-qg build -b embargo -p 01_pipeline_hips_warp.yaml \
    --input "${COLLECTION}" --output "${HIPS_COLLECTION}" --pixels "$FIXED_PIXELS" -q "$HIPS_QGRAPH_FILE" -o 1 2>&1 | tee "${LOGPATH}/${LOGFILE}"
    EC=$?
    test $EC -eq 0 || echo "QGraph Builder Had a Non-Zero Exit Code: ${LOGPATH}/${LOGFILE}"
    test $EC -eq 0 || exit 1
fi

################################################################################
# Run the graph
LOGFILE=m49_fl_ci_hips-warp.log
JSONFILE="$(basename $LOGFILE .log).json"
if [[ (! -s "${LOGPATH}/${LOGFILE}") && (! -s "${WORKDIR}/${JSONFILE}") ]]; then
    echo "RUNNING HiPS Warp Graph"
    bps submit 01_bps_hips_warp.yaml 2>&1 | tee "${LOGPATH}/${LOGFILE}"
fi

# Loop until the exit code is 0
set +e
while true
do
    test -s "${LOGPATH}/${LOGFILE}" || { sleep 60; continue; }
    python ../node_status_parser.py --file "${LOGPATH}/${LOGFILE}" | jq -f ../workflow_status.jq
    EC=$?
    case $EC in
        0) break;;
        1) exit 1;;
        9) date; python ../node_status_parser.py --file "${LOGPATH}/${LOGFILE}" | jq -f ../node_status.jq;;
        *) echo "Unknown status"; exit 1;;
    esac
    sleep 60
done
set -e

WORKFLOW_STATUS=$(python ./node_status_parser.py --file "${LOGPATH}/${LOGFILE}")
echo "$WORKFLOW_STATUS" | jq . | tee "${WORKDIR}/${JSONFILE}"

################################################################################
# Build Rasters
LOGFILE=m49_fl_ci_hips-raster.log
JSONFILE="$(basename $LOGFILE .log).json"
if [[ (! -s "${LOGPATH}/${LOGFILE}") && (! -s "${WORKDIR}/${JSONFILE}") ]]; then
    echo "RUNNING HiPS Rasterize Graph"
    bps submit 02_bps_hips_raster.yaml  2>&1 | tee "${LOGPATH}/${LOGFILE}"
fi

# Loop until the exit code is 0
set +e
while true
do
    test -s "${LOGPATH}/${LOGFILE}" || { sleep 60; continue; }
    python ../node_status_parser.py --file "${LOGPATH}/${LOGFILE}" | jq -f ../workflow_status.jq
    EC=$?
    case $EC in
        0) break;;
        1) exit 1;;
        9) date; python ../node_status_parser.py --file "${LOGPATH}/${LOGFILE}" | jq -f ../node_status.jq;;
        *) echo "Unknown status"; exit 1;;
    esac
    sleep 900
done
set -e
WORKFLOW_STATUS=$(python ./node_status_parser.py --file "${LOGPATH}/${LOGFILE}")
echo "$WORKFLOW_STATUS" | jq . | tee "${WORKDIR}/${JSONFILE}"

################################################################################
# Finished
MESSAGE="FL CI M49 - ${LSST_VERSION} HiPS maps Finished: ${HIPS_OUTPUT_URI}"
notify
echo "$MESSAGE"

popd
