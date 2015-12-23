#!/bin/bash
# Script based on freevps bench.sh, dacentec bench.sh, Rafa3d's vhminfo.sh, blackdotsh's speedtest.sh, hidden refuge's bench.sh and Sayem Chowdhury's bench.sh
# This script was put together in the hope that you would find it useful.
# Rafa3d's, blackdotsh's and hidden refuge's scripts are licensed under GPLv2 and GPLv3 so this script goes under a GPLv3 license.
# Use at your own risk. will not be liable for data loss, damages, loss of profits or any other kind of loss while using or misusing this script.
clear
sleep 2
cpu=$( awk -F: '/model name/ {name=$2} END {print name}' /proc/cpuinfo )
cores=$( awk -F: '/model name/ {core++} END {print core}' /proc/cpuinfo )
corescache=$( awk -F: '/cache size/ {cache=$2} END {print cache}' /proc/cpuinfo )
freq=$( awk -F: ' /cpu MHz/ {freq=$2} END {print freq}' /proc/cpuinfo )
tram=$( free -m | grep Mem | awk 'NR==1 {print $2}' )
fram=$( free -m | grep Mem | awk 'NR==1 {print $4}' )
tswap=$( free -m | grep Swap | awk 'NR==1 {print $2}' )
fswap=$( free -m | grep Swap | awk 'NR==1 {print $4}' )
up=$(uptime|awk '{ $1=$2=$(NF-6)=$(NF-5)=$(NF-4)=$(NF-3)=$(NF-2)=$(NF-1)=$NF=""; print }' )
hostname=$( uname -n )
os=$( cat /etc/issue.net | awk 'NR==1 {print}' )
kernel=$( uname -r )
arch=$( uname -m )
lbit=$( getconf LONG_BIT )
printf "\n\n"
printf "This is just a basic benchmark script\n"
printf "This script will output info about your system\n"
printf "It will give you CPU, RAM, MB, SSD/HDD, Device info\n"
printf "It will do a CPU test\n"
printf "It will do a disk I/O test\n"
printf "It will do some network download tests using a quite big list of speedtest sites\n"
printf "Script is based on (code used from) freevps bench, dacentec bench, Rafa3d vhminfo, blackdotsh's speedtest, hidden refuge's bench and Sayem Chowdhury's bench\n"
printf "Credits goes out to the original authors.\n"
printf "Script uses sleep and clear, some may say it uses them both too much\n"
printf "After tests are done it will show them as a final result\n"
sleep 5
printf ".\n"
sleep 5
printf "..\n"
sleep 4
printf "...\n"
sleep 3
printf "....\n"
sleep 2
printf ".....\n"
sleep 1
clear
printf "\n\nCollecting some system information...\n"
printf "Running one CPU Test\n"
printf "Processing...\n"
cputest=$( ( time echo "scale=5000; 4*a(1)" | bc -lq) 2>&1 | grep real |  cut -f2 )
printf "\nDisk I/O Test\n"
printf "Running three I/O tests\n"
printf "Writing data to disk...\n"
io=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' )
io2=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' )
io3=$( ( dd if=/dev/zero of=test_$$ bs=64k count=16k conv=fdatasync && rm -f test_$$ ) 2>&1 | awk -F, '{io=$NF} END { print io}' )
ioraw=$( echo $io | awk 'NR==1 {print $1}' )
ioraw2=$( echo $io2 | awk 'NR==1 {print $1}' )
ioraw3=$( echo $io3 | awk 'NR==1 {print $1}' )
ioall=$( awk 'BEGIN{print '$ioraw' + '$ioraw2' + '$ioraw3'}' )
ioavg=$( awk 'BEGIN{print '$ioall'/3}' )
printf "\n\n"
printf "Hostname: $hostname\n"
printf "System uptime: $up\n"
printf "CPU model: $cpu\n"
printf "Number of CPU cores: $cores\n"
printf "CPU cache: $corescache\n"
printf "CPU frequency: $freq MHz\n"
printf "Total amount of RAM: $tram MB Free: $fram MB\n"
printf "Total amount of swap: $tswap MB Free: $fswap MB\n"
printf "Operation System: $os\n"
printf "32/64-Bits: $arch ($lbit Bit)\n"
printf "Kernel: $kernel\n\n"
sleep 10
printf "Listing Memory Modules \n"
memory=$( dmidecode --type 17 | grep -i "size\|locator\|type:\|speed\|manufacturer\|serial\|asset\|part" | sed 's/Size/\n &/g' )
printf "$memory"
sleep 10
printf "\nListing HAL Info \n"
if which hal-find-by-property >/dev/null; then
udi=$(hal-find-by-property --key info.product --string Computer)
mobomfg=$(hal-get-property --udi $udi --key system.board.vendor 2>/dev/null)
if [ -z "$mobomfg" ]; then
printf "Motherboard Manufacturer: $mobomfg\n"
fi
mobomodel=$(hal-get-property --udi $udi --key system.board.product 2>/dev/null)
if [ -z "$mobomodel" ]; then
printf "Model: $mobomodel\n"
fi
moboversion=$(hal-get-property --udi $udi --key system.board.version 2>/dev/null)
if [ -z "$moboversion" ]; then
printf "Version: $moboversion\n"
fi
moboserial=$(hal-get-property --udi $udi --key system.board.serial 2>/dev/null)
if [ -z "$moboserial" ]; then
printf "Serial No.: $moboserial\n"
fi
moborelease=$(hal-get-property --udi $udi --key system.firmware.release_date 2>/dev/null)
if [ -z "$moborelease" ]; then
printf "Release Date: $moborelease\n"
fi
mobofirmware=$(hal-get-property --udi $udi --key system.firmware.version 2>/dev/null)
if [ -z "$mobofirmware" ]; then
printf "Bios Version: $mobofirmware\n"
fi
mobouuid=$(hal-get-property --udi $udi --key system.hardware.uuid 2>/dev/null)
if [ -z "$mobouuid" ]; then
printf "Motherboard UUID: $mobouuid\n"
fi
sleep 5
printf "\n\nDisk Listing\n"
 printf "VENDOR  -   MODEL   -    DEVICE  -   MOUNT  -   LABEL  -    SIZE \n"
