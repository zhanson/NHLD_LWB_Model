%For reference only. Script relating to placement of wells into Trout Lake Watershed GFLOW and
%the modified Trout Lake Watershed Results described in Hanson et al
%Discussion (SW in/out set to 0 for BM,CR,SP; reference elevation adjusted
%for TB; Volume adjustments for all NTL-LTER lakes and bogs)
%Allequash upper basin, using volume calculated weith mean depth (Hanson et
%al (2014)

%% 0)   MasterFile INPUT values:

%begin runtime clock

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%1) Variables (VIC output to GFLOW recharge input for all time intervals):

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
close all
clear
clc
Cur_HUC12 = '070500020105';
save_out = 0; %1 = save workspace; 0 = do not 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

Inpath_GFLOW = ['../GFLOW_NHLD_HUC12_Final/GFLOW_RUN_Files/HUC12_' Cur_HUC12 '/']; %HUC12-based
Inpath_GFLOW_txt = ['../WI_HUC12/HUC12_' Cur_HUC12 '/']; %HUC12-based
Inpath_VIC_Flux = '../VIC_Flux_Files/Rev8/'; %HUC12-based
Inpath_VIC_Lake = '../VIC_Lake_Files/'; %Constant for all HUC12s

FluxData = load(fullfile(Inpath_VIC_Flux,['NHLD_Avg_' Cur_HUC12 '_Flux_fprint.txt']));
LakeData = load(fullfile(Inpath_VIC_Lake,'LAKE_46.03125_-89.65625_Final_F_0pt01_d3m_10node.txt'));
load('NHLD_LakeClassification_withStreamSheds.mat') 
load('NHLD_GW_Disconnect_IDs.mat') %GIS PERMs of NHLD PNF_NF lakes that failed loads variable "NHLD_GW_Disconnect_IDs
load('In_IDs_SW_Fill_Rev16_Apr2005_maxSWinBase_V_r1.mat') %GIS PERMS of NHLD PNF_NF lakes that Apr 2005 max(SWin + Base)/ V0  >= 1 (meaning lake completely filled in 1 event), loads variable "In_IDs_SW_Fill"
load('WALA_adjusted_lookup.mat')

%%  VIC Output Files Format:

%Note: All contain 3 columns YY MM DD before the data
% N_OUTFILES   4
% OUTFILE        FORCE  12
%4 OUTVAR	     OUT_AIR_TEMP
%5 OUTVAR	     OUT_NET_LONG
%6 OUTVAR	     OUT_NET_SHORT
%7 OUTVAR	     OUT_LONGWAVE
%8 OUTVAR	     OUT_SHORTWAVE
%9 OUTVAR	     OUT_REL_HUMID
%10 OUTVAR	     OUT_VPD
%11 OUTVAR	     OUT_PRESSURE
%12 OUTVAR	     OUT_WIND
%13 OUTVAR	     OUT_SENSIBLE
%14 OUTVAR	     OUT_LATENT
%15 OUTVAR	     OUT_ALBEDO
%
% OUTFILE      Flux  19
%4 OUTVAR	     OUT_PREC
%5 OUTVAR 	     OUT_EVAP
%6 OUTVAR	     OUT_EVAP_BARE
%7 OUTVAR	     OUT_EVAP_CANOP
%8 OUTVAR	     OUT_RUNOFF
%9 OUTVAR	     OUT_BASEFLOW
%10,11,12 OUTVAR	     OUT_SOIL_MOIST
%13 OUTVAR	     OUT_SWE
%14 OUTVAR	     OUT_SNOW_DEPTH
%15 OUTVAR	     OUT_PET_NATVEG
%16 OUTVAR	     OUT_PET_H2OSURF
%17 OUTVAR	     OUT_PET_VEGNOCR
%18 OUTVAR	     OUT_PET_TALL
%19 OUTVAR	     OUT_PET_SHORT
%20 OUTVAR	     OUT_PET_SATSOIL
%21 OUTVAR       OUT_GRND_RECHARGE
%22 OUTVAR       OUT_GRND_EVAP
%23 OUTVAR	     OUT_AIR_TEMP
%24 OUTVAR	     OUT_SNOW_MELT
%
%
% OUTFILE      Temp  1
%4 OUTVAR	     OUT_SOIL_TNODE
%
% OUTFILE      WB  7
%4 OUTVAR	     OUT_PREC
%5 OUTVAR	     OUT_EVAP
%6 OUTVAR	     OUT_RUNOFF
%7 OUTVAR	     OUT_BASEFLOW
%8 OUTVAR	     OUT_SOIL_MOIST
%9 OUTVAR       OUT_GRND_RECHARGE
%10 OUTVAR       OUT_GRND_EVA
%
%N_OUTFILES   1
%OUTFILE     LAKE 29
%4   OUTVAR      OUT_PREC
%5   OUTVAR      OUT_SURF_TEMP
%6   OUTVAR      OUT_AIR_TEMP
%7   OUTVAR      OUT_LAKE_DEPTH
%8   OUTVAR      OUT_LAKE_ICE
%9   OUTVAR      OUT_LAKE_ICE_FRACT
%10  OUTVAR      OUT_LAKE_ICE_HEIGHT
%11  OUTVAR      OUT_LAKE_MOIST
%12  OUTVAR      OUT_LAKE_SURF_AREA
%13  OUTVAR      OUT_LAKE_SWE
%14  OUTVAR      OUT_LAKE_SWE_V
%15  OUTVAR      OUT_LAKE_VOLUME
%16  OUTVAR      OUT_LAKE_DSWE
%17  OUTVAR      OUT_LAKE_EVAP
%18  OUTVAR      OUT_LAKE_VAPFLX
%19,20,21   OUTVAR      OUT_SOIL_MOIST
%22  OUTVAR      OUT_LAKE_RCHRG_V
%23  OUTVAR      OUT_LAKE_BF_IN_V
%24  OUTVAR      OUT_LAKE_BF_OUT_V
%25  OUTVAR      OUT_LAKE_EVAP_V
%26  OUTVAR      OUT_LAKE_PREC_V
%27  OUTVAR      OUT_LAKE_RO_IN_V
%28  OUTVAR      OUT_LAKE_VAPFLX_V
%29  OUTVAR      OUT_LAKE_DSTOR_V
%30  OUTVAR      OUT_LAKE_CHAN_IN_V
%31  OUTVAR      OUT_LAKE_CHAN_OUT_V
%32  OUTVAR      OUT_BASEFLOW
%33  OUTVAR      OUT_RUNOFF
%34  OUTVAR      OUT_SWE


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%2) Variables (Setup GFLOW RUN#)
Ini_dat = [Cur_HUC12(5:end) '.dat']; %GFLOW saves this with lower-case "General", all other files "GENERAL"
Ini_xtr = [Cur_HUC12(5:end) '.xtr']; % 00020105.xtr

WYs = [1980 2015]; %Desired WYs to run (WY Oct1 - Sept 30)  %Oct 1
time_window_size = 1; %size of simualtion interval in months (1+, factors of 12)

HydK = 1; %m/day
Res = 0.1; %days (1m/[m/d])
Res_small_lakes = 10000;
AQ_Thk_local = 50; %m 50 default Used to set AQ_Base_Elev
AQ_Thk_global = 500; %m 500 default
 
StdGW = 1; %1 == ON, 0 == OFF; If ON, using standard constant annual GW. If Off, inter monthly variability
Lake_Dry_Threshold = 0; %0 default alt: 2000,3000, in testing

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%6)Run LAKE_MODEL for all lakes
tau = 90;
Rech_AF = 1/tau; %recharge* 0 == OFF
Tstr = 16; %q = delta Volume/T*
lin_AF_value = 0; %lin reservior adjust (m), 0 default


%% GIS Import Data(1):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize variables.
filename = ['HUC12_' Cur_HUC12 '_PNF_NF_lakes_Simp_100.txt'];

%GIS Import Data(2):
delimiter = ',';
startRow = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: text (%s)
%   column5: text (%s)
%	column6: text (%s)
%   column7: text (%s)
%	column8: text (%s)
%   column9: double (%f)
%	column10: double (%f)
%   column11: double (%f)
%	column12: double (%f)
%   column13: double (%f)
%	column14: double (%f)
%   column15: double (%f)
%	column16: double (%f)
%   column17: text (%s)
%	column18: double (%f)
%   column19: double (%f)
%	column20: double (%f)
%   column21: double (%f)
%	column22: double (%f)
%   column23: double (%f)
%	column24: double (%f)
%   column25: double (%f)
%	column26: double (%f)
%   column27: double (%f)
%	column28: double (%f)
%   column29: double (%f)
%	column30: double (%f)
%   column31: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%s%s%s%s%s%f%f%f%f%f%f%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open the text file.
%fileID = fopen(filename,'r');
fileID = fopen(fullfile(Inpath_GFLOW_txt,filename),'r');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close the text file.
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allocate imported array to column variable names
GIS_XCoord = dataArray{:, 1};
GIS_YCoord = dataArray{:, 2};
GIS_FID = dataArray{:, 3};
GIS_PERMANENT_ = dataArray{:, 4};
GIS_FDATE = dataArray{:, 5};
GIS_GNIS_ID = dataArray{:, 6};
GIS_GNIS_NAME = dataArray{:, 7};
GIS_REACHCODE = dataArray{:, 8};
GIS_FTYPE = dataArray{:, 9};
GIS_FCODE = dataArray{:, 10};
GIS_LONGITUDE = dataArray{:, 11};
GIS_LATITUDE = dataArray{:, 12};
GIS_BUFFERID = dataArray{:, 13};
GIS_PERIM_M_0 = dataArray{:, 14};
GIS_AREA_M2_0 = dataArray{:, 15};
GIS_WALA_0 = dataArray{:, 16};
GIS_PNF_HUC12 = dataArray{:, 17};
GIS_RASTERVALU = dataArray{:, 18};
GIS_ORIG_FID = dataArray{:, 19};
GIS_PERIM_M_1 = dataArray{:, 20}; %USE for Perimeter: After islands were removed from lake shp (perimeter reduced)
GIS_AREA_M2_1 = dataArray{:, 21}; %USE for Area: After islands were removed from lake shp (area increased)
GIS_WALA_1 = dataArray{:, 22}; %%USE for WALA: After islands were removed from lake shp (WALA reduced)
GIS_MBG_WIDTH = dataArray{:, 23}; 
GIS_MBG_LENGTH = dataArray{:, 24};
GIS_WIDTH_M_1 = dataArray{:, 25};
GIS_MAXSIMPTOL = dataArray{:, 26};
GIS_MINSIMPTOL = dataArray{:, 27};
GIS_BUFF_DIST = dataArray{:, 28};
GIS_PERIM_M_S = dataArray{:, 29}; %"S" for simplified. These were soley used for GFLOW setup
GIS_AREA_M2_S = dataArray{:, 30};
GIS_WIDTH_M_S = dataArray{:, 31};

%Calc AQ_Base_Elev:
AQ_Base_Elev = mean(GIS_RASTERVALU) - AQ_Thk_local;

%Calc GIS_WA_1
%WALA = WA/LA
%WA = WALA*LA
%GIS_WA_M2_1 = GIS_WALA_1.*GIS_AREA_M2_1;
%GIS_WA_M2_1 = GIS_WA_M2_1 - GIS_AREA_M2_1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% GIS Import PNF Data(1):
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize variables.
filename = ['HUC12_' Cur_HUC12 '_PNF_lakes_Simp_100.txt'];

%GIS Import PNF Data(2):
delimiter = ',';
startRow = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Format string for each line of text:
%   column1: double (%f)
%	column2: double (%f)
%   column3: double (%f)
%	column4: text (%s)
%   column5: text (%s)
%	column6: text (%s)
%   column7: text (%s)
%	column8: text (%s)
%   column9: double (%f)
%	column10: double (%f)
%   column11: double (%f)
%	column12: double (%f)
%   column13: double (%f)
%	column14: double (%f)
%   column15: double (%f)
%	column16: double (%f)
%   column17: text (%s)
%	column18: double (%f)
%   column19: double (%f)
%	column20: double (%f)
%   column21: double (%f)
%	column22: double (%f)
%   column23: double (%f)
%	column24: double (%f)
%   column25: double (%f)
%	column26: double (%f)
%   column27: double (%f)
%	column28: double (%f)
%   column29: double (%f)
%	column30: double (%f)
%   column31: double (%f)
% For more information, see the TEXTSCAN documentation.
formatSpec = '%f%f%f%s%s%s%s%s%f%f%f%f%f%f%f%f%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%[^\n\r]';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Open the text file.
%fileID = fopen(filename,'r');
fileID = fopen(fullfile(Inpath_GFLOW_txt,filename),'r');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Read columns of data according to format string.
% This call is based on the structure of the file used to generate this
% code. If an error occurs for a different file, try regenerating the code
% from the Import Tool.
dataArray = textscan(fileID, formatSpec, 'Delimiter', delimiter, 'HeaderLines' ,startRow-1, 'ReturnOnError', false);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Close the text file.
fclose(fileID);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Post processing for unimportable data.
% No unimportable data rules were applied during the import, so no post
% processing code is included. To generate code which works for
% unimportable data, select unimportable cells in a file and regenerate the
% script.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Allocate imported array to column variable names
% GIS_XCoord = dataArray{:, 1};
% GIS_YCoord = dataArray{:, 2};
% GIS_FID = dataArray{:, 3};
GIS_PERMANENT_PNF = dataArray{:, 4};
% GIS_FDATE = dataArray{:, 5};
% GIS_GNIS_ID = dataArray{:, 6};
% GIS_GNIS_NAME = dataArray{:, 7};
% GIS_REACHCODE = dataArray{:, 8};
% GIS_FTYPE = dataArray{:, 9};
% GIS_FCODE = dataArray{:, 10};
% GIS_LONGITUDE = dataArray{:, 11};
% GIS_LATITUDE = dataArray{:, 12};
% GIS_BUFFERID = dataArray{:, 13};
% GIS_PERIM_M_0 = dataArray{:, 14};
% GIS_AREA_M2_0 = dataArray{:, 15};
% GIS_WALA_0 = dataArray{:, 16};
% GIS_PNF_HUC12 = dataArray{:, 17};
% GIS_RASTERVALU = dataArray{:, 18};
% GIS_ORIG_FID = dataArray{:, 19};
% GIS_PERIM_M_1 = dataArray{:, 20}; %USE for Perimeter: After islands were removed from lake shp (perimeter reduced)
% GIS_AREA_M2_1 = dataArray{:, 21}; %USE for Area: After islands were removed from lake shp (area increased)
% GIS_WALA_1 = dataArray{:, 22}; %%USE for WALA: After islands were removed from lake shp (WALA reduced)
% GIS_MBG_WIDTH = dataArray{:, 23}; %"S" for simplified. These were soley used for GFLOW setup
% GIS_MBG_LENGTH = dataArray{:, 24};
% GIS_WIDTH_M_1 = dataArray{:, 25};
% GIS_MAXSIMPTOL = dataArray{:, 26};
% GIS_MINSIMPTOL = dataArray{:, 27};
% GIS_BUFF_DIST = dataArray{:, 28};
% GIS_PERIM_M_S = dataArray{:, 29};
% GIS_AREA_M2_S = dataArray{:, 30};
% GIS_WIDTH_M_S = dataArray{:, 31};

