function correlational_analysis2_rmoutlier
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

writefile=[Tvaluefolder '_correlation1_rmoutlier.txt'];
cd(root);
if exist(writefile)
   delete(writefile);
end
fid_w=fopen(writefile,'wt');
fprintf(fid_w,'%s %s %s %s\n', 'participant_id', 'withinGram', 'withinSCon', 'acrosstask');

for i=1:length(subjects)
    this_sub=subjects{i}(end-3:end);
    txt_run1Gram=[root '/' Tvaluefolder '/Gram_vs_PC_run1/' this_sub '/' ROI '_Gram_vs_PC_run1_output.txt'];
    fid=fopen(txt_run1Gram);
    data1=textscan(fid,'%d %d %d %f');
    gramrun1=data1{4};
    nonoutlier_loc1_gram=(gramrun1 < (mean(gramrun1)+3*std(gramrun1)) & gramrun1 > (mean(gramrun1)- 3*std(gramrun1)));
    txt_run2Gram=[root '/' Tvaluefolder '/Gram_vs_PC_run2/' this_sub '/' ROI '_Gram_vs_PC_run2_output.txt'];
    fid2=fopen(txt_run2Gram);
    data2=textscan(fid2,'%d %d %d %f');
    gramrun2=data2{4};
    nonoutlier_loc2_gram=(gramrun2 < (mean(gramrun2)+3*std(gramrun2)) & gramrun2 > (mean(gramrun2)- 3*std(gramrun2)));
    nonoutlier_loc_gram= (nonoutlier_loc1_gram & nonoutlier_loc2_gram);
    withinGram=corrcoef(gramrun1(nonoutlier_loc_gram), gramrun2(nonoutlier_loc_gram));
    r_withinGram=withinGram(1,2);
    
    txt_run1SCon=[root '/' Tvaluefolder '/SCon_vs_PC_run1/' this_sub '/' ROI '_SCon_vs_PC_run1_output.txt'];
    fid3=fopen(txt_run1SCon);
    data3=textscan(fid3,'%d %d %d %f');
    sconrun1=data3{4};
    nonoutlier_loc1_scon=(sconrun1 < (mean(sconrun1)+3*std(sconrun1)) & sconrun1 > (mean(sconrun1)- 3*std(sconrun1)));
    txt_run2SCon=[root '/' Tvaluefolder '/SCon_vs_PC_run2/' this_sub '/' ROI '_SCon_vs_PC_run2_output.txt'];
    fid4=fopen(txt_run2SCon);
    data4=textscan(fid4,'%d %d %d %f');
    sconrun2=data4{4};
    nonoutlier_loc2_scon=(sconrun2 < (mean(sconrun2)+3*std(sconrun2)) & sconrun2 > (mean(sconrun2)- 3*std(sconrun2)));
    nonoutlier_loc_scon= (nonoutlier_loc1_scon & nonoutlier_loc2_scon);
    withinSCon=corrcoef(sconrun1(nonoutlier_loc_scon), sconrun2(nonoutlier_loc_scon));
    r_withinSCon=withinSCon(1,2);
    
    acrosstask11=corrcoef(gramrun1(nonoutlier_loc1_gram & nonoutlier_loc1_scon), sconrun1(nonoutlier_loc1_gram & nonoutlier_loc1_scon)); r_acrosstask11=acrosstask11(1,2);
    acrosstask12=corrcoef(gramrun1(nonoutlier_loc1_gram & nonoutlier_loc2_scon), sconrun2(nonoutlier_loc1_gram & nonoutlier_loc2_scon)); r_acrosstask12=acrosstask12(1,2);
    acrosstask21=corrcoef(gramrun2(nonoutlier_loc2_gram & nonoutlier_loc1_scon), sconrun1(nonoutlier_loc2_gram & nonoutlier_loc1_scon)); r_acrosstask21=acrosstask21(1,2);
    acrosstask22=corrcoef(gramrun2(nonoutlier_loc2_gram & nonoutlier_loc2_scon), sconrun2(nonoutlier_loc2_gram & nonoutlier_loc2_scon)); r_acrosstask22=acrosstask22(1,2);
    acrosstask=mean([r_acrosstask11,r_acrosstask12,r_acrosstask21,r_acrosstask22]);
    
    fprintf(fid_w,'%s %f %f %f\n',subjects{i},r_withinGram, r_withinSCon, acrosstask); 

end 