#! /bin/bash

# Diagnostic Tool v2.1 alpha

# keep an eye on outputs
# may have to work with the variable naming scheme
# something about local vs global variables

# also maybe rename the $path variable that points to /tmp

# have to write additional logic for MacPro6,1 w/ dual gfx

# contains instructions for LAPTOPS
function LAPTOPMEMORYINFO(){ 


	local memBanks=$(
		system_profiler SPMemoryDataType \
		| grep -A 7 "BANK" \
		| awk '{print $1,$2,$3,$4}'
		)

	echo "$memBanks" >> ~/Desktop/$serial.txt

	local ramECC=$(
		system_profiler SPMemoryDataType \
		| grep "ECC" \
		| awk '{print $2}'
		)

	echo "--" >> ~/Desktop/$serial.txt # writes proper spacing to report
	
	echo "ECC: $ramECC" >> ~/Desktop/$serial.txt

	local upgradeRAM=$(
		system_profiler SPMemoryDataType \
		| grep "Upgradeable Memory:" \
		| awk '{print $3}'
		)

	echo "Upgradeable Memory: $upgradeRAM" >> ~/Desktop/$serial.txt

	local ramSize=$(
		system_profiler SPHardwareDataType \
		| grep "Memory" \
		| awk '{print $2,$3}'
		)

	echo "Total RAM Installed: $ramSize" >> ~/Desktop/$serial.txt

	local swapUsed=$(
		sysctl vm.swapusage \
		| awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'
		)

	echo "Swap Usage: $swapUsed" >> ~/Desktop/$serial.txt


}

# contains instructions for DESKTOPS
function DESKTOPMEMORYINFO(){

	local memDimms=$(
		system_profiler SPMemoryDataType \
		| grep -A 7 "DIMM" \
		| awk '{print $1,$2,$3,$4}'
		)

	echo "$memDimms" >> ~/Desktop/$serial.txt

	local ramECC=$(
		system_profiler SPMemoryDataType \
		| grep "ECC" \
		| awk '{print $2}'
		)

	echo "--" >> ~/Desktop/$serial.txt # writes proper spacing to report
	 
	echo "ECC: $ramECC" >> ~/Desktop/$serial.txt

	local upgradeRAM=$(
		system_profiler SPMemoryDataType \
		| grep "Upgradeable Memory:" \
		| awk '{print $3}'
		)

	echo "Upgradeable Memory: $upgradeRAM" >> ~/Desktop/$serial.txt

	local ramSize=$(
		system_profiler SPHardwareDataType \
		| grep "Memory" \
		| awk '{print $2,$3}'
		)

	echo "Total RAM Installed: $ramSize" >> ~/Desktop/$serial.txt

	local swapUsed=$(
		sysctl vm.swapusage \
		| awk '{print $2,$3,$4,$5,$6,$7,$8,$9,$10,$11}'
		)

	echo "Swap Usage: $swapUsed" >> ~/Desktop/$serial.txt

}

# contains conditional to determine if host is laptop or desktop
function MEMORYINFOSTART {

	if [ "$modelType" == "MacBook" ]; then LAPTOPMEMORYINFO
	else DESKTOPMEMORYINFO
	fi

}

