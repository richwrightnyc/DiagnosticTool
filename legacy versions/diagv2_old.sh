#! /bin/bash

# run system_profiler in background
# json output was introduced in catalina, needs work for backwards compatibility 
~/Scripts/diag\ project/jsonProfiler.sh &

# WiFi Signal
# networksetup -setairportpower airport on
# networksetup -setairportnetwork en0 mssguest Wi117rJR
# networksetup -setairportnetwork en1 mssguest Wi117rJR


# Folder to save HDD's reports
# dont think we need this anymore; cleaner if the script only needs to create a single file
# that all child processes can write to
# mkdir ~/Desktop/.tmp




# KeyboardViewer
# open -a KeyboardViewer

# Textedit
# open -a Textedit

# Photo Booth
# open -a Photo\ Booth

# osascript -e 'tell app "System Events" to display dialog "Sound Test will now begin"'

# Set volume to 100
# osascript -e 'set volume output volume 100'

# Play Audio from Command Line in the Background
# afplay /Volumes/diag/audiotest.m4a &

# Malware Scan
# /Volumes/diag/DetectX\ Swift.app/Contents/MacOS/DetectX\ Swift search > ~/Desktop/.tmp/Malware.txt &

# The tech need save the Disk report
# osascript -e 'tell app "System Events" to display dialog "Save the DriveDX report in ~/Desktop/MSSHDD/"'

# grab serial number and send it to $serial
serial=$(system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $4}')
echo "Diagnostic Tool v2.0.4 -- The Mac Support Store" > ~/Desktop/$serial.txt

# Variable-ize relevant strings from sys prof to be called on below
modelName=$(system_profiler SPHardwareDataType | grep "Model Name" | awk '{print $3,$4,$5,$6}')
modelID=$(system_profiler SPHardwareDataType | grep "Model Identifier" | awk '{print $3}')

# macOS version and build number
softwareVersion=$(system_profiler SPSoftwareDataType | grep "System Version" | awk '{print $3,$4,$5}')

# chipset information
procName=$(sysctl machdep.cpu.brand_string | awk '{print $2,$3,$4}')
procSpeed=$(system_profiler SPHardwareDataType | grep "Processor Speed" | awk '{print $3,$4,$5,$6,$7}')
procNumber=$(system_profiler SPHardwareDataType | grep "Number of Processors" | awk '{print $4}')
procCores=$(system_profiler SPHardwareDataType | grep "Total Number of Cores" | awk '{print $5}')
procThread=$(system_profiler SPHardwareDataType | grep "Hyper-Threading" | awk '{print $3}')
bootRom=$(system_profiler SPHardwareDataType | grep "Boot ROM" | awk '{print $4,$5,$6,$7}')
csrutilStatus=$(csrutil status)

# memory information
ramMan=$(system_profiler SPMemoryDataType | grep -A 10 "Memory" | grep "Manufacturer" | awk '{print $2,$3,$4,$5}')
ramType=$(system_profiler SPMemoryDataType | grep -A 10 "Memory" | grep "Type" | awk '{print $2}')
ramSize=$(system_profiler SPHardwareDataType | grep "Memory" | awk '{print $2,$3}')
ramECC=$(system_profiler SPMemoryDataType | grep "ECC" | awk '{print $2}')
ramSpeed=$(system_profiler SPMemoryDataType | grep -A 10 "Memory" | grep "Speed" | awk '{print $2,$3}')
swapUsed=$(sysctl vm.swapusage | awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}')


# graphics data, focused only on discreet gpu if
graphics=$(system_profiler SPDisplaysDataType | tail -20 | grep "Chipset Model" | awk '{print $3,$4,$5,$6}')
# for integrated graphics, use SPDisplaysDataType | tail -20 | grep "Chipset Model" | awk '{print $3,$4,$5,$6}'
# but will end up duplicating gpu info on machines w only integrated
# need to work more on this
vram=$(system_profiler SPDisplaysDataType | tail -20 | grep "VRAM" | awk '{print $3,$4}')
dispType=$(system_profiler SPDisplaysDataType | grep "Display Type" | awk '{print $3,$4,$5}')
dispRes=$(system_profiler SPDisplaysDataType | grep "Resolution" | awk '{print $2,$3,$4,$5}')

