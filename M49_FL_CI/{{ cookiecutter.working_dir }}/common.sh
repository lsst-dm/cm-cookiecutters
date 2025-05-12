notify () {
    # send slack notification ${MESSAGE} using ${SLACK_WEBHOOK_URL} if one is defined.
    test -n "${SLACK_WEBHOOK_URL}" || return
    test -n "${MESSAGE}" || return
    curl -X POST -H 'Content-type: application/json' --data '{"text":"'"${MESSAGE}"'"}' ${SLACK_WEBHOOK_URL} &> /dev/null
}

rotate () {
    # Rotates ALL logs in $LOGDIR
    if [ -f ${WORKDIR}/etc/logrotate.conf ]; then
        logrotate --state ${WORKDIR}/logrotate.status -f ${WORKDIR}/etc/logrotate.conf
    fi
}

# source any .env file in PWD or its parent
test -f {{ cookiecutter.nv_root }}/.env && source {{ cookiecutter.nv_root }}/.env
test -f ${WORKDIR}/.env && source ${WORKDIR}/.env

export LSST_DISTRIB={{ cookiecutter.lsst_distrib_dir }}
export WORKDIR={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}
export SCREENRC=${WORKDIR}/etc/screenrc
export LOGPATH=${WORKDIR}/logs

if [ -f .lsst-version ]; then
    export LSST_VERSION=$(cat .lsst-version)
else
    export LSST_VERSION=$(ls -1dt $LSST_DISTRIB/[dw]_latest | head -n 1)
    export LSST_VERSION=$(readlink -nf $LSST_VERSION | xargs -- basename)
    echo $LSST_VERSION > .lsst-version
fi

export COLLECTION="LSSTCam/runs/M49-FL-CI/${LSST_VERSION}/{{ cookiecutter.jira_ticket_number }}"
export OUT_COLLECTION="LSSTCam/runs/M49-FL-CI/${LSST_VERSION}/{{ cookiecutter.jira_ticket_number }}"
export HIPS_COLLECTION="LSSTCam/runs/M49-FL-CI/${LSST_VERSION}/{{ cookiecutter.jira_ticket_number }}/hips"
export HIPS_OUTPUT_URI="s3://embargo@rubin-views/${COLLECTION}"

export HIPS_QGRAPH_FILE="m49_fl_ci_hips_warp.qgraph"
export FIXED_PIXELS="25 27 28 36 37 40 41 42 43"

mkdir -p ${LOGPATH}