# contains instructions for DESKTOPS
function DESKTOPGRAPHICSINFO(){

	local gpu=$(
		system_profiler SPDisplaysDataType \
		| grep "Chipset Model:" \
		| awk '{print $3,$4,$5}'
		)

	echo "Graphics: $gpu" >> ~/Desktop/$serial.txt

	local bus=$(
		system_profiler SPDisplaysDataType \
		| grep "Bus:" \
		| awk '{print $2}'
		)

	echo "Connection: $bus" >> ~/Desktop/$serial.txt

	local slot=$(
		system_profiler SPDisplaysDataType \
		| grep "Slot:" \
		| awk '{print $2}'
		)
	
	# slot info not available on every desktop mac model
	# this if statement tests to see if the variable $slot is available
	# if so, it will print that info to report, if not it will do nothing
	# this way it does not leave a blank in the final report

	if test -z "$slot"; then echo "slot information not available for this device" > /dev/null
	else echo "Slot: $slot" >> ~/Desktop/$serial.txt
	fi


	local laneWidth=$(
		system_profiler SPDisplaysDataType \
		| grep "PCIe Lane Width:" \
		| awk '{print $4}'
		)

	echo "PCIe Lane Width: $laneWidth" >> ~/Desktop/$serial.txt

	local gpuVRAM=$(
		system_profiler SPDisplaysDataType \
		| grep "VRAM" \
		| awk '{print $1,$2,$3,$4,$5,$6}'
		)

	echo "$gpuVRAM" >> ~/Desktop/$serial.txt

	local vendor=$(
		system_profiler SPDisplaysDataType \
		| grep "Vendor:" \
		| awk '{print $2}'
		)

	echo "Manufacturer: $vendor" >> ~/Desktop/$serial.txt

	local metal=$(
		system_profiler SPDisplaysDataType \
		| grep "Metal:" \
		| awk '{print $2}'
		)

	if [ "$metal" == "Supported," ]
		then echo "Metal: Supported" >> ~/Desktop/$serial.txt
		else echo "Metal: Not Supported" >> ~/Desktop/$serial.txt
	fi

	# displays data
	local dispType=$(
		system_profiler SPDisplaysDataType \
		| grep "Display Type:" \
		| awk '{print $3}'
		)

	echo "Display Type: $dispType" >> ~/Desktop/$serial.txt

	echo "Display Resolution: $dispRes" >> ~/Desktop/$serial.txt

	local framebuffer=$(
		system_profiler SPDisplaysDataType \
		| grep "Framebuffer Depth:" \
		| awk '{print $3,$4,$5,$6,$7}'
		)

	echo "Framebuffer Depth: $framebuffer" >> ~/Desktop/$serial.txt

}

# contains instructions for LAPTOPS with integrated graphics ONLY
function LAPTOPINTEGRATEDGRAPHICSINFO(){

	local intGPU=$(
		system_profiler SPDisplaysDataType \
		| grep -B 3 "Bus: Built-In" \
		| grep "Chipset Model" \
		| awk '{print $3,$4,$5,$6}'
		)

	echo "Integrated Graphics: $intGPU" >> ~/Desktop/$serial.txt

	local vramInt=$(
		system_profiler SPDisplaysDataType \
		| grep "VRAM (Dynamic, Max)" \
		| awk '{print $4,$5}'
		)

	echo "VRAM: $vramInt" >> ~/Desktop/$serial.txt

	local metal=$(
		system_profiler SPDisplaysDataType \
		| grep "Metal:" \
		| awk '{print $2}'
		)
	
	if [ "$metal" == "Supported," ]
		then echo "Metal: Supported" >> ~/Desktop/$serial.txt
		else echo "Metal: Not Supported" >> ~/Desktop/$serial.txt
	fi

	
	# displays info
	local dispType=$(
		system_profiler SPDisplaysDataType \
		| grep "Display Type" \
		| awk '{print $3,$4,$5}'
		)

	echo "Display Type: $dispType" >> ~/Desktop/$serial.txt

	local dispRes=$(
		system_profiler SPDisplaysDataType \
		| grep "Resolution" \
		| awk '{print $2,$3,$4,$5}'
		)

	echo "Resolution: $dispRes" >> ~/Desktop/$serial.txt

	local framebuffer=$(
		system_profiler SPDisplaysDataType \
		| grep "Framebuffer Depth:" \
		| awk '{print $3,$4,$5,$6,$7}'
		)

	echo "Framebuffer Depth: $framebuffer" >> ~/Desktop/$serial.txt

}

