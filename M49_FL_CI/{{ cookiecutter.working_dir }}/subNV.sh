#!/bin/sh
# script for launching nightly
# -----------------------------------------
# subnightlystepbystep
# author: Homer for DM CM
# circa: Feb. 2025
#
#  Submit Interim Nightly Validation pipeline processing step by step.
#
# ------------------------------------------
if [[ $UID -ne 17951 ]];
	then echo "You should be lsstsvc1 before running this script"
	exit 1
fi

subdir={{ cookiecutter.nv_root }}/{{ cookiecutter.working_dir }}
pushd ${subdir}

mkdir -p ${subdir}/bps_sub_logs

if [ -f ./logrotate.conf ]; then
    logrotate --state ./logrotate.status -f ./logrotate.conf
fi

echo "setting up environment"
source ./setup_lsstcam.sh

export DISTRIB=`eups list -s lsst_distrib | awk '{print $2}'`
echo "Using distribution: ${DISTRIB}"

echo "setting steps to process"
export steplist=("bps_M49_CL_CI-stage1" "bps_M49_CL_CI-stage3")

echo "First step = ${steplist[0]}"

export fj="INIT"

for i in "${!steplist[@]}"
do
  export stepname="${steplist[$i]}"
  export bynoext=$(basename ${stepname} .yaml)
  export curlog=${subdir}/bps_sub_logs/${bynoext}.log

  # if first step submit it now
  if [[ $i -eq 0 ]]; then
    echo "performing bps submission for ${stepname}"
    # comment out to recover from first step timeout
    time bps submit ${subdir}/${stepname} 2>&1 | tee ${curlog}
  else
	# periodically check bps submission progression and wait for finalJob to have run
    # - this loops for ~1 day
	for iloop in $(seq 1 2880);
	do
	    sleep 30
	    export fini=1
		export sd=`grep "Submit dir" ${curlog} | cut -d " " -f 3,3`
		export fj=`awk /finalJob/'{getline stat;split(stat,dsc,"\"");print ( (match(dsc[2],"DONE") == 0) ? ( (match(dsc[2],"ERROR") == 0) ? 0 : 2) : 1) }' ${sd}/*.node_status`
		echo "finalJob status for ${bynoext} = ${fj}"
		if [[ ${fj} == "0" || ${fj} == "" ]]; then
		    export fini=0
		fi
	    done

	    if [[ ${fini} -eq 0 ]]; then
    		echo "still waiting for all jobs to finish"
	    else
    		echo "all done ... proceeding to next step"
            export sd=`grep "Submit dir" ${curlog} | cut -d " " -f 3,3`
            export qg=`ls -1 ${sd}/*.qgraph`
    		`pipetask report embargo ${qg}  --force-v2 --full-output-filename ./${bynoext}.json  &> pipetask_report_${bynoext}.log &`
	    fi

	    if [[ ${fini} -eq 1 ]]; then

		# check the number of jobs successfully run before finalJob to know whether the next step should be submitted
        # skipping check for now
		export pf=1
		if [[ ${pf} != "0" ]]; then
			echo "performing bps submission for yaml ${bynoext}"
			time bps submit ${subdir}/${stepname} 2>&1 | tee ${curlog}
			echo "submit directory :"
			grep "Submit dir" ${curlog}
		    done

		    sleep 30
		    break
		else
		    echo "Ending. Nothing for the next step to process :-("
		    exit
		fi
	    fi
#	    if [[ ${fj} == "2" || ${fj} == "" ]]; then
#		exit
#	    fi

	done
    fi
#    if [[ ${fj} == "2" || ${fj} == "" ]]; then
#	exit
#    fi
done
