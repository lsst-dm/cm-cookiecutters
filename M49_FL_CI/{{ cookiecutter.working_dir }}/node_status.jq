. |
{
    remaining: ((.nodesTotal|tonumber) - (.nodesDone|tonumber)),
    pct_done: ((((.nodesDone|tonumber) / (.nodesTotal|tonumber)) * 100) | round),
    error: (.nodesFailed|tonumber)
}
