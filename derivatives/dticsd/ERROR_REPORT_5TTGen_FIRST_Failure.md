# 5ttgen FSL FIRST セグメンテーション失敗 — 詳細診断報告書

## 実行環境

- **OS**: Linux (Ubuntu/Debian系)
- **スクリプト**: `/home/brain/dti_research/derivatives/dticsd/s_create5TT_8_auto.sh`
- **対象被験者**: sub-032301
- **実行日**: 2025年11月13日 および 2025年11月28日
- **MRtrix バージョン**: 3.0.4-48-gfdec23df
- **FSL バージョン**: 6.0.7.17

---

## 症状

5ttgen FSL（FSL FIRST を使用したアルゴリズム）の実行時に、**全 10 構造（bilateral accumbens, caudate, pallidum, putamen, thalamus）のセグメンテーションが失敗**し、以下のエラーが報告されました：

```
5ttgen: [ERROR] FSL FIRST has failed; 0 of 10 structures were segmented successfully
5ttgen: Scratch directory retained; location: /home/brain/dti_research/derivatives/dticsd/sub-032301/5ttgen-tmp-PJZXFA/
```

---

## 根本原因分析

### 1. ログから観察されたエラーメッセージ

#### primary stderr（first.e94552.1, etc.）
```
WARNING: NO INTERIOR VOXELS TO ESTIMATE MODE
```

この警告は、FIRST の形状モデル（shape model）が初期内側ボクセル（interior voxels）を特定できず、モード推定が失敗したことを示します。

#### segmentation fault
```
/usr/local/fsl/bin/run_first: line 165: 102200 Segmentation fault (core dumped) ${FSLDIR}/bin/first ...
```

FIRST バイナリ実行中に segmentation fault（終了コード 139）が発生し、プロセスが強制終了されました。

#### 後続処理の失敗
```
Error: cannot find image first-L_Accu_first
```

FIRST が出力ファイルを作成できず、後続の `first_boundary_corr` が失敗。

### 2. 入力画像の詳細検査

#### メタデータ確認
- **次元**: 128 × 128 × 88 (元の解像度) → 220 × 220 × 150 (regrid後 1mm isotropic)
- **ボクセルサイズ**: 1.71875 × 1.71875 × 1.7 mm (元) → 1.0 × 1.0 × 1.0 mm (regrid後)
- **データ型**: 32-bit float
- **データ破損**: なし（NaN/Inf検出なし）

#### 統計（T1_BET.nii.gz）
| 項目 | 値 |
|------|-----|
| 最小値 (min) | -184.19 |
| 最大値 (max) | 4081.20 |
| 非ゼロボクセル数 | 655,467 / 1,297,296 (50.5%) |
| 平均値 | 2155.24 |
| 標準偏差 | 873.92 |
| 脳組織強度 (P25-P75) | 1755.57 - 2679.98 |

#### 統計（T1_1mm.nii regrid後）
| 項目 | 値 |
|------|-----|
| 最小値 | -707.86 |
| 最大値 | 4598.85 |
| 非ゼロボクセル数 | 5,627,069 / 7,260,000 (77.5%) |
| 平均値 | 1855.33 |
| 標準偏差 | 1026.18 |

#### 画像向き（qform/sform）
- **Orientation**: Right-to-Left, Posterior-to-Anterior, Inferior-to-Superior (標準的な Scanner Anat)
- **qform_code**: 1 (Scanner Anatomical)
- **sform_code**: 1 (Scanner Anatomical)

**評価**: 入力 T1 画像は **正常**。データ破損、脳消失、向き異常なし。

### 3. 試行した対処

#### 試行 #1: BET パラメータ調整
- **試行内容**: BET の fractional intensity threshold を `-f 0.15` (元) → `-f 0.3` (標準値) に変更
- **結果**: ❌ 失敗。同じ警告・segfault が発生。出力ファイルなし。
- **教訓**: BET パラメータの調整では解決しない。問題は脳抽出より下流。

#### 試行 #2: 画像強度の正規化（負値クリップ）
- **試行内容**: T1_1mm.nii 内の負値を 0 にクリップして FIRST を実行
- **結果**: ❌ 失敗。同じ警告が出現し、segfault 発生。
- **教訓**: 負値が根本原因ではない。

#### 試行 #3: Image strides 修正
- **試行内容**: `mrconvert` で明示的に `-strides -1,+2,+3` を指定せず、代わりに標準 strides `[1,2,3]` で処理
- **比較**:
  - `-strides` 版: `T1.nii` の strides = `[-1, 2, 3]` (最初の軸が反転)
  - 標準版: `T1_nostrides.nii` の strides = `[1, 2, 3]` (標準)
- **結果**: ❌ 失敗。同じ segfault が再現。
- **教訓**: strides 修正でも解決しない。

### 4. 環境・ライブラリ確認

#### FSL 依存ライブラリ
すべて正常に resolve:
```
libfsl-shapeModel.so ✓
libfsl-vtkio.so ✓
libfsl-meshclass.so ✓
libfsl-newimage.so ✓
libfsl-miscmaths.so ✓
libfsl-utils.so ✓
liblapack.so.3 ✓
libgfortran.so.5 ✓
...
```

