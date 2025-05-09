# M49 FL CI

## Variables

- `nv_root`: Absolute path to the root of the campaign directory tree. Workflow submit directories will be relative to this location.
- `working_dir`: Relative path from the active client directory (see Setup) for individual cookies. Log files and other support artifacts will be relative to this location.
- `obs_day`: A `YYYYmmdd` date for identifying the cookie, but not otherwise used, e.g., in a data query.

## Setup
- Navigate to the root directory for the rendered cookies. This should be the `nv_root` but may be any directory.
- `cookiecutter https://github.com/lsst-dm/cm-cookiecutters.git --directory="M49_FL_CI" obs_day=$(date '+%Y%m%d')`

## Contents

### Submit Workflow Stage
The `submit_workflow_stage.sh` script is used to submit a single BPS workflow from one of the BPS yaml files included in the cookie. The name of the YAML file should be provided as the first and only argument to this script.

The script should submit the workflow and then loop until it is complete according to the contents of the `.node_status` file in the workflow's submit directory.

### Generate HiPS Maps
The `generate_hips_maps.sh` script is used to perform the warp and rasterization of healpix tiles after the availability of `deep_coadd_predetection` products. The pipeline and workflow files for these operations are in the `hips/` directory.

### Allocate Nodes
The `allocate.sh` script is used to generate glide-ins for HTCondor jobs during campaign processing. It is written to loop every 2 minutes for up to 1 day.

### BPS Submit Node Status
This cookie includes a Python script and related `jq` filter for parsing a `.node_status` file written by BPS to quickly produce a progress report of a running BPS workflow. "Quickly" is relative to running a `bps report` for the same information.

From a cookie, execute the node status parser script with the `--file` argument pointing to a BPS submit log output file, which can be searched for a `Submit dir`. The output will include the contents of the `DagStatus` object in JSON format. You may optionally pipe this output to `jq` with the included filter program for a more succinct summary.

This filter also provides the absolute path to both the BPS submit directory and the qgraph file associated with the workflow.

```
$ ./node_status_parser.py --file path/to/<bps_submit_log>
{"type": "DagStatus", "dagStatus": "3", "nodesTotal": "3398", "nodesDone": "2629", "nodesPre": "0", "nodesFailed": "0"}
```

```
$ ./node_status_parser.py --file path/to/<bps_submit_log> | jq -f node_status.jq
{
  "remaining": 745,
  "pct_done": 78,
  "error": 0
}
```

### BPS Submit Workfow Status
This cookie includes a `workflow_status.jq` filter that can be used with the output of the `node_status_parser.py` script mentioned above.
This filter checks high-level values in the DagStatus and sets an exit code.

- `0`: The workflow is complete and successful.
- `1`: The workflow is not successful or there are any failures.
- `9`: The workflow is nominal and still running.

This filter can be used in a loop to watch the Workflow status:

```
while true
do
    python ./node_status_parser.py --file ${LOGPATH}/${LOGFILE} | jq -f ./workflow_status.jq
    EC=$?
    case $EC in
        0) break;;
        1) break;;
        9) date; python ./node_status_parser.py --file ${LOGPATH}/${LOGFILE} | jq -f ./node_status.jq;;
        *) echo "Unknown status"; break;;
    esac
    sleep 900
done
```
