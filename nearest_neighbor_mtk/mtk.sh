#!/usr/bin/env bash
set -e
set -x

if [ $# -eq 0 ]; then
    echo 'Usage: mtk.sh <model file>'
    exit 1
fi

MODEL="$1"

echo "################"
echo "Starting with $MODEL"
echo "################"

OUT_DIR="$(dirname $MODEL)/mtk"
if [ -d "$OUT_DIR" ]; then
  rm -r "$OUT_DIR"
fi
mkdir --parents "$OUT_DIR"

MODEL_BASENAME="$(basename $MODEL)"

COM_MTK_HA="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_HA.com"
COM_MTK_OTHER="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_other.com"
COM_MTK_VRNPS="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_vRNPs.com"

MOD_HA="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_HA.mod"
MOD_OTHER="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_other.mod"
MOD_VRNPS="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_vRNPs.mod"

# Shifted model and comfiles
COM_SHIFT_MODEL="${OUT_DIR}/${MODEL_BASENAME%%.*}_shift.com"
MODEL_SHIFTED="${OUT_DIR}/${MODEL_BASENAME%%.*}_shifted.mod"

COM_MTK_HA_SHIFTED="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_HA_shifted.com"
COM_MTK_OTHER_SHIFTED="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_other_shifted.com"
COM_MTK_VRNPS_SHIFTED="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_vRNPs_shifted.com"

MOD_HA_SHIFTED="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_HA_shifted.mod"
MOD_OTHER_SHIFTED="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_other_shifted.mod"
MOD_VRNPS_SHIFTED="${OUT_DIR}/${MODEL_BASENAME%%.*}_mtk_vRNPs_shifted.mod"


function join_by { local IFS="$1"; shift; echo "$*"; } # https://stackoverflow.com/a/17841619
# Get vRNPs
mapfile -t VRNP_OBJECTS_ARR < <( imodinfo -h "$MODEL" | grep -B 1 '^NAME:  Viral Ribonucleoprotein' | grep OBJECT | cut -d ' ' -f 2)
echo "The model has ${#VRNP_OBJECTS[@]} vRNP objects:"
VRNP_OBJECTS=$(join_by ',' ${VRNP_OBJECTS_ARR[@]})
echo "${VRNP_OBJECTS}"

# Get HA membranes
mapfile -t HA_OBJECTS_ARR < <( imodinfo -h "$MODEL" | grep -B 1 '^NAME:  Hemagglutinin coated membrane' | grep OBJECT | cut -d ' ' -f 2)
echo "The model has ${#HA_OBJECTS[@]} HA membranes:"
HA_OBJECTS=$(join_by ',' ${HA_OBJECTS_ARR[@]})
echo "${HA_OBJECTS}"

# Get other membranes
mapfile -t MEM_OBJECTS_ARR < <( imodinfo -h "$MODEL" | grep -B 1 '^NAME:  Other membrane' | grep OBJECT | cut -d ' ' -f 2)
N_MEM_OBJECTS=${#MEM_OBJECTS_ARR[@]}
echo "The model has ${#MEM_OBJECTS[@]} other membranes:"
MEM_OBJECTS=$(join_by ',' ${MEM_OBJECTS_ARR[@]})
echo "${MEM_OBJECTS}"

function shiftcom() {
  # Usage: shiftcom <input model> <objects to shift> <output model>
  cat <<EOF
# First two lines are blank for keyboard input and no output file for density values
\$mtk


1          # Supress graphs
0          # For 3D density/closest approach analysis.... # line below = input file (******)
$1
# Two blank lines for empty tilt info and empty list of Z-values to connect surfaces


0,0        # Starting and ending Z (0,0 for all)
0.010,1000 # Bin width (radial distance), number of bins: 0.005 microns * 1000 = 5 microns limit
0          # To find closest approach.
2,0        # Good power for radial weighting, & number points to fit over.
1          # To find closest approach to segment.
1          # To measure from surface
1          # Number of different graphs to compute:
# Reference and neighbor objects
$2
$2
# Option 20: random shifts
20
0.01,1 # random shift in X/Y by 0.01 to 1 um
0.1 # Z factor
$2 # shift object

0 # number of probability curves to use for rejection of close spacings
0.01 # Maximum distance to shift outside bounding box of original data
0 # Object # of object with bounding contours, or 0 if none
1 # 1 to check shifted items against ones yet to be shifted, or 0 to check only against ones that have been shifted already
10 # max n of trials
10,1 # n of trials per cycle, factor to change maximum shift by per cycle
# Option 21: save current set of objects and their types as an IMOD model and don't copy analyzed contours
21
$3

# Exit
25
EOF
}

function mtkcom() {
  # Usage: mtkcom <input model> <reference objects> <neighbor objects> <output model>
  cat <<EOF
# First two lines are blank for keyboard input and no output file for density values
\$mtk


1          # Supress graphs
0          # For 3D density/closest approach analysis.... # line below = input file (******)
$1
# Two blank lines for empty tilt info and empty list of Z-values to connect surfaces


0,0        # Starting and ending Z (0,0 for all)
0.010,1000 # Bin width (radial distance), number of bins: 0.005 microns * 1000 = 5 microns limit
0          # To find closest approach.
2,0        # Good power for radial weighting, & number points to fit over.
1          # To find closest approach to segment.
1          # To measure from surface
1          # Number of different graphs to compute:
# Reference and neighbor objects
$2
$3
# Option 44: toggle between recording distances to all and nearest neighbors
44
# Option 17: Set min & max distances at which to compute angles and add lines to model.
17
0,5        # Min & max distance for adding connecting lines and computing angles (micron)
0.010,1000 # Bin width (radial distance), number of bins: 0.005 microns * 1000 = 5 microns limit
0          # Keep other parameters same as before.
0          # Keep same graph specifications same as before.
# Option 21: save current set of objects and their types as an IMOD model and don't copy analyzed contours
21
$4

# Exit
25
EOF
}

########################
# Create shifted model #
########################
shiftcom "$MODEL" "$VRNP_OBJECTS" "$MODEL_SHIFTED"> "$COM_SHIFT_MODEL"
submfg "$COM_SHIFT_MODEL"
echo ''

###################################
# MTK: vRNP-HA membrane distances #
###################################
mtkcom "$MODEL" "${VRNP_OBJECTS}" "${HA_OBJECTS}" "$MOD_HA" > "$COM_MTK_HA"
submfg "$COM_MTK_HA"
echo ''
# shifted
mtkcom "$MODEL_SHIFTED" "${VRNP_OBJECTS}" "${HA_OBJECTS}" "$MOD_HA_SHIFTED" > "$COM_MTK_HA_SHIFTED"
submfg "$COM_MTK_HA_SHIFTED"
echo ''

############################
# MTK: vRNP-vRNP distances #
############################
mtkcom "$MODEL" "${VRNP_OBJECTS}" "${VRNP_OBJECTS}" "$MOD_VRNPS" > "$COM_MTK_VRNPS"
submfg "$COM_MTK_VRNPS"
echo ''
# shifted
mtkcom "$MODEL_SHIFTED" "${VRNP_OBJECTS}" "${VRNP_OBJECTS}" "$MOD_VRNPS_SHIFTED" > "$COM_MTK_VRNPS_SHIFTED"
submfg "$COM_MTK_VRNPS_SHIFTED"
echo ''

######################################
# MTK: vRNP-other membrane distances #
######################################
if [ $N_MEM_OBJECTS -gt 0 ]; then
  mtkcom "$MODEL" "$VRNP_OBJECTS" "$MEM_OBJECTS" "$MOD_OTHER" > "$COM_MTK_OTHER"
	submfg "$COM_MTK_OTHER"
  echo ''
  # shifted
  mtkcom "$MODEL_SHIFTED" "$VRNP_OBJECTS" "$MEM_OBJECTS" "$MOD_OTHER_SHIFTED" > "$COM_MTK_OTHER_SHIFTED"
	submfg "$COM_MTK_OTHER_SHIFTED"
  echo ''
fi

##################################
# Convert MTK model to CSV table #
##################################
# MTK will create 2 objects per distance analysis and append them to the end of the model
# The first will be the connecting lines (this is what I'm interested in)
# The second are the midpoints on these lines
# For  now, I'm not looking at vRNP--other membrane distances, so I'm just exporting vRNP--vRNP and vRNP--HA distances
PYTHON_BIN='/opt/anaconda3/bin/python'
MTK_TO_CSV_SCRIPT="$(dirname $0)/mtk_to_csv.py"

# Get the newly created object number of the lines connecting the nearest neighbors
# The same for all created models, so I'll just fetch it for one of the created models
mapfile -t MTK_OBJECTS < <( imodinfo -h "$MOD_VRNPS" | grep -B 1 --no-group-separator '^NAME:  Wimp no. ' | grep OBJECT | cut -f 2 -d ' ')
MTK_OBJECT="${MTK_OBJECTS[-2]}"

eval "$PYTHON_BIN" "$MTK_TO_CSV_SCRIPT" "$MOD_HA" "$MOD_OTHER" "$MOD_VRNPS" "$MOD_HA_SHIFTED" "$MOD_OTHER_SHIFTED" "$MOD_VRNPS_SHIFTED"

echo "################"
echo "Done with $MODEL"
echo "################"
