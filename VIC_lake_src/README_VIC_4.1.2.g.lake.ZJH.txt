The software provided here is licensed under the GNU General Public License v2.0, described in LICENSE_VIC_4.1.2.g.lake.ZJH.txt

The original 4.1.2.g VIC source code can be obtained at https://github.com/UW-Hydro/VIC
 
The modified source code that this code was derived from can be obtained from the directory within this repository containing the VIC_4.1.2.g.RCH modified source code. Changes were made to the VIC_4.1.2.g.RCH code in order to eliminate inflow, baseflow, and runoff betweeen the lake and single grid cell used.

These changes can be seen in "lakes.eb.c" on lines:"

1989 - 1991
2136 - 2146
2175 - 2196
