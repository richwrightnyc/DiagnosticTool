#! /bin/bash

# make a hidden tmp folder to store output files
mkdir ~/Desktop/.tmp

# run log first, takes lots of time, save PID to $pid
log show --predicate 'eventMessage contains "Previous shutdown cause"' --last 7d --style compact | awk '{print $1,$2,$7,$8,$9}' > ~/Desktop/.tmp/powerLog.txt &
echo $! > ~/Desktop/.tmp/logpid.txt
logPID=$(cat ~/Desktop/.tmp/logpid.txt)

# run system_profiler in background
/Volumes/diagv2/jsonProfiler.sh &

# WiFi Signal
networksetup -setairportpower airport on
networksetup -setairportnetwork en0 mssguest Wi117rJR
networksetup -setairportnetwork en1 mssguest Wi117rJR

# KeyboardViewer
open -a KeyboardViewer

# Photo Booth
open -a Photo\ Booth

# sound test
osascript -e 'tell app "System Events" to display dialog "Sound Test will now begin"'
osascript -e 'set volume output volume 100' # Set volume to 100
afplay /Volumes/diagv2/audiotest.m4a & # Play Audio from Command Line in the Background

# Malware Scan
/Volumes/diagv2/DetectX\ Swift.app/Contents/MacOS/DetectX\ Swift search > ~/Desktop/.tmp/malware.txt &
echo $! > ~/Desktop/.tmp/malwarepid.txt
malwarePID=$(cat ~/Desktop/.tmp/malwarepid.txt)

# Open DriveDX
/Volumes/diagv2/DriveDx.app/Contents/MacOS/DriveDx &

# The tech needs save the DriveDX report
osascript -e 'tell app "System Events" to display dialog "Save the DriveDX report in ~/Desktop/MSSHDD/"'




# grab serial number and create report named $serial.txt
serial=$(system_profiler SPHardwareDataType | grep "Serial Number (system)" | awk '{print $4}')
echo "Diagnostic Tool v2.0.4a -- The Mac Support Store" > ~/Desktop/$serial.txt
echo >> ~/Desktop/$serial.txt
echo "----------------" >> ~/Desktop/$serial.txt

# system overview
echo "System Profile:" >> ~/Desktop/$serial.txt
modelName=$(system_profiler SPHardwareDataType | grep "Model Name" | awk '{print $3,$4,$5,$6}')
echo "Mac Model: $modelName" >> ~/Desktop/$serial.txt
modelID=$(system_profiler SPHardwareDataType | grep "Model Identifier" | awk '{print $3}')
echo "Model Identifier: $modelID" >> ~/Desktop/$serial.txt
echo "Serial Number: $serial" >> ~/Desktop/$serial.txt

# macOS version and build number
softwareVersion=$(system_profiler SPSoftwareDataType | grep "System Version" | awk '{print $3,$4,$5}')
echo "Software Version: $softwareVersion" >> ~/Desktop/$serial.txt
# boot rom version
bootRom=$(system_profiler SPHardwareDataType | grep "Boot ROM" | awk '{print $4,$5,$6,$7}')
echo "Boot ROM Version: $bootRom" >> ~/Desktop/$serial.txt
# system integrity protection status
csrutilStatus=$(csrutil status)
echo "$csrutilStatus" >> ~/Desktop/$serial.txt

# chipset info
echo "----------------" >> ~/Desktop/$serial.txt
echo "Chipset:" >> ~/Desktop/$serial.txt
procName=$(sysctl machdep.cpu.brand_string | awk '{print $2,$3,$4}')
echo "Processor Type: $procName" >> ~/Desktop/$serial.txt
procSpeed=$(system_profiler SPHardwareDataType | grep "Processor Speed" | awk '{print $3,$4,$5,$6,$7}')
echo "Processor Speed: $procSpeed" >> ~/Desktop/$serial.txt
procNumber=$(system_profiler SPHardwareDataType | grep "Number of Processors" | awk '{print $4}')
echo "Number of Processors: $procNumber" >> ~/Desktop/$serial.txt
procCores=$(system_profiler SPHardwareDataType | grep "Total Number of Cores" | awk '{print $5}')
echo "Number of Processing Cores: $procCores" >> ~/Desktop/$serial.txt
procThread=$(system_profiler SPHardwareDataType | grep "Hyper-Threading" | awk '{print $3}')
echo "Hyper-Threading Technology: $procThread" >> ~/Desktop/$serial.txt



# memory info
echo "----------------" >> ~/Desktop/$serial.txt
echo "Memory Info:
--" >> ~/Desktop/$serial.txt
memBanks=$(system_profiler SPMemoryDataType | grep -A 6 "BANK" | awk '{print $1,$2,$3,$4}')
echo "$memBanks" >> ~/Desktop/$serial.txt
ramECC=$(system_profiler SPMemoryDataType | grep "ECC" | awk '{print $2}')
echo "--
ECC: $ramECC" >> ~/Desktop/$serial.txt
ramSize=$(system_profiler SPHardwareDataType | grep "Memory" | awk '{print $2,$3}')
echo "Total RAM Installed: $ramSize" >> ~/Desktop/$serial.txt
swapUsed=$(sysctl vm.swapusage | awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}')
echo "Swap Usage: $swapUsed" >> ~/Desktop/$serial.txt