% %Calc AQ_Base_Elev:
% AQ_Base_Elev = mean(GIS_RASTERVALU) - AQ_Thk_local;
% 
% %Calc GIS_WA_1
% %WALA = WA/LA
% %WA = WALA*LA
% GIS_WA_M2_1 = GIS_WALA_1.*GIS_AREA_M2_1;
% GIS_WA_M2_1 = GIS_WA_M2_1 - GIS_AREA_M2_1;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Clear temporary variables
clearvars filename delimiter startRow formatSpec fileID dataArray ans;

%% TR Basin Specifics
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % vi_CR = strcmp(GIS_PERMANENT_,'69886510');
% % GIS_WA_M2_1(vi_CR) = 5.2*GIS_AREA_M2_1(vi_CR);
% % GIS_WA_M2_1(vi_CR) = GIS_WA_M2_1(vi_CR) - GIS_AREA_M2_1(vi_CR);


%%
%GIS_Label_to_GFLOW_LS_Lookup: Must run GFLOW once, copy/paste Linesink
%model results into a .txt file for this lookup table
fid = fopen(fullfile(Inpath_GFLOW,['GFLOW_IN_Label_Lookup_NHLD_' Cur_HUC12(5:end) '.txt'])); 
formatSpec = '%s%s%f%f%f%f%f%f%f%f%f%f%f%f%f%f%s%s';
GIS_Label_to_GFLOW_LS_Lookup = textscan(fid,formatSpec,'HeaderLines',2);
fclose(fid);
GIS_Label = GIS_Label_to_GFLOW_LS_Lookup{1};
GFLOW_Label = GIS_Label_to_GFLOW_LS_Lookup{2};
NF_or_FF = GIS_Label_to_GFLOW_LS_Lookup{18};


%% 1a)  VIC output to GFLOW recharge input for all time intervals;

FluxData_sort = sortrows(FluxData,[1 2 3]);
LakeData_sort = sortrows(LakeData,[1 2 3]);

Date_b = ['10/1/' num2str(WYs(1)-1)];
Date_e = ['9/30/' num2str(WYs(end))];
NumDaysSub = time_window_size*31 + 2;
NumDaysTot = daysdif(Date_b,Date_e,0) + 3; %+1 becasue = initialize index + The first date (StartDate) is not included when determining the number of days between first and last date. I extra just for assurance that ventor long enough


%Example:
%Want time-seiers of water years (WYs) 2009 and 2010
%WY begins Oct 1 and ends Sept 30
% WYs 2009 and 2010 would
%BEGIN: Oct 1, 2008
%END: Sept 30, 2010

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Year_threshold_min = WYs(1)-1;
Year_threshold_max = WYs(end);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ind_front,~] = find(FluxData_sort(:,1) == Year_threshold_min  & FluxData_sort(:,2) == 9 & FluxData_sort(:,3) == 30); %find Sept 30 before desired WY period
[ind_back,~] = find(FluxData_sort(:,1) == Year_threshold_max  & FluxData_sort(:,2) == 10 & FluxData_sort(:,3) == 1);%find Oct 1 after desired WY period
ind_begin = ind_front(end)+1;
ind_end = ind_back(1)-1;

FluxData_bounds = FluxData_sort(ind_begin:ind_end,:);
LakeData_bounds = LakeData_sort(ind_begin:ind_end,:);
Date_bounds = datetime(FluxData_bounds(:,1),FluxData_bounds(:,2),FluxData_bounds(:,3));

t_min = min(Date_bounds);
t_max = max(Date_bounds);
t_interval = t_min:calmonths(time_window_size):t_max+calmonths(1);


for i = 1:length(t_interval)-1;
    
    if i == length(t_interval)-1 %if at the end
        vi = (t_interval(i) <= Date_bounds) & (Date_bounds <= t_max);
        
    else
        vi = (t_interval(i) <= Date_bounds) & (Date_bounds < t_interval(i+1));
        
    end
    
    t_interval_char = matlab.lang.makeValidName(char(t_interval(i)));
    VICout_results.(t_interval_char).Date = Date_bounds(vi);
    VICout_results.(t_interval_char).GRND_Recharge = FluxData_bounds(vi,21)/1000;
    VICout_results.(t_interval_char).GRND_Evap = FluxData_bounds(vi,22)/1000;
    VICout_results.(t_interval_char).NET_RECHARGE = VICout_results.(t_interval_char).GRND_Recharge - VICout_results.(t_interval_char).GRND_Evap;
    VICout_results.(t_interval_char).Mean = mean(VICout_results.(t_interval_char).NET_RECHARGE); %m/d (takes mean of all domain daily values)
    VICout_results.(t_interval_char).Median = median(VICout_results.(t_interval_char).NET_RECHARGE);
    
    GFLOW_NetRechargeIN(i) = mean(VICout_results.(t_interval_char).NET_RECHARGE)*Rech_AF; %m/d
    GFLOW_DateIN_begin(i) = VICout_results.(t_interval_char).Date(1);
    GFLOW_DateIN_end(i) = VICout_results.(t_interval_char).Date(end);
   
end

