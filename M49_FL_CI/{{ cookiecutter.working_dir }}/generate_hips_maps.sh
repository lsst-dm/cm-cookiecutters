#!/bin/bash

source ./common.sh

pushd $WORKDIR/hips

################################################################################
# First get the survey segments (pixels) or use the FIXED_PIXELS list for M49
# build-high-resolution-hips-qg segment -b embargo -p 01_pipeline_hips_warp.yaml -i "$COLLECTION" -o 1

################################################################################
# Build the graph
echo "BUILDING HiPS Warp Graph"
if [ -s $HIPS_QGRAPH_FILE]; then
    build-high-resolution-hips-qg build -b embargo -p 01_pipeline_hips_warp.yaml \
    --input "${COLLECTION}" --output "${HIPS_COLLECTION}" --pixels $FIXED_PIXELS -q "$HIPS_QGRAPH_FILE" -o 1 2>&1 | tee ${LOGPATH}/m49_fl_ci_hips-build-warp.log
    EC=$?
    test $EC -eq 0 || echo "QGraph Builder Had a Non-Zero Exit Code: ${LOGPATH}/m49_fl_ci_hips-build-warp.log"
    test $EC -eq 0 || exit 1
fi

################################################################################
# Run the graph
if [ -s ${LOGPATH}/m49_fl_ci_hips-warp.log ]; then
    echo "RUNNING HiPS Warp Graph"
    bps submit 01_bps_hips_warp.yaml 2>&1 | tee ${LOGPATH}/m49_fl_ci_hips-warp.log
fi

# Loop until the exit code is 0
set +e
while true
do
    test -s ${LOGPATH}/m49_fl_ci_hips-warp.log || { sleep 60; continue; }
    python ../node_status_parser.py --file ${LOGPATH}/m49_fl_ci_hips-warp.log | jq -f ../workflow_status.jq
    EC=$?
    case $EC in
        0) break;;
        1) exit 1;;
        9) date; python ../node_status_parser.py --file ${LOGPATH}/m49_fl_ci_hips-warp.log | jq -f ../node_status.jq;;
        *) echo "Unknown status"; exit 1;;
    esac
    sleep 60
done
set -e

WORKFLOW_STATUS=$(python ./node_status_parser.py --file ${LOGPATH}/m49_fl_ci_hips-warp.log
echo $WORKFLOW_STATUS | jq .

################################################################################
# Build Rasters
if [ -s ${LOGPATH}/m49_fl_ci_hips-raster.log ]; then
    echo "RUNNING HiPS Rasterize Graph"
    bps submit 02_bps_hips_raster.yaml  2>&1 | tee ${LOGPATH}/m49_fl_ci_hips-raster.log
fi

# Loop until the exit code is 0
set +e
while true
do
    test -s ${LOGPATH}/m49_fl_ci_hips-raster.log || { sleep 60; continue; }
    python ../node_status_parser.py --file ${LOGPATH}/m49_fl_ci_hips-raster.log | jq -f ../workflow_status.jq
    EC=$?
    case $EC in
        0) break;;
        1) exit 1;;
        9) date; python ../node_status_parser.py --file ${LOGPATH}/m49_fl_ci_hips-raster.log | jq -f ../node_status.jq;;
        *) echo "Unknown status"; exit 1;;
    esac
    sleep 900
done
set -e
WORKFLOW_STATUS=$(python ./node_status_parser.py --file ${LOGPATH}/m49_fl_ci_hips-raster.log
echo $WORKFLOW_STATUS | jq .

################################################################################
# Finished
MESSAGE="FL CI M49 - ${LSST_VERSION} HiPS maps Finished: ${HIPS_OUTPUT_URI}"
notify
echo $MESSAGE

popd