# graphics info
echo "----------------" >> ~/Desktop/$serial.txt
echo "Graphics:" >> ~/Desktop/$serial.txt # all of the following may be removed, leaving it for now in order to reference
intGPU=$(system_profiler SPDisplaysDataType | grep -B 3 "Built-In" | grep "Chipset Model" | awk '{print $3,$4,$5,$6}') #int gpu
vramInt=$(system_profiler SPDisplaysDataType | grep "VRAM (Dynamic, Max)" | awk '{print $4,$5}') #int gpu vram
echo "Integrated Graphics: $intGPU $vramInt" >> ~/Desktop/$serial.txt
dGPU=$(system_profiler SPDisplaysDataType | grep -B 3 "Bus: PCIe" | grep "Chipset Model:" | awk '{print $3,$4,$5,$6}') #discreet gpu
vramD=$(system_profiler SPDisplaysDataType | grep "VRAM (Total):" | awk '{print $3,$4}') #dgpu vram
echo "Discreet Graphics: $dGPU $vramD" >> ~/Desktop/$serial.txt
dispType=$(system_profiler SPDisplaysDataType | grep "Display Type" | awk '{print $3,$4,$5}')
echo "Display Type: $dispType" >> ~/Desktop/$serial.txt
dispRes=$(system_profiler SPDisplaysDataType | grep "Resolution" | awk '{print $2,$3,$4,$5}')
echo "Resolution: $dispRes" >> ~/Desktop/$serial.txt
framebuffer=$(system_profiler SPDisplaysDataType | grep "Framebuffer Depth:" | awk '{print $3,$4,$5,$6,$7}')
echo "Framebuffer Depth: $framebuffer" >> ~/Desktop/$serial.txt


# battery info
batteryInstalled=$(system_profiler SPPowerDataType | grep "Battery Installed" | awk '{print $3}')
batteryCycles=$(system_profiler SPPowerDataType | grep "Cycle Count" | awk '{print $3}')
batteryCondition=$(system_profiler SPPowerDataType | grep "Condition" | awk '{print $2,$3}')
batteryCapacity=$(system_profiler SPPowerDataType | grep "Full Charge Capacity (mAh)" | awk '{print $5}')
batteryCharge=$(system_profiler SPPowerDataType | grep "Charge Remaining (mAh)" | awk '{print $4}')
batteryAmp=$(system_profiler SPPowerDataType | grep "Amperage (mA):" | awk '{print $3}')
batteryVolt=$(system_profiler SPPowerDataType | grep "Voltage (mV)" | awk '{print $3}')
# ac power
restartOnLoss=$(system_profiler SPPowerDataType | grep "Automatic Restart on Power Loss:" | awk '{print $1,$2,$3,$4,$5,$6}')
wakeOnLAN=$(system_profiler SPPowerDataType | grep "Wake on LAN:" | awk '{print $4}')
gpuSwitch=$(system_profiler SPPowerDataType | grep -A 18 "AC Power" | grep "GPUSwitch" | awk '{print $2}')
ups=$(system_profiler SPPowerDataType | grep "UPS Installed:" | awk '{print $3}')

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
	echo "$restartOnLoss" >> ~/Desktop/$serial.txt;
	echo "Wake on LAN: $wakeOnLAN" >> ~/Destkop/$serial.txt;
	echo "GPU Switch: $gpuSwitch" >> ~/Desktop/$serial.txt;
	echo "UPS Installed: $ups" >> ~/Desktop/$serial.txt
fi

# wireless sample to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Wireless Statistics:" >> ~/Desktop/$serial.txt
/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I >> ~/Desktop/$serial.txt

# wireless info
echo "----------------" >> ~/Desktop/$serial.txt
echo "Network Info:" >> ~/Desktop/$serial.txt
intName=$(system_profiler SPNetworkDataType | head -25 | grep "ConfirmedInterfaceName" | awk '{print $2}')
echo "Wireless Interface: $intName" >> ~/Desktop/$serial.txt
intType=$(system_profiler SPNetworkLocationDataType | head -15 | grep "Type" | awk '{print $2}')
echo "Interface Type: $intType" >> ~/Desktop/$serial.txt
wifiMacAddr=$(system_profiler SPNetworkDataType | head -20 | grep "ARPResolvedHardwareAddress" | awk '{print $2}')
echo "MAC Address: $wifiMacAddr" >> ~/Desktop/$serial.txt
ipAddr=$(system_profiler SPNetworkDataType | head -20 | grep "IPv4 Addresses" | awk '{print $3}')
echo "IPv4 Address: $ipAddr" >> ~/Desktop/$serial.txt
ipv4ConfigType=$(system_profiler SPNetworkDataType | head -30 | grep -A 10 "IPv6" | grep "Configuration Method" | awk '{print $3}')
echo "IPv4 Configuration Type: $ipv4ConfigType" >> ~/Desktop/$serial.txt
ipv6ConfigType=$(system_profiler SPNetworkDataType | head -30 | grep -A 1 "IPv6" | grep "Configuration" | awk '{print $3}')
echo "IPv6 Configuration Type: $ipv6ConfigType" >> ~/Desktop/$serial.txt

