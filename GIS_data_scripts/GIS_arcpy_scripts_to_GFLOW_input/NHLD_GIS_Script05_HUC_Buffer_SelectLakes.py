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
infile_name = "WBDHU12_AlbCon_NHLD_NoBufferLakes_Adjusted_Turtle_Eagle" #WBDHU12_AlbCon_TR WBDHU12_AlbCon_NHLD_NoBufferLakes_Adjusted_Turtle_Eagle
HUCSet = Loc+inpath+infile_name+".shp"
print(HUCSet)

PNF_NF_Small_Lake_exclude = 0; #1 = exclude (TESTING ONLY), 0 = include (can't have this on and ff off, or ff will include those small ones that shoulc be nf)
FF_Small_Lake_exclude = PNF_NF_Small_Lake_exclude; #1 = exclude, 0 = include

PNF_NF_res = 100;
FF_res = 1000;
BuffIn_val = 1; # [1 2]: Run HUC_INH, PNF_NF, FF when BuffIn_val == 1; Run PNF_NF_INH when BuffIn_val == 2 (For TESING ONLY) Tested to see effects of setting inh for every lake (HighK lakes)


LakeSet_shp_in = Loc+ ":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\NHLDandBuffLakes\Simplify" + str(PNF_NF_res) + "\NHLDandBuffLakes_ElevVal_ElmIslands_MBG_Simplify" + str(PNF_NF_res) + "_RemoveIntLakes_BuffIn_" + str(BuffIn_val) + "m_GenTol_1m_Mod_PNF_HUC12.shp"
LakeSet_VertPt_shp_in = Loc+ ":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\NHLDandBuffLakes\Simplify" + str(PNF_NF_res) + "\NHLDandBuffLakes_ElevVal_ElmIslands_MBG_Simplify" + str(PNF_NF_res) + "_RemoveIntLakes_BuffIn_" + str(BuffIn_val) + "m_GenTol_1m_VertPt.shp"

#Coarse used for FF lakes -- could potentially have overlap with NF lakes
#We do have issue with vertex selection ...
LakeSet_FF_shp_in = Loc+ ":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\NHLDandBuffLakes\Simplify" + str(FF_res) + "\NHLDandBuffLakes_ElevVal_ElmIslands_MBG_Simplify" + str(FF_res) + "_RemoveIntLakes_BuffIn_1m_GenTol_1m.shp"
LakeSet_FF_VertPt_shp_in = Loc+ ":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\NHLDandBuffLakes\Simplify" + str(FF_res) + "\NHLDandBuffLakes_ElevVal_ElmIslands_MBG_Simplify" + str(FF_res) + "_RemoveIntLakes_BuffIn_1m_GenTol_1m_VertPt.shp"

NHLD_LakeSet = Loc + inpath + "NHLD_LakeSet.lyr"
NHLD_LakeSet_VertPt = Loc + inpath + "NHLD_LakeSet_VertPt.lyr"
NHLD_LakeSet_FF = Loc + inpath + "NHLD_LakeSet_FF.lyr"
NHLD_LakeSet_FF_VertPt = Loc + inpath + "NHLD_LakeSet_FF_VertPt.lyr"

arcpy.MakeFeatureLayer_management(LakeSet_shp_in,NHLD_LakeSet) #Need to have NHLD_LakeSet a "layer" rather than a .shp file in order for "Select by Location" to function

###Modify PNF_HUC12 Field
##fc = NHLD_LakeSet
##field = ['PNF_HUC12']
##cursor = arcpy.UpdateCursor(fc,field)
##with arcpy.da.UpdateCursor(fc,field)as cursor:
##    for row in cursor:
##        #int(row[0])
##        #print(str(0) + str(int(row[0])))
##        #row[0] = str(0) + str(int(row[0])) #commented out 1/19/2017
##        row[0] = str(0) + str((row[0]))
##        cursor.updateRow(row)

arcpy.MakeFeatureLayer_management(LakeSet_VertPt_shp_in,NHLD_LakeSet_VertPt) #Need to have NHLD_LakeSet a "layer" rather than a .shp file in order for "Select by Location" to function
arcpy.MakeFeatureLayer_management(LakeSet_FF_shp_in,NHLD_LakeSet_FF) #Need to have NHLD_LakeSet a "layer" rather than a .shp file in order for "Select by Location" to function
arcpy.MakeFeatureLayer_management(LakeSet_FF_VertPt_shp_in,NHLD_LakeSet_FF_VertPt) #Need to have NHLD_LakeSet a "layer" rather than a .shp file in order for "Select by Location" to function

