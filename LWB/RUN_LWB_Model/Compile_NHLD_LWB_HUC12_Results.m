%Compile_NHLD_LWB_HUC12_Results.m
%Previous internal version: Compile_HUC12_Results_Rev2.m

close all
clear
clc

load('../GFLOW_NHLD_HUC12_Final/HUC12_IDs/WBDHU12_AlbCon_NHLD_NoBufferLakes_Adjusted_Turtle_Eagle.mat');

sum_PNF = 0;
sum_PNF_NF = 0;
perm_PNF = [];
perm_PNF_NF = [];
Uni_HUC12_ID_NHLD = Uni_HUC12_ID;
Run_length = length(Uni_HUC12_ID_NHLD);

%% Loop in order to determine pre-allocation sizes
Catch_HUC = {};
for HUC12_loop_ID = 1:Run_length
    HUC12_loop_ID
    
    if HUC12_loop_ID > 1
        clearvars -except HUC12_loop_ID Uni_HUC12_ID_NHLD sum_PNF sum_PNF_NF Run_length Catch_HUC perm_PNF perm_PNF_NF
    end
    
    Cur_HUC12 = Uni_HUC12_ID_NHLD{HUC12_loop_ID};
    
    try
    filename = ['NHLD_LWB_Model_' Cur_HUC12 '.mat'];
    cd ./mat_OUTPUT/
    load(filename)
    cd ..
    
    catch
       Catch_HUC = {Catch_HUC Cur_HUC12};
    end
    
    
    %filter PNF from total (PNF_NF) data for Current HUC12, calc sum of
    %all PNF
    vi = strcmp(GIS_PNF_HUC12,Cur_HUC12); %Determine if GIS_PERMANENT_ is a PNF lake
    [ind_PNF,~] = find(vi == 1); %grabs index of PNF Lakes
    tmp_sum = length(ind_PNF);
    sum_PNF = sum_PNF + tmp_sum;
    perm_PNF = [perm_PNF; GIS_PERMANENT_(ind_PNF)];
    
    L_PNF_NF = length(GIS_PERMANENT_);
    sum_PNF_NF = sum_PNF_NF + L_PNF_NF;
    perm_PNF_NF = [perm_PNF_NF; GIS_PERMANENT_];
    
end

