#!/system/software/bin/bash

REFORMAT="false"
DEVICE="false"
RECHECKOUT="false"
BUILD="false"

function main()
{
    process_args $@                                                    &&
    init                                                               &&
    reformat_local_bos                                                 &&
    mount_local_bos                                                    &&
    recheckout                                                         &&
    do_build                                                           &&
    echo "Done"
}

function process_args()
{
    function usage()
    {
        echo "Usage: SetupBOS.sh [--reformat <device>] [--recheckout] [--build]"
        exit -1
    }

    if [ -z "$1" ]
    then
        usage

    else
        while [ -n "$1" ]
        do
            case "$1" in
                "--reformat")
                    REFORMAT="true"; shift
                    if [ -b "$1" ]
                    then
                        DEVICE="$1"; shift
                    else
                        echo "Invalid device to reformat: $1"
                        usage
                    fi
                    ;;
                "--recheckout")
                    RECHECKOUT="true"; shift
                    ;;

                "--build")
                    BUILD="true"; shift
                    ;;
                *)
                    echo "Invalid argument: $1"
                    usage
                    ;;
            esac
        done
    fi
}

function init()
{
    cp       GITConfig .gitconfig                                      &&
    mkdir -p /local/bos
}

function reformat_local_bos()
{
    function purge_device()
    {
        local result=`grep "$1" /system/processes/mounts`

        if [ "" != "$result" ]
        then
            if [ -d "/local/bos/checkouts/BOS/bos/bin" ]
            then
                /local/bos/checkouts/BOS/bos/bin/unmount /sfs/bos/Securizant* &&
                /local/bos/checkouts/BOS/bos/bin/loclean
            fi &&
            umount "$DEVICE"
        fi
    }

    if [ "true" == "$REFORMAT" ]
    then
        if [ -b "$DEVICE" ]
        then
            local label=`e2label $DEVICE`                              &&

            if [ "BOS" == "$label" ]
            then
                purge_device  "$DEVICE"                                &&
                mke2fs -L BOS "$DEVICE"                                &&
                return 0
            else
                echo "Invalid label ($label) for device ($DEVICE)"     &&
                return -1
            fi
        else
            echo "Invalid device to reformat: $DEVICE"
            return -1
        fi
    fi
}

function mount_local_bos()
{
    local result=`grep "/local/bos" /system/processes/mounts`

    if [ "" != "$result" ]
    then
        return 0;

    else
        mount -L BOS /local/bos
        return $?
    fi
}

function recheckout()
{
    if [ "true" == "$RECHECKOUT" ]
    then
        rm    -rf /local/bos/checkouts                                     &&
        mkdir -p  /local/bos/checkouts                                     &&
        cd /local/bos/checkouts                                            &&
        git clone -b next https://github.com/danielbradley/BOS.git         &&
        git clone -b next https://github.com/danielbradley/Securizant.git
    fi
}

function do_build()
{
    if [ "true" == "$BUILD" ]
    then
        if [ ! -d "/local/bos/checkouts/BOS" -o ! -d "/local/bos/checkouts/Securizant" ]
        then
            echo "Aborting: no checkout, use '--recheckout' option to checkout."
            return -1
        else
            cd /local/bos/checkouts/BOS/bos/bin &&
            ./setup_szt                         &&
            ./bos_all /local/bos/checkouts/Securizant/szt/securizant.proj
        fi
    fi
}

main $@
