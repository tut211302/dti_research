Step 1: b=0 イメージ抽出（fslroi）
位相エンコード方向（AP・PA）ごとのb=0イメージを複数枚抽出し、後のTOPUP補正に利用する。
| ファイル名            | 内容                                 | 備考                                      |
| ---------------- | ---------------------------------- | --------------------------------------- |
| `b0_PA_1.nii.gz` | PA方向（Posterior→Anterior）の1枚目のb=0画像 | fmapディレクトリ内の `*_dir-PA_epi.nii.gz` から抽出 |
| `b0_PA_2.nii.gz` | 同上、2枚目                             |                                         |
| `b0_PA_3.nii.gz` | 同上、3枚目                             |                                         |
| `b0_AP_1.nii.gz` | AP方向（Anterior→Posterior）の1枚目のb=0画像 | fmapディレクトリ内の `*_dir-AP_epi.nii.gz` から抽出 |
| `b0_AP_2.nii.gz` | 同上、2枚目                             |                                         |
| `b0_AP_3.nii.gz` | 同上、3枚目                             |                                         |

Step 2: b=0ファイルの統合（fslmerge）
TOPUPで使用するため、異なる位相エンコード方向のb=0画像を1つのファイルにまとめる。
| ファイル名               | 内容                            | 備考                  |
| ------------------- | ----------------------------- | ------------------- |
| `APPAb0_all.nii.gz` | 6枚のb=0画像を時系列方向（4次元）に結合したNIfTI | `AP3枚 + PA3枚` の合計6枚 |

Step 3: TOPUPの実行
TOPUPは、APとPAの位相反転ペアから**磁場歪み（susceptibility distortion）**を推定し、補正用マップを生成する。

出力された field.nii.gz と topup_PA_AP_b0_fieldcoef.nii.gz は、次に行う eddy 処理の入力として利用される。
| ファイル名                             | 内容                                  | 備考                      |
| --------------------------------- | ----------------------------------- | ----------------------- |
| `topup_PA_AP_b0_fieldcoef.nii.gz` | 磁場歪み（field inhomogeneity）の**係数マップ** | TOPUPの内部パラメータを格納        |
| `topup_PA_AP_b0_movpar.txt`       | 画像の動きパラメータ                          | 各b=0イメージ間のシフト情報など       |
| `field.nii.gz`                    | **磁場歪みマップ（field map）**              | 歪み補正のための位相変化量（ラジアン/秒など） |
| `unwarped_images.nii.gz`          | **歪み補正後のb=0画像**                     | 各ペア（AP/PA）の歪みが補正された画像   |
| `topup_PA_AP_b0_log.txt`          | TOPUPの処理ログ                          | 実行状況やパラメータの詳細（任意）       |

出力ファイルまとめ
| カテゴリ    | ファイル名                                                                                                    | 内容概要           |
| ------- | -------------------------------------------------------------------------------------------------------- | -------------- |
| 抽出b=0   | `b0_AP_*.nii.gz`, `b0_PA_*.nii.gz`                                                                       | 位相方向別のb=0画像    |
| 結合ファイル  | `APPAb0_all.nii.gz`                                                                                      | TOPUP入力用の統合b=0 |
| TOPUP出力 | `topup_PA_AP_b0_fieldcoef.nii.gz`, `field.nii.gz`, `unwarped_images.nii.gz`, `topup_PA_AP_b0_movpar.txt` | 歪み補正結果とパラメータ   |

| ファイル名                             | 主な内容            | 主な用途             |
| --------------------------------- | --------------- | ---------------- |
| `topup_PA_AP_b0_fieldcoef.nii.gz` | 磁場歪みモデルの係数マップ   | `eddy` での歪み補正に使用 |
| `field.nii.gz`                    | 磁場歪み（field map） | 歪み量の可視化・理解用      |
| `unwarped_images.nii.gz`          | 歪み補正後のb=0画像群    | 補正結果の品質確認        |
| `topup_PA_AP_b0_movpar.txt`       | 各b=0画像の動きパラメータ  | `eddy` での動き補正に利用 |

