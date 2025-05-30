. |
if (.dagStatus|tonumber) == 3 then "Workflow still running\n"
elif (.dagStatus|tonumber) == 5 then halt
elif (.nodesFailed|tonumber) > 0 then "Workflow has failures\n"
else "Error 1\n"
end