# disk info
diskType=$(system_profiler SPStorageDataType | head -20 | grep "Medium Type" | awk '{print $3}')
diskCapacity=$(system_profiler SPStorageDataType | head -6 | grep Capacity | awk '{print $2, $3}')
diskAvailable=$(system_profiler SPStorageDataType | head -5 | grep Free | awk '{print $2, $3}')
diskHealth=$(smartctl --health disk0 | grep "SMART overall-health self-assessment")
diskFS=$(diskutil list disk0 | grep disk0s2 | awk '{print $2}')


# battery info
batteryInstalled=$(system_profiler SPPowerDataType | grep "Battery Installed" | awk '{print $3}')
batteryCycles=$(system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}')
batteryCondition=$(system_profiler SPPowerDataType | grep "Condition" | awk '{print $2,$3}')
batteryCapacity=$(system_profiler SPPowerDataType | grep "Full Charge Capacity (mAh)" | awk '{print $5}')
batteryCharge=$(system_profiler SPPowerDataType | grep "Charge Remaining (mAh)" | awk '{print $4}')
batteryAmp=$(system_profiler SPPowerDataType | grep "Amperage (mA):" | awk '{print $3}')
batteryVolt=$(system_profiler SPPowerDataType | grep "Voltage (mV)" | awk '{print $3}')

# ac power info
restartOnLoss=$(system_profiler SPPowerDataType | grep "Automatic Restart on Power Loss:" | awk '{print $1,$2,$3,$4,$5,$6}')
wakeOnLAN=$(system_profiler SPPowerDataType | grep "Wake on LAN:" | awk '{print $4}')
gpuSwitch=$(system_profiler SPPowerDataType | grep -A 18 "AC Power" | grep "GPUSwitch" | awk '{print $2}')
ups=$(system_profiler SPPowerDataType | grep "UPS Installed:" | awk '{print $3}')

# airport info
intName=$(system_profiler SPNetworkDataType | head -25 | grep "ConfirmedInterfaceName" | awk '{print $2}')
intType=$(system_profiler SPNetworkLocationDataType | head -15 | grep "Type" | awk '{print $2}')
ipAddr=$(system_profiler SPNetworkDataType | head -20 | grep "IPv4 Addresses" | awk '{print $3}')
ipv4ConfigType=$(system_profiler SPNetworkDataType | head -30 | grep -A 10 "IPv6" | grep "Configuration Method" | awk '{print $3}')
wifiMacAddr=$(system_profiler SPNetworkDataType | head -20 | grep "ARPResolvedHardwareAddress" | awk '{print $2}')
ipv6ConfigType=$(system_profiler SPNetworkDataType | head -30 | grep -A 1 "IPv6" | grep "Configuration" | awk '{print $3}')

# signal sample
# signal1=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep agrCtlRSSI | awk '{print $2}')
# signal2=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep agrExtRSSI | awk '{print $2}')
# signal3=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep agrCtlNoise | awk '{print $2}')
# signal4=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep agrExtNoise | awk '{print $2}')
# signal5=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep state | awk '{print $2}')
# signal6=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep lastTxRate | awk '{print $2}')
# signal7=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep maxRate | awk '{print $2}')

# bluetooth
btPower=$(system_profiler SPBluetoothDataType | grep "Bluetooth Power" | awk '{print $3}')
btDiscover=$(system_profiler SPBluetoothDataType | head -15 | grep "Discoverable" | awk '{print $2}')
handoff=$(system_profiler SPBluetoothDataType | head -15 | grep "Handoff Supported" | awk '{print $3}')
btMan=$(system_profiler SPBluetoothDataType | head -15 | grep "Manufacturer" | awk '{print $2}')
btRev=$(system_profiler SPBluetoothDataType | head -25 | grep "Bluetooth Core Spec" | awk '{print $4,$5,$6}')
btHostname=$(system_profiler SPBluetoothDataType | head -15 | grep "Name" | awk '{print $2,$3,$4,$5}')
btMacAddr=$(system_profiler SPBluetoothDataType | head -15 | grep "Address" | awk '{print $2}')





echo >> ~/Desktop/$serial.txt
echo "----------------" >> ~/Desktop/$serial.txt
echo "System Profile:" >> ~/Desktop/$serial.txt
echo "Mac Model: $modelName" >> ~/Desktop/$serial.txt
echo "Model Identifier: $modelID" >> ~/Desktop/$serial.txt
echo "Serial Number: $serial" >> ~/Desktop/$serial.txt
# verify functionality of $DESC
# echo "$DESC" >> ~/Desktop/$serial.txt
echo "Software Version: $softwareVersion" >> ~/Desktop/$serial.txt
echo "Boot ROM Version: $bootRom" >> ~/Desktop/$serial.txt
echo "$csrutilStatus" >> ~/Desktop/$serial.txt

