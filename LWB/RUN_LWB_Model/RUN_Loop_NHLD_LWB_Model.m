%RUN_Loop_NHLD_LWB_Model.m
%Previous internal version: RUN_LakeModel_Loop_Rev23_8015.m

%%
close all
clear
clc
load('../GFLOW_NHLD_HUC12_Final/HUC12_IDs/WBDHU12_AlbCon_NHLD_NoBufferLakes_Adjusted_Turtle_Eagle.mat');

HUC_fail = [];
ID_fail = [];
for HUC12_loop_ID = 1:length(Uni_HUC12_ID)
    HUC12_loop_ID
    
    if HUC12_loop_ID > 1
        clearvars -except HUC12_loop_ID Uni_HUC12_ID HUC_fail ID_fail 
    end
        
    Cur_HUC12 = Uni_HUC12_ID{HUC12_loop_ID};
    
    try
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %RUN LAKE_MODEL
    run('NHLD_LWB_Model.m')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    filename = ['NHLD_LWB_Model_' Cur_HUC12 '.mat'];
    cd mat_OUTPUT
    save(filename)
    cd ..
    
    catch
     
        HUC_fail = [HUC_fail Cur_HUC12];
        ID_fail = [ID_fail HUC12_loop_ID];
        
    end
    
end
