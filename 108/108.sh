#!/bin/bash
E="../JACSD/tgenskew/dgenskew.exe"
for ((K=2;K<=108;K+=2))
do
	F="108-${K}"
	${E} ${F}.txt 1 108 ${K} ${F}
	unset F
done
unset E K
