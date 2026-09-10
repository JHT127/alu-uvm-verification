set coverage_dir [file normalize "cov_work/scope/test_sv1"]
load -run $coverage_dir
report -text -summary -metrics all -out coverage_summary.txt
report -text -detail -metrics functional -out coverage_report.txt
exit
