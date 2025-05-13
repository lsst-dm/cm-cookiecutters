#!/bin/bash

source ./common.sh
source ./setup_stack.sh

# ./submit_workflow_stage.sh bps_M49_FL_CI-stage1.yaml && \
./submit_workflow_stage.sh bps_M49_FL_CI-stage2.yaml && \
./submit_workflow_stage.sh bps_M49_FL_CI-stage3.yaml && \
./generate_hips_maps.sh
