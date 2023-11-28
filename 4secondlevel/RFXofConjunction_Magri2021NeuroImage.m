clear all
direc = '/Users/caterinamagri/Documents/Projects/SMRProject/SPM/SMR_Analysis/4_preprocessedData_PSF/sub%s/GLM_mainExp_id/';
direcOutput = '/Users/caterinamagri/Documents/Projects/SMRProject/SPM/FromCosti/18ConjunctionAnalysis';
contrasts = [6 8];
subjects = [12];

file1dircon = strcat(direc,'con_00%02d.nii');
file2dircon = strcat(direc,'con_00%02d.nii');

file1dirT = strcat(direc,'spmT_00%02d.nii');
file2dirT = strcat(direc,'spmT_00%02d.nii');

% saveFileName = 'MRContrastConjunctionP001';
saveFileName = 'RFXofConjunction_%02d_%02d';
saveSubFileName = 'RFXofConjunctionSUB%02d_%02d_%02d';

saveFileNamePvalue = 'RFXofConjunctionPvalue_%02d_%02d';
newcon.img = zeros(79,95,79,length(subjects));
newT.img = zeros(79,95,79,length(subjects));
newTRFX.img = zeros(79,95,79,length(subjects));
newTRFXPvalue.img = zeros(79,95,79,length(subjects));
newSubTRFX.img = zeros(79,95,79,length(subjects));

for iSub = 1:length(subjects)
    
    if subjects(iSub)<10
        subjectString = sprintf('0%d',subjects(iSub));
    else
        subjectString = sprintf('%d',subjects(iSub));
    end
    
    file1con = sprintf(file1dircon, subjectString,contrasts(1));
    file2con = sprintf(file1dircon, subjectString,contrasts(2));
    file1T = sprintf(file1dirT, subjectString,contrasts(1));
    file2T = sprintf(file1dirT, subjectString,contrasts(2));    
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
T1.hdr.hist.descrip = sprintf('SPM{T_[18.0]} - conjunction: %02d %02d - All Sessions',contrasts(1),contrasts(1));
newSubTRFX.filetype= T1.filetype;
newSubTRFX.fileprefix= fullfile(direcOutput, sprintf(saveSubFileName,subjects(iSub),contrasts(1),contrasts(2)));
newSubTRFX.machine= T1.machine;
newSubTRFX.original = T1.original;
save_nii(newSubTRFX, fullfile(direcOutput, strcat(sprintf(saveSubFileName,subjects(iSub),contrasts(1),contrasts(2)),'.nii')));

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
T1.hdr.hist.descrip = sprintf('SPM{T_[18.0]} - conjunction: %02d %02d - All Sessions',contrasts(1),contrasts(1));
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