# contains instructions for LAPTOPS with integrated AND discreet graphics
function LAPTOPDUALGRAPHICSINFO(){

	local intGPU=$(
		system_profiler SPDisplaysDataType \
		| grep -B 3 "Built-In" | grep "Chipset Model" \
		| awk '{print $3,$4,$5,$6}'
		)

	local vramInt=$(
		system_profiler SPDisplaysDataType \
		| grep "VRAM (Dynamic, Max)" \
		| awk '{print $4,$5}'
		)

	echo "Integrated Graphics: $intGPU $vramInt" >> ~/Desktop/$serial.txt

	local dGPU=$(
		system_profiler SPDisplaysDataType \
		| grep -B 3 "Bus: PCIe" \
		| grep "Chipset Model:" \
		| awk '{print $3,$4,$5,$6}'
		)

	local vramD=$(
		system_profiler SPDisplaysDataType \
		| grep "VRAM (Total):" \
		| awk '{print $3,$4}'
		)

	echo "Discreet Graphics: $dGPU $vramD" >> ~/Desktop/$serial.txt
	
	local metal=$(
		system_profiler SPDisplaysDataType \
		| grep "Metal:" \
		| awk '{print $2}'
		)
	
	if [ "$metal" == "Supported," ]
		then echo "Metal: Supported" >> ~/Desktop/$serial.txt
		else echo "Metal: Not Supported" >> ~/Desktop/$serial.txt
	fi
		

	# displays info
	local dispType=$(
		system_profiler SPDisplaysDataType \
		| grep "Display Type" \
		| awk '{print $3,$4,$5}'
		)

	echo "Display Type: $dispType" >> ~/Desktop/$serial.txt

	local dispRes=$(
		system_profiler SPDisplaysDataType \
		| grep "Resolution" \
		| awk '{print $2,$3,$4,$5}'
		)

	echo "Resolution: $dispRes" >> ~/Desktop/$serial.txt

	local framebuffer=$(
		system_profiler SPDisplaysDataType \
		| grep "Framebuffer Depth:" \
		| awk '{print $3,$4,$5,$6,$7}'
		)

	echo "Framebuffer Depth: $framebuffer" >> ~/Desktop/$serial.txt

}

# contains the test conditions that determine whether a laptop has dual graphics or not
function GRAPHICSTYPETEST {

	gfxSwitching=$(
		system_profiler SPDisplaysDataType \
		| grep "Automatic Graphics Switching:"
		)

	if test -z "$gfxSwitching" 
		then
		  LAPTOPINTEGRATEDGRAPHICSINFO
		else
		  LAPTOPDUALGRAPHICSINFO 
	fi


}

# contains conditional to determine which graphics function to execute
function GRAPHICSINFOSTART {

	if [ "$modelType" == "MacBook" ]; then GRAPHICSTYPETEST
	else DESKTOPGRAPHICSINFO
	fi

}

# contains instructions for printing battery information in LAPTOPS
function BATTERYINFO(){

	echo "Battery Installed: Yes" >> ~/Desktop/$serial.txt

	local batteryCondition=$(
		system_profiler SPPowerDataType \
		| grep "Condition" \
		| awk '{print $2,$3}'
		)

	echo "Battery Condition: $batteryCondition" >> ~/Desktop/$serial.txt

	local batteryCycles=$(
		system_profiler SPPowerDataType \
		| grep "Cycle Count" \
		| awk '{print $3}'
		)

	echo "Battery Cycle Count: $batteryCycles" >> ~/Desktop/$serial.txt

	local batteryCapacity=$(
		system_profiler SPPowerDataType \
		| grep "Full Charge Capacity (mAh)" \
		| awk '{print $5}'
		)

	echo "Full Charge Capacity: $batteryCapacity" >> ~/Desktop/$serial.txt

	local batteryCharge=$(
		system_profiler SPPowerDataType \
		| grep "Charge Remaining (mAh)" \
		| awk '{print $4}'
		)

	echo "Charge Remaining: $batteryCharge" >> ~/Desktop/$serial.txt

	local batteryAmp=$(
		system_profiler SPPowerDataType \
		| grep "Amperage (mA):" \
		| awk '{print $3}'
		)

	echo "Amperage (mA): $batteryAmp" >> ~/Desktop/$serial.txt

	local batteryVolt=$(
		system_profiler SPPowerDataType \
		| grep "Voltage (mV)" \
		| awk '{print $3}'
		)

	echo "Voltage (mV): $batteryVolt" >> ~/Desktop/$serial.txt
	
	chargerConnected=$(
		system_profiler SPPowerDataType \
		| grep -A 2 "AC Charger Information" \
		| grep "Connected:" \
		| awk '{print $2}'
		)
		
	if [ "$chargerConnected" == "Yes" ]
		then
			echo "AC Charger Connected: $chargerConnected" >> ~/Desktop/$serial.txt;		
			ACCHARGERINFO
	else
		echo "AC Charger Connected: $chargerConnected" >> ~/Desktop/$serial.txt
	fi

}

