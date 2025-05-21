#!/bin/bash

source ./common.sh
source ./setup_stack.sh

./submit_workflow_stage.sh bps_Nightly-Validation-stage1.yaml && \
./submit_workflow_stage.sh bps_Nightly-Validation-stage2.yaml && \
#./submit_workflow_stage.sh bps_Nightly-Validation-stage3.yaml && \
./generate_hips_maps.sh
