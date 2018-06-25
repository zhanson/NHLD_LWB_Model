#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
# This script is used to modify original dataset to simplify, bufferin and generalize,
# allowing for comparison of Linesink properties legnth, number or vertices.
# These features can then be selected in a separate script and used for the
# creation of GFLOW input to look at the sensativity these properties have to
# groundwater solution/ lake discharges
#
# Author:      zhanson
#
# Created:     20/10/2016  (DD/MM/YYYY)
# Copyright:   (c) zhanson 2016
# Licence:     <your licence>
#-------------------------------------------------------------------------------

def main():
    pass

if __name__ == '__main__':
    main()

# Import arcpy module
import arcpy
arcpy.env.overwriteOutput=True
# Check out any necessary licenses
arcpy.CheckOutExtension("spatial")





#------------------------------------------------------------------------------>
#Input Data
#Only need to change THIS Section

print("Input Data Defined")
Loc = "G"
in_path = Loc+":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\NHLDandBuffLakes\\"
in_file_name = "NHLDandBuffLakes_ElevVal_ElmIslands_MBG"
##rast_inpath = Loc+":\\NHLD\\GIS_DATA\\NHLD_GIS_Data_FINAL\\NHLD_DEM\\"
##rast_in_file_name = "NHLD_DEMs_1_3_mosaic.img"

SimpTol = 1000 #m
BuffIn_Dist = -1 #m

BuffIn_Dist_str = BuffIn_Dist*-1
Gen_Tol = 1 #m
Gen_Tol_str = "1"

# Action 01:------------------------------------------------------------------->
#Simplyfy Lakes to reduce the number of vertices (tolerance = 100)
print("Process: SimplifyPolygon_cartography")


out_path = in_path
in_file_1 = in_file_name + ".shp"
out_file_name_1 = in_file_name + "_Simplify"+ str(SimpTol)
out_file_1 = out_file_name_1 + ".shp"
shapefile_in = in_path + in_file_1
shapefile_out = out_path + out_file_1
arcpy.SimplifyPolygon_cartography(shapefile_in,shapefile_out,"POINT_REMOVE",SimpTol,"1 SquareMeters","RESOLVE_ERRORS","NO_KEEP")


# Action 02:------------------------------------------------------------------->
#Remove Interior Lakes (must wait to remove interior lakes until after simplifiy because little lakes could be lost --> arg for why simp should be ~100 (1000 could loose too many little lakes)
print("Remove Interior Lakes")

out_path = in_path
in_file_name_2 =  out_file_name_1
in_file_2 = in_file_name_2 + ".shp"
out_file_name_2 = in_file_name_2 + "_RemoveIntLakes"
out_file_2 = out_file_name_2 + ".shp"
shapefile_in = in_path + in_file_2
shapefile_out = out_path + out_file_2

#Create two separate layers from the input shapefile, both have all lakes
layer01 = "layer01"
layer02 = "layer02"
arcpy.MakeFeatureLayer_management(shapefile_in,layer01)
arcpy.MakeFeatureLayer_management(shapefile_in,layer02)

#Smaller lakes that are completely within larger lakes will be selected
arcpy.SelectLayerByLocation_management(layer01, "COMPLETELY_WITHIN", layer02)
#Removes all the lakes that were within other lakes from the selection
arcpy.SelectLayerByAttribute_management(layer01, "SWITCH_SELECTION")
#check
print (arcpy.GetCount_management(layer02)) #Total number of lakes
print (arcpy.GetCount_management(layer01)) #Total number of lakes - lakes removed

#Copies out the selected lakes (that contained the smaller lakes);
#Essentially deletes out interior lakes
arcpy.CopyFeatures_management(layer01, out_path + out_file_2)

# Action 03:------------------------------------------------------------------->
# Process: Feature Vertices To Points
print("Process: FeatureVerticesToPoints_management")

out_path = in_path
in_file_name_3 =  out_file_name_2
in_file_3 = in_file_name_3 + ".shp"
out_file_name_3 = in_file_name_3 + "_VertPt"
out_file_3 = out_file_name_3+".shp"
shapefile_in = in_path + in_file_3
shapefile_out = out_path + out_file_3

# Process: Feature Vertices To Points
arcpy.FeatureVerticesToPoints_management(shapefile_in, shapefile_out, "ALL")

# Action 04:------------------------------------------------------------------->
# Process: Buffer
#Buff IN 1m (In order to reduce where edges are the exeact same location)
#linear -1m
#SideType: FULL
#Dissolve Type: List
#Select All
print("Process: Buffer_analysis")

