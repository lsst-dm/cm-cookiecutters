# M49 FL CI

## Variables

- `nv_root`: Absolute path to the root of the campaign directory tree. Subdirectories of this location will include submit, logs, etc.
- `working_dir`: Relative path from the active client directory (see Setup) for individual cookies.
- `obs_day`: Usually set to "yesterday".

## Setup
- Navigate to the root directory for the rendered cookies. This should be the `nv_root` but may be any directory.
- `cookiecutter https://github.com/lsst-dm/cm-cookiecutters.git --directory="M49_FL_CI" obs_day=$(date '+%Y%m%d')`

## Contents

### BPS Submit Node Status
This cookie includes a Python script and related `jq` filter for parsing a `.node_status` file written by BPS to quickly produce a progress report of a running BPS workflow. "Quickly" is relative to running a `bps report` for the same information.

From a cookie, execute the node status parser script with the `--file` argument pointing to a BPS submit log output file, which can be searched for a `Submit dir`. The output will include the contents of the `DagStatus` object in JSON format. You may optionally pipe this output to `jq` with the included filter program for a more succinct summary.

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