%% Loop in order to grab and move data
for HUC12_loop_ID = 1:Run_length
    HUC12_loop_ID
    tic
    %% HUC12_loop_ID == 1
    if HUC12_loop_ID == 1
        OUT_GIS_PERMANENT_ = cell(sum_PNF,1);
        OUT_A0 = zeros(sum_PNF,1);%m2
        OUT_V0 = zeros(sum_PNF,1); %m3
        OUT_r0 = zeros(sum_PNF,1); %m
        OUT_D0 = zeros(sum_PNF,1); %m
        OUT_Perim0 = zeros(sum_PNF,1); %m
        OUT_stage0 = zeros(sum_PNF,1); %m
        OUT_DL = zeros(sum_PNF,1); %[]
        OUT_r2h = zeros(sum_PNF,1); %[]
        OUT_WA = zeros(sum_PNF,1); %m2
        OUT_Stream_WA_m2 = zeros(sum_PNF,1); %m2
        OUT_GIS_WALA_1 = zeros(sum_PNF,1); %[]
        OUT_z0_DEM = zeros(sum_PNF,1); %m
        OUT_V_LinRes = zeros(sum_PNF,1); %m3
        OUT_stage_LinRes = zeros(sum_PNF,1); %m
        
        OUT_A_APP = zeros(sum_PNF,length(Date_APP));
        OUT_r_APP = zeros(sum_PNF,length(Date_APP));
        OUT_Perim_APP = zeros(sum_PNF,length(Date_APP));
        OUT_stage_APP = zeros(sum_PNF,length(Date_APP));
        OUT_z_APP = zeros(sum_PNF,length(Date_APP));
        OUT_V_APP = zeros(sum_PNF,length(Date_APP));
        
        OUT_SW_in_APP = zeros(sum_PNF,length(Date_APP));
        OUT_Base_in_APP = zeros(sum_PNF,length(Date_APP));
        OUT_DirectP_APP = zeros(sum_PNF,length(Date_APP));
        OUT_LakeE_APP = zeros(sum_PNF,length(Date_APP));
        OUT_GWin_APP = zeros(sum_PNF,length(Date_APP));
        OUT_GWout_APP = zeros(sum_PNF,length(Date_APP));
        OUT_SW_out_APP = zeros(sum_PNF,length(Date_APP));
        OUT_IceSnow_APP = zeros(sum_PNF,length(Date_APP));
        OUT_LandMelt_APP = zeros(sum_PNF,length(Date_APP));
        OUT_IceMelt_APP = zeros(sum_PNF,length(Date_APP));
        
        Cur_HUC12 = Uni_HUC12_ID_NHLD{HUC12_loop_ID};
        
        filename = ['NHLD_LWB_Model_' Cur_HUC12 '.mat'];
        cd ./mat_OUTPUT/
        load(filename)
        cd ..
        
        vi = strcmp(GIS_PNF_HUC12,Cur_HUC12); %Determine if GIS_PERMANENT_ is a PNF lake
        [ind_PNF,~] = find(vi == 1); %grabs index of PNF Lakes
        L_PNF = length(ind_PNF);
        L_PNF_NF = length(GIS_PERMANENT_);
        
        uni_fail_all_APP_PNF = {};
        uni_fail_all_APP_PNF_NF = {};
        
        
        for i = 1:length(ind_PNF)
            
            % % %Lake Initial Property Variables to Include:
            %NoDate
            OUT_GIS_PERMANENT_(i) = GIS_PERMANENT_(ind_PNF(i));
            OUT_A0(i) = A0(ind_PNF(i)); %m2
            OUT_V0(i) = V0(ind_PNF(i)); %m3
            OUT_r0(i) = r0(ind_PNF(i)); %m
            OUT_D0(i) = D0(ind_PNF(i)); %m
            OUT_Perim0(i) = Perim0(ind_PNF(i)); %m
            OUT_stage0(i) = stage0(ind_PNF(i)); %m
            OUT_DL(i) = DL(ind_PNF(i)); %[]
            OUT_r2h(i) = r2h(ind_PNF(i)); %[]
            OUT_WA(i) = WA(ind_PNF(i)); %m2
            OUT_Stream_WA_m2(i) = Stream_WA_m2(ind_PNF(i)); %m2
            OUT_GIS_WALA_1(i) = GIS_WALA_1(ind_PNF(i)); %[]
            OUT_z0_DEM(i) = z0_DEM(ind_PNF(i)); %m
            OUT_V_LinRes(i) = V_LinRes(ind_PNF(i)); %m3
            OUT_stage_LinRes(i) = stage_LinRes(ind_PNF(i)); %m
            
            OUT_A_APP(i,:) = A_APP(ind_PNF(i),:);
            OUT_r_APP(i,:) = r_APP(ind_PNF(i),:);
            OUT_Perim_APP(i,:) = Perim_APP(ind_PNF(i),:);
            OUT_stage_APP(i,:) = stage_APP(ind_PNF(i),:);
            OUT_z_APP(i,:) = z_APP(ind_PNF(i),:);
            OUT_V_APP(i,:) = V_APP(ind_PNF(i),:);
            
            OUT_SW_in_APP(i,:) = SW_in_APP(ind_PNF(i),:);
            OUT_Base_in_APP(i,:) = Base_in_APP(ind_PNF(i),:);
            OUT_DirectP_APP(i,:) = DirectP_APP(ind_PNF(i),:);
            OUT_LakeE_APP(i,:) = LakeE_APP(ind_PNF(i),:);
            OUT_GWin_APP(i,:) = GWin_APP(ind_PNF(i),:);
            OUT_GWout_APP(i,:) = GWout_APP(ind_PNF(i),:);
            OUT_SW_out_APP(i,:) = SW_out_APP(ind_PNF(i),:);
            OUT_IceSnow_APP(i,:) = IceSnow_APP(ind_PNF(i),:);
            OUT_LandMelt_APP(i,:) = LandMelt_APP(ind_PNF(i),:);
            OUT_IceMelt_APP(i,:) = IceMelt_APP(ind_PNF(i),:);
            
            
        end
        
        GIS_PERMANENT_PNF_filter = GIS_PERMANENT_(ind_PNF);
        clear ind_PNF 
        vi_sum = zeros(length(uni_fail_all),1);
        for i = 1:length(uni_fail_all)
            clear vi
            vi = strcmp(GIS_PERMANENT_PNF_filter,uni_fail_all(i)); %Determine if uni_fail_all is a PNF lake
            vi_sum(i) = sum(vi);
        end
        [ind_PNF,~] = find(vi_sum == 1); %grabs index of PNF Lakes
        uni_fail_all_APP_PNF = [uni_fail_all_APP_PNF uni_fail_all(ind_PNF)];
        uni_fail_all_APP_PNF_NF = [uni_fail_all_APP_PNF_NF uni_fail_all];
        toc
        %% HUC12_loop_ID > 1
    else
        clearvars -except HUC12_loop_ID Uni_HUC12_ID_NHLD...
            OUT_GIS_PERMANENT_ OUT_A0 OUT_V0 OUT_r0 ...
            OUT_D0 OUT_Perim0 OUT_stage0 OUT_DL OUT_r2h ...
            OUT_WA OUT_Stream_WA_m2 OUT_GIS_WALA_1 OUT_z0_DEM OUT_V_LinRes ...
            OUT_stage_LinRes...
            OUT_A_APP OUT_r_APP OUT_Perim_APP OUT_stage_APP ...
            OUT_z_APP OUT_V_APP ...
            OUT_SW_in_APP OUT_Base_in_APP OUT_DirectP_APP OUT_LakeE_APP ...
            OUT_GWin_APP OUT_GWout_APP OUT_SW_out_APP...
            OUT_IceSnow_APP OUT_IceMelt_APP OUT_LandMelt_APP...
            sum_PNF Run_length uni_fail_all_APP_PNF uni_fail_all_APP_PNF_NF
        
        END_idx = find(OUT_z0_DEM ~= 0);
        
        Cur_HUC12 = Uni_HUC12_ID_NHLD{HUC12_loop_ID};
        
        filename = ['NHLD_LWB_Model_' Cur_HUC12 '.mat'];
        cd ./mat_OUTPUT/
        load(filename)
        cd ..
        
        vi = strcmp(GIS_PNF_HUC12,Cur_HUC12); %Determine if GIS_PERMANENT_ is a PNF lake
        [ind_PNF,~] = find(vi == 1); %grabs index of PNF Lakes
        length(ind_PNF)
        length(GIS_PERMANENT_)

        for i = 1:length(ind_PNF)
             
            % % %Lake Initial Property Variables to Include:
            %NoDate
            OUT_GIS_PERMANENT_(END_idx(end)+i) = GIS_PERMANENT_(ind_PNF(i));
            OUT_A0(END_idx(end)+i) = A0(ind_PNF(i)); %m2
            OUT_V0(END_idx(end)+i) = V0(ind_PNF(i)); %m3
            OUT_r0(END_idx(end)+i) = r0(ind_PNF(i)); %m
            OUT_D0(END_idx(end)+i) = D0(ind_PNF(i)); %m
            OUT_Perim0(END_idx(end)+i) = Perim0(ind_PNF(i)); %m
            OUT_stage0(END_idx(end)+i) = stage0(ind_PNF(i)); %m
            OUT_DL(END_idx(end)+i) = DL(ind_PNF(i)); %[]
            OUT_r2h(END_idx(end)+i) = r2h(ind_PNF(i)); %[]
            OUT_WA(END_idx(end)+i) = WA(ind_PNF(i)); %m2
            OUT_Stream_WA_m2(END_idx(end)+i) = Stream_WA_m2(ind_PNF(i)); %m2
            OUT_GIS_WALA_1(END_idx(end)+i) = GIS_WALA_1(ind_PNF(i)); %[]
            OUT_z0_DEM(END_idx(end)+i) = z0_DEM(ind_PNF(i)); %m
            OUT_V_LinRes(END_idx(end)+i) = V_LinRes(ind_PNF(i)); %m3
            OUT_stage_LinRes(END_idx(end)+i) = stage_LinRes(ind_PNF(i)); %m
            
            OUT_A_APP(END_idx(end)+i,:) = A_APP(ind_PNF(i),:);
            OUT_r_APP(END_idx(end)+i,:) = r_APP(ind_PNF(i),:);
            OUT_Perim_APP(END_idx(end)+i,:) = Perim_APP(ind_PNF(i),:);
            OUT_stage_APP(END_idx(end)+i,:) = stage_APP(ind_PNF(i),:);
            OUT_z_APP(END_idx(end)+i,:) = z_APP(ind_PNF(i),:);
            OUT_V_APP(END_idx(end)+i,:) = V_APP(ind_PNF(i),:);
            
            OUT_SW_in_APP(END_idx(end)+i,:) = SW_in_APP(ind_PNF(i),:);
            OUT_Base_in_APP(END_idx(end)+i,:) = Base_in_APP(ind_PNF(i),:);
            OUT_DirectP_APP(END_idx(end)+i,:) = DirectP_APP(ind_PNF(i),:);
            OUT_LakeE_APP(END_idx(end)+i,:) = LakeE_APP(ind_PNF(i),:);
            OUT_GWin_APP(END_idx(end)+i,:) = GWin_APP(ind_PNF(i),:);
            OUT_GWout_APP(END_idx(end)+i,:) = GWout_APP(ind_PNF(i),:);
            OUT_SW_out_APP(END_idx(end)+i,:) = SW_out_APP(ind_PNF(i),:);
            OUT_IceSnow_APP(END_idx(end)+i,:) = IceSnow_APP(ind_PNF(i),:);
            OUT_LandMelt_APP(END_idx(end)+i,:) = LandMelt_APP(ind_PNF(i),:);
            OUT_IceMelt_APP(END_idx(end)+i,:) = IceMelt_APP(ind_PNF(i),:);
            
            
        end
        

        GIS_PERMANENT_PNF_filter = GIS_PERMANENT_(ind_PNF);
        clear ind_PNF 
        vi_sum = zeros(length(uni_fail_all),1);
        for i = 1:length(uni_fail_all)
            clear vi
            vi = strcmp(GIS_PERMANENT_PNF_filter,uni_fail_all(i)); %Determine if uni_fail_all is a PNF lake
            vi_sum(i) = sum(vi);
        end
        [ind_PNF,~] = find(vi_sum == 1); %grabs index of PNF Lakes
        uni_fail_all_APP_PNF = [uni_fail_all_APP_PNF uni_fail_all(ind_PNF)];
        uni_fail_all_APP_PNF_NF = [uni_fail_all_APP_PNF_NF uni_fail_all];
        
        toc
    end
end
length(uni_fail_all_APP_PNF)
length(uni_fail_all_APP_PNF_NF)
uni_PNF = unique(uni_fail_all_APP_PNF);
uni_PNF_NF = unique(uni_fail_all_APP_PNF_NF);
uni_fail_DIFF = setdiff(uni_PNF_NF,uni_PNF);

cd ./mat_OUTPUT/
save('OUT_data_NHLD_LWB_Model_Test.mat')
cd ..








