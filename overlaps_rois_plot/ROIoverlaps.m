function ROIoverlaps
% This script will combine all the individual ROIs, and using mricron to
% show color-code clusters depending on the amount of overlaps. written by
% Jin Wang 5/3/2019

addpath(genpath('/dors/gpc/JamesBooth/JBooth-Lab/BDL/LabTools/nifti')); % addpath the nifti function tools, for this script it is mainly using the load_nii.m and save_nii.m.

%root_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/rLIFG_Oper_mask_topvoxels_ROIs'; % your individual ROI paths
root_dir = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/rL_STG_mask_topvoxels_ROIs';
subjects = {};
%roi_name= 'rLIFG_Oper_mask_allsentence_vs_PC_p1_k250_adjust_mask.nii';
roi_name= 'rL_STG_mask_allsentence_vs_PC_p1_k250_adjust_mask.nii';
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/scripts/final_sample.xlsx';

if isempty(subjects)
    M=readtable(data_info);
    subjects=M.participant_id;
end

    %set s.img as zeros, the matrix sized depends on the first subejct
    %s.img size
    idx = 1; 
    roi_dir = [root_dir '/' subjects{1}(5:end) '/' roi_name];
    s = load_nii(roi_dir);
    s.img = zeros(size(s(1).img));
    
    % add subjects s.img up
    for ii = 1:length(subjects)
        roi_dir = [root_dir '/' subjects{ii}(5:end) '/' roi_name];
        m(idx) = load_nii(roi_dir);
        s.img = s.img + double(m(idx).img);
        idx=idx+1;
    end
cd(root_dir);
%save_nii(s,[roi_name(1:end-16) '_overlaps.nii'])  % The name of your combined ROI
save_nii(s,[roi_name(1:end-16) '_overlaps.nii']) 
end