NHLD_bound = Loc+ ":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\nhld_boundary\\nhld_boundary_AlbCon_Edit.shp"
NHLD_bound_lyr = Loc+ ":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\nhld_boundary\\nhld_boundary_AlbCon_Edit.lyr"
arcpy.MakeFeatureLayer_management(NHLD_bound,NHLD_bound_lyr) #Need to have NHLD_bound a "layer" rather than a .shp file in order for "Select by Location" to function

CurHUC = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\CurHUC.shp" #For selecting PNF
CurHUC_clip = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\CurHUC_clip.shp" #For selecting PNF
CurHUC_lyr = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\CurHUC_lyr.lyr" #For selecting PNF
CurHUC_2kmBuff = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\CurHUC_2kmBuff.shp" #For selecting NF
CurHUC_7kmBuff = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\CurHUC_7kmBuff.shp" #For selecting FF
PNF_lakes = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\PNF_lakes.shp"
PNF_NF_lakes = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\PNF_NF_lakes.shp"
FF_lakes = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\FF_lakes.shp"

#SaveName
outpath = Loc + inpath

#------------------------------------------------------------------------------>
#IDs
fc = HUCSet
cursor = arcpy.SearchCursor(fc)
HUC_IDs = [] #Creates empty list
for row in cursor:
    HUC_IDs.append(row.getValue('HUC12'))
HUC_IDs_len = len(HUC_IDs)
print HUC_IDs_len

HUC_count = 1
for HUC_curID in HUC_IDs:
    curQuery = "\"HUC12\" = '" + HUC_curID + "'"
    #print(HUC_curID+"_"+i)
    print(str(HUC_count)+" out of "+str(len(HUC_IDs)))
    print(curQuery)
    HUC_count=HUC_count+1

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
    #Make HUC12 output directory

    outpath = str(Loc + inpath + "HUC12_" + out_file + "\\")
    if not os.path.isdir(outpath):
        print('MAKE HUC12 Directory')
        os.makedirs(outpath)
    #else:
        #print('Remove HUC12 Directory Files')
        #fileList = os.listdir(outpath)
        #for filename in fileList:
            #item = os.path.join(outpath,filename)
            #if os.path.isfile(item):
                #os.remove(item)


#------------------------------------------------------------------------------>
    #Make outfile variable names:
    out_file_HUC12 = outpath + "HUC12_" + out_file + "_orig.shp"
    out_file_HUC12_0kmBuff = outpath + "HUC12_" + out_file + "_0kmBuff.shp"
    out_file_HUC12_2kmBuff = outpath + "HUC12_" + out_file + "_2kmBuff.shp"
    out_file_HUC12_7kmBuff = outpath + "HUC12_" + out_file + "_7kmBuff.shp"
    out_file_HUC12_7kmBuff_MBG = outpath + "HUC12_" + out_file + "_7kmBuff_MBG.shp"
    out_file_HUC12_7kmBuff_MBG_VertPt = outpath + "HUC12_" + out_file + "_7kmBuff_MBG_VertPt.shp"

    outfile_PNF_lakes = outpath + "HUC12_" + out_file + "_PNF_lakes_Simp_" + str(PNF_NF_res) + ".shp"
    outfile_PNF_lakes_txt = outpath + "HUC12_" + out_file + "_PNF_lakes_Simp_" + str(PNF_NF_res) + ".txt"
    outfile_PNF_NF_lakes = outpath + "HUC12_" + out_file + "_PNF_NF_lakes_Simp_" + str(PNF_NF_res) + ".shp"
    outfile_PNF_NF_lakes_txt = outpath + "HUC12_" + out_file + "_PNF_NF_lakes_Simp_" + str(PNF_NF_res) + ".txt"
    outfile_FF_lakes = outpath + "HUC12_" + out_file + "_FF_lakes_Simp_" + str(FF_res) + ".shp"

    outfile_PNF_lakes_VertPt = outpath + "HUC12_" + out_file + "_PNF_lakes_Simp_" + str(PNF_NF_res) + "_VertPt.shp"
    outfile_PNF_NF_lakes_VertPt = outpath + "HUC12_" + out_file + "_PNF_NF_lakes_Simp_" + str(PNF_NF_res) + "_VertPt.shp"
    outfile_FF_lakes_VertPt = outpath + "HUC12_" + out_file + "_FF_lakes_Simp_" + str(FF_res) + "_VertPt.shp"

