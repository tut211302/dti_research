#!/usr/bin/env python3
import os
import os.path as op

BASE = '/home/brain/dti_research'

checks = {
    'dwi': op.join(BASE,'preproc','test','sub-032301_ses-01_dir-PA_dwi_aftereddy.nii.gz'),
    'bval': op.join(BASE,'raw','sub-032301','ses-01','dwi','sub-032301_ses-01_dwi.bval'),
    'bvec': op.join(BASE,'preproc','test','sub-032301_ses-01_dir-PA_dwi_aftereddy.eddy_rotated_bvecs'),
    'mask': op.join(BASE,'preproc','test','b0_1_PA_aftereddy_brain_mask.nii.gz'),
    'tck': op.join(BASE,'derivatives','tractography','test','Tensor_Det_500_leftV1.tck'),
}

missing = []
for k,p in checks.items():
    if not op.exists(p):
        missing.append((k,p))

if missing:
    print('Missing required inputs:')
    for k,p in missing:
        print(f" - {k}: {p}")
    raise SystemExit(2)

print('All required input files were found:')
for k,p in checks.items():
    print(f" - {k}: {p}")
