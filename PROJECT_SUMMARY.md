## プロジェクト概要

このリポジトリは拡散テンソル/拡散モデル解析ワークフロー（DTI/CSd/トラクトグラフィー）をまとめた実験用パイプラインです。主要な目的は被験者毎の前処理（TOPUP/eddy 等）、T1 前処理、5TT（五組織）生成、FOD 推定、トラクトグラフィーおよび AFQ 等の解析を自動化することです。

## 主要ディレクトリ構成（抜粋）

- `raw/` - 元データ（被験者フォルダ）
- `preproc/` - 前処理（TOPUP, eddy, DWI<->T1 アラインなど）の出力
- `first/` - T1 に対する FIRST / 5tt 生成などのスクリプトと一時ファイル
  - `first/first.sh` は T1 の N4, BET, FLIRT, 5ttgen 等の実行例スクリプトです。
- `derivatives/` - MRtrix/FSL の処理結果（dticsd/ や tractography/ などの出力）
  - `derivatives/dticsd/ERROR_REPORT_5TTGen_FIRST_Failure.md` に 5ttgen（FSL FIRST）失敗の詳細診断がまとめられています。
- `tractography/` - 被験者ごとのトラクトグラフィー出力
- `pyafq/` - AFQ（自動化された曲線抽出）関連スクリプト
- `scripts/` - 実行用ラッパースクリプト（自動実行用シェル等）

（全文のディレクトリ一覧はリポジトリルートと `derivatives/`, `tractography/` 配下に多数の被験者フォルダがあります）

## これまでに行ったこと（要約）

- データ抽出と TOPUP 用 b=0 画像の準備（`preproc/` 内の `APPAb0_all.nii.gz` 等）
- TOPUP と eddy を用いた歪み・動き補正。`preproc/` 内に `unwarped_images_mean.nii.gz` や対応する行列が生成されている。
- T1 前処理: N4 バイアス補正、BET（脳抽出）、1mm 等倍格子への再グリッド（regrid）、FLIRT を用いた DWI へのアライメント（`first/first.sh` に処理例あり）
- MRtrix の 5ttgen を用いた 5TT 生成を試行（既定では FSL FIRST を使用するモードで実行）
- 問題発生: `5ttgen FSL FIRST` 実行時に全 10 構造がセグメンテーションに失敗し、FIRST 実行中に segmentation fault（コアダンプ）を発生させる事象を確認。`derivatives/dticsd/ERROR_REPORT_5TTGen_FIRST_Failure.md` に詳細解析を記録。

## 発生しているエラー（現在の障害点）

- 主要エラー: 5ttgen の FSL FIRST 実行中に次のメッセージが出力され、segmentation fault（終了コード 139）が発生。

  - "WARNING: NO INTERIOR VOXELS TO ESTIMATE MODE"
  - "5ttgen: [ERROR] FSL FIRST has failed; 0 of 10 structures were segmented successfully"

- 結果: FIRST が出力ファイルを生成できないため `first_boundary_corr` 等の後続処理も失敗する。
- これまで試した対処（要約）:
  - BET パラメータ変更（-f の調整） → 解決せず
  - 画像の負値除去（クリップ） → 解決せず
  - strides の整合化（mrconvert による修正） → 解決せず
  - FSL 依存ライブラリの確認、グローバルな環境変数確認 → 異常は見つからず

## これまでの診断からの結論（要点）

- 入力画像（T1）は大きな破損や向きの異常がなく、BET 後のマスクも概ね妥当であるため、入力データ側の単純な不良が直接の原因とは考えにくい。
- 最も疑わしい原因は FSL FIRST 自体の実行環境不具合、もしくは FSL の特定バージョンに存在する既知バグによる segmentation fault。

## 次にやるべきこと（優先順位付き）

1. 代替アルゴリズムで 5TT を作る（短期、低コスト）
   - MRtrix の 5ttgen は `hsvs`, `gif`, `freesurfer` など複数のバックエンドをサポートしています。まず `hsvs` を試し、その後 `gif`、時間が許せば `freesurfer` を試す。例:

```bash
5ttgen hsvs T1_in_dwi_space.nii.gz 5TT_hsvs.mif -force
5ttgen gif  T1_in_dwi_space.nii.gz 5TT_gif.mif  -force
5ttgen freesurfer T1_in_dwi_space.nii.gz 5TT_fs.mif -force
```

2. FSL（FIRST）のバージョンとパッチの確認（中期）
   - `fslversion` を確認し、既知のバグフィックスが出ていないか確認。可能であれば FSL のアップデートまたは FIRST の再インストールを検討。

3. core dump の取得と解析（必要なら、上級者向け）
   - `ulimit -c unlimited` をセットして FIRST を再実行。gdb で backtrace を取り、FSL 開発者に報告する。

4. システム診断（並行で実行可）
   - メモリ・ディスク不足の確認: `free -h`, `df -h`。
   - カーネルログ確認: `dmesg | tail -50`。

5. 最終手段として、別環境（コンテナや別マシン）で同じデータを実行して再現性を確認。再現するなら FSL のバグ報告へ。

## 便利なファイルと確認ポイント

- `first/first.sh` - T1 の前処理フロー（N4, BET, FLIRT, 5ttgen の例）。
- `preproc/sub-032301/unwarped_images_mean.nii.gz` - DWI b0 の歪み補正平均画像（T1->DWI の基準に使用）
- `derivatives/dticsd/5ttgen-tmp-*/` - 5ttgen のスクラッチディレクトリ。内部ログ（`first.logs/` 等）を確認。
- `derivatives/dticsd/ERROR_REPORT_5TTGen_FIRST_Failure.md` - 詳細な診断レポート（既に作成済み）

## 追加の提案（将来的）

- 5ttgen の結果を自動的にフォールバックする仕組みをラッパースクリプトに入れる（例: FIRST 失敗時に自動で hsvs を試す）。
- 処理ログとメタデータ（fslversion, mrtrix version, 使用コマンド）を毎回保存し、再現性とデバッグを容易にする。

---

作成日: 2026-05-26

## テスト実行（追記）

- 実施内容: `scripts/5ttgen_fallback.sh` を用いて `preproc/sub-032301/T1w_in_dwi_space_highres.nii.gz` に対して hsvs → gif → freesurfer → fsl の順で 5ttgen を試行しました。
- 実行結果: すべてのバックエンドで失敗しました（ログは下記参照）。
  - サマリ: `derivatives/dticsd/sub-032301/logs/5ttgen_5TT_test_<timestamp>.summary`
  - 直近の scratch ディレクトリ: `5ttgen-tmp-VMIVUX/`（root に作成）
  - FIRST のスクラッチログにて確認されたメッセージ（抜粋）:
    - `WARNING: NO INTERIOR VOXELS TO ESTIMATE MODE`
    - `Error: cannot find image first-L_Accu_first`

注: これらのログは `derivatives/dticsd/sub-032301/logs/` に保存されています。今後のデバッグでは core dump や gdb のバックトレース取得が有用です。
