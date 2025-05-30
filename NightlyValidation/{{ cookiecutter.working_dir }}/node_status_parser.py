#!/usr/bin/env python3
# /// script
# requires-python = ">=3.11"
# dependencies = [
#     "click",
# ]
# ///

"""Script to locate a node_status file in a BPS submit directory by
dereferencing the location logged by the BPS submit output. The contents of a
DagStatus block is matched in the node_status file and its relevant contents
output as JSON.
"""

import json
import re
import sys
from pathlib import Path

import click

BPS_SUBMIT_DIR = r"^Submit dir:\s*(.*)$"
NODE_STATUS_OBJECT = r"\[(?P<object>(?:.*\n)+?)\]"
DAG_STATUS = (
    r"Type\s*=\s*\"(?P<type>.*?)\"\s*;.*?"
    r"DagStatus\s*=\s*(?P<dagStatus>\d*?)\s*;.*?"
    r"NodesTotal\s*=\s*(?P<nodesTotal>\d*?)\s*;.*?"
    r"NodesDone\s*=\s*(?P<nodesDone>\d*?)\s*;.*?"
    r"NodesPre\s*=\s*(?P<nodesPre>\d*?)\s*;.*?"
    r"NodesFutile\s*=\s*(?P<nodesFutile>\d*?)\s*;.*?"
    r"NodesFailed\s*=\s*(?P<nodesFailed>\d*?)\s*;.*?"
)


def get_submit_dir_from_bps_log(logfile: Path):
    bps_submit_dir_r = re.compile(BPS_SUBMIT_DIR, re.MULTILINE)
    with open(logfile) as f:
        for line in f:
            candidate = re.match(bps_submit_dir_r, line)
            if candidate:
                return candidate.group(1)
    print("ERROR: No submit dir found in BPS log")
    sys.exit(1)


def get_qgraph_file(submit_dir: Path):
    try:
        qgraph_file = next(submit_dir.glob("*.qgraph"))
    except StopIteration:
        qgraph_file = None
    return str(qgraph_file)


@click.command()
@click.option("-f", "--file")
def main(file):
    object_r = re.compile(NODE_STATUS_OBJECT, re.MULTILINE)
    dag_status_r = re.compile(DAG_STATUS)

    submit_dir = get_submit_dir_from_bps_log(Path(file))
    qgraph_file = get_qgraph_file(Path(submit_dir))

    try:
        node_status_file = next(Path(submit_dir).glob("*.node_status"))
    except StopIteration:
        print("ERROR: no node status file found in bps submit directory")
        sys.exit(1)

    node_status_file_contents = Path(node_status_file).read_text()
    for match in object_r.finditer(node_status_file_contents):
        object = match.group("object").strip()
        object = re.sub(r"\s+", " ", object)
        if dag_status := re.match(dag_status_r, object):
            print(json.dumps({"bps_submit_directory": submit_dir, "qgraph_file": qgraph_file, **dag_status.groupdict()}))


if __name__ == "__main__":
    main()
