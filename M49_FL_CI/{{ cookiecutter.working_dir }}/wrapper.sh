#!/bin/bash
set -eo pipefail

source ./common.sh
source setup_lsstcam.sh

# screen -dmS "{{ cookiecutter.obs_day}}"

submit_workflow_stage.sh bps_M49_FL_CI-stage1.yaml && \
submit_workflow_stage.sh bps_M49_FL_CI-stage2.yaml && \
submit_workflow_stage.sh bps_M49_FL_CI-stage3.yaml

# generate_hips_maps.sh
