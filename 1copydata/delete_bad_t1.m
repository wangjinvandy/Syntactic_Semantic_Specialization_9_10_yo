%%This code is used to remove the bad anat_T1 that is not in the
%%good_t1_list.txt 

data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/scripts/better_t1.xlsx';
%This is your excel path. In this excel, it should have two columns, one is
%subjects, the other is better_t1. 
data_path='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/preproc';
session='ses-9'; % This code can only run session by session. You cannot run multiple sessions all at once using this simple code.


M=readtable(data_info);
good_t1=M.better_t1; 
subjects=M.participant_id;

for i=1:length(subjects)
    t1s_path=[data_path '/' subjects{i} '/' session '/anat'];
    cd(t1s_path);
    t1s=dir(t1s_path);
    for j=3:length(t1s)
        thist1=t1s(j).name;
        thist1=thist1(1:end-4);
        if ~strcmp(thist1,good_t1{i})
           delete([thist1 '.nii']);
        end
    end
end

        
        

