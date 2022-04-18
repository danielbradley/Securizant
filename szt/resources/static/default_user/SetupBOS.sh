#!/system/software/bin/bash

function main()
{
    cp GITConfig .gitconfig                                            &&
    mkdir -p     /local/bos                                            &&
    mount_local_bos                                                    &&
    rm    -rf /local/bos/checkouts                                     &&
    mkdir -p  /local/bos/checkouts                                     &&
    cd /local/bos/checkouts                                            &&
    git clone -b next https://github.com/danielbradley/BOS.git         &&
    git clone -b next https://github.com/danielbradley/Securizant.git  &&
    cd /local/bos/checkouts/BOS/bos                                    &&
    do_build $@                                                        &&
    echo "Done"
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

function do_build()
{
    if [ "$1" == "--build" ]
    then
        cd /local/bos/checkouts/BOS/bos/bin &&
        ./setup_szt                         &&
        ./bos_all /local/bos/checkouts/Securizant/szt/securizant.proj
    fi
}

main $@
