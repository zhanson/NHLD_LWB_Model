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

############## Pretty Print


#----------------------------------------------------------------------
#Begin Create an example XML file


from xml.etree import ElementTree as ET
root = ET.Element("InhomogeneitiesFile")
root.set("version","1")
print root.tag
ComputationalUnits = ET.SubElement(root,"ComputationalUnits")
ComputationalUnits.text = "Meters"
BasemapUnits = ET.SubElement(root,"BasemapUnits")
BasemapUnits.text = "Meters"


#----------------------------------------------------------------------
#Within creating XML file, need to bring in linesink GIS data

#PNF Script
################################################################################
##BEGIN INPUT
################################################################################

infile = outfile_PNF_NF_lakes

################################################################################
##END INPUT
################################################################################

#SaveName
outfile_name = "HUC12_" + out_file + "_PNF_NF_lakes_NFsimp" + str(PNF_NF_res) + "_BuffIn" + str(BuffIn_val)
SaveName = outpath + outfile_name + ".inh.xml"
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
        INH_Permanent = row.getValue('Permanent_')
        print("Time End LSS Properties")
        print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'


    print("Time Begin Vetices Create")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'
    #Select CurLakeVert
    CurLake_str = str(INH_Permanent)
    outfile_PNF_NF_lakes_VertPt_lyr = outpath + out_file + "_PNF_NF_lakes_VertPt.lyr"
    arcpy.MakeFeatureLayer_management(outfile_PNF_NF_lakes_VertPt,outfile_PNF_NF_lakes_VertPt_lyr) #Need to have NHLD_LakeSet a "layer" rather than a .shp file in order for "Select by Location" to function
    L0 = """ arcpy.SelectLayerByAttribute_management(outfile_PNF_NF_lakes_VertPt_lyr, "NEW_SELECTION", """
    L1 = '"""'
    L2 = """ "Permanent_" in ('"""
    L3 = CurLake_str
    L4 = """ ' ) """
    L5 = '"""'
    L6 = """ ) """
    Select_CurLake_VertPt = L0+L1+L2+L3+L4+L5+L6
    Select_CurLake_VertPt_OneLine = """ arcpy.SelectLayerByAttribute_management(outfile_PNF_NF_lakes_VertPt_lyr, "NEW_SELECTION", """ + '"""' + """ "Permanent_" in ('""" + CurLake_str + """ ' ) """ + '"""' + """ ) """
    eval(Select_CurLake_VertPt)
    print("Select_CurLake_VertPt Evaluated")

    print("Time Begin Vetices Find")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'
    fc = outfile_PNF_NF_lakes_VertPt_lyr #once attributes are selected, search sursor will only work on selected
    cursor = arcpy.SearchCursor(fc)
    INH_Vert_X = [] #Creates empty list
    INH_Vert_Y = []
    for row in cursor:
        INH_Vert_X.append(row.getValue('POINT_X'))
        INH_Vert_Y.append(row.getValue('POINT_Y'))

##    #Change last vertex just slightly so not exact same coord as first vertex
##    INH_Vert_X[-1] = INH_Vert_X[-1]+0.000001
##    INH_Vert_Y[-1] = INH_Vert_Y[-1]+0.000001
    #Remove last vertex; GFLOW does not want closing vertex for INH
    del INH_Vert_X[-1]
    del INH_Vert_Y[-1]

    del row
    del cursor
    del fc

    print("Time End Vetices Find")
    print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'

    #----------------------------------------------------------------------
    #Back to creating XML file:

    INH = ET.SubElement(root,"Inhomogeneity")

    # add Linesink children:
    Label = ET.SubElement(INH, "Label")
    Label.text = INH_Permanent+"_HighK"

    HydK = ET.SubElement(INH, "HydCond")
    HydK.text = "100000"

    BotElev = ET.SubElement(INH, "BottomElevation")
    BotElev.text = "425"

    AvgHead = ET.SubElement(INH, "AverageHead")
    AvgHead.text = "925"

    Recharge = ET.SubElement(INH, "Recharge")
    Recharge.text = "0.000"

    Porosity = ET.SubElement(INH, "Porosity")
    Porosity.text = "0.29"

    Color = ET.SubElement(INH, "Color")
    Color.text = "0" #black

    ChangeK = ET.SubElement(INH, "ChangeK")
    ChangeK.text = "true"

    ChangeR = ET.SubElement(INH, "ChangeR")
    ChangeR.text = "false"

    ChangeP = ET.SubElement(INH, "ChangeP")
    ChangeP.text = "false"

    ChangeB = ET.SubElement(INH, "ChangeB")
    ChangeB.text = "false"

    ChangeA = ET.SubElement(INH, "ChangeA")
    ChangeA.text = "false"

    ScenHydCond = ET.SubElement(INH, "ScenHydCond")
    ScenHydCond.text = "__NONE__"

    ScenRecharge = ET.SubElement(INH, "ScenRecharge")
    ScenRecharge.text = "__NONE__"

    chkScenarioHydCond = ET.SubElement(INH, "chkScenarioHydCond")
    chkScenarioHydCond.text = "false"

    chkScenarioRecharge = ET.SubElement(INH, "chkScenarioRecharge")
    chkScenarioRecharge.text = "false"

    DefaultHydCond = ET.SubElement(INH, "DefaultHydCond")
    DefaultHydCond.text = "1"

    DefaultRecharge = ET.SubElement(INH, "DefaultRecharge")
    DefaultRecharge.text = "0"


    #Vertices
    Vertices = ET.SubElement(INH, "Vertices")

    #for vert in range(len(INH_Vert_X)-1): #Use to not include redundant vertex
    for vert in range(len(INH_Vert_X)):

        Vertex = ET.SubElement(Vertices,"Vertex")
        X = ET.SubElement(Vertex,"X")
        X.text = str(INH_Vert_X[vert])
        Y = ET.SubElement(Vertex,"Y")
        Y.text = str(INH_Vert_Y[vert])


#----------------------------------------------------------------------
#Output cleaned XML File

indent(root)
tree = ET.ElementTree(root)
tree.write(SaveName, xml_declaration=True, encoding='ISO-8859-1', method="xml")

#End Timing Code:
print(time.ctime()) # 'Mon Oct 18 13:35:29 2010'

print('Complete Lake INH xml create')