%% Read Initial .dat and .xtr files
%% 2a)  Get x1,y1,x2,y2, and label vectors from original Initial .dat file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get x1,y1,x2,y2, and label vectors from original .dat file:
%(Must have previously set up a GFLOW file and ran it in order to obtian
%this .dat file. Only need to do it once because we will create the rest that
%we need in this script.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Read in entire .dat file

fid = fopen(fullfile(Inpath_GFLOW,Ini_dat),'r');
datImport = textscan(fid,'%s','Delimiter','\n');
datImport = datImport{1};
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Looping through each row to get LS data

LD_Ini_dat = length(datImport);
rowWithLS_Ini_dat = zeros(LD_Ini_dat,1);

for i = 1:LD_Ini_dat
    temp_Line_LS_Ini_dat = datImport{i}; % pull out a single row from the .dat file
    
    % test for LS_
    idx_LS_Ini_dat = strfind(temp_Line_LS_Ini_dat,'LS_');
    
    % idx will be empty if 'LS_' is NOT found within the string. However, we
    % are only interested in the rows WITH 'LS_'.
    rowWithLS_Ini_dat(i) = ~isempty(idx_LS_Ini_dat);
    
end

clear temp_Line_LS_Ini_dat

% Pre-allocating
numRowsWithLS_Ini_dat = sum(rowWithLS_Ini_dat);

LS_Ini_dat_x1 = zeros(numRowsWithLS_Ini_dat,1);
LS_Ini_dat_y1 = zeros(numRowsWithLS_Ini_dat,1);
LS_Ini_dat_x2 = zeros(numRowsWithLS_Ini_dat,1);
LS_Ini_dat_y2 = zeros(numRowsWithLS_Ini_dat,1);
LS_Ini_dat_z = zeros(numRowsWithLS_Ini_dat,1);
LS_Ini_dat_Label = cell(numRowsWithLS_Ini_dat,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Looping through each row, again, to grab out necessary data

LS_Ini_dat_count = 1;
for i = 1:LD_Ini_dat
    % If this line contains 'LS_', then we can pull out x1, y1, etc.
    if rowWithLS_Ini_dat(i) == 1
        temp_Line_LS_Ini_dat = datImport{i};
        
        A_LS_Ini_dat = textscan(temp_Line_LS_Ini_dat,'%f %f %f %f %f %s','MultipleDelimsAsOne',1);
        LS_Ini_dat_x1(LS_Ini_dat_count) = A_LS_Ini_dat{1};
        LS_Ini_dat_y1(LS_Ini_dat_count) = A_LS_Ini_dat{2};
        LS_Ini_dat_x2(LS_Ini_dat_count) = A_LS_Ini_dat{3};
        LS_Ini_dat_y2(LS_Ini_dat_count) = A_LS_Ini_dat{4};
        LS_Ini_dat_z(LS_Ini_dat_count) = A_LS_Ini_dat{5};
        LS_Ini_dat_Label(LS_Ini_dat_count) = A_LS_Ini_dat{6};
        
        % account for indexing
        LS_Ini_dat_count = LS_Ini_dat_count + 1;
    end
    
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
%% 2c)  Get width vector from original Initial .dat file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get width vector from original .dat file:
%(Must have previously set up a GFLOW file and ran it in order to obtian
%this .dat file. Only need to do it once because we will create the rest that
%we need in this script.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Read in entire .dat file

fid = fopen(fullfile(Inpath_GFLOW,Ini_dat),'r');
datImport = textscan(fid,'%s','Delimiter','\n');
datImport = datImport{1};
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Looping through each row to get LS data

LD_Ini_dat_width = length(datImport);
rowWithWidth_Ini_dat = zeros(LD_Ini_dat_width,1);

for i = 1:LD_Ini_dat_width
    temp_Line_Width_Ini_dat = datImport{i}; % pull out a single row from the .dat file
    
    % test for LS_
    idx_Width_Ini_dat = strfind(temp_Line_Width_Ini_dat,'width');
    
    % idx will be empty if 'width' is NOT found within the string. However, we
    % are only interested in the rows WITH 'width'.
    rowWithWidth_Ini_dat(i) = ~isempty(idx_Width_Ini_dat);
    
end

clear temp_Line_Width_Ini_dat

% Pre-allocating for speed
numRowsWithWidth_Ini_dat = sum(rowWithWidth_Ini_dat);

Width_Ini_dat_width = zeros(numRowsWithWidth_Ini_dat,1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Looping through each row, again, to grab out necessary data

Width_Ini_dat_count = 1;
for i = 1:LD_Ini_dat_width
    if rowWithWidth_Ini_dat(i) == 1
        temp_Line_Width_Ini_dat = datImport{i};
        
        % If this line contains 'width', then we can pull out x1, y1, etc.
        A_Width_Ini_dat = textscan(temp_Line_Width_Ini_dat,'%s %f %f','MultipleDelimsAsOne',1);
        Width_Ini_dat_width(Width_Ini_dat_count) = A_Width_Ini_dat{2};
        
        % store floats
        Width_Ini_dat_count = Width_Ini_dat_count + 1;
    end
end
Width = Width_Ini_dat_width;
    
%% 2d)  Get Other data from original Initial .dat file

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get other data vector from original .dat file:
%(Must have previously set up a GFLOW file and ran it in order to obtian
%this .dat file. Only need to do it once because we will create the rest that
%we need in this script.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Read in entire .dat file\

fid = fopen(fullfile(Inpath_GFLOW,Ini_dat),'r');
datImport = textscan(fid,'%s','Delimiter','\n');
datImport = datImport{1};
fclose(fid);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Looping through each row to get OTHER data

%Preallocating
LD_Ini_dat = length(datImport);
rowWith_MO_Ini_dat = false(LD_Ini_dat,1);
rowWith_Por_Ini_dat = false(LD_Ini_dat,1);
rowWith_REF_Ini_dat = false(LD_Ini_dat,1);
rowWith_WIN_Ini_dat = false(LD_Ini_dat,1);

rowWith_IN0_Ini_dat = false(LD_Ini_dat,1);
rowWith_IN1_Ini_dat = false(LD_Ini_dat,1);
rowWith_IN2_Ini_dat = false(LD_Ini_dat,1);
rowWith_IN3_Ini_dat = false(LD_Ini_dat,1);
rowWith_IN4_Ini_dat = false(LD_Ini_dat,1);

rowWith_HzPt_Ini_dat = false(LD_Ini_dat,1);

for i = 1:LD_Ini_dat
    temp_Line_Ini_dat = datImport{i}; % pull out a single row from the .dat file
    
    idx_MO_Ini_dat = strfind(temp_Line_Ini_dat,'modelorigin');
    idx_REF_Ini_dat = strfind(temp_Line_Ini_dat,'reference');
    idx_WIN_Ini_dat = strfind(temp_Line_Ini_dat,'window');
    idx_Por_Ini_dat = strfind(temp_Line_Ini_dat,'porosity');
    
    idx_IN0_Ini_dat = strfind(temp_Line_Ini_dat,'IN_000001_0001');
    idx_IN1_Ini_dat = strfind(temp_Line_Ini_dat,'IN_000001_0101');
    idx_IN2_Ini_dat = strfind(temp_Line_Ini_dat,'IN_000001_0201');
    idx_IN3_Ini_dat = strfind(temp_Line_Ini_dat,'IN_000001_0301');
    
    idx_HzPt_Ini_dat = strfind(temp_Line_Ini_dat,'horizontalpoints');
    
    
    % idx will be empty if 'XXXX' is NOT found within the string. However, we
    % are only interested in the rows WITH 'XXXX'.
    rowWith_MO_Ini_dat(i) = ~isempty(idx_MO_Ini_dat);
    rowWith_REF_Ini_dat(i) = ~isempty(idx_REF_Ini_dat);
    rowWith_WIN_Ini_dat(i) = ~isempty(idx_WIN_Ini_dat);
    rowWith_Por_Ini_dat(i) = ~isempty(idx_Por_Ini_dat);
        
    rowWith_IN0_Ini_dat(i) = ~isempty(idx_IN0_Ini_dat);
    rowWith_IN1_Ini_dat(i) = ~isempty(idx_IN1_Ini_dat);
    rowWith_IN2_Ini_dat(i) = ~isempty(idx_IN2_Ini_dat);
    rowWith_IN3_Ini_dat(i) = ~isempty(idx_IN3_Ini_dat);
    
    rowWith_HzPt_Ini_dat(i) = ~isempty(idx_HzPt_Ini_dat);
    
    clear temp_Line_Ini_dat
    
end

[idx,~] = find(rowWith_MO_Ini_dat == 1);
MO = datImport{idx};

%Reference Elevation Point
[idx,~] = find(rowWith_REF_Ini_dat == 1);
REF = datImport{idx};
REF_adj = textscan(REF,'%s %f %f %f','MultipleDelimsAsOne',1);

[idx,~] = find(rowWith_WIN_Ini_dat == 1);
WIN = datImport{idx(1)};
[idx,~] = find(rowWith_Por_Ini_dat == 1);
Por = datImport{idx};

[idx,~] = find(rowWith_IN0_Ini_dat == 1);
IN0 = datImport{idx};
[idx,~] = find(rowWith_IN1_Ini_dat == 1);
IN1 = datImport{idx};
[idx,~] = find(rowWith_IN2_Ini_dat == 1);
IN2 = datImport{idx};
[idx,~] = find(rowWith_IN3_Ini_dat == 1);
IN3 = datImport{idx};

[idx,~] = find(rowWith_HzPt_Ini_dat == 1);
HzPt = datImport{idx};

%% 2e)  Get resistance and depth vectors from GFLOW Initial .xtr file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Get resistance and depth from GFLOW Initial .xtr file
%(Must have previously set up a GFLOW file and ran it in order to obtian
%this .xtr file. Only need to do it once because we will create the rest that
%we need in this script.)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fid = fopen(fullfile(Inpath_GFLOW,Ini_xtr),'r');
clear datImport
datImport = textscan(fid,'%s','Delimiter','\n');
datImport = datImport{1};
fclose(fid);

%%LS Data:
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Looping through each row to get LS data

LD_LS_Ini_xtr = length(datImport);
rowWithLS_Ini_xtr = zeros(LD_LS_Ini_xtr,1);

for i = 1:LD_LS_Ini_xtr
    temp_Line_LS_Ini_xtr = datImport{i}; % pull out a single row from the .dat file
    
    % test for LS_
    idx_LS_Ini_xtr = strfind(temp_Line_LS_Ini_xtr,'LS_');
    
    % idx will be empty if 'LS_' is NOT found within the string. However, we
    % are only interested in the rows WITH 'TP_'.
    %So find ind where it is not empty
    rowWithLS_Ini_xtr(i) = ~isempty(idx_LS_Ini_xtr);
    
end

% Preallocating
numRowsWithLS_Ini_xtr = sum(rowWithLS_Ini_xtr);
LS_Ini_xtr_x1 = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_y1 = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_x2 = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_y2 = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_spec_head = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_calc_head = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_discharge = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_width = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_resistance = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_depth = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_baseflow = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_overlandflow = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_PerErrBC = zeros(numRowsWithLS_Ini_xtr,1);
LS_Ini_xtr_label = cell(numRowsWithLS_Ini_xtr,1);

clear temp_Line_LS_Ini_xtr

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%Looping through each row, again, to extract out data

count_LS_Ini_xtr = 1;
for i = 1:LD_LS_Ini_xtr
    if rowWithLS_Ini_xtr(i) == 1
        temp_Line_LS_Ini_xtr = datImport{i};
        
        A_LS_Ini_xtr = textscan(temp_Line_LS_Ini_xtr,'%f %f %f %f %f %f %f %f %f %f %f %f %f %s','Delimiter',',');
        
        LS_Ini_xtr_x1(count_LS_Ini_xtr) = A_LS_Ini_xtr{1};
        LS_Ini_xtr_y1(count_LS_Ini_xtr) = A_LS_Ini_xtr{2};
        LS_Ini_xtr_x2(count_LS_Ini_xtr) = A_LS_Ini_xtr{3};
        LS_Ini_xtr_y2(count_LS_Ini_xtr) = A_LS_Ini_xtr{4};
        LS_Ini_xtr_spec_head(count_LS_Ini_xtr) = A_LS_Ini_xtr{5};
        LS_Ini_xtr_calc_head(count_LS_Ini_xtr) = A_LS_Ini_xtr{6};
        LS_Ini_xtr_discharge(count_LS_Ini_xtr) = A_LS_Ini_xtr{7};
        LS_Ini_xtr_width(count_LS_Ini_xtr) = A_LS_Ini_xtr{8};
        LS_Ini_xtr_resistance(count_LS_Ini_xtr) = A_LS_Ini_xtr{9};
        LS_Ini_xtr_depth(count_LS_Ini_xtr) = A_LS_Ini_xtr{10};
        LS_Ini_xtr_baseflow(count_LS_Ini_xtr) = A_LS_Ini_xtr{11};
        LS_Ini_xtr_overlandflow(count_LS_Ini_xtr) = A_LS_Ini_xtr{12};
        LS_Ini_xtr_PerErrBC(count_LS_Ini_xtr) = A_LS_Ini_xtr{13};
        LS_Ini_xtr_label(count_LS_Ini_xtr) = A_LS_Ini_xtr{14};
        
        % account for indexing
        count_LS_Ini_xtr = count_LS_Ini_xtr + 1;
    end
end

Resistance = LS_Ini_xtr_resistance;
for i = 1:length(LS_Ini_xtr_resistance)
    if LS_Ini_xtr_resistance(i) > 0 %Is a NF Lake (FF lakes = 0)
        Resistance(i) = Res;
    end
end

Depth = LS_Ini_xtr_depth;
Label = LS_Ini_xtr_label;


%% MAIN LOOP (time period loop)
eltime = [];
Lake_fail_dry = [];

for k = 1:length(GFLOW_NetRechargeIN); %Number of GFLOW simulations
    tic
    
    %% 2b)  Modification to Head elevations
    
    %If k ==1 then use the DEM values to initialize from
    %Else, update with the final elevation calculated from the previous lake
    %model run.
    
    if k == 1
        z_new = LS_Ini_dat_z; %If turned on, then Static Lake Levels (DEM values)
        disp('Initialized @ DEM lake elevation levels')
        
    else
        mean_FF_z_adj(k) = mean2(FF_z_adj); %take the mean of all change in NF lakes elevations over past timeperiod compared to initial DEM value
        %z_new = LS_Ini_dat_z + mean2(FF_z_adj); %apply mean of all change in NF lakes elevations over past timeperiod to all lake elevations 
        z_new = LS_Ini_dat_z; %Set elevations to initial DEM values
        for i = 1:length(IDchk_gflow) %NF Lakes will now be updated with actual elevation values Lake Model soved for:
            clear vi_ID
            vi_ID = strcmp(IDchk_gflow(i),GIS_Label);
            z_new(vi_ID) = z_end(i);
        end
        disp('NF Lake elevation levels updated')
    end
    
    %% Modification to Drying Lake Resistance Vector
    
    if k ==  1 %From NHLD PNF_NF fail lookup table set appropriate lakes to disconnect from AQ
        vi_NHLD_PNF_NF_fail_ind_all = [];
        for i = 1:length(NHLD_GW_Disconnect_IDs)
            clear vi_NHLD_PNF_NF_GW
            vi_NHLD_PNF_NF_GW = strcmp(NHLD_GW_Disconnect_IDs(i),GIS_Label);
            if sum(Resistance(vi_NHLD_PNF_NF_GW)) > 0 %if lake is PNF_NF in CurHuc12 then sum > 0; else it is a FF lake and sum == 0;
                Resistance(vi_NHLD_PNF_NF_GW) = Res_small_lakes; %overwrite resistance for historically failed lakes
                vi_NHLD_PNF_NF_fail_ind = find(vi_NHLD_PNF_NF_GW == 1); %find index in order to build all index to all historically known fail lakes so we can change resistance easily for k > 1
                vi_NHLD_PNF_NF_fail_ind_all = [vi_NHLD_PNF_NF_fail_ind_all; vi_NHLD_PNF_NF_fail_ind];
            end
        end
    else %past first timestep so find if any additional lakes are failing
        if isempty(Lake_fail_dry) ~= 1 
            uniq_Lake_fail_dry = unique(Lake_fail_dry);
            for i = 1:length(uniq_Lake_fail_dry)
                vi_uniq_Lake_fail_dry = [];
                vi_uniq_Lake_fail_dry = strcmp(uniq_Lake_fail_dry(i),GIS_Label);
                Resistance(vi_uniq_Lake_fail_dry) = Res_small_lakes; %overwrite resistance for newly failed lakes 
            end
                
        end
        
        Resistance(vi_NHLD_PNF_NF_fail_ind_all) = Res_small_lakes; %overwrite resistance for historically failed lakes
    end

    %% 2f)  Write NEW GFLOW RUN# .dat file
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %e) Write NEW GFLOW RUN# .dat file
    % This is all automated, except to manually copy in TP information for
    % initial .dat file (str_14)
    %Note: Watch out for spaces so that .dat file is written properly
    %E.g. "title savename" rather than "titlesavename"
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    % Open file for writing
    file_out = [Ini_dat(1:end-4) '_LM'];
    fid = fopen([file_out '.dat'],'wt');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print Header
    
    fprintf(fid,'%s\n','* Written by GFLOW for Windows 2.2.1');
    fprintf(fid,'%s\n',' error error.log');
    fprintf(fid,'%s\n',' yes');
    fprintf(fid,'%s\n',' message message.log');
    fprintf(fid,'%s\n',' yes');
    fprintf(fid,'%s\n',' echo echo.log');
    fprintf(fid,'%s\n',' yes');
    fprintf(fid,'%s\n',' picture off');
    fprintf(fid,'%s\n',' quit');
    fprintf(fid,'%s\n','');
    fprintf(fid,'%s',' bfname  ');
    
    
    % Print unique filename
    str_filename = file_out;
    fprintf(fid,'%s\n ',str_filename);
    fprintf(fid,'%s\n',MO);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s ',' title');
    
    % Print unique title
    str_title = file_out;
    fprintf(fid,'%s\n',str_title);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s\n',' aquifer');
    fprintf(fid,'%s ',' base');
    
    % Print Base Elev
    str_base = num2str(AQ_Base_Elev,'%.5E');
    fprintf(fid,'%s\n',str_base);
    fprintf(fid,'%s ',' permeability');
    
    % Print Permeability
    str_perm = num2str(HydK,'%.7E');
    fprintf(fid,'%s\n',str_perm);
    fprintf(fid,'%s ',' thickness');
    
    % Print AQ Thk
    str_thk = num2str(AQ_Thk_global,'%.7E');
    fprintf(fid,'%s\n ',str_thk);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s\n ',Por);
    
    %Print Reference Point (z = average lake head in domain)
    fprintf(fid,'%s    ',char(REF_adj{1}));
    ref_x = num2str(cell2mat(REF_adj(2)),'%.7E');
    fprintf(fid,'%s ',ref_x);
    ref_y = num2str(cell2mat(REF_adj(3)),'%.7E');
    fprintf(fid,'%s ',ref_y);
    ref_z_val = mean(z_new);
    ref_z_val_k(k) = ref_z_val;
    ref_z = num2str(ref_z_val,'%.7E');
    fprintf(fid,'%s\n ',ref_z);
    fprintf(fid,'%s\n ','quit');
    fprintf(fid,'%s\n ','layout');
    fprintf(fid,'%s\n ',WIN);
    fprintf(fid,'%s\n ','quit ');
    fprintf(fid,'%s\n ','inhomogeneity ');
    fprintf(fid,'%s ','transmissivity -9.99900E+03 -9.99900E+03 -9.99900E+03');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print Permeability
    
    Recharge = GFLOW_NetRechargeIN(k)*-1; %GFLOW: positive recharge read in as negative number, vice versa
    fprintf(fid,'%.7E',Recharge);
        
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s\n  ',' -9.99900E+03 IN_000001_0000');
    fprintf(fid,'%s\n  ',IN0);
    fprintf(fid,'%s\n  ',IN1);
    fprintf(fid,'%s\n  ',IN2);
    fprintf(fid,'%s\n ',IN3);
    fprintf(fid,'%s\n ','quit ');
    fprintf(fid,'%s\n','linesink ');
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Loop through polygon elements and print unique values
    poly = Label;
    poly = cellfun(@(s) {s(1:end-6)}, poly, 'UniformOutput', false);
    poly = vertcat(poly{:});
    
    uniq_poly = unique(poly);
    uniq_Depth = [];
    uniq_Label = [];
    uniq_Resistance = [];
    uniq_Width = [];
    
    for i = 1:length(uniq_poly)
        
        clear vi_ploy
        vi_poly = strcmp(poly,uniq_poly(i));
        
        tmp_Depth = Depth(vi_poly);
        tmp_Label = Label(vi_poly);
        tmp_Resistance = Resistance(vi_poly);
                
        uniq_Depth = [uniq_Depth; tmp_Depth(1)];
        uniq_Label = [uniq_Label; tmp_Label];
        uniq_Resistance = [uniq_Resistance; tmp_Resistance(1)];
                
        str_Head = ' head ';
        fprintf(fid,'%s\n',str_Head);
        
        str_Resistance = [' resistance ',num2str(uniq_Resistance(i),'%E')];
        fprintf(fid,'%s\n',str_Resistance);
        
        str_Width = [' width ',num2str(Width(i),'%E'),'  2'];
        fprintf(fid,'%s\n',str_Width);
        
        str_Depth = [' depth ',num2str(uniq_Depth(i),'%E')];
        fprintf(fid,'%s\n',str_Depth);
        
        for j = 1:length(tmp_Label) %Loop over each LS that makes up the j_th polygon
            
            clear vi_LS
            vi_LS = strcmp(Label,tmp_Label(j));
            
            %Could use either Ini_dat OR Ini_xtr x1,y1,x2,y2 information:
            x1_print = LS_Ini_dat_x1(vi_LS);
            y1_print = LS_Ini_dat_y1(vi_LS);
            x2_print = LS_Ini_dat_x2(vi_LS);
            y2_print = LS_Ini_dat_y2(vi_LS);
            z_print = z_new(vi_LS); %NEED TO GET VECTOR OF HeadElevations
            
            % Print LS  rows of
            fprintf(fid,'  %.6E %.6E %.6E %.6E %.5E %s \n',x1_print,y1_print,x2_print,y2_print,z_print,tmp_Label{j});
            
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s\n',' quit ');
    fprintf(fid,'%s\n ',' layout');
    fprintf(fid,'%s\n',WIN);
    fprintf(fid,'%s\n ',' quit ');
    fprintf(fid,'%s\n ','time 0');
    fprintf(fid,'%s\n\n ','solve 5 3 0 1');
    fprintf(fid,'%s','save ');
    
    % Print save
    str_save = file_out;
    fprintf(fid,'%s\n',str_save);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s\n ','y');
    fprintf(fid,'%s\n ','time          0 ');
    fprintf(fid,'%s\n ','extract');
    fprintf(fid,'%s','file ');
    
    % Print file
    str_file = file_out;
    fprintf(fid,'%s\n',str_file);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters %Check last vertex (VID),
    % Add from there for TPs
    fprintf(fid,'%s\n',' y');
    
    %Add TR Basin Wells
    fprintf(fid,'%s\n','  12286.72 15447.98 TP_001503');
    fprintf(fid,'%s\n','  12314.74 15455.42 TP_001504');
    fprintf(fid,'%s\n','  15530.11 12345.17 TP_001505');
    fprintf(fid,'%s\n','  14538.26 12258.13 TP_001506');
    fprintf(fid,'%s\n','  15924.85 12006.53 TP_001507');
    fprintf(fid,'%s\n','  15941.14 12033.55 TP_001508');
    fprintf(fid,'%s\n','  15920.35 12034.04 TP_001509');
    fprintf(fid,'%s\n','  15146.13 11967.03 TP_001510');
    fprintf(fid,'%s\n','  15131.52 11971.61 TP_001511');
    fprintf(fid,'%s\n','  11974.89 12536.93 TP_001512');
    fprintf(fid,'%s\n','  11957.19 12569.12 TP_001513');
    fprintf(fid,'%s\n','  15501.16 12371.03 TP_001514');
    fprintf(fid,'%s\n','  16870.64 12392.90 TP_001515');
    fprintf(fid,'%s\n','  16825.69 12328.68 TP_001516');
    fprintf(fid,'%s\n','  14819.35 12028.50 TP_001517');
    fprintf(fid,'%s\n','  15738.98 11860.52 TP_001518');
    fprintf(fid,'%s\n','  15753.60 11874.41 TP_001519');
    fprintf(fid,'%s\n','  15947.16 12117.39 TP_001520');
    fprintf(fid,'%s\n','  15952.89 12089.96 TP_001521');
    fprintf(fid,'%s\n','  11356.14 12373.25 TP_001522');
    fprintf(fid,'%s\n','  15457.39 12483.00 TP_001523');
    fprintf(fid,'%s\n','  11975.35 13033.75 TP_001524');
    fprintf(fid,'%s\n','  13762.73 12597.21 TP_001525');
    fprintf(fid,'%s\n','  10712.91 11156.79 TP_001526');
    fprintf(fid,'%s\n','  9534.39 12706.09 TP_001527');
    fprintf(fid,'%s\n','  15442.41 12474.65 TP_001528');
    fprintf(fid,'%s\n','  17426.77 14920.37 TP_001529');
    fprintf(fid,'%s\n','  15802.34 11670.11 TP_001530');
    fprintf(fid,'%s\n','  15485.52 12449.74 TP_001531');
    fprintf(fid,'%s\n','  15775.38 11666.40 TP_001532');
    fprintf(fid,'%s\n','  14561.04 12246.64 TP_001533');
    fprintf(fid,'%s\n','  9968.70 12779.47 TP_001534');
    fprintf(fid,'%s\n','  9665.10 19364.20 TP_001535');
    fprintf(fid,'%s\n','  10563.53 22564.06 TP_001536');
    fprintf(fid,'%s\n','  12387.76 22430.21 TP_001537');
    fprintf(fid,'%s\n','  13622.52 19628.69 TP_001538');
    fprintf(fid,'%s\n','  14943.04 18106.57 TP_001539');

    
    % Print additional run parameters
    fprintf(fid,'%s\n',' well discharge');
    fprintf(fid,'%s\n',' well head');
    fprintf(fid,'%s\n',' ppwell discharge');
    fprintf(fid,'%s\n',' ppwell head');
    fprintf(fid,'%s\n',' Theis well');
    fprintf(fid,'%s\n',' linesink discharge');
    fprintf(fid,'%s\n',' linesink head');
    fprintf(fid,'%s\n',' inhomogeneity');
    fprintf(fid,'%s\n',' quit');
    fprintf(fid,'%s\n ',' grid');
    fprintf(fid,'%s\n',WIN);
    fprintf(fid,'%s\n',' dotmap off');
    fprintf(fid,'%s\n',' horizontalpoints  40');
    fprintf(fid,'%s\n',' plot heads');
    fprintf(fid,'%s\n',' go');
    fprintf(fid,'%s ',' save');
    
    % Print save
    str_save = file_out;
    fprintf(fid,'%s\n',str_save);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s\n',' y');
    fprintf(fid,'%s ',' surfer');
    
    % Print surfer
    str_surfer = file_out;
    fprintf(fid,'%s\n',str_surfer);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s\n',' y ');
    fprintf(fid,'%s\n',' quit');
    fprintf(fid,'%s\n',' trace');
    fprintf(fid,'%s\n',' picture off');
    fprintf(fid,'%s ',' file');
    
    % Print file
    str_file = file_out;
    fprintf(fid,'%s\n',str_file);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Print additional run parameters
    fprintf(fid,'%s\n',' y ');
    fprintf(fid,'%s\n',' time 3650');
    fprintf(fid,'%s\n',' step 320');
    fprintf(fid,'%s\n',' go');
    fprintf(fid,'%s\n',' quit');
    fprintf(fid,'%s\n',' stop');
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Close file
    fclose(fid);
    
    
    %% 3)   Write .bat file to run GFLOW RUN#
    
    fid = fopen([file_out '.bat'],'w');
    str_bat1 = ['C:\"Program Files (x86)"\GFLOW\gflow1.exe ' file_out '.dat' ];
    str_bat2 = 'exit';
    fprintf(fid, '%s\n%s',str_bat1,str_bat2);
    fclose(fid);
    
    %% 4)  Exceute GFLOW RUN# .bat file
    
    disp(['Running GFLOW: ' file_out ' (' num2str(k) ')']);
    %system([file_out '.bat'],'-echo');
    system([file_out '.bat']);
    disp(['Completed GFLOW: ' file_out ' (' num2str(k) ')']);
    
    
    %% 5a)   Open .xtr file to extract TestPoint and LineSink data from GFLOW RUN# .xtr data
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Read in entire .xtr file
    
    fid = fopen([file_out '.xtr'],'r');
    clear datImport
    datImport = textscan(fid,'%s','Delimiter','\n');
    datImport = datImport{1};
    fclose(fid);
    
    
    %% 5b)  Extract TP Data (NOT COMMENTED OUT)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Looping through each row to get TP data
    
    LD_TP_xtr_out = length(datImport);
    rowWithTP_xtr_out = zeros(LD_TP_xtr_out,1);
    
    for i = 1:LD_TP_xtr_out
        temp_Line_TP_xtr_out = datImport{i}; % pull out a single row from the .xtr file
        
        % test for TP_
        idx_TP_xtr_out = strfind(temp_Line_TP_xtr_out,'TP_');
        
        % idx will be empty if 'TP_' is NOT found within the string. However, we
        % are only interested in the rows WITH 'TP_'.
        %So find ind where it is not empty
        rowWithTP_xtr_out(i) = ~isempty(idx_TP_xtr_out);
        
    end
    
    clear temp_Line_TP_xtr_out
    % Preallocating
    numRowsWithTP_xtr_out = sum(rowWithTP_xtr_out);
    
    TP_xtr_out_x = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_y = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_z = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_porosity = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_hyd_conduct = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_base_elevation = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_net_recharge = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_leakage_bot = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_head = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_lower_head = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_resistance = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_Vx = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_Vy = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_Vz = zeros(numRowsWithTP_xtr_out,1);
    TP_xtr_out_label = cell(numRowsWithTP_xtr_out,1);
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Looping through each row, again, to extract out data, save data
    
    TP_head_data_chk_ind = 1;
    while TP_head_data_chk_ind < 2;
        if exist('TP_head_data','var') ~= 1; %if 'TP_head_data' is not present
            TP_head_data = [];
            TP_label = [];
            %else%if 'TP_head_data' is present
            %Do nothing becasue we are passing through the loop and need to
            %append data to 'TP_head_data'
            clear TP_xtr_out_head TP_xtr_out_label
            
        end
        
        TP_head_data_chk_ind = TP_head_data_chk_ind + 1; %ends while loop
    end
    
    count_TP_xtr_out = 1;
    
    for i = 1:LD_TP_xtr_out
        if rowWithTP_xtr_out(i) == 1
            temp_Line_TP_xtr_out = datImport{i};
            temp_Line_TP_xtr_out = temp_Line_TP_xtr_out(3:end); %neglects '@  ' at beginning of TP line
            
            
            % If this line contains 'TP_', then we can pull out all data
            A_TP_xtr_out = textscan(temp_Line_TP_xtr_out,'%f %f %f %f %f %f %f %f %f %f %f %f %f %f %s','Delimiter',',');
            
            TP_xtr_out_x(count_TP_xtr_out) = A_TP_xtr_out{1};
            TP_xtr_out_y(count_TP_xtr_out)= A_TP_xtr_out{2};
            TP_xtr_out_z(count_TP_xtr_out) = A_TP_xtr_out{3};
            TP_xtr_out_porosity(count_TP_xtr_out) = A_TP_xtr_out{4};
            TP_xtr_out_hyd_conduct(count_TP_xtr_out) = A_TP_xtr_out{5};
            TP_xtr_out_base_elevation(count_TP_xtr_out) = A_TP_xtr_out{6};
            TP_xtr_out_net_recharge(count_TP_xtr_out) = A_TP_xtr_out{7};
            TP_xtr_out_leakage_bot(count_TP_xtr_out) = A_TP_xtr_out{8};
            TP_xtr_out_head(count_TP_xtr_out) = A_TP_xtr_out{9};
            TP_xtr_out_lower_head(count_TP_xtr_out) = A_TP_xtr_out{10};
            TP_xtr_out_resistance(count_TP_xtr_out) = A_TP_xtr_out{11};
            TP_xtr_out_Vx(count_TP_xtr_out) = A_TP_xtr_out{12};
            TP_xtr_out_Vy(count_TP_xtr_out) = A_TP_xtr_out{13};
            TP_xtr_out_Vz(count_TP_xtr_out) = A_TP_xtr_out{14};
            TP_xtr_out_label(count_TP_xtr_out) = A_TP_xtr_out{15};
            
            
            TP_head_data = [TP_head_data;TP_xtr_out_head(count_TP_xtr_out)];
            TP_label = [TP_label;TP_xtr_out_label(count_TP_xtr_out)];
            
            count_TP_xtr_out = count_TP_xtr_out + 1;
        end
        
    end
    
    %Save TP well elevation data for post-processing
    t_interval_char = matlab.lang.makeValidName(char(t_interval(k)));
    GFLOWout_results.(t_interval_char).Heads = TP_xtr_out_head;
    GFLOWout_results.(t_interval_char).TP_Label = TP_xtr_out_label;
    
    
    %% 5c)  Extract LS Data
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Looping through each row to get LS data
    
    LD_LS_xtr_out = length(datImport);
    rowWithLS_xtr_out = zeros(LD_LS_xtr_out,1);
    
    for i = 1:LD_LS_xtr_out
        temp_Line_LS_xtr_out = datImport{i}; % pull out a single row from the .xtr file
        
        % test for LS_
        idx_LS_xtr_out = strfind(temp_Line_LS_xtr_out,'LS_');
        
        % idx will be empty if 'LS_' is NOT found within the string. However, we
        % are only interested in the rows WITH 'LS_'.
        %So find ind where it is not empty
        rowWithLS_xtr_out(i) = ~isempty(idx_LS_xtr_out);
        
    end
    
    clear temp_Line_LS_xtr_out
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%Looping through each row, again, to extract out data, save data
    
    LS_data_chk_ind = 1;
    while LS_data_chk_ind < 2;
        if exist('LS_discharge_data','var') ~= 1; %if 'LS_discharge_data' is not present
            LS_discharge_data = [];
            LS_label = [];
            %else%if 'TP_head_data' is present
            %Do nothing becasue we are passing through the loop and need to
            %append data to 'TP_head_data'
            clear LS_xtr_out_discharge LS_xtr_out_label
            
        end
        
        LS_data_chk_ind = LS_data_chk_ind + 1; %ends while loop
    end
    
    if exist('LS_xtr_out_discharge','var') == 1;
        clear LS_xtr_out_discharge
    end
    
    count_LS_xtr_out = 1;
    for i = 1:LD_LS_xtr_out
        if rowWithLS_xtr_out(i) == 1
            temp_Line_LS_xtr_out = datImport{i};
            temp_Line_LS_xtr_out = temp_Line_LS_xtr_out(2:end); %neglects ' ' at beginning of TP line
            
            
            % If this line contains 'LS_', then we can pull out all data
            A_LS_xtr_out = textscan(temp_Line_LS_xtr_out,'%f %f %f %f %f %f %f %f %f %f %f %f %f %s','Delimiter',',');
            
            LS_xtr_out_x1(count_LS_xtr_out) = A_LS_xtr_out{1};
            LS_xtr_out_y1(count_LS_xtr_out) = A_LS_xtr_out{2};
            LS_xtr_out_x2(count_LS_xtr_out) = A_LS_xtr_out{3};
            LS_xtr_out_y2(count_LS_xtr_out) = A_LS_xtr_out{4};
            LS_xtr_out_spec_head(count_LS_xtr_out) = A_LS_xtr_out{5};
            LS_xtr_out_calc_head(count_LS_xtr_out) = A_LS_xtr_out{6};
            LS_xtr_out_discharge(count_LS_xtr_out) = A_LS_xtr_out{7};
            LS_xtr_out_width(count_LS_xtr_out) = A_LS_xtr_out{8};
            LS_xtr_out_resistance(count_LS_xtr_out) = A_LS_xtr_out{9};
            LS_xtr_out_depth(count_LS_xtr_out) = A_LS_xtr_out{10};
            LS_xtr_out_baseflow(count_LS_xtr_out) = A_LS_xtr_out{11};
            LS_xtr_out_overlandflow(count_LS_xtr_out) = A_LS_xtr_out{12};
            LS_xtr_out_PerErrBC(count_LS_xtr_out) = A_LS_xtr_out{13};
            LS_xtr_out_label(count_LS_xtr_out) = A_LS_xtr_out{14};
            
            
            LS_discharge_data = [LS_discharge_data;LS_xtr_out_discharge(count_LS_xtr_out)];
            LS_label = [LS_label;LS_xtr_out_label(count_LS_xtr_out)];
            
            count_LS_xtr_out = count_LS_xtr_out + 1;
        end
        
    end
    
    %Output to use for later discahrge calculations
    LS_name = LS_xtr_out_label;
    LS_x1 = LS_xtr_out_x1;
    LS_y1 = LS_xtr_out_y1;
    LS_x2 = LS_xtr_out_x2;
    LS_y2 = LS_xtr_out_y2;
    LS_Q = LS_xtr_out_discharge;
    LS_w = LS_xtr_out_width;
    LS_c = LS_xtr_out_resistance;
    LS_spec_head = LS_xtr_out_spec_head;
    LS_calc_head = LS_xtr_out_calc_head;
    
    
    %% 5d) Calculate LineSink String Discharges
    if StdGW == 1 %else, do the String Discharge Calc Daily whithin the Lake Model
        
        LS_name = LS_xtr_out_label;
        LS_x1 = LS_xtr_out_x1;
        LS_y1 = LS_xtr_out_y1;
        LS_x2 = LS_xtr_out_x2;
        LS_y2 = LS_xtr_out_y2;
        LS_Q = LS_xtr_out_discharge;
        LS_spec_head = LS_xtr_out_spec_head;
        LS_calc_head = LS_xtr_out_calc_head;
         
        %Only run Lake Model over NF, Move FF Mean change of NF
        vi_NF = strcmp(NF_or_FF,'NearField');
        GIS_NF_Label = GIS_Label(vi_NF);
        LS_x1 = LS_x1(vi_NF);
        LS_y1 = LS_y1(vi_NF);
        LS_x2 = LS_x2(vi_NF);
        LS_y2 = LS_y2(vi_NF);
        LS_Q = LS_Q(vi_NF);
        LS_spec_head = LS_spec_head(vi_NF);
        LS_calc_head = LS_calc_head(vi_NF);
        
        
        Elm_Dist_store = [];
        
        uni_GIS_NF_Label = unique(GIS_NF_Label,'stable'); 
        for i = 1:length(uni_GIS_NF_Label)
            clear vi tmp_label tmp_x1 tmp_y1 tmp_x2 tmp_y2 tmp_Q tmp_spec_head tmp_calc_head
            vi = strcmp(GIS_NF_Label,uni_GIS_NF_Label(i));
            tmp_label = GIS_NF_Label(vi);
            tmp_x1 = LS_x1(vi);
            tmp_y1 = LS_y1(vi);
            tmp_x2 = LS_x2(vi);
            tmp_y2 = LS_y2(vi);
            tmp_Q = LS_Q(vi);
            tmp_spec_head = LS_spec_head(vi); %Lake Elevation
            tmp_calc_head = LS_calc_head(vi); %Aquifer Elevation
            
            %save z0 and label in order to start LakeModel. Will have loop to go from Label to Permanent_ ID
            LakeM_label(i) = tmp_label(1);
            LakeM_z0(i) = mean(tmp_spec_head);
            
            clear Elm_Distance Elm_PerLengthDischarge Elm_TotalDischarge Elm_Qin Elm_Qout Elm_L_in Elm_L_out
            for j = 1:length(tmp_label)
                
                Elm_Distance(j) = sqrt((tmp_x2(j)-tmp_x1(j))^2 + (tmp_y2(j)-tmp_y1(j))^2);
                Elm_PerLengthDischarge(j) = tmp_Q(j);
                Elm_TotalDischarge(j) = Elm_Distance(j)*Elm_PerLengthDischarge(j);
                
                if Elm_TotalDischarge(j) >= 0
                    Elm_Qin(j) = Elm_TotalDischarge(j);
                    Elm_L_in(j) = Elm_Distance(j);
                else
                    Elm_Qin(j) = 0;
                    Elm_L_in(j) = 0;
                end
                
                if Elm_TotalDischarge(j) < 0
                    Elm_Qout(j) = Elm_TotalDischarge(j);
                    Elm_L_out(j) = Elm_Distance(j);
                else
                    Elm_Qout(j) = 0;
                    Elm_L_out(j) = 0;
                end
                
            end
            
                       
            LakeM_NetQ(i) = sum(Elm_TotalDischarge);
            LakeM_NetQin(i) = sum(Elm_Qin);
            LakeM_L_in(i) = sum(Elm_L_in);
            LakeM_NetQout(i) = sum(Elm_Qout);
            LakeM_L_out(i) = sum(Elm_L_out);
            LakeM_NetChk(i) = LakeM_NetQin(i) + LakeM_NetQout(i);
            GW_chk = LakeM_NetQ - LakeM_NetChk;
            
            Elm_Dist_store = [Elm_Dist_store Elm_Distance];
        end
       
    end
    
    %% 6a)  Initialize forcings to run LAKE_MODEL for all lakes
    
    %Get vi for dates of current time period
    if k == length(GFLOW_NetRechargeIN); %if at the end
        vi = (t_interval(k) <= Date_bounds) & (Date_bounds <= t_max);
    else
        vi = (t_interval(k) <= Date_bounds) & (Date_bounds < t_interval(k+1));
    end
    
    if k == 1
        
        %Lake Property Variables:
        A_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %m2
        r_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %m
        Perim_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %m
        stage_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %m
        z_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %m
        V_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %m3
                
        
        SW_in_APP = zeros(length(GIS_PERMANENT_),NumDaysTot);
        Base_in_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); 
        DirectP_APP = zeros(length(GIS_PERMANENT_),NumDaysTot);
        LakeE_APP = zeros(length(GIS_PERMANENT_),NumDaysTot);
        GWin_APP = zeros(length(GIS_PERMANENT_),NumDaysTot);
        GWout_APP = zeros(length(GIS_PERMANENT_),NumDaysTot);
        SW_out_APP = zeros(length(GIS_PERMANENT_),NumDaysTot);
        
        
        IceSnow_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %Amount of Snow in Ice
        LandMelt_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %Amount of snow melting from land
        IceMelt_APP = zeros(length(GIS_PERMANENT_),NumDaysTot); %Amount of snow melting from Ice
        
    end
    
    LakeM_Date = Date_bounds(vi);
    LakeM_FluxData = FluxData_bounds(vi,:);
    LakeM_LakeData = LakeData_bounds(vi,:);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Time-series Forcing/Flux Vectors:
    
    P = LakeM_FluxData(:,4)/1000; %Daily Precip (mm to m)
    E_h20 = LakeM_FluxData(:,16)/1000; %5 = OUT_EVAP, 16 = OUT_PET_H2OSURF (mm to m)
    Run = LakeM_FluxData(:,8)/1000; %Daily Runoff (mm to m)
    Base = LakeM_FluxData(:,9)/1000; %Daily Baseflow (mm to m)
    
    if StdGW == 1
        GW_in = LakeM_NetQin; %Daily GW discahrge (m3)
        GW_out = LakeM_NetQout*-1; %Daily GW discahrge (m3) %Change to positive values (reflected in MB eq)
    end
    
    IceChk = LakeM_LakeData(:,9); %OUT_LAKE_ICE_FRACT
    Ice_SWE = LakeM_LakeData(:,13); %LAKE Ice SWE (m)
    Ice_SWE(isnan(Ice_SWE)) = 0;
    IceSnow_TS = LakeM_LakeData(:,14); %OUT_LAKE_SWE_V (m3)
    LandMelt_TS = LakeM_FluxData(:,24)/1000; %Daily Land Snow Melt (mm to m)
    %Need to Output Land Snow Refreeze (partitioning runoff between
    %rainfall and snow melt runoff)
    IceMelt_TS = zeros(length(Ice_SWE),1);
    IceMelt_TS(1,1) = 0;
    for i = 2:length(Ice_SWE)-1
        melt_chk(i) = Ice_SWE(i-1) - Ice_SWE(i); 
        if melt_chk(i) > 0
            IceMelt_TS(i) = melt_chk(i); % Need to account for sublimation
        else
            IceMelt_TS(i) = 0;
        end
    end
    
    IceMelt_TS(:) = IceMelt_TS(:);
    %Lake_fail_dry = []; %Empty in order to catch new drying lakes (won't have to loop through all drying lakes for resistance setting)
    Lake_fail_dry_new = [];
    WA_fail = [];
    
    
    %% 6b)  Run Lake Model; k==1 (first WY), Initialize Lake Variables

    if k == 1 %If first timeRUN (WY)
        
        %Pre-Allocate Initial Vectors
        A0 = zeros(length(GIS_PERMANENT_),1);
        T_star = zeros(length(GIS_PERMANENT_),1);
        V0 = zeros(length(GIS_PERMANENT_),1);
        r0 = zeros(length(GIS_PERMANENT_),1);
        D0 = zeros(length(GIS_PERMANENT_),1);
        Perim0 = zeros(length(GIS_PERMANENT_),1);
        stage0 = zeros(length(GIS_PERMANENT_),1);
        DL = zeros(length(GIS_PERMANENT_),1);
        r2h = zeros(length(GIS_PERMANENT_),1);
        WA = zeros(length(GIS_PERMANENT_),1);
        WALA = zeros(length(GIS_PERMANENT_),1);
        z0_DEM = zeros(length(GIS_PERMANENT_),1);
        z0_DEM_chk = zeros(length(GIS_PERMANENT_),1);
        V_LinRes = zeros(length(GIS_PERMANENT_),1);
        stage_LinRes = zeros(length(GIS_PERMANENT_),1);
        lin_AF = zeros(length(GIS_PERMANENT_),1);
        Baseflow_Class = zeros(length(GIS_PERMANENT_),1);
        
        lin_AF(:) = lin_AF_value;
        
        FF_z_adj = [];
        
        A = zeros(length(GIS_PERMANENT_),NumDaysSub); %368 is max NumDays/yr: 365+InitialYearIndex(+1)+LeapYear(+1)+1 for storing last years last day (+1) = 368
        r = zeros(length(GIS_PERMANENT_),NumDaysSub);
        Perim = zeros(length(GIS_PERMANENT_),NumDaysSub);
        stage = zeros(length(GIS_PERMANENT_),NumDaysSub);
        z = zeros(length(GIS_PERMANENT_),NumDaysSub);
        V = zeros(length(GIS_PERMANENT_),NumDaysSub);
        Lake_Date_out = repmat(datetime([],[],[]),length(GIS_PERMANENT_),NumDaysSub);
        
        SW_in = zeros(length(GIS_PERMANENT_),NumDaysSub);
        Base_in = zeros(length(GIS_PERMANENT_),NumDaysSub);
        SW_out = zeros(length(GIS_PERMANENT_),NumDaysSub);
        DirectP = zeros(length(GIS_PERMANENT_),NumDaysSub);
        LakeE = zeros(length(GIS_PERMANENT_),NumDaysSub);
        GWin = zeros(length(GIS_PERMANENT_),NumDaysSub);
        GWout = zeros(length(GIS_PERMANENT_),NumDaysSub);
        GWnet = zeros(length(GIS_PERMANENT_),NumDaysSub);
        GWnet_chk = zeros(length(GIS_PERMANENT_),NumDaysSub);
        
        IceSnow = zeros(length(GIS_PERMANENT_),NumDaysSub);
        LandMelt = zeros(length(GIS_PERMANENT_),NumDaysSub);
        IceMelt = zeros(length(GIS_PERMANENT_),NumDaysSub);
        
        Lake_Date = [LakeM_Date(1) - caldays(2);LakeM_Date(1) - caldays(1);LakeM_Date(:)]; %Add in 2 dummy days (caldays(2)) for initialization
        Date_APP = Lake_Date';
        
        
        for kk = 1:length(GIS_PERMANENT_); %Loop through all Lakes
            disp(kk)
            vi_LakeGIS = strcmp(GIS_PERMANENT_,GIS_PERMANENT_(kk)); %69886228 to GIS_PERMANENT_(kk) for all lakes
            if StdGW == 1
                IDchk_gis(kk) = GIS_PERMANENT_(vi_LakeGIS);
                vi_LakeGFLOW = strcmp(LakeM_label,GIS_PERMANENT_(kk));
                IDchk_gflow(kk) = LakeM_label(vi_LakeGFLOW);
            else
                IDchk_gis(kk) = GIS_PERMANENT_(vi_LakeGIS);
                vi_LakeGFLOW2 = strcmp(GIS_Label,GIS_PERMANENT_(kk));
                [ind_vi_LakeGFLOW,~] = find(vi_LakeGFLOW2 == 1);
                IDchk_gflow(kk) = GIS_Label(ind_vi_LakeGFLOW(1));
            end

            % Initial Lake Demension Variables (derived from DEM elevation information):
            T_star(kk) = Tstr;
            A0(kk) = GIS_AREA_M2_1(vi_LakeGIS);
            if sum(strcmp(GIS_PERMANENT_(kk),'69886156')) >= 1; %AL == 1;
                A0(kk) = 1120000; %AL upper basin from Hanson et al (2014). 1.12 km2
            end
            V0(kk) = 10^(-0.0589+1.12963*log10(A0(kk)));
            
            %Overwrite V for LTER lakes and bogs
            %Perm = {'69886156' '69886284' '69886510' '69886472' '69886444' '69886228' '69886158'};
            %Name = {'"AL"'     '"BM"'      '"CR"'      '"CB"'      '"SP"'      '"TR"'    '"TB"'};
            if sum(strcmp(GIS_PERMANENT_(kk),'69886156')) >= 1; %AL == 1;
                V_AL_upper_orig = V0(kk);
                V0(kk) = A0(kk)*3.2; %use default volume above and adjusted perim below for GW fluxes
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886284')) >= 1; %BM == 1;
                V0(kk) = A0(kk)*7.5;
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886510')) >= 1; %CR == 1;
                V0(kk) = A0(kk)*10.4;
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886472')) >= 1; %CB == 1;
                V0(kk) = A0(kk)*1.7;
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886444')) >= 1; %SP == 1;
                V0(kk) = A0(kk)*10.9;
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886228')) >= 1; %TR == 1;
                V0(kk) = A0(kk)*14.6;
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886158')) >= 1; %TB == 1;
                V0(kk) = A0(kk)*5.6;
            end
            
            r0(kk) = sqrt(A0(kk)/pi);
            D0(kk) = 2*r0(kk);
            Perim0(kk) = GIS_PERIM_M_1(vi_LakeGIS); %m
            if sum(strcmp(GIS_PERMANENT_(kk),'69886156')) >= 1; %AL == 1;
                Perim0(kk) = 5900; %AL upper basin from Hanson et al (2014). 5.9 km
            end
            stage0(kk) = 3*V0(kk)/(pi*r0(kk)^2);
            
            %Overwrite lin_AF for LTER seepage lakes
            %Perm = {'69886156' '69886284' '69886510' '69886472' '69886444' '69886228' '69886158'};
            %Name = {'"AL"'     '"BM"'      '"CR"'      '"CB"'      '"SP"'      '"TR"'    '"TB"'};
            if sum(strcmp(GIS_PERMANENT_(kk),'69886156')) >= 1; %AL == 1;
                lin_AF(kk) = lin_AF(kk);
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886284')) >= 1; %BM == 1;
                lin_AF(kk) = 2.0;
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886510')) >= 1; %CR == 1;
                lin_AF(kk) = 2.0;
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886472')) >= 1; %CB == 1;
                lin_AF(kk) = lin_AF(kk);
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886444')) >= 1; %SP == 1;
                lin_AF(kk) = 2.0;
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886228')) >= 1; %TR == 1;
                lin_AF(kk) = lin_AF(kk);
            elseif sum(strcmp(GIS_PERMANENT_(kk),'69886158')) >= 1; %TB == 1;
                lin_AF(kk) = lin_AF(kk);
            end
            
            stage_LinRes(kk) = stage0(kk) + lin_AF(kk);
            DL(kk) = Perim0(kk)/(2*sqrt(pi*A0(kk))); %Ratio in difference of actual perimeter and a circular perimeter (Lake will be greater than 1)
            r2h(kk) = r0(kk)/stage0(kk);
            V_LinRes(kk) = (1/3)*pi*((r2h(kk)*stage_LinRes(kk))^2)*stage_LinRes(kk);
            %WA(kk) = GIS_WA_M2_1(vi_LakeGIS);
            %WALA(kk) = GIS_WALA_1(vi_LakeGIS);
            
            vi_stShed = strcmp(GIS_PERMANENT_(kk),stShed_Permanent_);
            Stream_WA_m2(kk) = stShed_WA_m2(vi_stShed);
            
            %Calc Watershed area from WALA
            %WALA = WA/LA
            %WA = WALA*LA
            vi_WALA = strcmp(GIS_PERMANENT_(kk),Permanent_outlier_adjusted);
            WALA(kk) = WALA_outlier_adjusted(vi_WALA);
            WA(kk) = WALA(kk)*A0(kk); 
            
            clear vi_Tstar
            vi_Tstar = strcmp(GIS_PERMANENT_(kk),In_IDs_SW_Fill);
            if sum(vi_Tstar) >= 1
                T_star(kk) = 1;
            end
           
            
            
            %Get z0_DEM:
            if StdGW == 1
                z0_DEM(kk) = LakeM_z0(vi_LakeGFLOW);
                z0_DEM_chk(kk) = GIS_RASTERVALU(kk); 
            else
                z0_DEM(kk) = LS_spec_head(ind_vi_LakeGFLOW(1));
                z0_DEM_chk(kk) = GIS_RASTERVALU(kk);
            end
            
            if sum(strcmp(GIS_PERMANENT_(kk),'69886158')) >= 1; %TB == 1;
                z0_DEM(kk) = 493.6551; %Set to mean of observations
            end
            
            
            %Input Dummy ID for initial timesteps (2):
            Pk1 = [0;0;P(:)];
            E_h20k1 = [0;0;E_h20(:)];
            Runk1 = [0;0;Run(:)];
            Basek1 = [0;0;Base(:)];
            IceSnowk1 = [0;0;IceSnow_TS(:)];
            LandMeltk1 = [0;0;LandMelt_TS(:)];
            IceMeltk1 = [0;0;IceMelt_TS(:)];
            IceChkk1 = [0;0;IceChk(:)];
            
            for i = 1:length(Lake_Date)
                if i < 3  %first 2 time steps, use initial variables to base from
                    A(kk,i) = A0(kk);
                    r(kk,i) = r0(kk);
                    Perim(kk,i) = Perim0(kk);
                    stage(kk,i) = stage0(kk);
                    z(kk,i) = z0_DEM(kk); %Base z0 from the DEM value
                    V(kk,i) = V0(kk);  %Initial TimeStep set to V0 (no WB components necessary -- but have put in dummy anyway)
                    
                else % i >= 3, past the first 2 dummy time steps, update vairable given previous time step info
                    
                    if V(kk,i-1) == 0;
                        
                        stage(kk,i) = 0;
                        A(kk,i) = 0;
                        r(kk,i) = 0;
                        Perim(kk,i) = 0;
                        z(kk,i) = z0_DEM(kk) - stage0(kk); %Calc change in z relative to DEM values of z and stage
                        
                    else
                        
                        stage(kk,i) = ((3*V(kk,i-1))/(r2h(kk)^2*pi))^(1/3);
                        A(kk,i) = pi*(r2h(kk)*stage(kk,i))^2;
                        r(kk,i) = sqrt(A(kk,i)/pi);
                        Perim(kk,i) = 2*pi*r(kk,i)*DL(kk);
                        z(kk,i) = z0_DEM(kk) + (stage(kk,i) - stage0(kk)); %Calc change in z relative to DEM values of z and stage
                        
                    end
                    
                end
                

                %%%%%%%%%%%%%%%%%%%% Lake Mass Balance Input/Output vaiables for timestep %%%%%%%%%%%%%%%%%%%%
                %SW_in(kk,i) = Runk1(i)*WA(kk);

                Base_in(kk,i) = Basek1(i)*(Stream_WA_m2(kk));
                SW_in(kk,i) = Runk1(i)*WA(kk);



                DirectP(kk,i) = Pk1(i)*(A(kk,i));
                LakeE(kk,i) = E_h20k1(i)*A(kk,i);
                
                
                
                if StdGW == 1
                    GWin(kk,i) = GW_in(vi_LakeGFLOW)*(Perim(kk,i)/Perim0(kk)); %Apply Fraction of GW as Perim +/-. p
                    GWout(kk,i) = GW_out(vi_LakeGFLOW)*(Perim(kk,i)/Perim0(kk));
                    
                    if sum(strcmp(GIS_PERMANENT_(kk),'69886156')) >= 1; %AL == 1;
                        GWin(kk,i) = GW_in(vi_LakeGFLOW)*(Perim(kk,i)/Perim0(kk))*0.63; %Apply Fraction of GW as Perim +/-. p
                        GWout(kk,i) = GW_out(vi_LakeGFLOW)*(Perim(kk,i)/Perim0(kk))*0.63; %adjusted to perim for upper AL (perim upper/total) = 5900/9426 = 0.6259 from Hanson et al (2014)
                    end

                
                else %read note description below:
                    
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Calc Lake LS GW discharges, after updating lake z elevation and comparing
                    %it to aquifer elevation that the solution is based upon
                    
                    % Imported before running through all lakes:
                    
                    %         LS_name = LS_xtr_out_label;
                    %         LS_x1 = LS_xtr_out_x1;
                    %         LS_y1 = LS_xtr_out_y1;
                    %         LS_x2 = LS_xtr_out_x2;
                    %         LS_y2 = LS_xtr_out_y2;
                    %         LS_Q = LS_xtr_out_discharge;
                    %         LS_w = LS_xtr_out_width;
                    %         LS_c = LS_xtr_out_resistance;
                    %         LS_spec_head = LS_xtr_out_spec_head;
                    
                    clear vi tmp_label tmp_x1 tmp_y1 tmp_x2 tmp_y2 tmp_Q tmp_spec_head tmp_calc_head tmp_w tmp_c
                    vi = strcmp(GIS_Label,GIS_PERMANENT_(kk));
                    tmp_label = GIS_Label(vi);
                    tmp_x1 = LS_x1(vi);
                    tmp_y1 = LS_y1(vi);
                    tmp_x2 = LS_x2(vi);
                    tmp_y2 = LS_y2(vi);
                    tmp_Q = LS_Q(vi);
                    tmp_w = LS_w(vi);
                    tmp_c = LS_c(vi);
                    tmp_spec_head = LS_spec_head(vi); %Lake Elevation
                    tmp_calc_head = LS_calc_head(vi); %Aquifer Elevation
                    
                    %save z0 and label in order to start LakeModel. Will have loop to go
                    %from Label to Permanent_ ID
                    LakeM_label(i,k) = tmp_label(1);
                    LakeM_z_spec(i,k) = mean(tmp_spec_head); %should all be the same (lake elevation)
                    
                    clear Elm_Distance Elm_PerLengthDischarge Elm_TotalDischarge Elm_Qin Elm_Qout Elm_L_in Elm_L_out
                    for j = 1:length(tmp_label)
                        
                        Elm_Distance(j) = sqrt((tmp_x2(j)-tmp_x1(j))^2 + (tmp_y2(j)-tmp_y1(j))^2);
                        
                        %This is calculating new discharges relating the lake elevation to the specified head used for the solution, for each lake's LS
                        Elm_PerLengthDischarge(j) = (tmp_w(j)/tmp_c(j))*(tmp_calc_head(j) - z(kk,i));
                        Elm_TotalDischarge(j) = Elm_Distance(j)*Elm_PerLengthDischarge(j);
                        
                        if Elm_TotalDischarge(j) >= 0
                            Elm_Qin(j) = Elm_TotalDischarge(j);
                            Elm_L_in(j) = Elm_Distance(j);
                        else
                            Elm_Qin(j) = 0;
                            Elm_L_in(j) = 0;
                        end
                        
                        if Elm_TotalDischarge(j) < 0
                            Elm_Qout(j) = Elm_TotalDischarge(j);
                            Elm_L_out(j) = Elm_Distance(j);
                        else
                            Elm_Qout(j) = 0;
                            Elm_L_out(j) = 0;
                        end
                        
                    end
                    
                    
                    GWnet(kk,i) = sum(Elm_TotalDischarge);
                    GWnet_chk(kk,i) = sum(Elm_Qin)+sum(Elm_Qout);
                    GWin(kk,i) = sum(Elm_Qin)*(Perim(kk,i)/Perim0(kk));
                    GWout(kk,i) = sum(Elm_Qout)*-1*(Perim(kk,i)/Perim0(kk));
                    
                    
                end
                
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                GWin(kk,1) = 0; %overwrite the first GW input so no MB variables computed towards V0
                GWout(kk,1) = 0;
                GWin(kk,2) = 0; %overwrite the second GW input so no MB variables computed towards V0
                GWout(kk,2) = 0;
                
                IceSnow(kk,i) = IceSnowk1(i);
                LandMelt(kk,i) = LandMeltk1(i)*WA(kk);
                IceMelt(kk,i) = 0; %To be overwritten in there is actually icemelt
                
                %%%%%%%%%%%%%%%%%%%% Ice %%%%%%%%%%%%%%%%%%%%
                if IceChkk1(i) >= 0.99;
                    LakeE(kk,i) = 0; %There is ice cover, so no evap from lake surface
                    E_h20(i) = 0; %There is ice cover, so no evap from lake surface, overwrite
                    IceMelt(kk,i) = IceMeltk1(i)*(A(kk,i)); %Melt snow only when once ice is on
                    
                    if IceSnow(kk,i) > 0 %if Snow Vol on ice > 0
                        DirectP(kk,i) = 0; %Shut off DirectP if Ice is on and start accumulating snow storage on top of ice, which will melt in spring
                    end
                end
                
                %%%%%%%%%%%%%%%%%%%% V calc at end of timestep %%%%%%%%%%%%%%%%%%%%
                if k == 1 %If first timeRUN (WY)
                    if i < 3; %first two timesteps
                        SW_out(kk,1) = 0;
                    else
                        if (V(kk,i-1) - V_LinRes(kk)) > 0; %If Volume rises about Linear Res Volume, calc SW_out(T_star)
                            SW_out(kk,i) = (V(kk,i-1) - V_LinRes(kk))/T_star(kk);
                        else
                            SW_out(kk,i) = 0;
                        end
                        
                        if T_star(kk) == 1
                            SW_out(kk,i) = SW_in(kk,i) + Base_in(kk,i);
                        end
                        
                        
                        
                        %Overwrite SW for LTER seepage lakes and bogs
                        %Perm = {'69886156' '69886284' '69886510' '69886472' '69886444' '69886228' '69886158'};
                        %Name = {'"AL"'     '"BM"'      '"CR"'      '"CB"'      '"SP"'      '"TR"'    '"TB"'};
                        if sum(strcmp(GIS_PERMANENT_(kk),'69886284')) >= 1; %BM == 1;
                            SW_in(kk,i) = 0;
                            SW_out(kk,i) = 0;
                        elseif sum(strcmp(GIS_PERMANENT_(kk),'69886510')) >= 1; %CR == 1;
                            SW_in(kk,i) = 0;
                            SW_out(kk,i) = 0;
                        elseif sum(strcmp(GIS_PERMANENT_(kk),'69886444')) >= 1; %SP == 1;
                            SW_in(kk,i) = 0;
                            SW_out(kk,i) = 0;
                            Base_in(kk,i) = 0;
                        end
                        
            
                        V(kk,i) = V(kk,i-1)+ DirectP(kk,i) + SW_in(kk,i) + Base_in(kk,i) + GWin(kk,i) - GWout(kk,i) - LakeE(kk,i) - SW_out(kk,i) + IceMelt(kk,i);
                    end
                end
                
                if V(kk,i) < Lake_Dry_Threshold
                    Lake_fail_dry = [Lake_fail_dry GIS_PERMANENT_(kk)]; %Add drying lakes in this stress period to Lake_fail_dry
                    Lake_fail_dry_new = [Lake_fail_dry_new GIS_PERMANENT_(kk)];
                    
                    V(kk,i) = 0; %If the lake dries up, leave dry and disconnect from aquifer next GW solution. Need to modify other lake parameters
                    z(kk,i) = z0_DEM(kk) - stage0(kk); %Set Lake Level to bottom
                    stage(kk,i) = 0;
                    A(kk,i) = 0;
                    r(kk,i) = 0;
                    Perim(kk,i) = 0;
                    
                    
                end
                
                if i <= 2
                    A_APP(kk,i) = A(kk,i); %m2
                    r_APP(kk,i) = r(kk,i); %m
                    Perim_APP(kk,i) = Perim(kk,i); %m
                    stage_APP(kk,i) = stage(kk,i); %m
                    z_APP(kk,i) = z(kk,i); %m
                    V_APP(kk,i) = V(kk,i); %m3
                    
                    SW_in_APP(kk,i) = SW_in(kk,i);
                    Base_in_APP(kk,i) = Base_in(kk,i);
                    DirectP_APP(kk,i) = DirectP(kk,i);
                    LakeE_APP(kk,i) = LakeE(kk,i);
                    GWin_APP(kk,i) = GWin(kk,i);
                    GWout_APP(kk,i) = GWout(kk,i);
                    SW_out_APP(kk,i) = SW_out(kk,i);
                    
                    IceSnow_APP(kk,i) = IceSnow(kk,i);
                    LandMelt_APP(kk,i) = LandMelt(kk,i);
                    IceMelt_APP(kk,i) = IceMelt(kk,i);
                    
                else
                    IN_idx = find(z(kk,:) ~= 0);
                    
                    %If CurLake dried up during this stress period, set elevation into next GFLOW solution to DEM value
                    %As well as setting all other lake demensions to
                    %initial for next lake model timestep. Set fluxes to
                    %zero (will be updated next stress-period)
