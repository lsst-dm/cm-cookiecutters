. |
if (.dagStatus|tonumber) == 3 then "Workflow still running\n" | halt_error(9)
elif (.dagStatus|tonumber) == 5 then halt
elif (.nodesFailed|tonumber) > 0 then "Workflow has failures\n" | halt_error(1)
else halt_error(1)
end
