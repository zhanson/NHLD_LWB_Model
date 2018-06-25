#-------------------------------------------------------------------------------
# Name:        NHLD_GIS_04a_lss_PNF_NF.py
# Purpose:
#
# Author:      Zach
#
# Created:     10/27/2016
# Copyright:   (c) Zach 2016
# Licence:     <your licence>
#import sys
#print(sys.version)
#2.7.2 (default, Jun 12 2011, 15:08:59) [MSC v.1500 32 bit (Intel)]
#-------------------------------------------------------------------------------

############## Pretty Print

def indent(elem, level=0):
  i = "\n" + level*"  "
  if len(elem):
    if not elem.text or not elem.text.strip():
      elem.text = i + "  "
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
    for elem in elem:
      indent(elem, level+1)
    if not elem.tail or not elem.tail.strip():
      elem.tail = i
  else:
    if level and (not elem.tail or not elem.tail.strip()):
      elem.tail = i

################ Pretty Print


###----------------------------------------------------------------------
#Begin Create an example XML file

from xml.etree import ElementTree as ET
root = ET.Element("LinesinkStringFile")
root.set("version","1")
print root.tag
ComputationalUnits = ET.SubElement(root,"ComputationalUnits")
ComputationalUnits.text = "Meters"
BasemapUnits = ET.SubElement(root,"BasemapUnits")
BasemapUnits.text = "Meters"


#----------------------------------------------------------------------
#Within creating XML file, need to bring in linesink GIS data

#FF Script
################################################################################
##BEGIN INPUT
################################################################################

infile = outfile_FF_lakes

################################################################################
##END INPUT
################################################################################


#SaveName
outfile_name = "HUC12_" + out_file + "_FF_lakes_FFsimp" + str(FF_res)
SaveName = outpath + outfile_name + ".lss.xml"
print(SaveName)

CurLake = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\CurLake.shp"
CurLake_Vert = Loc+":\NHLD\GIS_DATA\NHLD_GIS_Data_FINAL\WI_HUC12\CurLake_Vert.shp"

#IDs
fc = infile
cursor = arcpy.SearchCursor(fc)
IDs = [] #Creates empty list
for row in cursor:
    IDs.append(row.getValue('Permanent_'))
IDs_len = len(IDs)
print IDs_len