#------------------------------------------------------------------------------>
    # Process: Clip
    arcpy.MakeFeatureLayer_management(CurHUC,CurHUC_lyr) #Need to have CurHUC_lyr a "layer" rather than a .shp file in order for "Select by Location" to function
    #arcpy.Clip_analysis(CurHUC, NHLD_bound_lyr, out_file_HUC12_0kmBuff, "")
    arcpy.Clip_analysis(CurHUC, NHLD_bound_lyr, CurHUC_clip, "")
    arcpy.CopyFeatures_management(CurHUC_clip, out_file_HUC12_0kmBuff)
#------------------------------------------------------------------------------>
    #Make HUC12_2kmBuff Boundary Feature
    arcpy.Buffer_analysis(out_file_HUC12_0kmBuff, CurHUC_2kmBuff, "2 Kilometers", "FULL", "ROUND", "LIST", "FID;TNMID;METASOURCE;SOURCEDATA;SOURCEORIG;SOURCEFEAT;LOADDATE;GNIS_ID;AREAACRES;AREASQKM;STATES;HUC12;NAME;HUTYPE;HUMOD;TOHUC;NONCONTR_A;NONCONTR_K;SHAPE_LENG;SHAPE_AREA")
#------------------------------------------------------------------------------>
    #Save HUC12_2kmBuff Boundary Feature
    arcpy.CopyFeatures_management(CurHUC_2kmBuff, out_file_HUC12_2kmBuff)
#------------------------------------------------------------------------------>
    #Make HUC12_7kmBuff Boundary Feature
    arcpy.Buffer_analysis(out_file_HUC12_0kmBuff, CurHUC_7kmBuff, "7 Kilometers", "FULL", "ROUND", "LIST", "FID;TNMID;METASOURCE;SOURCEDATA;SOURCEORIG;SOURCEFEAT;LOADDATE;GNIS_ID;AREAACRES;AREASQKM;STATES;HUC12;NAME;HUTYPE;HUMOD;TOHUC;NONCONTR_A;NONCONTR_K;SHAPE_LENG;SHAPE_AREA")
#------------------------------------------------------------------------------>
    #Save HUC12_7kmBuff Boundary Feature
    arcpy.CopyFeatures_management(CurHUC_7kmBuff, out_file_HUC12_7kmBuff)

################################################################################
##  MBG for 7km Buffer
    print('Select/Save HUC12s')
################################################################################

    print("Process: Minimum Bounding Geometry")
    # Process: Minimum Bounding Geometry
    arcpy.MinimumBoundingGeometry_management(out_file_HUC12_7kmBuff, out_file_HUC12_7kmBuff_MBG, "RECTANGLE_BY_WIDTH", "NONE", "", "MBG_FIELDS")

    print("Process: Feature Vertices To Points")
    # Process: Feature Vertices To Points
    arcpy.FeatureVerticesToPoints_management(out_file_HUC12_7kmBuff_MBG, out_file_HUC12_7kmBuff_MBG_VertPt, "ALL")

    print("Process: AddXY_management")
    # Process: AddXY_management (in_features)
    arcpy.AddXY_management(out_file_HUC12_7kmBuff_MBG_VertPt)

    #NEED to Project to same PROJ as Shapefile (ALB)


################################################################################
## Select/Save Lakes
    print('Select/Save Lakes')
################################################################################
#------------------------------------------------------------------------------>
    fc = NHLD_LakeSet
    cursor = arcpy.SearchCursor(fc)
    test = []
    for row in cursor:
        test.append(row.getValue('PNF_HUC12'))

    # Process: Select Layer By Attribute
    #arcpy.SelectLayerByAttribute_management(NHLDandBuffLakes_ElevVal_ElmIslands_MBG_Simplify100_RemoveIntLakes_BuffIn_1m, "NEW_SELECTION", "\"PNF_HUC12\" = '70700010205'")
    L0 = """ arcpy.SelectLayerByAttribute_management(NHLD_LakeSet, "NEW_SELECTION", """
    L1 = '"""'
    L2 = """ "PNF_HUC12" in ('"""
    L3 = str(out_file)
    L4 = """ ' ) """
    L5 = '"""'
    L6 = """ ) """
    Select_PNF = L0+L1+L2+L3+L4+L5+L6
    eval(Select_PNF)
    print("Select_PNF Evaluated properly")
    if PNF_NF_Small_Lake_exclude == 1:
        arcpy.SelectLayerByAttribute_management(NHLD_LakeSet, "REMOVE_FROM_SELECTION", "\"Area_m2_0\" < 10000") #PNF_VertPt only larger than 1ha (10000 m2)

