#!/bin/bash

#constants
TEMP_DIR=tmp
BINARY_INPUT_DIR=input
RANKS_DIR=output

SUCCESS=0
FAILURE=1
EMPTY=2

STATE=$SUCCESS

##TRUESTART=$(gdate +%s.%N)
#Part 0. Preprocessing - convering text files to binary with sentinels
#need directory input to store binary files with sentinels
if [[ -d $BINARY_INPUT_DIR ]]
then
    rm -rf ${BINARY_INPUT_DIR}/*
else
    mkdir ${BINARY_INPUT_DIR}
fi

#convert text files to binary input
TOTALFILES=0

if [[ -d $1 ]]
then
    for FILE in $1/*
    do
        if [[ -f "$FILE" ]]
        then
            ./input_to_binary $FILE $BINARY_INPUT_DIR "${TOTALFILES}" 0
            echo "processed file $FILE with exit code $?"
            (( TOTALFILES++ ))
        fi
    done
else
    echo "No such directory $1"
    exit 1
fi

echo "Total $TOTALFILES files to process"

#prepare directory structure for processing
#need output dir
if [[ -d $RANKS_DIR ]]
then
    rm -rf ${RANKS_DIR}/*
else
    mkdir ${RANKS_DIR}
fi

#need tmp dir
if [[ -d $TEMP_DIR ]]
then
    rm -rf ${TEMP_DIR}/*
else
    mkdir ${TEMP_DIR}
fi

#Part 1. Count totals of characters in all input files
./count_characters ${BINARY_INPUT_DIR} $TOTALFILES ${TEMP_DIR}
STATUS=$?

if [[ $STATUS -ne $SUCCESS ]]
then
    exit 1
fi
echo "Finished counting characters"

#Part 2. Replace input file of characters with an array of initial ranks
#this array will be updated in each iteration of an algorithm
RANKS_ARRAY_FILE="${TEMP_DIR}/initial_ranks"

./init_ranks ${BINARY_INPUT_DIR} ${RANKS_DIR} $TOTALFILES ${RANKS_ARRAY_FILE}
STATUS=$?

if [[ $STATUS -ne $SUCCESS ]]
then
    exit 1
fi

echo "Init ranks completed"
echo

rm -rf ${BINARY_INPUT_DIR}/*

#set prefix length to 2^H
H=0

#Part 3. Perform O(log N) iterations of an algorithm
# main loop
MORE_RUNS=1

while (( $MORE_RUNS == 1 ))
do
    MORE_RUNS=0;
    ##START=$(gdate +%s.%N)
    #clean temp directory for the next iteration
    rm -rf ${TEMP_DIR}/*

    #generate sorted runs with counts and local rank pairs grouped by file_id and interval_id
    #valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes
    ./generate_local_runs ${RANKS_DIR} ${TEMP_DIR} $TOTALFILES $H
    STATUS=$?

    if [[ $STATUS -ne $EMPTY ]]
    then
        MORE_RUNS=1
    fi

    if [[ $STATUS -eq $FAILURE ]]
    then
        exit 1
    fi

    ##DUR=$(echo "$(gdate +%s.%N) - $START" | bc)
    ##printf "Generated local ranks for iteration %d in %.4f seconds\n" $H $DUR
    printf "Generated local ranks for iteration %d\n" $H

    #only if there are ranks to be resolved - continue
    if [[ $STATUS -ne $EMPTY ]]
    then
        ##START=$(gdate +%s.%N)
        #merge local ranks into global ranks - from all the chunks
        ./resolve_global_ranks ${TEMP_DIR}
        STATUS=$?

        if [[ $STATUS -eq $FAILURE ]]
        then
            exit 1
        fi

        ##DUR=$(echo "$(gdate +%s.%N) - $START" | bc)
        ##printf "Resolved global ranks for iteration %d in %.4f seconds\n" $H $DUR
        printf "Resolved global ranks for iteration %d\n" $H

        #at least something was resolved
        if [[ $STATUS -ne $EMPTY ]]
        then
            #update local ranks with resolved global ranks
            ##START=$(gdate +%s.%N)
            #valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes ./update_local_ranks ${RANKS_DIR} ${TEMP_DIR} $H
            ./update_local_ranks ${RANKS_DIR} ${TEMP_DIR} $H
            STATUS=$?

            if [[ $STATUS -eq $FAILURE ]]
            then
                exit 1
            fi
            ##DUR=$(echo "$(gdate +%s.%N) - $START" | bc)
            ##printf "Updated local ranks for iteration %d in %.4f seconds\n" $H $DUR
            printf "Updated local ranks for iteration %d\n" $H
        fi
    fi

    echo "Finished iteration $H"


    echo
    (( H++ ))
done
##DUR=$(echo "$(gdate +%s.%N) - $TRUESTART" | bc)
##printf "Total time: %.4f seconds\n" $DUR
printf "Finished"
exit 0
