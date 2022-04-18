#!/system/software/bin/bash

cp GITConfig .gitconfig                                                       &&
mkdir -p     /local/bos                                                       &&
mount -L BOS /local/bos                                                       &&
rm    -rf    /local/bos/*                                                     &&
mkdir -p /local/bos/checkouts                                                 &&
cd /local/bos/checkouts                                                       &&
git clone https://github.com/danielbradley/BOS.git                            &&
git clone https://github.com/danielbradley/Securizant.git                     &&
cd /local/bos/checkouts/BOS/bos-6.1.1/bin                                     &&
./setup_szt                                                                   &&
./bos_all /local/bos/checkouts/Securizant/Securizant-lfs-2005/securizant.proj &&
echo "Done"
