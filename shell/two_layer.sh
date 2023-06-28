#!/bin/bash
#PBS -l nodes=1:ppn=2
#PBS -N InterfModeling
#PBS -V
#


#export PATH=../../bin:$PATH
export PATH=/home/bharath/Documents/OpenSource-master/bin:$PATH
makewave w=g2 nt=2000 verbose=1 fmin=0.5 fmax=10 fp=3 shift=1 dt=0.001771 file_out=G1.su
#cp G1.su G1_c.su

# genrate vp from vs where vp = 1.29+1.11*vs
generateVp() {
    local vp=$(awk "BEGIN {printf \"%.0f\", 1.29 + 1.11 * $1}")
    echo $vp
}

# generate density from vp where density = 1.2475 + 0.399 * vp - 0.026 * vp * vp
generateDensity () {
    density=$(awk "BEGIN {print 1.2475 + 0.399 * (1.29 + 1.11 * $1) / 1000 - 0.026 * (1.29 + 1.11 * $1) * (1.29 + 1.11 * $1) / 1000000}")
    echo $density
}

if [ -d "data" ]; then
    echo "data exists"
else
    mkdir "data"
    echo "data created"
fi

if [ -d "data/two_layer" ]; then
    echo "data/two_layer exists"
else
    mkdir "data/two_layer"
    echo "data/two_layer created"
fi

if [ -d "seismic_files" ]; then
    echo "seismic_files exists"
else
    mkdir "seismic_files"
    echo "seismic_files created"
fi


if [ -d "seismic_files/two_layer" ]; then
    echo "seismic_files/two_layer exists"
else
    mkdir "seismic_files/two_layer"
    echo "seismic_files/two_layer created"
fi

i=2
cs2=400
cp2=$(generateVp $cs2)
ro02=$(generateDensity $cp2)
cs1=800
cp1=$(generateVp $cs1)
ro01=$(generateDensity $cp1)
thickness=5
sizez=150
noOfLayers=`expr $sizez / $thickness`
z=40
file_name="data/two_layer/`expr $i + 1`.csv"
echo "z,Vs,Vp,rho" > $file_name
currentDepth=0
for ((j=0;j<$noOfLayers;j++))
do
    currentDepth=`expr $currentDepth + $thickness`
    if [ $currentDepth -lt $z ]
    then
        echo "$thickness,$cs1,$cp1,$ro01" >> $file_name
    else
        echo "$thickness,$cs2,$cp2,$ro02" >> $file_name
    fi
done
echo "`expr $i + 1` file created"

if [ -d "seismic_files/two_layer/`expr $i + 1`" ]; then
    echo "seismic_files/two_layer/`expr $i + 1` exists"
else
    mkdir "seismic_files/two_layer/`expr $i + 1`"
    echo "seismic_files/two_layer/`expr $i + 1` created"
fi

folderLocation="seismic_files/two_layer/`expr $i + 1`"
makemod sizex=4000 sizez=$sizez dx=5 dz=5 cp0=$cp1 cs0=$cs1 ro0=$ro01 file_base=$folderLocation/small_rec.su orig=0,0
intt=def poly=0 x=0,1000,2000,4000 z=$z,$z,$z,$z cp=$cp2 cs=$cs2 ro=$ro02

xsrc1=0
xsrc2=4000
dxsrc=10

xsrc=$xsrc1
ishot=1


while (( xsrc <= xsrc2 ))
do
file_shot=shotRef_active_rec_x${xsrc}.su
echo $file_shot
echo ' modeling shot at x=' $xsrc

/home/bharath/Documents/OpenSource-master/fdelmodc/fdelmodc \
    file_cp=$folderLocation/small_rec_cp.su ischeme=3 \
    file_cs=$folderLocation/small_rec_cs.su ischeme=3 \
    file_den=$folderLocation/small_rec_ro.su \
    file_src=G1.su \
    fmax=10\
    top=1\
    file_rcv=$folderLocation/$file_shot \
    src_type=7 \
    verbose=1 \
    xrcv1=0. \
    xrcv2=4000. \
    zrcv1=0. \
    zrcv2=0. \
    dxrcv=20 \
    dtrcv=0.001771\
    rec_type_vz=1 \
    xsrc=$xsrc\
    verbose=4


(( ishot = $xsrc / $dxsrc ))
echo ishot=$ishot
(( xsrc = $xsrc + $dxsrc))

done
verbose=4