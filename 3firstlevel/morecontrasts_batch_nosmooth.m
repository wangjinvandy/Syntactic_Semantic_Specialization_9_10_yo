%% First level analysis, more contrasts, written by Jin Wang 3/15/2019
% All you need to do with this code is to comment out the lines from 97 to
% 155 from a typical firstlevel code (e.g. firstlevel_generate_bids_ELP.m). 
% Then you can specify the new contrast you want. It will call
% more_contrast.m code which will add on or repalce your previous contrasts.
% This code can save you a lot of time of model specification and
% estimation.

%%%Do you want to rewrite your contrasts or add on new contrasts?
type=1; %1 is rewrite, 0 is append on. 

addpath(genpath('/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/scripts/3firstlevel')); % the path of your scripts
spm_path='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/LabCode/typical_data_analysis/spm12_elp'; %the path of spm
addpath(genpath(spm_path));

%define your data path
data=struct();
root='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10';  %your project path
subjects=[];
data_info='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/jinwang/PlausGram_9-10/scripts/final_sample.xlsx';
if isempty(subjects)
    M=readtable(data_info);
    subjects=M.participant_id;
end

analysis_folder='analysis_nosmooth'; % the name of your first level modeling folder
model_deweight='deweight'; % the deweigthed modeling folder, it will be inside of your analysis folder
global CCN
CCN.preprocessed='preproc'; % your data folder
CCN.session='ses-9'; % the time points you want to analyze
CCN.func_pattern='sub*'; % the name of your functional folders
CCN.file='vs6_wsub*bold.nii'; % the name of your preprocessed data (4d)
CCN.rpfile='rp_*.txt'; %the movement files
events_file_exist=0; % 1 means you did copy the events.tsv into your preprocessed folder, 0 means you cleaned the events.tsv in your preprocessed folder
bids_folder='/gpfs51/dors2/gpc/JamesBooth/JBooth-Lab/BDL/ELP/bids'; % if you assign 0 to events_file_exist, then you mask fill in this path, so it can read events.tsv file for individual onsets from bids folder

%%define your task conditions, each run is a cell, be sure it follows the
%%sequence of the output from count_repaired_acc_rt.m. The task follows
%%alphabetic order based on its file name Gram is before Plaus task. 
conditions=[]; %start with an empty conditions.
conditions{1}={'G_C' 'G_F' 'G_G' 'G_P'};
conditions{2}={'G_C' 'G_F' 'G_G' 'G_P'};
conditions{3}={'SP_C' 'SP_I' 'SP_S' 'SP_W'};
conditions{4}={'SP_C' 'SP_I' 'SP_S' 'SP_W'};


%duration
dur=0; %I think all projects in BDL are event-related, so I hard coded the duration as 0.

%TR
TR=1.25; %ELP project

%define your contrasts, make sure your contrasts and your weights should be
%matched.
contrasts={
    'Gram_vs_PC_run1' ...
    'Gram_vs_PC_run2' ...
    'Gram_vs_PC' ...
    'SCon_vs_PC_run1' ...
    'SCon_vs_PC_run2' ...
    'SCon_vs_PC' ...
    'Gram_vs_PC_VS_SCon_vs_PC' ...
    'Finite_vs_PC_run1' ...
    'Finite_vs_PC_run2' ...
    'Finite_vs_PC' ...
    'InCon_vs_PC_run1' ...
    'InCon_vs_PC_run2' ...
    'InCon_vs_PC'...
    'Finite_vs_PC_VS_InCon_vs_PC' ...
    'Syn_spec_correct_vs_incorrect'...
    'Sem_spec_correct_vs_incorrect'...
    'allsentence_vs_PC'};
Gram_FVio = [0 -1 1 0];
SCon_InCon = [0 -1 1 0];
Gram_vs_PC=[-1 0 1 0];
SCon_vs_PC=[-1 0 1 0];
Finite_vs_PC=[-1 1 0 0];
InCon_vs_PC=[-1 1 0 0];
allsentence_vs_PC=[-3 1 1 1];
%adjust the contrast by adding six 0s into the end of each session
rp_w=zeros(1,6);
empty=zeros(1,10);
weights={    [Gram_vs_PC rp_w empty empty empty] ...
    [empty Gram_vs_PC rp_w empty empty] ...
    [Gram_vs_PC rp_w Gram_vs_PC rp_w empty empty] ...
    [empty empty SCon_vs_PC rp_w empty] ...
    [empty empty empty SCon_vs_PC rp_w] ...
    [empty empty SCon_vs_PC rp_w SCon_vs_PC rp_w] ...
    [Gram_vs_PC rp_w Gram_vs_PC rp_w -1*SCon_vs_PC rp_w -1*SCon_vs_PC rp_w] ...
    [Finite_vs_PC rp_w empty empty empty] ...
    [empty Finite_vs_PC rp_w empty empty] ...
    [Finite_vs_PC rp_w Finite_vs_PC rp_w empty empty] ...
    [empty empty InCon_vs_PC rp_w empty] ...
    [empty empty empty InCon_vs_PC rp_w] ...
    [empty empty InCon_vs_PC rp_w InCon_vs_PC rp_w]...
    [Finite_vs_PC rp_w Finite_vs_PC rp_w -1*InCon_vs_PC rp_w -1*InCon_vs_PC rp_w]...
    [Gram_FVio rp_w Gram_FVio rp_w -1*SCon_InCon rp_w -1*SCon_InCon rp_w]...
    [-1*Gram_FVio rp_w -1*Gram_FVio rp_w SCon_InCon rp_w SCon_InCon rp_w] ...
    [allsentence_vs_PC rp_w allsentence_vs_PC rp_w allsentence_vs_PC rp_w allsentence_vs_PC rp_w]};

%%%%%%%%%%%%%%%%%%%%%%%%Do not edit below here%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%check if you define your contrasts in a correct way
if length(weights)~=length(contrasts)
    error('the contrasts and the weights are not matched');
end      

% Initialize
%addpath(spm_path);
spm('defaults','fmri');
spm_jobman('initcfg');
spm_figure('Create','Graphics','Graphics');

% Dependency and sanity checks
if verLessThan('matlab','R2013a')
    error('Matlab version is %s but R2013a or higher is required',version)
end

req_spm_ver = 'SPM12 (6225)';
spm_ver = spm('version');
if ~strcmp( spm_ver,req_spm_ver )
    error('SPM version is %s but %s is required',spm_ver,req_spm_ver)
end

%Start to analyze the data from here
try
    for i=1:length(subjects)
        fprintf('work on subject %s', subjects{i});
        CCN.subject=[root '/' CCN.preprocessed '/' subjects{i}];
        
        %specify the outpath,create one if it does not exist
        out_path=[CCN.subject '/' analysis_folder];
        if ~exist(out_path)
            mkdir(out_path)
        end
        %specify the deweighting spm folder, create one if it does not exist
        model_deweight_path=[out_path '/' model_deweight];
        if exist(model_deweight_path,'dir')~=7
            mkdir(model_deweight_path)
        end
        

        mat=[model_deweight_path,'/SPM.mat'];
        origmat=[out_path '/SPM.mat'];
        %run the contrasts
        more_contrast(origmat,contrasts,weights, type);
        more_contrast(mat,contrasts,weights,type);
        
    end
    
catch e
    rethrow(e)
    %display the errors
end