#!/bin/bash
for ((K=2;K<=108;K+=2))
do
    F="108-${K}"
    echo -n "RANK=${K},"
    ../ttol.exe ${F} 108 1D0
    unset F
done
unset K