count = 1
for curID in IDs:
    curQuery = "\"Permanent_\" = '" + curID + "'"
    print(str(count)+" out of "+str(len(IDs)))
    print(curQuery)
    count=count+1

    #Infile data:
    arcpy.MakeFeatureLayer_management(infile, CurLake, curQuery, "", "FID FID VISIBLE NONE;Shape Shape VISIBLE NONE;Permanent_ Permanent_ VISIBLE NONE;FDate FDate VISIBLE NONE;GNIS_ID GNIS_ID VISIBLE NONE;GNIS_Name GNIS_Name VISIBLE NONE;ReachCode ReachCode VISIBLE NONE;FType FType VISIBLE NONE;FCode FCode VISIBLE NONE;Longitude Longitude VISIBLE NONE;Latitude Latitude VISIBLE NONE;BufferID BufferID VISIBLE NONE;Perim_m_0 Perim_m_0 VISIBLE NONE;Area_m2_0 Area_m2_0 VISIBLE NONE;WALA_0 WALA_0 VISIBLE NONE;RASTERVALU RASTERVALU VISIBLE NONE;ORIG_FID ORIG_FID VISIBLE NONE;Perim_m_1 Perim_m_1 VISIBLE NONE;Area_m2_1 Area_m2_1 VISIBLE NONE;WALA_1 WALA_1 VISIBLE NONE;MBG_Width MBG_Width VISIBLE NONE;MBG_Length MBG_Length VISIBLE NONE;Width_m_1 Width_m_1 VISIBLE NONE;MaxSimpTol MaxSimpTol VISIBLE NONE;MinSimpTol MinSimpTol VISIBLE NONE;BUFF_DIST BUFF_DIST VISIBLE NONE;Perim_m_S Perim_m_S VISIBLE NONE;Area_m2_S Area_m2_S VISIBLE NONE;Width_m_S Width_m_S VISIBLE NONE")

    print("Time Begin LSS Properties")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'
    #LSS Properties
    fc = CurLake
    cursor = arcpy.SearchCursor(fc)
    for row in cursor:
        LSS_Permanent = row.getValue('Permanent_')
        LSS_ElevMean = float(row.getValue('RASTERVALU'))
        print("Time End LSS Properties")
        print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'


    print("Time Begin Vetices Create")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'
    #Select CurLakeVert
    CurLake_str = str(LSS_Permanent)
    outfile_FF_lakes_VertPt_lyr = outpath + out_file + "_FF_lakes_VertPt.lyr"
    arcpy.MakeFeatureLayer_management(outfile_FF_lakes_VertPt,outfile_FF_lakes_VertPt_lyr) #Need to have NHLD_LakeSet a "layer" rather than a .shp file in order for "Select by Location" to function
    L0 = """ arcpy.SelectLayerByAttribute_management(outfile_FF_lakes_VertPt_lyr, "NEW_SELECTION", """
    L1 = '"""'
    L2 = """ "Permanent_" in ('"""
    L3 = CurLake_str
    L4 = """ ' ) """
    L5 = '"""'
    L6 = """ ) """
    Select_CurLake_VertPt = L0+L1+L2+L3+L4+L5+L6
    Select_CurLake_VertPt_OneLine = """ arcpy.SelectLayerByAttribute_management(outfile_FF_lakes_VertPt_lyr, "NEW_SELECTION", """ + '"""' + """ "Permanent_" in ('""" + CurLake_str + """ ' ) """ + '"""' + """ ) """
    eval(Select_CurLake_VertPt)
    print("Select_CurLake_VertPt Evaluated")

    print("Time Begin Vetices Find")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'
    fc = outfile_FF_lakes_VertPt_lyr #once attributes are selected, search sursor will only work on selected
    cursor = arcpy.SearchCursor(fc)
    LSS_Vert_X = [] #Creates empty list
    LSS_Vert_Y = []
    for row in cursor:
        LSS_Vert_X.append(row.getValue('POINT_X'))
        LSS_Vert_Y.append(row.getValue('POINT_Y'))

    #Change last vertex just slightly so not exact same coord as first vertex
    LSS_Vert_X[-1] = LSS_Vert_X[-1]+0.000001
    LSS_Vert_Y[-1] = LSS_Vert_Y[-1]+0.000001

    del row
    del cursor
    del fc

    print("Time End Vetices Find")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'

    #----------------------------------------------------------------------
    #Back to creating XML file:

    print("Time Begin XML Writing")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'

    LSS = ET.SubElement(root,"LinesinkString")

    # add Linesink children:
    Label = ET.SubElement(LSS, "Label")
    Label.text = LSS_Permanent

    HeadSpecified = ET.SubElement(LSS, "HeadSpecified")
    HeadSpecified.text = "1"

    StartingHead = ET.SubElement(LSS, "StartingHead")
    StartingHead.text = str(LSS_ElevMean)

    EndingHead = ET.SubElement(LSS, "EndingHead")
    EndingHead.text = str(LSS_ElevMean)

    Resistance = ET.SubElement(LSS, "Resistance")
    Resistance.text = "0"

    Width = ET.SubElement(LSS, "Width")
    #Width.text = str(float(LSS_Width))
    Width.text = "0"

    Depth = ET.SubElement(LSS, "Depth")
    #Depth.text = str(float(LSS_Depth))
    Depth.text = "0"

    Routing = ET.SubElement(LSS, "Routing")
    Routing.text = "0"

    EndStream = ET.SubElement(LSS, "EndStream")
    EndStream.text = "0"

    OverlandFlow = ET.SubElement(LSS, "OverlandFlow")
    OverlandFlow.text = "0"

    EndInflow = ET.SubElement(LSS, "EndInflow")
    EndInflow.text = "0"

    ScenResistance = ET.SubElement(LSS, "ScenResistance")
    ScenResistance.text = "__NONE__"

    Drain = ET.SubElement(LSS, "Drain")
    Drain.text = "0"

    ScenFluxName = ET.SubElement(LSS, "ScenFluxName")
    ScenFluxName.text = "__NONE__"

    Gallery = ET.SubElement(LSS, "Gallery")
    Gallery.text = "0"

    TotalDischarge = ET.SubElement(LSS, "TotalDischarge")
    TotalDischarge.text = "0"

    InletStream = ET.SubElement(LSS, "InletStream")
    InletStream.text = "0"

    OutletStream = ET.SubElement(LSS, "OutletStream")
    OutletStream.text = "0"

    #Dummy name to be replaced if either "OutletStream" = 1 or "Lake" = 1
    OutletTable = ET.SubElement(LSS, "OutletTable")
    OutletTable.text = "Filename"

    Lake = ET.SubElement(LSS, "Lake")
    Lake.text = "0"

    Precipitation = ET.SubElement(LSS, "Precipitation")
    Precipitation.text = "0"

    Evapotranspiration = ET.SubElement(LSS, "Evapotranspiration")
    Evapotranspiration.text = "0"

    #Far-field Flag is set
    Farfield = ET.SubElement(LSS, "Farfield")
    Farfield.text = "1" #0 = NF, 1 = FF

    chkScenario = ET.SubElement(LSS, "chkScenario")
    chkScenario.text = "false"

    AutoSWIZC = ET.SubElement(LSS, "AutoSWIZC")
    AutoSWIZC.text = "2" #LS location: 0=unknown, 1=along centerline, 2=along boundary

    DefaultResistance = ET.SubElement(LSS, "DefaultResistance")
    DefaultResistance.text = "0"

    #Vertices
    Vertices = ET.SubElement(LSS, "Vertices")

    #for vert in range(len(LSS_Vert_X)-1): #Use to not include redundant vertex
    for vert in range(len(LSS_Vert_X)):

        Vertex = ET.SubElement(Vertices,"Vertex")
        X = ET.SubElement(Vertex,"X")
        X.text = str(LSS_Vert_X[vert])
        Y = ET.SubElement(Vertex,"Y")
        Y.text = str(LSS_Vert_Y[vert])

    print("Time End XML Writing")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'


#----------------------------------------------------------------------
#Output cleaned XML File

indent(root)
tree = ET.ElementTree(root)
tree.write(SaveName, xml_declaration=True, encoding='ISO-8859-1', method="xml")

#End Timing Code:
print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'

print('Complete FF lss xml create')