out_path = in_path
in_file_name_4 =  out_file_name_2 #input = output from Remove Interior Lakes (02)
in_file_4 = in_file_name_4 + ".shp"
out_file_name_4 = in_file_name_4 + "_BuffIn_" + str(BuffIn_Dist_str) + "m"
out_file_4 = out_file_name_4 + ".shp"
shapefile_in = in_path + in_file_4
shapefile_out = out_path + out_file_4

#Buffinput = "-" + str(BuffIn_Dist) + " " + "Meters"
Buffinput = str(BuffIn_Dist) + " " + "Meters"

# Process: Buffer
arcpy.Buffer_analysis(shapefile_in, shapefile_out, Buffinput, "FULL", "ROUND", "NONE", "")

# Action 04a:------------------------------------------------------------------->
#Calc Simp Perim_m_simp, Area_m2_simp, Width_m_est
print("Process: Calc Simp Perim_m_simp, Area_m2_simp, Width_m_est")

#Add Field Perim_m_simp
# Process: Add Field
arcpy.AddField_management(shapefile_out, "Perim_m_S", "DOUBLE", "", "", "", "", "NULLABLE", "NON_REQUIRED", "")
#Calc Field Perim_m_simp
arcpy.CalculateField_management(shapefile_out, "Perim_m_S","!shape.geodesicLength@meters!","PYTHON_9.3")

#Add Field Area_m2_simp
arcpy.AddField_management(shapefile_out, "Area_m2_S", "DOUBLE", "", "", "", "", "NULLABLE", "NON_REQUIRED", "")
#Calc Field Area_m2_simp
arcpy.CalculateField_management(shapefile_out, "Area_m2_S","!shape.geodesicArea@squaremeters!","PYTHON_9.3")

#Add Field Width_m_est
arcpy.AddField_management(shapefile_out, "Width_m_S", "DOUBLE", "", "", "", "", "NULLABLE", "NON_REQUIRED", "")
#Calc Width_m_est
arcpy.CalculateField_management(shapefile_out, "Width_m_S", "( [Perim_m_S] /3.14)*( [Area_m2_S] /(( [Perim_m_S] ^2)/(4*3.14)))", "VB", "") #width_est = width(perim)*(Area/Area(perim)) #Using Area and perim of lake, makes to a circular lake and estimates the width


# Action 05:------------------------------------------------------------------->
# Process: Feature Vertices To Points
print("Process: FeatureVerticesToPoints_management")

out_path = in_path
in_file_name_5 =  out_file_name_4
in_file_5 = in_file_name_5 + ".shp"
out_file_name_5 = in_file_name_5 + "_VertPt"
out_file_5 = out_file_name_5 +".shp"
shapefile_in = in_path + in_file_5
shapefile_out = out_path + out_file_5

# Process: Feature Vertices To Points
arcpy.FeatureVerticesToPoints_management(shapefile_in, shapefile_out, "ALL")

# Action 06:------------------------------------------------------------------->
# Process: Copy Features
print("Process: CopyFeatures_management")

out_path = in_path
in_file_name_6 =  out_file_name_4 #input = output from Buffer (04)
in_file_6 = in_file_name_6 + ".shp"
out_file_name_6 = in_file_name_6 + "_GenTol_" + Gen_Tol_str + "m"
out_file_6 = out_file_name_6 + ".shp"
shapefile_in = in_path + in_file_6
shapefile_out = out_path + out_file_6

arcpy.CopyFeatures_management(shapefile_in, shapefile_out, "", "0", "0", "0")

# Action 07:------------------------------------------------------------------->
# Process: Generalize (In order to reduce vertices/elements)
#Tolerance 2.5m this reduces the vertices of concave polygon edges significantly
#BuffIn makes one vertex into many along a smooth line and this brings it back to 1 vertex
print("Process: Generalize_edit")

in_file_name_7 =  out_file_name_6
in_file_7 = in_file_name_7 + ".shp"
shapefile_in = in_path + in_file_7

# Process: Generalize
arcpy.Generalize_edit(shapefile_in, "2.5 Meters")


# Action 08:------------------------------------------------------------------->
# Process: Feature Vertices To Points
print("Process: FeatureVerticesToPoints_management")

out_path = in_path
in_file_8 = in_file_name_7 + ".shp" #07 did not have output, it edited out_file_name_6
out_file_name_8 = in_file_name_7 + "_VertPt"
out_file_8 = out_file_name_8 + ".shp"
shapefile_in = in_path + in_file_8
shapefile_out = out_path + out_file_8

# Process: Feature Vertices To Points
arcpy.FeatureVerticesToPoints_management(shapefile_in, shapefile_out, "ALL")

print("Process: AddXY_management")
# Process: AddXY_management (in_features)
arcpy.AddXY_management(shapefile_out)

#------------------------------------------------------------------------------>


print('Job Completed')