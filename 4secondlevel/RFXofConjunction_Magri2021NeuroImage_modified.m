clear all
addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabTools/nifti'));
direc = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/preproc';
direcOutput = '/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/ConjunctionAnalysis';
contrasts = [10 13]; %[3 6];
%001 Gram_vs_PC_run1, 002 Gram_vs_PC_run2, 003 Gram_vs_PC,
%004 SCon_vs_PC_run1, 005 SCon_vs_PC_run2, 006 SCon_vs_PC, 
%007 Gram_vs_PC_VS_SCon_vs_PC,
%008 Finite_vs_PC_run1, 009 Finite_vs_PC_run2, 010 Finite_vs_PC, 
%011 InCon_vs_PC_run1, 012 InCon_vs_PC_run2, 013 InCon_vs_PC,
%014 Finite_vs_PC_VS_InCon_vs_PC, 
%015 Syn_spec_correct_vs_incorrect, 016 Sem_spec_correct_vs_incorrect, 
%017 allsentence_vs_PC
subjects=[];
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/scripts/final_sample.xlsx';
if isempty(subjects)
    M=readtable(data_info);
    subjects=M.participant_id;
end

saveFileName = 'RFXofConjunction_%02d_%02d';
saveSubFileName = 'RFXofConjunction%08s_%02d_%02d';
saveFileNamePvalue = 'RFXofConjunctionPvalue_%02d_%02d';


newcon.img = zeros(79,95,79,length(subjects));
newT.img = zeros(79,95,79,length(subjects));
newTRFX.img = zeros(79,95,79,length(subjects));
newTRFXPvalue.img = zeros(79,95,79,length(subjects));
newSubTRFX.img = zeros(79,95,79,length(subjects));

for iSub = 1:length(subjects)
    
    file1dircon = strcat(direc,'/',subjects{iSub},'/analysis_smooth/deweight/','con_00%02d.nii');
    file2dircon = strcat(direc,'/',subjects{iSub},'/analysis_smooth/deweight/','con_00%02d.nii');

    file1dirT = strcat(direc,'/',subjects{iSub},'/analysis_smooth/deweight/','spmT_00%02d.nii');
    file2dirT = strcat(direc,'/',subjects{iSub},'/analysis_smooth/deweight/','spmT_00%02d.nii');

    file1con = sprintf(file1dircon,contrasts(1));
    file2con = sprintf(file1dircon,contrasts(2));
    file1T = sprintf(file1dirT, contrasts(1));
    file2T = sprintf(file1dirT, contrasts(2));    
    contrast1 = load_nii(file1con);
    contrast2 = load_nii(file2con);
    T1 = load_nii(file1T);
    T2 = load_nii(file2T);    
    Tempnewcon.img = zeros(79,95,79);
    TempnewT.img = zeros(79,95,79);    
    %%Select only voxels that are nonzero in both
    CommonVoxels = intersect(find(T1.img),find(T2.img));
    
    for ind=1:size(CommonVoxels,1)     
        %if btoh contrasts are above zero
        if T1.img(CommonVoxels(ind))>0 && T2.img(CommonVoxels(ind))>0   
            %pick the smallest
            if T1.img(CommonVoxels(ind))>T2.img(CommonVoxels(ind))
                Tempnewcon.img(CommonVoxels(ind)) =contrast2.img(CommonVoxels(ind));
                TempnewT.img(CommonVoxels(ind)) =T2.img(CommonVoxels(ind));
            else
                Tempnewcon.img(CommonVoxels(ind)) =contrast1.img(CommonVoxels(ind));
                TempnewT.img(CommonVoxels(ind)) =T1.img(CommonVoxels(ind));
            end           
            %if btoh contrasts are below zero
        elseif contrast1.img(CommonVoxels(ind))<0 && contrast2.img(CommonVoxels(ind))<0           
            %pick the higher
            if T1.img(CommonVoxels(ind))>T2.img(CommonVoxels(ind))
                Tempnewcon.img(CommonVoxels(ind)) = contrast1.img(CommonVoxels(ind));
                TempnewT.img(CommonVoxels(ind)) = T1.img(CommonVoxels(ind));
            else
                Tempnewcon.img(CommonVoxels(ind)) =contrast2.img(CommonVoxels(ind));
                TempnewT.img(CommonVoxels(ind)) =T2.img(CommonVoxels(ind));
            end
        else            
        end
    end
    newcon.img(:,:,:,iSub)=Tempnewcon.img;
    newT.img(:,:,:,iSub)=TempnewT.img;   
    
    
    for x=1:79
        for y=1:95
            for z=1:79
                newSubTRFX.img(x,y,z) = newcon.img(x,y,z,iSub);
                
            end
        end
    end
    
    %%If you want to save subject conjunction analyses...
newSubTRFX.hdr= T1.hdr;
T1.hdr.hist.descrip = sprintf('SPM{T_[18.0]} - conjunction: %02d %02d',contrasts(1),contrasts(2));
newSubTRFX.filetype= T1.filetype;
newSubTRFX.fileprefix= fullfile(direcOutput, sprintf(saveSubFileName,subjects{iSub},contrasts(1),contrasts(2)));
newSubTRFX.machine= T1.machine;
newSubTRFX.original = T1.original;
save_nii(newSubTRFX, fullfile(direcOutput, strcat(sprintf(saveSubFileName,subjects{iSub},contrasts(1),contrasts(2)),'.nii')));

end


for x=1:79
    for y=1:95
        for z=1:79
            [H,P,CI,STATS] = ttest(newcon.img(x,y,z,:));
            if isnan(H)
            newTRFX.img(x,y,z) = 0;
            newTRFXPvalue.img(x,y,z) = 0;
            else
            newTRFX.img(x,y,z) = STATS.tstat;
            newTRFXPvalue.img(x,y,z) = P;
            end
        end
    end
end

newTRFX.hdr= T1.hdr;
newTRFXPvalue.hdr= T1.hdr;
T1.hdr.hist.descrip = sprintf('SPM{T_[18.0]} - conjunction: %02d %02d',contrasts(1),contrasts(2));
newTRFX.filetype= T1.filetype;
newTRFX.fileprefix= fullfile(direcOutput, sprintf(saveFileName,contrasts(1),contrasts(2)));
newTRFX.machine= T1.machine;
newTRFX.original = T1.original;
save_nii(newTRFX, fullfile(direcOutput, strcat(sprintf(saveFileName,contrasts(1),contrasts(2)),'.nii')));


newTRFXPvalue.filetype= T1.filetype;
newTRFXPvalue.fileprefix= fullfile(direcOutput, sprintf(saveFileName,contrasts(1),contrasts(2)));
newTRFXPvalue.machine= T1.machine;
newTRFXPvalue.original = T1.original;
save_nii(newTRFXPvalue, fullfile(direcOutput, strcat(sprintf(saveFileNamePvalue,contrasts(1),contrasts(2)),'.nii')));

