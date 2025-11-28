#!/bin/bash

LOGFILE="./auto_run.log"
echo "===== Auto Run Started: $(date) =====" >> $LOGFILE

# 実行したいスクリプトを順番に列挙
SCRIPTS=(
    "/home/brain/dti_research/scripts/s_fsltopup_3_auto.sh"
    "/home/brain/dti_research/scripts/s_fsleddy_4_auto.sh"
    "/home/brain/dti_research/scripts/s_T1wflirt_5_auto.sh"
)

# 指定された順番で順次実行
for script in "${SCRIPTS[@]}"; do
    if [[ ! -f "$script" ]]; then
        echo "Skipped: $script not found." | tee -a $LOGFILE
        continue
    fi

    echo "Running $script ..." | tee -a $LOGFILE
    bash "$script" >> $LOGFILE 2>&1

    if [[ $? -eq 0 ]]; then
        echo "$script completed successfully." | tee -a $LOGFILE
    else
        echo "Error occurred while running $script." | tee -a $LOGFILE
    fi
done

echo "===== Auto Run Finished: $(date) =====" >> $LOGFILE
