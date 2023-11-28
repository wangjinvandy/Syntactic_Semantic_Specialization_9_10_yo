function correlational_analysis_moutlier
%%The within and across task correlation code
subjects=[];
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/scripts/5mvpa/data_info.txt';
if isempty(subjects)
    M=readtable(data_info);
    subjects=M.participant_id;
end
root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10';
%Tvaluefolder='extractedT_rLIFG_Oper_mask_topvoxels_ROIs';
%Tvaluefolder='extractedT_rLIFG_Tri_mask_topvoxels_ROIs';
%Tvaluefolder='extractedT_rL_STG_mask_topvoxels_ROIs';
Tvaluefolder='extractedT_rL_MTG_mask_topvoxels_ROIs';
%ROI='rLIFG_Oper_mask_allsentence_vs_PC_p1_k250_adjust_mask';
%ROI='rLIFG_Tri_mask_allsentence_vs_PC_p1_k250_adjust_mask';
%ROI='rL_STG_mask_allsentence_vs_PC_p1_k250_adjust_mask';
ROI='rL_MTG_mask_allsentence_vs_PC_p1_k250_adjust_mask';

writefile=[Tvaluefolder '_correlation2_rmoutlier.txt'];
cd(root);
if exist(writefile)
   delete(writefile);
end
fid_w=fopen(writefile,'wt');
fprintf(fid_w,'%s %s %s %s\n', 'participant_id', 'withinFinite', 'withinInCon', 'acrosstask');

for i=1:length(subjects)
    this_sub=subjects{i}(end-3:end);
    txt_run1Finite=[root '/' Tvaluefolder '/Finite_vs_PC_run1/' this_sub '/' ROI '_Finite_vs_PC_run1_output.txt'];
    fid=fopen(txt_run1Finite);
    data1=textscan(fid,'%d %d %d %f');
    finiterun1=data1{4};
    nonoutlier_loc1_finite=(finiterun1 < (mean(finiterun1)+3*std(finiterun1)) & finiterun1 > (mean(finiterun1)- 3*std(finiterun1)));
    txt_run2Finite=[root '/' Tvaluefolder '/Finite_vs_PC_run2/' this_sub '/' ROI '_Finite_vs_PC_run2_output.txt'];
    fid2=fopen(txt_run2Finite);
    data2=textscan(fid2,'%d %d %d %f');
    finiterun2=data2{4};
    nonoutlier_loc2_finite=(finiterun2 < (mean(finiterun2)+3*std(finiterun2)) & finiterun2 > (mean(finiterun2)- 3*std(finiterun2)));
    nonoutlier_loc_finite= (nonoutlier_loc1_finite & nonoutlier_loc2_finite);
    withinFinite=corrcoef(finiterun1(nonoutlier_loc_finite), finiterun2(nonoutlier_loc_finite));
    r_withinFinite=withinFinite(1,2);
    
    txt_run1InCon=[root '/' Tvaluefolder '/InCon_vs_PC_run1/' this_sub '/' ROI '_InCon_vs_PC_run1_output.txt'];
    fid3=fopen(txt_run1InCon);
    data3=textscan(fid3,'%d %d %d %f');
    inconrun1=data3{4};
    nonoutlier_loc1_incon=(inconrun1 < (mean(inconrun1)+3*std(inconrun1)) & inconrun1 > (mean(inconrun1)- 3*std(inconrun1)));
    txt_run2InCon=[root '/' Tvaluefolder '/InCon_vs_PC_run2/' this_sub '/' ROI '_InCon_vs_PC_run2_output.txt'];
    fid4=fopen(txt_run2InCon);
    data4=textscan(fid4,'%d %d %d %f');
    inconrun2=data4{4};
    nonoutlier_loc2_incon=(inconrun2 < (mean(inconrun2)+3*std(inconrun2)) & inconrun2 > (mean(inconrun2)- 3*std(inconrun2)));
    nonoutlier_loc_incon=(nonoutlier_loc1_incon & nonoutlier_loc2_incon);
    withinInCon=corrcoef(inconrun1(nonoutlier_loc_incon), inconrun2(nonoutlier_loc_incon));
    r_withinInCon=withinInCon(1,2);
    
    acrosstask11=corrcoef(finiterun1(nonoutlier_loc1_finite & nonoutlier_loc1_incon), inconrun1(nonoutlier_loc1_finite & nonoutlier_loc1_incon)); r_acrosstask11=acrosstask11(1,2);
    acrosstask12=corrcoef(finiterun1(nonoutlier_loc2_finite & nonoutlier_loc2_incon), inconrun2(nonoutlier_loc2_finite & nonoutlier_loc2_incon)); r_acrosstask12=acrosstask12(1,2);
    acrosstask21=corrcoef(finiterun2(nonoutlier_loc2_finite & nonoutlier_loc1_incon), inconrun1(nonoutlier_loc2_finite & nonoutlier_loc1_incon)); r_acrosstask21=acrosstask21(1,2);
    acrosstask22=corrcoef(finiterun2(nonoutlier_loc2_finite & nonoutlier_loc2_incon), inconrun2(nonoutlier_loc2_finite & nonoutlier_loc2_incon)); r_acrosstask22=acrosstask22(1,2);
    acrosstask=mean([r_acrosstask11,r_acrosstask12,r_acrosstask21,r_acrosstask22]);
    
    fprintf(fid_w,'%s %f %f %f\n',subjects{i},r_withinFinite, r_withinInCon, acrosstask); 

end 