#------------------------------------------------------------------------------>
    #Save HUC12 PNF
    arcpy.CopyFeatures_management(NHLD_LakeSet, outfile_PNF_lakes)

    # Process: Export Feature Attribute to ASCII
    arcpy.ExportXYv_stats(outfile_PNF_lakes, "FID;Permanent_;FDate;GNIS_ID;GNIS_Name;ReachCode;FType;FCode;Longitude;Latitude;BufferID;Perim_m_0;Area_m2_0;WALA_0;PNF_HUC12;RASTERVALU;ORIG_FID;Perim_m_1;Area_m2_1;WALA_1;MBG_Width;MBG_Length;Width_m_1;MaxSimpTol;MinSimpTol;BUFF_DIST;Perim_m_S;Area_m2_S;Width_m_S", "COMMA", outfile_PNF_lakes_txt, "ADD_FIELD_NAMES")
#------------------------------------------------------------------------------>
    #Select PNF Vert select Permanent_ that match PNF Poly and use eval() to select. Issue in PNF could arise on edges where HUC12 is clipped by NHLD boundary
    UniPerm_PNF = []
    fc = outfile_PNF_lakes
    cursor = arcpy.SearchCursor(fc)
    for row in cursor:
        UniPerm_PNF.append(row.getValue('Permanent_'))
    UniPerm_PNF_str = str("','".join(UniPerm_PNF))

    L0 = """ arcpy.SelectLayerByAttribute_management(NHLD_LakeSet_VertPt, "NEW_SELECTION", """
    L1 = '"""'
    L2 = """ "Permanent_" in ('"""
    L3 = UniPerm_PNF_str
    L4 = """ ' ) """
    L5 = '"""'
    L6 = """ ) """
    Select_PNF_VertPt = L0+L1+L2+L3+L4+L5+L6
    eval(Select_PNF_VertPt)
    print("Select_PNF_VertPt Evaluated properly")
    if PNF_NF_Small_Lake_exclude == 1:
        arcpy.SelectLayerByAttribute_management(NHLD_LakeSet_VertPt, "REMOVE_FROM_SELECTION", "\"Area_m2_0\" < 10000") #PNF_VertPt only larger than 1ha (10000 m2)
#------------------------------------------------------------------------------>
    #Save HUC12 PNF VertPt
    arcpy.CopyFeatures_management(NHLD_LakeSet_VertPt, outfile_PNF_lakes_VertPt)
#------------------------------------------------------------------------------>
    #Select PNF_NF
    #arcpy.SelectLayerByLocation_management(NHLD_LakeSet,"COMPLETELY_WITHIN", out_file_HUC12_2kmBuff, "", "NEW_SELECTION")
    arcpy.SelectLayerByLocation_management(NHLD_LakeSet,"HAVE_THEIR_CENTER_IN", out_file_HUC12_2kmBuff, "", "NEW_SELECTION")
    if PNF_NF_Small_Lake_exclude == 1:
        arcpy.SelectLayerByAttribute_management(NHLD_LakeSet, "REMOVE_FROM_SELECTION", "\"Area_m2_0\" < 10000") #PNF_NF only larger than 1ha (10000 m2)

#------------------------------------------------------------------------------>
    #Save HUC12 PNF_NF
    arcpy.CopyFeatures_management(NHLD_LakeSet, outfile_PNF_NF_lakes)

    # Process: Export Feature Attribute to ASCII
    arcpy.ExportXYv_stats(outfile_PNF_NF_lakes, "FID;Permanent_;FDate;GNIS_ID;GNIS_Name;ReachCode;FType;FCode;Longitude;Latitude;BufferID;Perim_m_0;Area_m2_0;WALA_0;PNF_HUC12;RASTERVALU;ORIG_FID;Perim_m_1;Area_m2_1;WALA_1;MBG_Width;MBG_Length;Width_m_1;MaxSimpTol;MinSimpTol;BUFF_DIST;Perim_m_S;Area_m2_S;Width_m_S", "COMMA", outfile_PNF_NF_lakes_txt, "ADD_FIELD_NAMES")