# bluetooth info
echo "----------------" >> ~/Desktop/$serial.txt
echo "Bluetooth:" >> ~/Desktop/$serial.txt
btMan=$(system_profiler SPBluetoothDataType | head -15 | grep "Manufacturer" | awk '{print $2}')
echo "Bluetooth Manufacturer: $btMan" >> ~/Desktop/$serial.txt
btRev=$(system_profiler SPBluetoothDataType | head -25 | grep "Bluetooth Core Spec" | awk '{print $4,$5,$6}')
echo "Bluetooth Revision: $btRev" >> ~/Desktop/$serial.txt
btPower=$(system_profiler SPBluetoothDataType | grep "Bluetooth Power" | awk '{print $3}')
echo "Bluetooth Power: $btPower" >> ~/Desktop/$serial.txt
btDiscover=$(system_profiler SPBluetoothDataType | head -15 | grep "Discoverable" | awk '{print $2}')
echo "Discovery: $btDiscover" >> ~/Desktop/$serial.txt
handoff=$(system_profiler SPBluetoothDataType | head -15 | grep "Handoff Supported" | awk '{print $3}')
echo "Handoff Supported: $handoff" >> ~/Desktop/$serial.txt
btHostname=$(system_profiler SPBluetoothDataType | head -15 | grep "Name" | awk '{print $2,$3,$4,$5}')
echo "Hostname: $btHostname" >> ~/Desktop/$serial.txt
btMacAddr=$(system_profiler SPBluetoothDataType | head -15 | grep "Address" | awk '{print $2}')
echo "MAC Address: $btMacAddr" >> ~/Desktop/$serial.txt

# disk usage
echo "----------------" >> ~/Desktop/$serial.txt
echo "Disk Overview:" >> ~/Desktop/$serial.txt
diskType=$(system_profiler SPStorageDataType | head -20 | grep "Medium Type" | awk '{print $3}')
echo "Storage Medium: $diskType" >> ~/Desktop/$serial.txt
df -H /System/Volumes/Data | awk '{printf"%-25s%-10s%-10s%-10s\n", $9,$3,$4,$5}' >> ~/Desktop/$serial.txt 

# user directory usage
echo "----------------" >> ~/Desktop/$serial.txt
echo "Home Folder Usage:" >> ~/Desktop/$serial.txt
cd ~
du -hsc * >> ~/Desktop/$serial.txt

# malware scan to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Malware Scan:" >> ~/Desktop/$serial.txt
wait $malwarePID
cat ~/Desktop/.tmp/malware.txt >> ~/Desktop/$serial.txt

# Disk Full Report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Full Disk Report:" >> ~/Desktop/$serial.txt
echo >> ~/Desktop/$serial.txt
echo "Overview" >> ~/Desktop/$serial.txt
/Volumes/diagv2/smartctl -i /dev/disk0 | grep -A 20 "Model Number" >> ~/Desktop/$serial.txt # gives us the information section
echo "Capabilities" >> ~/Desktop/$serial.txt
/Volumes/diagv2/smartctl -c /dev/disk0 | grep -A 20 "Firmware" >> ~/Desktop/$serial.txt # gives us the capabilities section
echo "Attributes" >> ~/Desktop/$serial.txt
/Volumes/diagv2/smartctl -A -f brief /dev/disk0 | grep -A 40 "Health Information" >> ~/Desktop/$serial.txt # gives us the vendor-specific attributes section



# previous shutdown cause to report
echo "----------------" >> ~/Desktop/$serial.txt
echo "Previous Shutdown Log Summary:" >> ~/Desktop/$serial.txt
wait $logPID
cat ~/Desktop/.tmp/powerLog.txt >> ~/Desktop/$serial.txt

fsck_apfs log summary to report
echo "----------------" >> ~/Desktop/$serial.txt
# diskFS=$(diskutil list disk0 | grep disk0s2 | awk '{print $2}')
diskFS=$(system_profiler SPStorageDataType | head -10 | grep "File System" | awk '{print $3}')
if [ "$diskFS" == "APFS" ]
	then echo "FS Checker (APFS) Log:" >> ~/Desktop/$serial.txt;
		cat /var/log/fsck_apfs.log | tail -30 >> ~/Desktop/$serial.txt
else echo "FS Checker (HFS) Log:" >> ~/Desktop/$serial.txt;
	cat /var/log/fsck_hfs.log | tail -30 >> ~/Desktop/$serial.txt
fi

rm -rf ~/Desktop/.tmp
# Close diag tools
ps aux | grep -i KeyboardViewer | awk {'print $2'} | xargs kill -9
ps aux | grep -i Photo\ Booth | awk {'print $2'} | xargs kill -9
ps aux | grep -i DriveDX | awk {'print $2'} | xargs kill -9
# ps aux | grep -i Terminal | awk {'print $2'} | xargs kill -9