for udi in $(/usr/bin/hal-find-by-capability --capability storage)
do
        unset vendor
        unset model
        unset device
        unset mount
        unset label
        unset size
        device=$(hal-get-property --udi $udi --key block.device)
    vendor=$(hal-get-property --udi $udi --key storage.vendor)
    model=$(hal-get-property --udi $udi --key storage.model)
        parent_udi=$(hal-find-by-property --key block.storage_device --string $udi)
        mount=$(hal-get-property --udi $parent_udi --key volume.mount_point)
        label=$(hal-get-property --udi $parent_udi --key volume.label)
        media_size=$(hal-get-property --udi $udi --key storage.removable.media_size)
        size=$((media_size / 10**9))
if [ -z "$vendor" ]; then
    vendor="Vendor-N/A"
fi
if [ -z "$model" ]; then
    model="Model-N/A"
fi
if [ -z "$device" ]; then
    device="Device-N/A"
fi
if [ -z "$mount" ]; then
    mount="Mount-N/A"
fi
if [ -z "$label" ]; then
    label="Label-N/A"
fi
   printf "\n $vendor - $model - $device - $mount -  $label -  "${size}GB" \n"
done
sleep 5
printf "\n\nUSB Disks\n"
for udi in $(/usr/bin/hal-find-by-capability --capability storage)
do
device=$(hal-get-property --udi $udi --key block.device)
vendor=$(hal-get-property --udi $udi --key storage.vendor)
model=$(hal-get-property --udi $udi --key storage.model)
if [[ $(hal-get-property --udi $udi --key storage.bus) = "usb" ]]
then
parent_udi=$(hal-find-by-property --key block.storage_device --string $udi)
mount=$(hal-get-property --udi $parent_udi --key volume.mount_point)
label=$(hal-get-property --udi $parent_udi --key volume.label)
media_size=$(hal-get-property --udi $udi --key storage.removable.media_size)
size=$((media_size / 10**9))
printf "$vendor $model $device $mount $label "${size}GB" \n"
fi
done
sleep 5
printf "\n\nCDROM Drives\n"
for i in $(hal-find-by-property --key storage.drive_type --string cdrom)
do
printf "Manufacturer: $(hal-get-property --udi $i --key storage.vendor)\n"
printf "Model: $(hal-get-property --udi $i --key block.device)\n"
printf "Bus: $(hal-get-property --udi $i --key storage.model)\n"
printf "Path: $(hal-get-property --udi $i --key storage.bus)\n"
done
else
printf "\n\nLinux HAL not found, skipping advanced hardware detection \n\n"
fi
sleep 10
clear
sleep 2
printf "\n\n"
printf "Time taken to generate PI to 5000 decimal places with a single thread: $cputest\n"
printf "I/O speed #1: $io\n"
printf "I/O speed #2: $io2\n"
printf "I/O speed #3: $io3\n"
printf "Average I/O speed: $ioavg MB/s\n"
printf "Network download tests\n"
printf "a 100MB file is downloaded (to /dev/null) from each location, some locations may be dual-stack (IPv4/IPv6) which means if your side (system) is dual-stack it might use IPv6 for the speedtest\n"
printf "Depending on your network connection this can take quite awhile!\n"
printf "Downloading files...\n\n"
cachefly=$( wget -O /dev/null http://cachefly.cachefly.net/100mb.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from CacheFly CDN: $cachefly "
internode=$( wget -O /dev/null http://speedcheck.cdn.on.net/100meg.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Internode CDN: $internode "
ransomitauck=$( wget -O /dev/null http://auckland-lg.ransomit.com.au/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Ransom IT, Auckland, New Zealand: $ransomitauck "
prometeusind=$( wget -O /dev/null http://lg-pune.prometeus.net/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Prometeus, Pune, India: $prometeusind "
echo "-"
echo "Downloading from 3 Singapore sites"
echo "-"
linodesing=$( wget -O /dev/null http://speedtest.singapore.linode.com/100MB-singapore.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
leaseweb5=$( wget -O /dev/null http://mirror.sg.leaseweb.net/speedtest/100mb.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
slsg=$( wget -O /dev/null http://speedtest.sng01.softlayer.com/downloads/test100.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Linode, Singapore, Singapore: $linodesing "
echo "Download speed from Leaseweb, Singapore, Singapore: $leaseweb5 "
echo "Download speed from Softlayer, Singapore, Singapore: $slsg "
echo "-"
linodejp=$( wget -O /dev/null http://speedtest.tokyo.linode.com/100MB-tokyo.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Linode, Tokyo, Japan: $linodejp "
leaseweb6=$( wget -O /dev/null http://mirror.hk.leaseweb.net/speedtest/100mb.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Leaseweb, Hongkong, Hongkong: $leaseweb6 "
echo "-"
echo "Downloading from 3 London, UK sites"
echo "-"
linodeuk=$( wget -O /dev/null http://speedtest.london.linode.com/100MB-london.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
edis99=$( wget -O /dev/null http://uk.edis.at/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
vultlon=$( wget -O /dev/null http://lon-gb-ping.vultr.com/vultr.com.100MB.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Linode, London, UK: $linodeuk "
echo "Download speed from Edis, London, UK: $edis99 "
echo "Download speed from Vultr, London, UK: $vultlon "
echo "-"
echo "Downloading from 4 Frankfurt, Germany sites"
echo "-"
linodefra=$( wget -O /dev/null http://speedtest.frankfurt.linode.com/100MB-frankfurt.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
leaseweb4=$( wget -O /dev/null http://mirror.de.leaseweb.net/speedtest/100mb.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
tele2fra=$( wget -O /dev/null http://fra36-speedtest-1.tele2.net/100MB.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
edis5=$( wget -O /dev/null http://de.edis.at/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Linode, Frankfurt, Germany: $linodefra "
echo "Download speed from Leaseweb, Frankfurt, Germany: $leaseweb4 "
echo "Download speed from Tele2, Frankfurt, Germany: $tele2fra "
echo "Download speed from Edis, Frankfurt, Germany: $edis5 "
echo "-"
hetzner=$( wget -O /dev/null http://speed.hetzner.de/100MB.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Hetzner, Nuernberg, Germany: $hetzner "
ransomitmel=$( wget -O /dev/null http://melbourne-lg.ransomit.com.au/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Ransom IT, Melbourne, Australia: $ransomitmel "
ransomitsyd=$( wget -O /dev/null http://sydney-lg.ransomit.com.au/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Ransom IT, Sydney, Australia: $ransomitsyd "
tele2sth=$( wget -O /dev/null http://kst5-speedtest-1.tele2.net/100MB.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Tele2, Stockholm, Sweden: $tele2sth "
edis88=$( wget -O /dev/null http://se.edis.at/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Edis, Stockholm, Sweden: $edis88 "
echo "-"
echo "Downloading from 4 Amsterdam, Netherlands sites"
echo "-"
slams=$( wget -O /dev/null http://speedtest.ams01.softlayer.com/downloads/test100.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
tele2ams=$( wget -O /dev/null http://ams-speedtest-1.tele2.net/100MB.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
edis44=$( wget -O /dev/null http://nl.edis.at/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
vultams=$( wget -O /dev/null http://ams-nl-ping.vultr.com/vultr.com.100MB.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Softlayer, Amsterdam, Netherlands: $slams "
echo "Download speed from Tele2, Amsterdam, Netherlands: $tele2ams "
echo "Download speed from Edis, Amsterdam, Netherlands: $edis44 "
echo "Download speed from Vultr, Amsterdam, Netherlands: $vultams "
echo "-"
i3d=$( wget -O /dev/null http://mirror.i3d.net/100mb.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from i3d.net, Rotterdam, Netherlands: $i3d "
leaseweb3=$( wget -O /dev/null http://mirror.nl.leaseweb.net/speedtest/100mb.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Leaseweb, Haarlem, Netherlands: $leaseweb3 "
ramnodenet=$( wget -O /dev/null http://lg.nl.ramnode.com/static/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Ramnode, Alblasserdam, Netherlands: $ramnodenet "
echo "-"
echo "Downloading from 4 Dallas, TX, USA sites"
echo "-"
linodedal=$( wget -O /dev/null http://speedtest.dallas.linode.com/100MB-dallas.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
sldltx=$( wget -O /dev/null http://speedtest.dal05.softlayer.com/downloads/test100.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
prometeusdal=$( wget -O /dev/null http://lg-dallas.prometeus.net/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
vultdal=$( wget -O /dev/null http://tx-us-ping.vultr.com/vultr.com.100MB.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Linode, Dallas, TX, USA: $linodedal "
echo "Download speed from Softlayer, Dallas, TX, USA: $sldltx "
echo "Download speed from Prometeus, Dallas, TX, USA: $prometeusdal "
echo "Download speed from Vultr, Dallas, TX, USA: $vultdal "
echo "-"
linodefre=$( wget -O /dev/null http://speedtest.fremont.linode.com/100MB-fremont.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Linode, Fremont, CA, USA: $linodefre "
slsjc=$( wget -O /dev/null http://speedtest.sjc01.softlayer.com/downloads/test100.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Softlayer, San Jose, CA, USA: $slsjc "
leaseweb2=$( wget -O /dev/null http://mirror.sfo12.us.leaseweb.net/speedtest/100mb.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Leaseweb, San Jose, CA, USA: $leaseweb2 "
ramnodelos=$( wget -O /dev/null http://lg.la.ramnode.com/static/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Ramnode, Los Angeles, CA, USA: $ramnodelos "
echo "-"
echo "Downloading from 3 Atlanta, GA, USA sites"
echo "-"
linodeatl=$( wget -O /dev/null http://speedtest.atlanta.linode.com/100MB-atlanta.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
ramnodeatl=$( wget -O /dev/null http://lg.atl.ramnode.com/static/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
coloatatl=$( wget -O /dev/null http://speed.atl.coloat.com/100mb.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Linode, Atlanta, GA, USA: $linodeatl "
echo "Download speed from Ramnode, Atlanta, GA, USA: $ramnodeatl "
echo "Download speed from Coloat, Atlanta, GA, USA: $coloatatl "
echo "-"
ramnodenew=$( wget -O /dev/null http://lg.nyc.ramnode.com/static/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Ramnode, New York, NY, USA: $ramnodenew "
slwdc=$( wget -O /dev/null http://speedtest.wdc01.softlayer.com/downloads/test100.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Softlayer, Washington DC, USA: $slwdc "
ldc=$( wget -O /dev/null http://mirror.dacentec.com/100MB.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Dacentec, Lenoir, NC, USA: $ldc "
leaseweb1=$( wget -O /dev/null http://mirror.wdc1.us.leaseweb.net/speedtest/100mb.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Leaseweb, Manassas, VA, USA: $leaseweb1 "
edis00=$( wget -O /dev/null http://us.edis.at/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Edis, Chicago, IL, USA: $edis00 "
slwa=$( wget -O /dev/null http://speedtest.sea01.softlayer.com/downloads/test100.zip 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Softlayer, Seattle, WA, USA: $slwa "
ramnodesea=$( wget -O /dev/null http://lg.sea.ramnode.com/static/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Ramnode, Seattle, WA, USA: $ramnodesea "
vultsea=$( wget -O /dev/null http://wa-us-ping.vultr.com/vultr.com.100MB.bin 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Vultr, Seattle, WA, USA: $vultsea "
prometeusmil=$( wget -O /dev/null http://lg-milano.prometeus.net/100MB.test  2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Prometeus, Milano, Italy: $prometeusmil "
edis33=$( wget -O /dev/null http://it.edis.at/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Edis, Milano, Italy: $edis33 "
edis8=$( wget -O /dev/null http://fr.edis.at/100MB.test 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from Edis, Paris, France: $edis8 "
ovhfra=$( wget -O /dev/null http://rbx.proof.ovh.net/files/100Mio.dat 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from OVH, Roubaix, France: $ovhfra "
ovhcan=$( wget -O /dev/null http://bhs.proof.ovh.net/files/100Mio.dat 2>&1 | awk '/\/dev\/null/ {speed=$3 $4} END {gsub(/\(|\)/,"",speed); print speed}' )
echo "Download speed from OVH, Beauharnois, Canada: $ovhcan "
echo "-"
sleep 10
clear
sleep 2
printf "\n\n"
printf "Hostname: $hostname\n"
printf "System uptime: $up\n"
printf "CPU model: $cpu\n"
printf "Number of CPU cores: $cores\n"
printf "CPU cache: $corescache\n"
printf "CPU frequency: $freq MHz\n"
printf "Total amount of RAM: $tram MB Free: $fram MB\n"
printf "Total amount of swap: $tswap MB Free: $fswap MB\n"
printf "Operation System: $os\n"
printf "32/64-Bits: $arch ($lbit Bit)\n"
printf "Kernel: $kernel\n"
echo "-"
printf "Time taken to generate PI to 5000 decimal places with a single thread: $cputest\n"
printf "I/O speed #1: $io\n"
printf "I/O speed #2: $io2\n"
printf "I/O speed #3: $io3\n"
printf "Average I/O speed: $ioavg MB/s\n\n"
echo "-"
echo "Download speed from Asia:"
echo "Linode, Singapore, Singapore: $linodesing "
echo "Leaseweb, Singapore, Singapore: $leaseweb5 "
echo "Softlayer, Singapore, Singapore: $slsg "
echo "Linode, Tokyo, Japan: $linodejp "
echo "Leaseweb, Hongkong, Hongkong: $leaseweb6 "
echo "Prometeus, Pune, India: $prometeusind "
echo "-"
echo "Download speed from Australasia:"
echo "Ransom IT, Auckland, New Zealand: $ransomitauck "
echo "Ransom IT, Melbourne, Australia: $ransomitmel "
echo "Ransom IT, Sydney, Australia: $ransomitsyd "
echo "-"
echo "Download speed from EU:"
echo "Prometeus, Milano, Italy: $prometeusmil "
echo "Edis, Milano, Italy: $edis33 "
echo "Edis, Paris, France: $edis8 "
echo "OVH, Roubaix, France: $ovhfra"
echo "Edis, London, UK: $edis99 "
echo "Linode, London, UK: $linodeuk "
echo "Vultr, London, UK: $vultlon "
echo "Edis, Frankfurt, Germany: $edis5 "
echo "Linode, Frankfurt, Germany: $linodefra "
echo "Tele2, Frankfurt, Germany: $tele2fra "
echo "Leaseweb, Frankfurt, Germany: $leaseweb4 "
echo "Hetzner, Nuernberg, Germany: $hetzner "
echo "Edis, Stockholm, Sweden: $edis88 "
echo "Tele2, Stockholm, Sweden: $tele2sth "
echo "Edis, Amsterdam, Netherlands: $edis44 "
echo "Tele2, Amsterdam, Netherlands: $tele2ams "
echo "Softlayer, Amsterdam, Netherlands: $slams "
echo "Vultr, Amsterdam, Netherlands: $vultams "
echo "i3d.net, Rotterdam, Netherlands: $i3d "
echo "Leaseweb, Haarlem, Netherlands: $leaseweb3 "
echo "Ramnode, Alblasserdam, Netherlands: $ramnodenet "
echo "-"
echo "Download speed from US:"
echo "Edis, Chicago, IL, USA: $edis00 "
echo "Ramnode, New York, NY, USA: $ramnodenew "
echo "Softlayer, Washington DC, USA: $slwdc "
echo "Dacentec, Lenoir, NC, USA: $ldc "
echo "Linode, Dallas, TX, USA: $linodedal "
echo "Softlayer, Dallas, TX, USA: $sldltx "
echo "Prometeus, Dallas, TX, USA: $prometeusdal "
echo "Vultr, Dallas, TX, USA: $vultdal "
echo "Linode, Fremont, CA, USA: $linodefre "
echo "Ramnode, Los Angeles, CA, USA: $ramnodelos "
echo "Softlayer, San Jose, CA, USA: $slsjc "
echo "Leaseweb, San Jose, CA, USA: $leaseweb2 "
echo "Coloat, Atlanta, GA, USA: $coloatatl "
echo "Linode, Atlanta, GA, USA: $linodeatl "
echo "Ramnode, Atlanta, GA, USA: $ramnodeatl "
echo "Leaseweb, Manassas, VA, USA: $leaseweb1 "
echo "Softlayer, Seattle, WA, USA: $slwa "
echo "Ramnode, Seattle, WA, USA: $ramnodesea "
echo "Vultr, Seattle, WA, USA: $vultsea "
echo "OVH, Beauharnois, Canada: $ovhcan "
echo "-"
echo "Download speed from CDN:"
echo "CacheFly CDN: $cachefly "
echo "Internode CDN: $internode "
echo "-"
