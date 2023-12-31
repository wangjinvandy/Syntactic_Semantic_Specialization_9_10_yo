#! /bin/bash
root=/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10
topnum="250" 
subjects_file_path=${root}
subjects_file=scripts/5mvpa/data_info.txt #This should be a txt file with only a list of subject numbers
contrastsname="allsentence_vs_PC"
contrasts="spmT_0017.nii" #This should correspond to my allsentence_vs_contrl contrast
ROIs_path=ROIs
ROIs="rLIFG_Oper_mask rLIFG_Tri_mask rL_STG_mask rL_MTG_mask" # you don't need to write .nii
data_path=preproc
firstlevelspm_path=analysis_nosmooth/deweight

########do not need to modify below############
subjects=$(grep -Eo '[0-9\.]+' ${subjects_file_path}/${subjects_file})

#do roi loop
for roi in $ROIs
do 

cd ${root}
mkdir ${roi}_topvoxels_ROIs

#do topvoxels loop
for num in $topnum
do

#do subject loop
for subj in $subjects
do

cd ${root}/${roi}_topvoxels_ROIs
mkdir ${subj}

#do contrast loop
for con_idx in ${!contrastsname[@]}
do 

cd ${root}/${roi}_topvoxels_ROIs/${subj}/
# find the coordinates and the t-values within a mask 
3dmaskdump \
-mask ${root}/${ROIs_path}/${roi}.nii \
${root}/${data_path}/sub-${subj}/${firstlevelspm_path}/${contrasts[con_idx]} > ${roi}_${contrastsname[con_idx]}_output.txt

# sort the output.txt to select the top number of voxels
sort -rk4 -n ${roi}_${contrastsname[con_idx]}_output.txt | head -${num} > ${roi}_${contrastsname[con_idx]}_top${num}.txt
awk '$4+=1000' ${roi}_${contrastsname[con_idx]}_top${num}.txt > ${roi}_${contrastsname[con_idx]}_top${num}_adjust.txt

# put these top number of voxels back to brain
3dUndump \
-prefix ${roi}_${contrastsname[con_idx]}_p1_k${num}_adjust.nii \
-master ${root}/${data_path}/sub-${subj}/${firstlevelspm_path}/${contrasts[con_idx]} \
-ijk ${roi}_${contrastsname[con_idx]}_top${num}_adjust.txt
 
# make a mask of these top number of voxels (make them equal to 1)
3dcalc -a ${roi}_${contrastsname[con_idx]}_p1_k${num}_adjust.nii -expr 'ispositive(a)' -prefix ${roi}_${contrastsname[con_idx]}_p1_k${num}_adjust_mask.nii

done  # end of contrast loop

done  # end of subject loop

done  # end of num loop

done  # end of roi loop