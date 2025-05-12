#!/bin/bash
set -eo pipefail

source ./common.sh
source ./setup_lasstcam.sh

# (nodes * cores) % 120 == 0
# exclusive-user means nodes may not be shared with other user glide-ins
if [ -z "$1" ]
then
    MAXNODES=128  # was 576 -- x 15 cores/node = 8640 cores (= 72 nodes x 120 cores/node)
else
    MAXNODES=$1
fi

# Spend no more than 1 day allocating nodes every 2 minutes
for i in {1..720}
do
    allocateNodes.py --auto -c 30 --account rubin:production -n ${MAXNODES} --exclusive-user -m 1-00:00:00 -q milano -g 900 s3df
    sleep 120
done
