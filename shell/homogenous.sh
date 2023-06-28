#!/bin/bash
#PBS -l nodes=1:ppn=2
#PBS -N InterfModeling
#PBS -V

export PATH=/home/bharath/Documents/OpenSource-master/bin:$PATH

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

if [ -d "data/homogenous" ]; then
    echo "data/homogenous exists"
else
    mkdir "data/homogenous"
    echo "data/homogenous created"
fi

if [ -d "seismic_files" ]; then
    echo "seismic_files exists"
else
    mkdir "seismic_files"
    echo "seismic_files created"
fi

if [ -d "seismic_files/homogenous" ]; then
    echo "seismic_files/homogenous exists"
else
    mkdir "seismic_files/homogenous"
    echo "seismic_files/homogenous created"
fi

i=1
cs=800
cp=$(generateVp $cs)
ro0=$(generateDensity $cp)
thickness=10
sizez=150
noOfLayers=`expr $sizez / $thickness`
file_name="data/homogenous/`expr $i + 1`.csv"
echo "z,Vs,Vp,rho" > $file_name
for ((j=0;j<$noOfLayers;j++))
do
    echo "$thickness,$cs,$cp,$ro0" >> $file_name
done
echo "`expr $i + 1` file created"

if [ -d "seismic_files/homogenous/`expr $i + 1`" ]; then
    echo "seismic_files/homogenous/`expr $i + 1` exists"
else
    mkdir "seismic_files/homogenous/`expr $i + 1`"
    echo "seismic_files/homogenous/`expr $i + 1` created"
fi

folderLocation="seismic_files/homogenous/`expr $i + 1`"

makewave w=g2 nt=2000 verbose=1 fmin=0.5 fmax=10 fp=3 shift=1 dt=0.001771 file_out=G1.su
makemod sizex=4000 sizez=$sizez dx=5 dz=5 cp0=$cp cs0=$cs ro0=1037.6 file_base=$folderLocation/small_rec.su orig=0,0  \


xsrc1=0
xsrc2=4000
dxsrc=500

xsrc=$xsrc1
ishot=1


while (( xsrc <= xsrc2 ))
do
file_shot=shotRef_active_rec_x${xsrc}.su
image_file=image_x${xsrc}.eps
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
done