#!/bin/bash

source ./common.sh

pushd $WORKDIR/hips

################################################################################
# First get the survey segments (pixels) or use the FIXED_PIXELS list for M49
# build-high-resolution-hips-qg segment -b embargo -p 01_pipeline_hips_warp.yaml -i "$COLLECTION" -o 1

################################################################################
# Build the graph
echo "BUILDING HiPS Warp Graph"
build-high-resolution-hips-qg build -b embargo -p 01_pipeline_hips_warp.yaml \
--input "${COLLECTION}" --output "${HIPS_COLLECTION}" --pixels $FIXED_PIXELS -q "$HIPS_QGRAPH_FILE" -o 1 &2>1 | tee ${LOGPATH}/m49_fl_ci_hips-build-warp.log
EC=$?
test $EC -eq 0 || echo "QGraph Builder Had a Non-Zero Exit Code: ${LOGPATH}/m49_fl_ci_hips-build-warp.log"
test $EC -eq 0 || exit 1

################################################################################
# Run the graph
echo "RUNNING HiPS Warp Graph"
bps submit 01_bps_hips_warp.yaml 2>&1 | tee ${LOGPATH}/m49_fl_ci_hips-warp.log

# Loop until the exit code is 0
while true
do
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
################################################################################
# Build Rasters
# FIXME use bps for this with fancy workflow yaml
echo "RUNNING HiPS Rasterize Graph"
bps submit 02_bps_hips_raster.yaml  2>&1 | tee ${LOGPATH}/m49_fl_ci_hips-raster.log

# Loop until the exit code is 0
while true
do
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

################################################################################
# Finished
echo "FINISHED: ${HIPS_OUTPUT_URI}"
popd