#### FIRST バイナリ
- **パス**: `/usr/local/fsl/bin/first`（シェルスクリプト）
- **実体バイナリ**: `/usr/local/fsl/share/fsl/bin/first`（ELF実行形式）
- **依存解決**: 正常

**評価**: 環境/ライブラリ側の問題は検出されず。

---

## 診断結論

### 根本原因（最も可能性が高い順）

1. **FSL FIRST バイナリの環境不具合または既知バグ**
   - パラメータ調整、入力画像の修正、strides 修正のすべてが失敗
   - 「NO INTERIOR VOXELS TO ESTIMATE MODE」警告 → segfault というシーケンスは、形状モデルの内部アルゴリズムの崩壊を示唆
   - FSL 6.0.7.17 に関連する既知のバグが存在する可能性

2. **入力 T1 と FIRST の期待値ミスマッチ**
   - BET の結果（脳マスク）が FIRST の想定する内部構造との期待値にズレ
   - regrid による補間（sinc）後の画像の統計的性質が FIRST のモデルトレーニング時の統計と乖離している可能性

3. **システムレベルの問題**
   - メモリ不足、セキュリティモジュール（AppArmor等）による実行制限、ファイルシステムのI/O エラーなど

### 除外された原因

- ❌ **入力 T1 画像の破損**: NaN/Inf なし、次元/メタデータ正常、脳組織正常に存在
- ❌ **BET失敗**: 脳マスク適切に生成、非ゼロボクセル数妥当
- ❌ **画像向き異常**: qform/sform 正常、標準的な RPI 軸方向
- ❌ **negative intensity**: クリップしても失敗、根本原因ではない
- ❌ **strides/向き問題**: 標準化してもセグフォルト再現

---

## 推奨される対処方法

### 優先度 1（推奨、即座）

#### 1a. 代替セグメンテーションアルゴリズム試行
5ttgen は以下のアルゴリズムをサポート：
- **freesurfer**: FreeSurfer（recon-all）を使用した完全セグメンテーション
- **gif**: GIF（Geodesic Information Flows）アルゴリズム
- **hsvs**: MRtrix3 Hierarchical SVD Segmentation（軽量）

**試行順序**:
```bash
# 試行 1: hsvs (最軽量、依存最小)
5ttgen hsvs T1w_in_dwi_space_highres.nii.gz 5TT_hsvs.mif -force

# 試行 2: gif (中程度の重さ、精度高い可能性)
5ttgen gif T1w_in_dwi_space_highres.nii.gz 5TT_gif.mif -force

# 試行 3: freesurfer (最重い、最高精度、インストール必要)
5ttgen freesurfer T1w_in_dwi_space_highres.nii.gz 5TT_fs.mif -force
```

### 優先度 2（環境確認・修復）

#### 2a. FSL FIRST のバージョン確認・バグ報告
```bash
fslversion
first -version  # （あれば）
```

FSL 6.0.7.17 の既知バグリスト、または最新パッチの確認が必要。管理者に報告を推奨。

#### 2b. FSL の再インストール
```bash
# FSL アンインストール（管理者権限が必要な場合あり）
sudo rm -rf /usr/local/fsl

# 最新版の再インストール
# https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/FslInstallation を参照
```

### 優先度 3（システムレベル診断）

#### 3a. core dump の取得・分析（高度なデバッグ）
```bash
# core dump を有効化
ulimit -c unlimited

# FIRST を gdb で実行
gdb --args /usr/local/fsl/bin/first -i T1_1mm.nii -l T1_1mm_to_std_sub.mat -m /usr/local/fsl/data/first/models_336_bin/L_Accu_bin.bmv -k first-L_Accu_first -n 50

# または core dump を読み込み
gdb /usr/local/fsl/bin/first core
bt  # backtrace で crash 位置を確認
```

#### 3b. システムメモリ・ディスク確認
```bash
free -h  # メモリ使用量
df -h    # ディスク空き容量
dmesg | tail -20  # kernel messages
```

---

## 結論

**FSL FIRST の segmentation fault は、入力 T1 画像の品質や前処理パラメータの問題ではなく、FSL FIRST バイナリ自体の環境不具合、または既知バグの可能性が高い**。

推奨される解決策：
1. **短期**: 代替アルゴリズム（hsvs, gif, freesurfer）で 5ttgen を実行
2. **中期**: FSL バージョン確認・アップグレード、または FIRST の再インストール
3. **長期**: 他の脳セグメンテーションパイプライン（ANTs など）の導入検討

---

## 付録：実行ログ

### スクラッチディレクトリ
```
/home/brain/dti_research/derivatives/dticsd/sub-032301/5ttgen-tmp-PJZXFA/
```

### key files
- `log.txt`: 5ttgen の実行コマンド列
- `first.com`: 実行された run_first コマンド（全構造）
- `first.logs/first.e*.1`: stderr（警告・エラー出力）
- `first.logs/first.o*.1`: stdout（trace出力）
- `T1_preBET.nii.gz`: BET 前の T1
- `T1_BET.nii.gz`: BET 後（-f 0.15）
- `T1_1mm.nii`: regrid 後（1mm isotropic）

---

**報告作成日**: 2025年11月28日  
**報告者**: 自動診断ツール（MRtrix3/FSL 環境分析）