# contains instructions for printing AC Charger information in LAPTOPS, only if connected, as defined in BATTERYINFO
function ACCHARGERINFO(){

	local charging=$(
		system_profiler SPPowerDataType \
		| grep -A 11 "AC Charger Information" \
		| grep "Charging:" \
		| awk '{print $2}'
		)

	echo "Charging: $charging" >> ~/Desktop/$serial.txt

	local chargingWattage=$(
		system_profiler SPPowerDataType \
		| grep -A 11 "AC Charger Information" \
		| grep "Wattage (W):" \
		| awk '{print $3}'
		)
	
	echo "Wattage (W): $chargingWattage" >> ~/Desktop/$serial.txt

	local chargerName=$(
		system_profiler SPPowerDataType \
		| grep -A 11 "AC Charger Information" \
		| grep "Name:" \
		| awk '{print $2,$3,$4,$5,$6}'
		)

	echo "Name: $chargerName" >> ~/Desktop/$serial.txt

	local chargerVendor=$(
		system_profiler SPPowerDataType \
		| grep -A 11 "AC Charger Information" \
		| grep "Manufacturer:" \
		| awk '{print $2,$3,$4,$5,$6}'
		)

	echo "Manufacturer: $chargerVendor" >> ~/Desktop/$serial.txt

}

# contains instructions for printing AC Power information in DESKTOPS
function ACPOWERINFO(){

	echo "Power Source: AC Power" >> ~/Desktop/$serial.txt

	local restartOnLoss=$(
		system_profiler SPPowerDataType \
		| grep "Automatic Restart on Power Loss:" \
		| awk '{print $1,$2,$3,$4,$5,$6}'
		)

	echo "$restartOnLoss" >> ~/Desktop/$serial.txt

	local wakeOnLAN=$(
		system_profiler SPPowerDataType \
		| grep "Wake on LAN:" \
		| awk '{print $4}'
		)

	echo "Wake on LAN: $wakeOnLAN" >> ~/Destkop/$serial.txt

	local gpuSwitch=$(
		system_profiler SPPowerDataType \
		| grep -A 18 "AC Power" \
		| grep "GPUSwitch" \
		| awk '{print $2}'
		)

	echo "GPU Switch: $gpuSwitch" >> ~/Desktop/$serial.txt
	
	local sysSleepTimer=$(
		system_profiler SPPowerDataType \
		| grep "System Sleep Timer" \
		| awk '{print $5}'
		)
	
	echo "System Sleep Timer (Minutes): $sysSleepTimer" >> ~/Desktop/$serial.txt
	
	local diskSleepTimer=$(
		system_profiler SPPowerDataType \
		| grep "Disk Sleep Timer" \
		| awk '{print $5}'
		)
		
	echo "Disk Sleep Timer (Minutes): $diskSleepTimer" >> ~/Desktop/$serial.txt

	local ups=$(
		system_profiler SPPowerDataType \
		| grep "UPS Installed:" \
		| awk '{print $3}'
		)

	echo "UPS Installed: $ups" >> ~/Desktop/$serial.txt

}

# contains instructions on which power information function to execute
function POWERINFOSTART {

	if [ "$modelType" == "MacBook" ]; then BATTERYINFO
	else ACPOWERINFO
	fi

}

# contains instructions for printing wifi signal to report
function WIRELESSSIGNALINFO {

	/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I >> ~/Desktop/$serial.txt

}

# contains instructions for printing disk usage to report
function DISKUSAGE(){

	df -H /System/Volumes/Data \
	| awk '{printf"%-25s%-10s%-10s%-10s\n", $9,$3,$4,$5}' \
	>> ~/Desktop/$serial.txt

}

# contains instructions for printing home folder usage to report
# this should be an external (background operation) in the next version
function USERDIRECTORYUSAGE(){

	cd ~

	du -hsc * >> ~/Desktop/$serial.txt

}




