#! /bin/bash
root=/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10
subjects_file_path=${root}
subjects_file=scripts/5mvpa/data_info.txt #This should be a txt file with only a list of subject numbers
contrastsname=('Gram_vs_PC_run1' 'Gram_vs_PC_run2' 'SCon_vs_PC_run1' 'SCon_vs_PC_run2')
contrasts=('spmT_0001.nii' 'spmT_0002.nii' 'spmT_0004.nii' 'spmT_0005.nii') #This should correspond to the contrast names
ROIs_path=('rLIFG_Oper_mask_topvoxels_ROIs' 'rLIFG_Tri_mask_topvoxels_ROIs' 'rL_STG_mask_topvoxels_ROIs' 'rL_MTG_mask_topvoxels_ROIs')
ROIs=('rLIFG_Oper_mask_allsentence_vs_PC_p1_k250_adjust_mask' 'rLIFG_Tri_mask_allsentence_vs_PC_p1_k250_adjust_mask' 'rL_STG_mask_allsentence_vs_PC_p1_k250_adjust_mask' 'rL_MTG_mask_allsentence_vs_PC_p1_k250_adjust_mask')
data_path=preproc
firstlevelspm_path=analysis_nosmooth/deweight

########do not need to modify below############
subjects=$(grep -Eo '[0-9\.]+' ${subjects_file_path}/${subjects_file})

#do roi loop
for roi_idx in ${!ROIs[@]}
do 

cd ${root}
mkdir extractedT_${ROIs_path[roi_idx]}

#do contrast loop
for con_idx in ${!contrastsname[@]}
do 
cd ${root}/extractedT_${ROIs_path[roi_idx]}
mkdir ${contrastsname[con_idx]}

#do subject loop
for sub in $subjects
do

cd ${root}/extractedT_${ROIs_path[roi_idx]}/${contrastsname[con_idx]}
mkdir ${sub}
cd ${sub}
# find the coordinates and the t-values within a mask 
3dmaskdump \
-mask ${root}/${ROIs_path[roi_idx]}/${sub}/${ROIs[roi_idx]}.nii \
${root}/${data_path}/sub-${sub}/${firstlevelspm_path}/${contrasts[con_idx]} > ${ROIs[roi_idx]}_${contrastsname[con_idx]}_output.txt

done  # end of subject loop

done  # end of contrast loop

done  # end of roi loop