# chipset info to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Chipset:" >> ~/Desktop/$serial.txt
echo "Processor Type: $procName" >> ~/Desktop/$serial.txt
echo "Processor Speed: $procSpeed" >> ~/Desktop/$serial.txt
echo "Number of Processors: $procNumber" >> ~/Desktop/$serial.txt
echo "Number of Processing Cores: $procCores" >> ~/Desktop/$serial.txt
echo "Hyper-Threading Technology: $procThread" >> ~/Desktop/$serial.txt

# memory info to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "RAM:" >> ~/Desktop/$serial.txt
echo "Memory Manufacturer: $ramMan" >> ~/Desktop/$serial.txt
echo "Memory Type: $ramType" >> ~/Desktop/$serial.txt
echo "Memory Size: $ramSize" >> ~/Desktop/$serial.txt
echo "Memory Speed: $ramSpeed" >> ~/Desktop/$serial.txt
echo "ECC: $ramECC" >> ~/Desktop/$serial.txt
echo "Swap Usage: $swapUsed" >> ~/Desktop/$serial.txt

# graphics info to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Graphics:" >> ~/Desktop/$serial.txt
echo "GPU: $graphics" >> ~/Desktop/$serial.txt
echo "VRAM (Total): $vram" >> ~/Desktop/$serial.txt
echo "Display Type: $dispType" >> ~/Desktop/$serial.txt
echo "Resolution: $dispRes" >> ~/Desktop/$serial.txt

# battery info to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Power Info:" >> ~/Desktop/$serial.txt
if [ "$batteryInstalled" == "Yes" ]
	then echo "Power Source: Battery" >> ~/Desktop/$serial.txt;
		echo "Battery Cycle Count: $batteryCycles" >> ~/Desktop/$serial.txt;
		echo "Battery Condition: $batteryCondition" >> ~/Desktop/$serial.txt;
		echo "Full Charge Capacity: $batteryCapacity" >> ~/Desktop/$serial.txt;
		echo "Charge Remaining: $batteryCharge" >> ~/Desktop/$serial.txt;
		echo "Amperage (mA): $batteryAmp" >> ~/Desktop/$serial.txt;
		echo "Voltage (mV): $batteryVolt" >> ~/Desktop/$serial.txt
else echo "Power Source: AC Power" >> ~/Desktop/$serial.txt;
	echo "$restartOnLoss" >> ~/Desktop/~$serial.txt;
	echo "Wake on LAN: $wakeOnLAN" >> ~/Destkop/$serial.txt;
	echo "GPU Switch: $gpuSwitch" >> ~/Desktop/$serial.txt;
	echo "UPS Installed: $ups" >> ~/Desktop/$serial.txt
fi

# wireless info to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Wireless Statistics:" >> ~/Desktop/$serial.txt
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I >> ~/Desktop/$serial.txt
# echo "agrCtlRSSI: $signal1" >> ~/Desktop/$serial.txt
# echo "agrExtRSSI: $signal2" >> ~/Desktop/$serial.txt
# echo "agrCtlNoise: $signal3" >> ~/Desktop/$serial.txt
# echo "agrExtNoise: $signal4" >> ~/Desktop/$serial.txt
# echo "state: $signal5" >> ~/Desktop/$serial.txt
# echo "lastTxRate: $signal6" >> ~/Desktop/$serial.txt
# echo "maxRate: $signal7" >> ~/Desktop/$serial.txt

echo "----------------" >> ~/Desktop/$serial.txt
echo "Network Info:" >> ~/Desktop/$serial.txt
echo "Wireless Interface: $intName" >> ~/Desktop/$serial.txt
echo "Interface Type: $intType" >> ~/Desktop/$serial.txt
echo "MAC Address: $wifiMacAddr" >> ~/Desktop/$serial.txt
echo "IPv4 Address: $ipAddr" >> ~/Desktop/$serial.txt
echo "IPv4 Configuration Type: $ipv4ConfigType" >> ~/Desktop/$serial.txt
echo "IPv6 Configuration Type: $ipv6ConfigType" >> ~/Desktop/$serial.txt
echo "----------------" >> ~/Desktop/$serial.txt
echo "Bluetooth:" >> ~/Desktop/$serial.txt
echo "Bluetooth Manufacturer: $btMan" >> ~/Desktop/$serial.txt
echo "Bluetooth Revision: $btRev" >> ~/Desktop/$serial.txt
echo "Bluetooth Power: $btPower" >> ~/Desktop/$serial.txt
echo "Discovery: $btDiscover" >> ~/Desktop/$serial.txt
echo "Handoff Supported: $handoff" >> ~/Desktop/$serial.txt
echo "Hostname: $btHostname" >> ~/Desktop/$serial.txt
echo "MAC Address: $btMacAddr" >> ~/Desktop/$serial.txt