#------------------------------------------------------------------------------>
    #Select PNF_NF Vert (This is perfromed because if use "COMPLETELY_WITHIN" CurHUC_2kmBuff, some PNF_NF verts will be selected when the related polygon is not becasue is it not completely within)
    UniPerm_PNF_NF = []
    fc = outfile_PNF_NF_lakes
    cursor = arcpy.SearchCursor(fc)
    for row in cursor:
        UniPerm_PNF_NF.append(row.getValue('Permanent_'))
    UniPerm_PNF_NF_str = str("','".join(UniPerm_PNF_NF))

    L0 = """ arcpy.SelectLayerByAttribute_management(NHLD_LakeSet_VertPt, "NEW_SELECTION", """
    L1 = '"""'
    L2 = """ "Permanent_" in ('"""
    L3 = UniPerm_PNF_NF_str
    L4 = """ ' ) """
    L5 = '"""'
    L6 = """ ) """
    Select_PNF_NF_VertPt = L0+L1+L2+L3+L4+L5+L6
    eval(Select_PNF_NF_VertPt)
    print("Select_PNF_NF_VertPt Evaluated properly")
    if PNF_NF_Small_Lake_exclude == 1:
        arcpy.SelectLayerByAttribute_management(NHLD_LakeSet_VertPt, "REMOVE_FROM_SELECTION", "\"Area_m2_0\" < 10000") #PNF_NF_VertPt only larger than 1ha (10000 m2)
#------------------------------------------------------------------------------>
    #Save HUC12 PNF_NF VertPt
    arcpy.CopyFeatures_management(NHLD_LakeSet_VertPt, outfile_PNF_NF_lakes_VertPt)
#------------------------------------------------------------------------------>
    #Select PNF_NF_FF (FF uses coarse 1000m simplification lake set)
    arcpy.SelectLayerByLocation_management(NHLD_LakeSet_FF,"COMPLETELY_WITHIN", out_file_HUC12_7kmBuff, "", "NEW_SELECTION")
#------------------------------------------------------------------------------>
    #DeSelect PNF_NF_Poly from Selected PNF_NF_FF Poly
    L0 = """ arcpy.SelectLayerByAttribute_management(NHLD_LakeSet_FF, "REMOVE_FROM_SELECTION", """
    L1 = '"""'
    L2 = """ "Permanent_" in ('"""
    L3 = UniPerm_PNF_NF_str
    L4 = """ ' ) """
    L5 = '"""'
    L6 = """ ) """
    Deselect_PNF_NF_Poly = L0+L1+L2+L3+L4+L5+L6
    eval(Deselect_PNF_NF_Poly)
    print("Deselect_PNF_NF_Poly Evaluated properly")
    if FF_Small_Lake_exclude == 1:
        arcpy.SelectLayerByAttribute_management(NHLD_LakeSet_FF, "REMOVE_FROM_SELECTION", "\"Area_m2_0\" < 10000") #FF Poly only larger than 1ha (10000 m2)
#------------------------------------------------------------------------------>
    #Save HUC12 FF Poly
    arcpy.CopyFeatures_management(NHLD_LakeSet_FF, outfile_FF_lakes)
#------------------------------------------------------------------------------>
    #Select FF Vert
    UniPerm_FF = []
    fc = outfile_FF_lakes
    cursor = arcpy.SearchCursor(fc)
    for row in cursor:
        UniPerm_FF.append(row.getValue('Permanent_'))
    UniPerm_FF_str = str("','".join(UniPerm_FF))
    del row #remove lock
    del cursor #remove lock
    del fc #remove lock

    L0 = """ arcpy.SelectLayerByAttribute_management(NHLD_LakeSet_FF_VertPt, "NEW_SELECTION", """
    L1 = '"""'
    L2 = """ "Permanent_" in ('"""
    L3 = UniPerm_FF_str
    L4 = """ ' ) """
    L5 = '"""'
    L6 = """ ) """
    Select_FF_VertPt = L0+L1+L2+L3+L4+L5+L6
    eval(Select_FF_VertPt)
    print("Select_FF_VertPt Evaluated properly")

#------------------------------------------------------------------------------>
    #Save HUC12 FF VertPt
    arcpy.CopyFeatures_management(NHLD_LakeSet_FF_VertPt, outfile_FF_lakes_VertPt)

#------------------------------------------------------------------------------>


    if BuffIn_val == 1:
        execfile("NHLD_GIS_Script06a_lss_PNF_NF.py")
        execfile("NHLD_GIS_Script06b_lss_FF.py")
        execfile("NHLD_GIS_Script06c_ModelRegion_inh.py")

    if BuffIn_val == 2:
        execfile("NHLD_GIS_Script06d_Lake_inh.py")

