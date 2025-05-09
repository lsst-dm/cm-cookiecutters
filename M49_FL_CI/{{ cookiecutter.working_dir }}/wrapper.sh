#!/bin/bash

export WORKDIR={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}
export LOGPATH=${WORKDIR}/bps_sub_logs

pushd ${WORKDIR}

mkdir -p ${LOGPATH}

source setup_lsstcam.sh

submit_workflow_stage.sh bps_M49_CL_CI-stage1.yaml
submit_workflow_stage.sh bps_M49_CL_CI-stage2.yaml
submit_workflow_stage.sh bps_M49_CL_CI-stage3.yaml

generate_hips_maps.sh