# disk usage
echo "----------------" >> ~/Desktop/$serial.txt
echo "Disk Overview:" >> ~/Desktop/$serial.txt
echo "Storage Medium: $diskType" >> ~/Desktop/$serial.txt
echo "$diskType Size: $diskCapacity" >>~/Desktop/$serial.txt
echo "Available: $diskAvailable" >> ~/Desktop/$serial.txt
echo "$diskHealth" >> ~/Desktop/$serial.txt

# user directory usage
echo "----------------" >> ~/Desktop/$serial.txt
echo "Home Folder Usage:" >> ~/Desktop/$serial.txt
cd ~
du -hsc * >> ~/Desktop/$serial.txt

# malware scan to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Malware Scan:" >> ~/Desktop/$serial.txt
# cat ~/Desktop/.tmp/Malware.txt >> ~/Desktop/$serial.txt
~/Desktop/diag/DetectX\ Swift.app/Contents/MacOS/DetectX\ Swift search >> ~/Desktop/$serial.txt

# this section needs work
# might be bc of my nvme drive that the output seems limited
# research possible other solutions
# Disk Full Report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Full Disk Report:" >> ~/Desktop/$serial.txt
echo >> ~/Desktop/$serial.txt
echo "Overview" >> ~/Desktop/$serial.txt
~/Desktop/diag/smartctl -i /dev/disk0 | grep -A 20 "Model Number" >> ~/Desktop/$serial.txt # gives us the information section
echo "Capabilities" >> ~/Desktop/$serial.txt
~/Desktop/diag/smartctl -c /dev/disk0 | grep -A 20 "Firmware" >> ~/Desktop/$serial.txt # gives us the capabilities section
echo "Attributes" >> ~/Desktop/$serial.txt
~/Desktop/diag/smartctl -A -f brief /dev/disk0 | grep -A 40 "Health Information" >> ~/Desktop/$serial.txt # gives us the vendor-specific attributes section



# like the idea of including logs
# take a look at what might be relevant and summarize it in report
# logs can be formatted to output in json by passing "--style json"


# previous shutdown cause to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Previous Shutdown Log Summary:" >> ~/Desktop/$serial.txt
log show --predicate 'eventMessage contains "Previous shutdown cause"' --last 7d --style compact >> ~/Desktop/$serial.txt

# fsck_apfs log summary to report
echo "----------------" >> ~/Desktop/$serial.txt
if [ "$diskFS" == "Apple_APFS" ]
	then echo "FS Checker (APFS) Log:" >> ~/Desktop/$serial.txt;
		cat /var/log/fsck_apfs.log | tail -30 >> ~/Desktop/$serial.txt
else echo "FS Checker (HFS) Log:" >> ~/Desktop/$serial.txt;
	cat /var/log/fsck_hfs.log | tail -30 >> ~/Desktop/$serial.txt
fi

# echo "FS Checker (APFS) Log Summary:" >> ~/Desktop/$serial.txt
# cat /private/var/log/fsck_apfs.log | tail -30 >> ~/Desktop/$serial.txt # this is the fsck APFS LOG
# cat /private/var/log/fsck_hfs.log | tail -30 >> ~/Desktop/$serial.txt # this is the fsck HFS LOG


# Unmount diag.dmg and delete diag files
# hdiutil unmount "/Volumes/diag"
# rm diag.dmg
# rm -rf ~/Desktop/.tmp

# Close diag tools
# ps aux | grep -i KeyboardViewer | awk {'print $2'} | xargs kill -9
# ps aux | grep -i Photo\ Booth | awk {'print $2'} | xargs kill -9
# ps aux | grep -i Textedit | awk {'print $2'} | xargs kill -9
# ps aux | grep -i DriveDX | awk {'print $2'} | xargs kill -9
# ps aux | grep -i Terminal | awk {'print $2'} | xargs kill -9
