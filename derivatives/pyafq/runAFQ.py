import os
import os.path as op
from AFQ.api.participant import ParticipantAFQ
from AFQ.definitions.image import ImageFile

bids_path = op.join('/home/brain/dti_research/')
data_path = op.join('/media/sf_share/MRI_MPILMBB_LEMON/MRI_Raw/')

dwi_path = op.join(bids_path,'preproc','test','sub-032301_ses-01_dir-PA_dwi_aftereddy.nii.gz')
bval_path = op.join(data_path,'sub-032301','ses-01','dwi','sub-032301_ses-01_dwi.bval')
bvec_path = op.join(bids_path,'preproc','test','sub-032301_ses-01_dir-PA_dwi_aftereddy.eddy_rotated_bvecs')
#/home/brain/dti_research/preproc/test/sub-032301_ses-01_dir-PA_dwi_aftereddy.eddy_rotated_bvecs
mask_path = op.join(bids_path,'preproc','test','b0_1_PA_aftereddy_brain_mask.nii.gz')
#tck_path = op.join(bids_path,'derivatives','dticsd','sub-01','CSD_Prob_ACT_300000.tck')
tck_path = op.join(bids_path,'derivatives','tractography','test','Tensor_Det_leftV1_500.tck')

out_dir = op.join(bids_path,'derivatives','pyafq','sub-032301')

brain_mask_definition = ImageFile(
	path = mask_path, 
	suffix = "mask", 
	filters = {"scope":"my_preproc_pipeline"})

myafq = ParticipantAFQ(
	dwi_path, bval_path, bvec_path, out_dir,
	import_tract = tck_path, 
	brain_mask_definition = brain_mask_definition, 
	mapping_definition = None)

myafq.export_all()