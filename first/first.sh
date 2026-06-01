N4BiasFieldCorrection -i /media/sf_share/MRI_MPILMBB_LEMON/MRI_Raw/sub-032301/ses-01/anat/sub-032301_ses-01_acq-mp2rage_T1w.nii.gz
                      -o T1w_N4.nii.gz

bet T1w_N4.nii.gz T1w_N4_bet.nii.gz -R -f 0.2

# 例：TOPUP からの出力 mean b0 を使う
cp /home/brain/dti_research/preproc/sub-032301/unwarped_images_mean.nii.gz DWI_b0.nii.gz
# もしくは元の最初のボリューム
#fslroi /path/to/dwi.nii.gz DWI_b0.nii.gz 0 1

flirt -in T1w_N4_bet.nii.gz -ref DWI_b0.nii.gz -omat T1_to_DWI.mat -dof 6 -cost mutualinfo

flirt -in T1w_N4_bet.nii.gz -ref DWI_b0.nii.gz -applyxfm -init T1_to_DWI.mat -out T1_in_DWI.nii.gz
# QC: mrview や fsleyes でオーバーレイして確認
mrview DWI_b0.nii.gz -overlay.load T1_in_DWI.nii.gz

5ttgen fsl T1w_N4_bet.nii.gz 5TT.mif -premat T1_to_DWI.mat -nocleanup -force
