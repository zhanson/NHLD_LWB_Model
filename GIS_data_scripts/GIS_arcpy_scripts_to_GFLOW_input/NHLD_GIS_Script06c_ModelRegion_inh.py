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


#INH Script
################################################################################
##BEGIN INPUT
################################################################################

infile = out_file_HUC12_7kmBuff_MBG_VertPt

################################################################################
##END INPUT
################################################################################

#SaveName
outfile_name = "HUC12_" + out_file
SaveName = outpath + outfile_name + ".inh.xml"
print(SaveName)

fc = infile
cursor = arcpy.SearchCursor(fc)
INH_Vert_X = [] #Creates empty list
INH_Vert_Y = []
for row in cursor:
    INH_Permanent = row.getValue('HUC12')
    INH_Vert_X.append(row.getValue('POINT_X'))
    INH_Vert_Y.append(row.getValue('POINT_Y'))

#Change last vertex just slightly so not exact same coord as first vertex
##INH_Vert_X[-1] = INH_Vert_X[-1]+50#+0.000005
##INH_Vert_Y[-1] = INH_Vert_Y[-1]+50#+0.000005
#Remove last vertex; GFLOW does not want closing vertex for INH
del INH_Vert_X[-1]
del INH_Vert_Y[-1]

del row
del cursor
del fc

#----------------------------------------------------------------------
#Back to creating XML file:

INH = ET.SubElement(root,"Inhomogeneity")

# add Linesink children:
Label = ET.SubElement(INH, "Label")
Label.text = INH_Permanent+"Rech"

HydK = ET.SubElement(INH, "HydCond")
HydK.text = "1"

BotElev = ET.SubElement(INH, "BottomElevation")
#StartingHead.text = str(float(INH_ElevMean))
#BotElev.text = str(INH_ElevMean)
BotElev.text = "425"

AvgHead = ET.SubElement(INH, "AverageHead")
#EndingHead.text = str(float(INH_ElevMean))
AvgHead.text = "925"

Recharge = ET.SubElement(INH, "Recharge")
Recharge.text = "0.000"

Porosity = ET.SubElement(INH, "Porosity")
Porosity.text = "0.29"

Color = ET.SubElement(INH, "Color")
Color.text = "0" #black

ChangeK = ET.SubElement(INH, "ChangeK")
ChangeK.text = "false"

ChangeR = ET.SubElement(INH, "ChangeR")
ChangeR.text = "true"

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

print('Complete INH xml create')