%                     if isempty(Lake_fail_dry) ~= 1 && sum(ismember(GIS_PERMANENT_(kk),Lake_fail_dry)) >= 1
                    if isempty(Lake_fail_dry_new) ~= 1 && sum(ismember(GIS_PERMANENT_(kk),Lake_fail_dry_new)) >= 1
                        
                        %Lake Property Variables:
                        A_APP(kk,IN_idx(end)) = 0; %m2
                        r_APP(kk,IN_idx(end)) = 0; %m
                        Perim_APP(kk,IN_idx(end)) = 0; %m
                        stage_APP(kk,IN_idx(end)) = 0; %m
                        z_APP(kk,IN_idx(end)) = z0_DEM(kk) - stage0(kk); %m
                        V_APP(kk,IN_idx(end)) = 0; %m3
                        
                        %Lake Water and Volume Flux Variables(m3/d):
                        SW_in_APP(kk,IN_idx(end)) = SW_in(kk,i);
                        Base_in_APP(kk,IN_idx(end)) = Base_in(kk,i);
                        DirectP_APP(kk,IN_idx(end)) = DirectP(kk,i);
                        LakeE_APP(kk,IN_idx(end)) = LakeE(kk,i);
                        GWin_APP(kk,IN_idx(end)) = GWin(kk,i);
                        GWout_APP(kk,IN_idx(end)) = GWout(kk,i);
                        SW_out_APP(kk,IN_idx(end)) = SW_out(kk,i);
                        
                        %Snow Volume Fluxes
                        IceSnow_APP(kk,IN_idx(end)) = IceSnow(kk,i);
                        LandMelt_APP(kk,IN_idx(end)) = LandMelt(kk,i);
                        IceMelt_APP(kk,IN_idx(end)) = IceMelt(kk,i);
                        
                    else
                        
                        A_APP(kk,IN_idx(end)) = A(kk,i); %m2
                        r_APP(kk,IN_idx(end)) = r(kk,i); %m
                        Perim_APP(kk,IN_idx(end)) = Perim(kk,i); %m
                        stage_APP(kk,IN_idx(end)) = stage(kk,i); %m
                        z_APP(kk,IN_idx(end)) = z(kk,i); %m
                        V_APP(kk,IN_idx(end)) = V(kk,i); %m3
                        
                        SW_in_APP(kk,IN_idx(end)) = SW_in(kk,i);
                        Base_in_APP(kk,IN_idx(end)) = Base_in(kk,i);
                        DirectP_APP(kk,IN_idx(end)) = DirectP(kk,i);
                        LakeE_APP(kk,IN_idx(end)) = LakeE(kk,i);
                        GWin_APP(kk,IN_idx(end)) = GWin(kk,i);
                        GWout_APP(kk,IN_idx(end)) = GWout(kk,i);
                        SW_out_APP(kk,IN_idx(end)) = SW_out(kk,i);
                        
                        IceSnow_APP(kk,IN_idx(end)) = IceSnow(kk,i);
                        LandMelt_APP(kk,IN_idx(end)) = LandMelt(kk,i);
                        IceMelt_APP(kk,IN_idx(end)) = IceMelt(kk,i);
                        
                    end
                end
            end
            
            %OUTPUT to go into GFLOW:
            z_end_idx = find(z_APP(kk,:) ~= 0);
            z_end(kk) = z_APP(kk,z_end_idx(end));
            %Possible Update to FF Elevations
            FF_z_adj(k,kk) = z_APP(kk,z_end_idx(end)) - z0_DEM(kk);
           
           
        end
        %write to unique fail (drying lakes)
        uni_fail_HUC12 = {};
        uni_fail{k} = unique(Lake_fail_dry); %output current stress period drying lakes to uni_fail

        
        eltime(end+1) = toc;
        
        disp('%%%%%%%%%%%%%%%%% OPEN ERROR.LOG %%%%%%%%%%%%%%%%%')
        %type('ERROR.LOG')
        
        copyfile('ERROR.LOG',[file_out '_' num2str(k) '_ERROR.LOG'])
        copyfile('MESSAGE.LOG',[file_out '_' num2str(k) '_MESSAGE.LOG'])
        disp('%%%%%%%%%%%%%%%%% CLOSE ERROR.LOG %%%%%%%%%%%%%%%%%')
        
        
    %% 6c) Run Lake Model; k>1 (1< WY)
    
         %k>1 We have passed at least once, so update parameters from last timeRun (k) if i == 1, then go from there:
    else
        Lake_Date = LakeM_Date(:);
        Date_APP = [Date_APP Lake_Date'];
        
        for kk = 1:length(GIS_PERMANENT_) %Loop through all Lakes
            disp(kk)
            vi_LakeGIS = strcmp(GIS_PERMANENT_,GIS_PERMANENT_(kk)); 
            if StdGW == 1
                IDchk_gis(kk) = GIS_PERMANENT_(vi_LakeGIS);
                vi_LakeGFLOW = strcmp(LakeM_label,GIS_PERMANENT_(kk));
                IDchk_gflow(kk) = LakeM_label(vi_LakeGFLOW);
            else
                IDchk_gis(kk) = GIS_PERMANENT_(vi_LakeGIS);
                vi_LakeGFLOW2 = strcmp(GIS_Label,GIS_PERMANENT_(kk));
                [ind_vi_LakeGFLOW,~] = find(vi_LakeGFLOW2 == 1);
                IDchk_gflow(kk) = GIS_Label(ind_vi_LakeGFLOW(1));
            end
            
            % Loop through time:
            for i = 1:length(Lake_Date)
                
                if i == 1 %first time step, use final variables from previous stress-period to base from
                    f_idx = find(z_APP(kk,:) ~= 0); %z_APP always greater than zero,
                    %but will have zeros trailing at end on their rows.
                    %Search for idx of last non-zero, and update current
                    %timeRun's starting value with that non-zero value
                    A(kk,i) = A_APP(kk,f_idx(end));
                    r(kk,i) = r_APP(kk,f_idx(end));
                    Perim(kk,i) = Perim_APP(kk,f_idx(end));
                    stage(kk,i) = stage_APP(kk,f_idx(end));
                    z(kk,i) = z_APP(kk,f_idx(end)); %update z from the previous timeRun ending z value
                    V(kk,i) = V_APP(kk,f_idx(end)); %Base new V0 from the previous timeRun ending z value
                    
                    %write all forward variables (2:end) as zeros:
                    A(kk,2:end) = 0;
                    r(kk,2:end) = 0;
                    Perim(kk,2:end) = 0;
                    stage(kk,2:end) = 0;
                    z(kk,2:end) = 0;
                    V(kk,2:end) = 0;
                    
                    SW_in(kk,2:end) = 0;
                    Base_in(kk,2:end) = 0;
                    SW_out(kk,2:end) = 0;
                    DirectP(kk,2:end) = 0;
                    LakeE(kk,2:end) = 0;
                    GWin(kk,2:end) = 0;
                    GWout(kk,2:end) = 0;
                    
                    IceSnow(kk,2:end) = 0;
                    LandMelt(kk,2:end) = 0;
                    IceMelt(kk,2:end) = 0;
                    
    
                else %past the first time step, update stage and z given previous time step info and current, else only need current
                    
                    if V(kk,i-1) == 0;
                        
                        stage(kk,i) = 0;
                        A(kk,i) = 0;
                        r(kk,i) = 0;
                        Perim(kk,i) = 0;
                        z(kk,i) = z0_DEM(kk) - stage0(kk); %Calc change in z relative to DEM values of z and stage
                        
                    else
                        
                        stage(kk,i) = ((3*V(kk,i-1))/(r2h(kk)^2*pi))^(1/3);
                        A(kk,i) = pi*(r2h(kk)*stage(kk,i))^2;
                        r(kk,i) = sqrt(A(kk,i)/pi);
                        Perim(kk,i) = 2*pi*r(kk,i)*DL(kk);
                        z(kk,i) = z0_DEM(kk) + (stage(kk,i) - stage0(kk)); %Calc change in z relative to DEM values of z and stage
                        
                    end
                    
                end
                
                %%%%%%%%%%%%%%%%%%%% Lake Mass Balance Input/Output vaiables for timestep %%%%%%%%%%%%%%%%%%%%

                Base_in(kk,i) = Base(i)*(Stream_WA_m2(kk));
                SW_in(kk,i) = Run(i)*WA(kk);
                DirectP(kk,i) = P(i)*(A(kk,i));
                LakeE(kk,i) = E_h20(i)*A(kk,i);
                
                if StdGW == 1
                    GWin(kk,i) = GW_in(vi_LakeGFLOW)*(Perim(kk,i)/Perim0(kk)); %Apply Fraction of GW as Perim +/-
                    GWout(kk,i) = GW_out(vi_LakeGFLOW)*(Perim(kk,i)/Perim0(kk));
                    
                    if sum(strcmp(GIS_PERMANENT_(kk),'69886156')) >= 1; %AL == 1;
                        GWin(kk,i) = GW_in(vi_LakeGFLOW)*(Perim(kk,i)/Perim0(kk))*0.63; %Apply Fraction of GW as Perim +/-. p
                        GWout(kk,i) = GW_out(vi_LakeGFLOW)*(Perim(kk,i)/Perim0(kk))*0.63; %adjusted to perim for upper AL (perim upper/total) = 5900/9426 = 0.6259 from Hanson et al (2014)
                    end

                else
                    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    %Calc Lake LS GW discharges, after updating lake z elevationa and comparing
                    %it to aquifer elevation that the solution is based upon
                    
                    % Imported before running through all lakes:
                    
                    %         LS_name = LS_xtr_out_label;
                    %         LS_x1 = LS_xtr_out_x1;
                    %         LS_y1 = LS_xtr_out_y1;
                    %         LS_x2 = LS_xtr_out_x2;
                    %         LS_y2 = LS_xtr_out_y2;
                    %         LS_Q = LS_xtr_out_discharge;
                    %         LS_w = LS_xtr_out_width;
                    %         LS_c = LS_xtr_out_resistance;
                    %         LS_spec_head = LS_xtr_out_spec_head;
                    
                    clear vi tmp_label tmp_x1 tmp_y1 tmp_x2 tmp_y2 tmp_Q tmp_spec_head tmp_calc_head tmp_w tmp_c
                    vi = strcmp(GIS_Label,GIS_PERMANENT_(kk));
                    tmp_label = GIS_Label(vi);
                    tmp_x1 = LS_x1(vi);
                    tmp_y1 = LS_y1(vi);
                    tmp_x2 = LS_x2(vi);
                    tmp_y2 = LS_y2(vi);
                    tmp_Q = LS_Q(vi);
                    tmp_w = LS_w(vi);
                    tmp_c = LS_c(vi);
                    tmp_spec_head = LS_spec_head(vi); %Lake Elevation
                    tmp_calc_head = LS_calc_head(vi); %Aquifer Elevation
                    
                    %save z0 and label in order to start LakeModel. Will have loop to go
                    %from Label to Permanent_ ID
                    LakeM_label(i,k) = tmp_label(1);
                    LakeM_z_spec(i,k) = mean(tmp_spec_head); %should all be the same (lake elevation)
                    
                    clear Elm_Distance Elm_PerLengthDischarge Elm_TotalDischarge Elm_Qin Elm_Qout Elm_L_in Elm_L_out
                    for j = 1:length(tmp_label)
                        
                        Elm_Distance(j) = sqrt((tmp_x2(j)-tmp_x1(j))^2 + (tmp_y2(j)-tmp_y1(j))^2);
                        
                        %This is calculating new discharges relating the lake elevation to the specified head used for the solution, for each lake's LS
                        Elm_PerLengthDischarge(j) = (tmp_w(j)/tmp_c(j))*(tmp_calc_head(j) - z(kk,i));
                        
                        
                        Elm_TotalDischarge(j) = Elm_Distance(j)*Elm_PerLengthDischarge(j);
                        
                        if Elm_TotalDischarge(j) >= 0
                            Elm_Qin(j) = Elm_TotalDischarge(j);
                            Elm_L_in(j) = Elm_Distance(j);
                        else
                            Elm_Qin(j) = 0;
                            Elm_L_in(j) = 0;
                        end
                        
                        if Elm_TotalDischarge(j) < 0
                            Elm_Qout(j) = Elm_TotalDischarge(j);
                            Elm_L_out(j) = Elm_Distance(j);
                        else
                            Elm_Qout(j) = 0;
                            Elm_L_out(j) = 0;
                        end
                        
                    end
                    
                    GWnet(kk,i) = sum(Elm_TotalDischarge);
                    GWnet_chk(kk,i) = sum(Elm_Qin)+sum(Elm_Qout);
                    GWin(kk,i) = sum(Elm_Qin)*(Perim(kk,i)/Perim0(kk));
                    GWout(kk,i) = sum(Elm_Qout)*-1*(Perim(kk,i)/Perim0(kk));
                    
                end
               


                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                
                IceSnow(kk,i) = IceSnow_TS(i);
                LandMelt(kk,i) = LandMelt_TS(i)*WA(kk);
                IceMelt(kk,i) = 0; %To be overwritten in there is actually icemelt
                
                %%%%%%%%%%%%%%%%%%%% Ice %%%%%%%%%%%%%%%%%%%%
                if IceChk(i) >= 0.99;
                    LakeE(kk,i) = 0; %There is ice cover, so no evap from lake surface
                    E_h20(i) = 0; %There is ice cover, so no evap from lake surface, overwrite
                    IceMelt(kk,i) = IceMelt_TS(i)*(A(kk,i)); %Melt snow only when once ice is on
                    
                    if IceSnow(kk,i) > 0 %if Snow Depth > 0
                        DirectP(kk,i) = 0; %Shut off DirectP if Ice is on and start accumulating snow storage on top of ice
                    end
                end
                 
                
                if i == 1;
                    if (V(kk,1) - V_LinRes(kk)) > 0; %If Volume rises about Linear Res Volume, calc SW_out(T_star)
                        SW_out(kk,i) = (V(kk,1) - V_LinRes(kk))/T_star(kk);
                    else
                        SW_out(kk,i) = 0;
                    end
                    if T_star(kk) == 1
                        SW_out(kk,i) = SW_in(kk,i) + Base_in(kk,i);
                    end
                    
                    
                    %Overwrite SW for LTER seepage lakes and bogs
                    %Perm = {'69886156' '69886284' '69886510' '69886472' '69886444' '69886228' '69886158'};
                    %Name = {'"AL"'     '"BM"'      '"CR"'      '"CB"'      '"SP"'      '"TR"'    '"TB"'};
                    if sum(strcmp(GIS_PERMANENT_(kk),'69886284')) >= 1; %BM == 1;
                        SW_in(kk,i) = 0;
                        SW_out(kk,i) = 0;
                    elseif sum(strcmp(GIS_PERMANENT_(kk),'69886510')) >= 1; %CR == 1;
                        SW_in(kk,i) = 0;
                        SW_out(kk,i) = 0;
                    elseif sum(strcmp(GIS_PERMANENT_(kk),'69886444')) >= 1; %SP == 1;
                        SW_in(kk,i) = 0;
                        SW_out(kk,i) = 0;
                        Base_in(kk,i) = 0;
                    end
                    
                    V(kk,i) = V(kk,1) + DirectP(kk,i) + SW_in(kk,i) + Base_in(kk,i) + GWin(kk,i) - GWout(kk,i) - LakeE(kk,i) - SW_out(kk,i) + IceMelt(kk,i);
                    
                else
                    if (V(kk,i-1) - V_LinRes(kk)) > 0; %If Volume rises about Linear Res Volume, calc SW_out(T_star)
                        SW_out(kk,i) = (V(kk,i-1) - V_LinRes(kk))/T_star(kk);
                    else
                        SW_out(kk,i) = 0;
                    end
                    
                    if T_star(kk) == 1
                        SW_out(kk,i) = SW_in(kk,i) + Base_in(kk,i);
                    end
                    
                    
                    %Overwrite SW for LTER seepage lakes and bogs
                    %Perm = {'69886156' '69886284' '69886510' '69886472' '69886444' '69886228' '69886158'};
                    %Name = {'"AL"'     '"BM"'      '"CR"'      '"CB"'      '"SP"'      '"TR"'    '"TB"'};
                    if sum(strcmp(GIS_PERMANENT_(kk),'69886284')) >= 1; %BM == 1;
                        SW_in(kk,i) = 0;
                        SW_out(kk,i) = 0;
                    elseif sum(strcmp(GIS_PERMANENT_(kk),'69886510')) >= 1; %CR == 1;
                        SW_in(kk,i) = 0;
                        SW_out(kk,i) = 0;
                    elseif sum(strcmp(GIS_PERMANENT_(kk),'69886444')) >= 1; %SP == 1;
                        SW_in(kk,i) = 0;
                        SW_out(kk,i) = 0;
                        Base_in(kk,i) = 0;
                    end
                    
                    V(kk,i) = V(kk,i-1) + DirectP(kk,i) + SW_in(kk,i) + Base_in(kk,i) + GWin(kk,i) - GWout(kk,i) - LakeE(kk,i) - SW_out(kk,i) + IceMelt(kk,i);
                end
                
                if V(kk,i) < Lake_Dry_Threshold
                    Lake_fail_dry = [Lake_fail_dry GIS_PERMANENT_(kk)]; %Add drying lakes in this stress period to Lake_fail_dry
                    Lake_fail_dry_new = [Lake_fail_dry_new GIS_PERMANENT_(kk)];

                    V(kk,i) = 0; %If the lake is dries up, leave dry and disconnect from aquifer next GW solution. Need to modify other lake parameters
                    z(kk,i) = z0_DEM(kk) - stage0(kk); %Set Lake Level to bottom
                    stage(kk,i) = 0;
                    A(kk,i) = 0;
                    r(kk,i) = 0;
                    Perim(kk,i) = 0;
                    
                    
                end
                
                    IN_idx = find(z_APP(kk,:) ~= 0);
                    
                    %If CurLake dried up during this stress period, set elevation into next GFLOW solution to DEM value
                    %As well as setting all other lake demensions to
                    %initial for next lake model timestep. Set fluxes to
                    %zero (will be updated next stress-period)
                    %if isempty(Lake_fail_dry) ~= 1 && sum(ismember(GIS_PERMANENT_(kk),Lake_fail_dry)) >= 1
                    if isempty(Lake_fail_dry_new) ~= 1 && sum(ismember(GIS_PERMANENT_(kk),Lake_fail_dry_new)) >= 1
                        
                        A_APP(kk,IN_idx(end)+1) = 0; %m2
                        r_APP(kk,IN_idx(end)+1) = 0; %m
                        Perim_APP(kk,IN_idx(end)+1) = 0; %m
                        stage_APP(kk,IN_idx(end)+1) = 0; %m
                        z_APP(kk,IN_idx(end)+1) = 0; %m
                        V_APP(kk,IN_idx(end)+1) = 0; %m3
                                                
                        SW_in_APP(kk,IN_idx(end)+1) = SW_in(kk,i);
                        Base_in_APP(kk,IN_idx(end)+1) = Base_in(kk,i);
                        DirectP_APP(kk,IN_idx(end)+1) = DirectP(kk,i);
                        LakeE_APP(kk,IN_idx(end)+1) = LakeE(kk,i);
                        GWin_APP(kk,IN_idx(end)+1) = GWin(kk,i);
                        GWout_APP(kk,IN_idx(end)+1) = GWout(kk,i);
                        SW_out_APP(kk,IN_idx(end)+1) = SW_out(kk,i);
                        
                        IceSnow_APP(kk,IN_idx(end)+1) = IceSnow(kk,i);
                        LandMelt_APP(kk,IN_idx(end)+1) = LandMelt(kk,i);
                        IceMelt_APP(kk,IN_idx(end)+1) = IceMelt(kk,i);
                        
                    else
                        
                        A_APP(kk,IN_idx(end)+1) = A(kk,i); %m2
                        r_APP(kk,IN_idx(end)+1) = r(kk,i); %m
                        Perim_APP(kk,IN_idx(end)+1) = Perim(kk,i); %m
                        stage_APP(kk,IN_idx(end)+1) = stage(kk,i); %m
                        z_APP(kk,IN_idx(end)+1) = z(kk,i); %m
                        V_APP(kk,IN_idx(end)+1) = V(kk,i); %m3
                        
                        SW_in_APP(kk,IN_idx(end)+1) = SW_in(kk,i);
                        Base_in_APP(kk,IN_idx(end)+1) = Base_in(kk,i);
                        DirectP_APP(kk,IN_idx(end)+1) = DirectP(kk,i);
                        LakeE_APP(kk,IN_idx(end)+1) = LakeE(kk,i);
                        GWin_APP(kk,IN_idx(end)+1) = GWin(kk,i);
                        GWout_APP(kk,IN_idx(end)+1) = GWout(kk,i);
                        SW_out_APP(kk,IN_idx(end)+1) = SW_out(kk,i);
                        
                        IceSnow_APP(kk,IN_idx(end)+1) = IceSnow(kk,i);
                        LandMelt_APP(kk,IN_idx(end)+1) = LandMelt(kk,i);
                        IceMelt_APP(kk,IN_idx(end)+1) = IceMelt(kk,i);
                    end
                    
            end
            
            %OUTPUT to go into GFLOW:
            z_end_idx = find(z_APP(kk,:) ~= 0);
            z_end(kk) = z_APP(kk,z_end_idx(end));
            %Possible Update to FF Elevations
            FF_z_adj(k,kk) = z_APP(kk,z_end_idx(end)) - z0_DEM(kk);


            
        end
        
        %write to unique fail (drying variables)
        uni_fail{k} = unique(Lake_fail_dry);
        
        
        eltime(end+1) = toc;
        
        disp('%%%%%%%%%%%%%%%%% OPEN ERROR.LOG %%%%%%%%%%%%%%%%%')
        %type('ERROR.LOG')
        if k <= 2
            copyfile('ERROR.LOG',[file_out '_' num2str(k) '_ERROR.LOG'])
            copyfile('MESSAGE.LOG',[file_out '_' num2str(k) '_MESSAGE.LOG'])
        end
        disp('%%%%%%%%%%%%%%%%% CLOSE ERROR.LOG %%%%%%%%%%%%%%%%%')
        
    end
end

%% 7) Summarize (Fail, runtime)



Total_time = sum(eltime)
Total_time/60
%end runtime clock

%% Fail Lakes


for i = 1:length(GIS_PERMANENT_)
    for j = 1:length(uni_fail)
        NF_Fail_chk = strcmp(GIS_PERMANENT_(i),uni_fail{j});
        NF_Fail_chk_count(i,j) = sum(NF_Fail_chk);
    end
end

for i = 1:length(GIS_PERMANENT_)
    NF_Fail_chk_count_tot(i) = sum(NF_Fail_chk_count(i,:));
end

ind_fail = find(NF_Fail_chk_count_tot > 0);
uni_fail_all = GIS_PERMANENT_(ind_fail)';
uni_fail_all_HUC12 = cell(1,length(uni_fail_all));
uni_fail_all_HUC12(:) = cellstr(Cur_HUC12);


      
