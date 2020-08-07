#!/bin/bash

########## VARIABLES ############################################

CHMOUNTHL=$HOME/charliecloud/bin/ch-mounthl
CHMOUNTLL=$HOME/charliecloud/bin/ch-mount
CHUMOUNT=$HOME/charliecloud/bin/ch-umount
CHRUN=$HOME/charliecloud/bin/ch-run
CHTAR2DIR=$HOME/charliecloud/bin/ch-tar2dir

SQFS=$HOME/chorkshop/hello.sqfs
TAR=$HOME/hello.tar.gz
PROG=/bin/true
EX=ex03
TRIALS=15
T=10
NAME=$(basename "$SQFS" | (IFS='.' read n a && echo $n))

########## PROCESSING ##########################################


if [ $# -eq 0 ]; then
    echo "No arguments specified, moving forward with defauls.
            Identifier is ex02, Trials is 1000, sqfs = ~/chorkshop/hello.sqfs"
elif [ $# -ne 3 ]; then 
    echo "USAGE: ./ex02.sh <Identifier> <trial count> <sqfs>"
    echo "example: ./ex02.sh ex02 1000 ~/chorkshop/hello.sqfs"
    exit 1
else 
    EX=$1
    TRIALS=$2
    SQFS=$3
    NAME=$(basename "$SQFS" | (IFS='.' read n a && echo $n))
    echo "defaults have been updated: Identifier is now "$EX", trials is now "$TRIALS",
    sqfs is now "$SQFS""
fi

################################################################
# Full workflow(ex02-E2E.csv)                                  #
################################################################


#create schema
printf "TRIAL, RUN_COUNT, S_SFSH, E_SFSH, S_SFSL, E_SFSL,S_PSFSH, E_PSFSH\n" > "$EX"-E2E.csv

for k in $(seq "$T")
do
#1000 trials
for i in $(seq "$TRIALS")
do
    
    #Suggested SquashfS High Level Workflow
    S_SFSH=$(date '+%s.%N')
    $CHMOUNTHL $SQFS /var/tmp 
    for j in $(seq "$i")
    do
        $CHRUN /var/tmp/$NAME -- $PROG
    done  
    $CHUMOUNT /var/tmp/$NAME
    E_SFSH=$(date '+%s.%N')

    #Suggested SquashFS Low Level Workflow
    S_SFSL=$(date '+%s.%N')
    $CHMOUNTLL $SQFS /var/tmp
    for j in $(seq "$i")
    do
        $CHRUN /var/tmp/$NAME -- $PROG
    done
    $CHUMOUNT /var/tmp/$NAME
    E_SFSL=$(date '+%s.%N')

    #Proposed SquashFS High Level Workflow
    S_PSFSH=$(date '+%s.%N')
    for j in $(seq "$i")
    do
        $CHRUN $SQFS -- $PROG
    done
    E_PSFSH=$(date '+%s.%N')

    printf "$k, $i, $S_SFSH,$E_SFSH,$S_SFSL,$E_SFSL,$S_PSFSH,$E_PSFSH\n" >> "$EX"-E2E.csv

done
done
