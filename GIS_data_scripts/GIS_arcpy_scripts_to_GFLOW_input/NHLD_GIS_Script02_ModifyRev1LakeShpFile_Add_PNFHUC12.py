#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      Zach
#
# Created:     10/26/2016
# Copyright:   (c) Zach 2016
# Licence:     <your licence>
#import sys
#print(sys.version)
#2.7.2 (default, Jun 12 2011, 15:08:59) [MSC v.1500 32 bit (Intel)]
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------

def main():
    pass

if __name__ == '__main__':
    main()



#----------------------------------------------------------------------
#Begin Create an example XML file
print("Import Libraries")

import arcpy
arcpy.env.overwriteOutput=True
# Check out any necessary licenses
arcpy.CheckOutExtension("spatial")
arcpy.CheckOutExtension("3D")
from arcpy.sa import *
import math
import shutil
import os
import time
import numpy as np

print("Time Begin XML Writing")
print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'
################################################################################
##  Set Variables
print('Set Variables')
################################################################################
#------------------------------------------------------------------------------>
# Local variables:
#E:\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\WBDHU12_TR.shp
Loc = "G"
inpath = ":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\\"
infile_name = "WBDHU12_AlbCon_NHLD_NoBufferLakes_Adjusted_Turtle_Eagle" #WBDHU12_AlbCon_NHLD
HUCSet = Loc+inpath+infile_name+".shp"
print(HUCSet)

# Local variables:
NHLDandBuffLakes_Rev1 = Loc+ ":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\NHLDandBuffLakes\\NHLDandBuffLakes_Rev1.shp"
NHLDandBuffLakes_Rev2_shp_mod = Loc+ ":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\NHLDandBuffLakes\\NHLDandBuffLakes_Rev2.shp"
NHLDandBuffLakes_Rev2_shp_mod_lyr = Loc+ ":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\NHLDandBuffLakes\\NHLDandBuffLakes_Rev2.lyr"

NHLD_bound = Loc+ ":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\nhld_boundary\\nhld_boundary_AlbCon_Edit.shp"
NHLD_bound_lyr = Loc+ ":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\nhld_boundary\\nhld_boundary_AlbCon_Edit.lyr"
arcpy.MakeFeatureLayer_management(NHLD_bound,NHLD_bound_lyr) #Need to have NHLD_bound a "layer" rather than a .shp file in order for "Select by Location" to function

CurHUC = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\CurHUC.shp" #For selecting PNF


# Process: Copy Features
arcpy.CopyFeatures_management(NHLDandBuffLakes_Rev1, NHLDandBuffLakes_Rev2_shp_mod, "", "0", "0", "0")

# Process: Add Field
#arcpy.AddField_management(NHLDandBuffLakes_Rev2_shp_mod, "PNF_HUC12", "TEXT", "", "", "", "", "NULLABLE", "NON_REQUIRED", "") #TEXT from DOUBLE
arcpy.AddField_management(NHLDandBuffLakes_Rev2_shp_mod, "PNF_HUC12", "TEXT", "", "", "12", "", "NULLABLE", "NON_REQUIRED", "") #Don't need to do this

# Make Feature Layer
arcpy.MakeFeatureLayer_management(NHLDandBuffLakes_Rev2_shp_mod,NHLDandBuffLakes_Rev2_shp_mod_lyr)

#------------------------------------------------------------------------------>
#IDs
fc = HUCSet
cursor = arcpy.SearchCursor(fc)
IDs = [] #Creates empty list
for row in cursor:
    IDs.append(row.getValue('HUC12'))
IDs_len = len(IDs)
print IDs_len

count = 1
for curID in IDs:
    curQuery = "\"HUC12\" = '" + curID + "'"
    #print(curID+"_"+i)
    print(str(count)+" out of "+str(len(IDs)))
    print(curQuery)
    count=count+1

################################################################################
##  Select/Save HUC12s
    print('Select/Save HUC12s')
################################################################################

#------------------------------------------------------------------------------>
    #Make HUC12 Boundary Feature
    arcpy.MakeFeatureLayer_management(HUCSet, CurHUC, curQuery, "", "FID FID VISIBLE NONE;Shape Shape VISIBLE NONE;TNMID TNMID VISIBLE NONE;METASOURCE METASOURCE VISIBLE NONE;SOURCEDATA SOURCEDATA VISIBLE NONE;SOURCEORIG SOURCEORIG VISIBLE NONE;SOURCEFEAT SOURCEFEAT VISIBLE NONE;LOADDATE LOADDATE VISIBLE NONE;GNIS_ID GNIS_ID VISIBLE NONE;AREAACRES AREAACRES VISIBLE NONE;AREASQKM AREASQKM VISIBLE NONE;STATES STATES VISIBLE NONE;HUC12 HUC12 VISIBLE NONE;NAME NAME VISIBLE NONE;HUTYPE HUTYPE VISIBLE NONE;HUMOD HUMOD VISIBLE NONE;TOHUC TOHUC VISIBLE NONE;NONCONTR_A NONCONTR_A VISIBLE NONE;NONCONTR_K NONCONTR_K VISIBLE NONE;SHAPE_LENG SHAPE_LENG VISIBLE NONE;SHAPE_AREA SHAPE_AREA VISIBLE NONE")
#------------------------------------------------------------------------------>
    #Save HUC12 Boundary Feature
    fc = CurHUC
    cursor = arcpy.SearchCursor(fc)
    for row in cursor:
        out_file = row.getValue('HUC12')

#------------------------------------------------------------------------------>
    #ADDs the CurHUC12 value to the selected lakes that have centers in the CurHUC12 and the NHLD boundary
    #Select PNF
    arcpy.SelectLayerByLocation_management(NHLDandBuffLakes_Rev2_shp_mod_lyr,"HAVE_THEIR_CENTER_IN", CurHUC, "", "NEW_SELECTION")
    arcpy.SelectLayerByLocation_management(NHLDandBuffLakes_Rev2_shp_mod_lyr,"COMPLETELY_WITHIN", NHLD_bound, "", "SUBSET_SELECTION")

    # Process: Calculate Field
    #arcpy.CalculateField_management(NHLDandBuffLakes_Rev2_shp_mod_lyr, "PNF_HUC12", str(out_file), "VB", "")
    arcpy.CalculateField_management(NHLDandBuffLakes_Rev2_shp_mod_lyr, "PNF_HUC12", str(out_file), "", "")