function MAIN {

	# grab serial number and create report named $serial.txt
	serial=$(
		system_profiler SPHardwareDataType \
		| grep "Serial Number (system)" \
		| awk '{print $4}'
		)

	echo "Diagnostic Tool v2.1 alpha -- The Mac Support Store" > ~/Desktop/$serial.txt

	echo >> ~/Desktop/$serial.txt

	echo "----------------" >> ~/Desktop/$serial.txt




	# system overview
	echo "System Profile:" >> ~/Desktop/$serial.txt

	modelName=$(
		system_profiler SPHardwareDataType \
		| grep "Model Name" \
		| awk '{print $3,$4,$5,$6}'
		)

	echo "Mac Model: $modelName" >> ~/Desktop/$serial.txt

	modelID=$(
		system_profiler SPHardwareDataType \
		| grep "Model Identifier" \
		| awk '{print $3}'
		)

	echo "Model Identifier: $modelID" >> ~/Desktop/$serial.txt

	echo "Serial Number: $serial" >> ~/Desktop/$serial.txt




	# macOS version and build number
	softwareVersion=$(
		system_profiler SPSoftwareDataType \
		| grep "System Version" \
		| awk '{print $3,$4,$5}'
		)

	echo "Software Version: $softwareVersion" >> ~/Desktop/$serial.txt

	# boot rom version
	bootRom=$(
		system_profiler SPHardwareDataType \
		| grep "Boot ROM" \
		| awk '{print $4,$5,$6,$7}'
		)

	echo "Boot ROM Version: $bootRom" >> ~/Desktop/$serial.txt

	# system integrity protection status
	csrutilStatus=$(
		csrutil status
		)

	echo "$csrutilStatus" >> ~/Desktop/$serial.txt




	# chipset info
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Chipset:" >> ~/Desktop/$serial.txt

	procName=$(
		sysctl machdep.cpu.brand_string \
		| awk '{print $2,$3,$4}'
		)

	echo "Processor Type: $procName" >> ~/Desktop/$serial.txt

	procSpeed=$(
		system_profiler SPHardwareDataType \
		| grep "Processor Speed" \
		| awk '{print $3,$4,$5,$6,$7}'
		)

	echo "Processor Speed: $procSpeed" >> ~/Desktop/$serial.txt

	procNumber=$(
		system_profiler SPHardwareDataType \
		| grep "Number of Processors" \
		| awk '{print $4}'
		)

	echo "Number of Processors: $procNumber" >> ~/Desktop/$serial.txt

	procCores=$(
		system_profiler SPHardwareDataType \
		| grep "Total Number of Cores" \
		| awk '{print $5}'
		)

	echo "Number of Processing Cores: $procCores" >> ~/Desktop/$serial.txt

	procThread=$(
		system_profiler SPHardwareDataType \
		| grep "Hyper-Threading" \
		| awk '{print $3}'
		)

	echo "Hyper-Threading Technology: $procThread" >> ~/Desktop/$serial.txt




	# memory info section
	modelType=$(
		system_profiler SPHardwareDataType \
		| grep "Model Name:" \
		| awk '{print $3}'
		)

	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Memory Info:
	--" >> ~/Desktop/$serial.txt

	MEMORYINFOSTART




	# graphics info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Graphics & Displays:" >> ~/Desktop/$serial.txt

	GRAPHICSINFOSTART




	# power info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Power Info:" >> ~/Desktop/$serial.txt

	POWERINFOSTART




	# wireless signal sample
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Wireless Statistics:" >> ~/Desktop/$serial.txt

	WIRELESSSIGNALINFO




	# wireless interface info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Network Info:" >> ~/Desktop/$serial.txt

	intName=$(
		system_profiler SPNetworkDataType \
		| head -25 \
		| grep "ConfirmedInterfaceName" \
		| awk '{print $2}'
		)

	echo "Wireless Interface: $intName" >> ~/Desktop/$serial.txt

	intType=$(
		system_profiler SPNetworkLocationDataType \
		| head -15 \
		| grep "Type" \
		| awk '{print $2}'
		)

	echo "Interface Type: $intType" >> ~/Desktop/$serial.txt

	wifiMacAddr=$(
		system_profiler SPNetworkDataType \
		| head -20 \
		| grep "ARPResolvedHardwareAddress" \
		| awk '{print $2}'
		)

	echo "MAC Address: $wifiMacAddr" >> ~/Desktop/$serial.txt

	ipAddr=$(
		system_profiler SPNetworkDataType \
		| head -20 \
		| grep "IPv4 Addresses" \
		| awk '{print $3}'
		)

	echo "IPv4 Address: $ipAddr" >> ~/Desktop/$serial.txt

	ipv4ConfigType=$(
		system_profiler SPNetworkDataType \
		| head -30 \
		| grep -A 10 "IPv6" \
		| grep "Configuration Method" \
		| awk '{print $3}'
		)

	echo "IPv4 Configuration Type: $ipv4ConfigType" >> ~/Desktop/$serial.txt

	ipv6ConfigType=$(
		system_profiler SPNetworkDataType \
		| head -30 \
		| grep -A 1 "IPv6" \
		| grep "Configuration" \
		| awk '{print $3}'
		)

	echo "IPv6 Configuration Type: $ipv6ConfigType" >> ~/Desktop/$serial.txt




	# bluetooth info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Bluetooth:" >> ~/Desktop/$serial.txt

	btMan=$(
		system_profiler SPBluetoothDataType \
		| head -15 \
		| grep "Manufacturer" \
		| awk '{print $2}'
		)

	echo "Bluetooth Manufacturer: $btMan" >> ~/Desktop/$serial.txt

	btRev=$(
		system_profiler SPBluetoothDataType \
		| head -25 \
		| grep "Bluetooth Core Spec" \
		| awk '{print $4,$5,$6}'
		)

	echo "Bluetooth Revision: $btRev" >> ~/Desktop/$serial.txt

	btPower=$(
		system_profiler SPBluetoothDataType \
		| grep "Bluetooth Power" \
		| awk '{print $3}'
		)

	echo "Bluetooth Power: $btPower" >> ~/Desktop/$serial.txt

	btDiscover=$(
		system_profiler SPBluetoothDataType \
		| head -15 \
		| grep "Discoverable" \
		| awk '{print $2}'
		)

	echo "Discovery: $btDiscover" >> ~/Desktop/$serial.txt

	handoff=$(
		system_profiler SPBluetoothDataType \
		| head -15 \
		| grep "Handoff Supported" \
		| awk '{print $3}'
		)

	echo "Handoff Supported: $handoff" >> ~/Desktop/$serial.txt

	btHostname=$(
		system_profiler SPBluetoothDataType \
		| head -15 \
		| grep "Name" \
		| awk '{print $2,$3,$4,$5}'
		)

	echo "Hostname: $btHostname" >> ~/Desktop/$serial.txt

	btMacAddr=$(
		system_profiler SPBluetoothDataType \
		| head -15 \
		| grep "Address" \
		| awk '{print $2}'
		)

	echo "MAC Address: $btMacAddr" >> ~/Desktop/$serial.txt




	# disk info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Disk Overview:" >> ~/Desktop/$serial.txt

	diskType=$(
		system_profiler SPStorageDataType \
		| head -20 \
		| grep "Medium Type" \
		| awk '{print $3}'
		)

	echo "Storage Medium: $diskType" >> ~/Desktop/$serial.txt

	fsType=$(
		system_profiler SPStorageDataType \
		| head -20 \
		| grep "File System:" \
		| awk '{print $3,$4,$5,$6}'
		)

	echo "File System: $fsType" >> ~/Desktop/$serial.txt

	writable=$(
		system_profiler SPStorageDataType \
		| head -20 \
		| grep "Writable:" \
		| awk '{print $2}'
		)

	echo "Writable: $writable" >> ~/Desktop/$serial.txt

	ignoreOwnership=$(
		system_profiler SPStorageDataType \
		| head -10 \
		| grep "Ignore Ownership:" \
		| awk '{print $3}'
		)

	echo "Ignore Ownership: $ignoreOwnership" >> ~/Desktop/$serial.txt

	bsdName=$(
		system_profiler SPStorageDataType \
		| head -20 \
		| grep "BSD Name:" \
		| awk '{print $3}'
		)

	echo "BSD Name: $bsdName" >> ~/Desktop/$serial.txt

	devName=$(
		system_profiler SPStorageDataType \
		| head -20 \
		| grep "Device Name:" \
		| awk '{print $3,$4,$5,$6,$7,$8,$9}'
		)

	echo "Device Name: $devName" >> ~/Desktop/$serial.txt


	attachmentProtocol=$(
		system_profiler SPStorageDataType \
		| head -21 \
		| grep "Protocol:" \
		| awk '{print $2,$3}'
		)

	echo "Protocol: $attachmentProtocol" >> ~/Desktop/$serial.txt

	attachmentLocation=$(
		system_profiler SPStorageDataType \
		| head -21 \
		| grep "Internal:" \
		| awk '{print $2}'
		)

	echo "Internal: $attachmentLocation" >> ~/Desktop/$serial.txt

	DISKUSAGE




	# user directory usage
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Home Folder Usage:" >> ~/Desktop/$serial.txt

	USERDIRECTORYUSAGE


}

MAIN 2> /dev/null

