#!/bin/bash

# ログファイルの指定
LOGFILE="auto_run.log"

# ログファイルの開始メッセージ
echo "===== Auto Run Start: $(date) =====" >> $LOGFILE

# カレントディレクトリ内のすべての .sh ファイルを順番に実行
for script in ./*.sh; do
    # 自分自身 (auto_run.sh) はスキップ
    if [[ "$script" == "./auto_run.sh" ]]; then
        continue
    fi

    echo "Running $script ..." | tee -a $LOGFILE
    bash "$script" >> $LOGFILE 2>&1

    # ステータスチェック
    if [[ $? -eq 0 ]]; then
        echo "$script completed successfully." | tee -a $LOGFILE
    else
        echo "Error occurred while running $script." | tee -a $LOGFILE
    fi
done

echo "===== Auto Run Finished: $(date) =====" >> $LOGFILE
