#! /bin/bash

# Diagnostic Tool v2.2

# written for The Mac Support Store
# written by Rich Wright


# contains instructions to print the full model description, if available
function PRODUCTDESCRIPTION {


	local description=$(
		/Volumes/diagv2/.Resources/warrantylookup-master/bin/swiftMacWarranty \
		| grep "PROD_DESCR:" \
		| awk '/PROD_DESCR/ {print substr($0, index($0,$2))}'
		)

	local modelName=$(
		system_profiler SPHardwareDataType \
		| grep "Model Name:" \
		| awk '{print $3,$4,$5,$6}'
		)


	# tests to see if product description program produced expected output
	# if not, falls back on system_profiler for model name
	if test -z "$description"
		
		then
			
			echo "Mac Model: $modelName" >> ~/Desktop/$serial.txt
		
		else
			
			echo "Mac Model: $description" >> ~/Desktop/$serial.txt
	
	fi

}

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
		| grep "ECC:" \
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
		| grep "ECC:" \
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
	
	local dispTypeTV=$(
		system_profiler SPDisplaysDataType \
		| tail -10 \
		| grep "Television:" \
		| awk '{print $2}'
		)
	
	
	if test -z "$dispType"

		then
		
			if [ "$dispTypeTV" == "Yes" ]
				
				then
					
					echo "Display Type: Television" >> ~/Desktop/$serial.txt
			
			else
				
				sleep 0
			
			fi
		
	else 
	
		echo "Display Type: $dispType" >> ~/Desktop/$serial.txt
		
	fi
			
	
	local dispRes=$(
		system_profiler SPDisplaysDataType \
		| grep "UI Looks like:" \
		| awk '{print $4,$5,$6}'
		)

	echo "Display Resolution: $dispRes" >> ~/Desktop/$serial.txt

	local framebuffer=$(
		system_profiler SPDisplaysDataType \
		| grep -A 7 "Displays" \
		| grep "Framebuffer Depth:" \
		| awk '{print $3,$4,$5,$6,$7}'
		)

	echo "Framebuffer Depth: $framebuffer" >> ~/Desktop/$serial.txt

}

# contains instructions specific to MacPro6,1 dual gpu machines
function MACPROGRAPHICSINFO(){

	local gpu=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep "Chipset Model:" \
		| awk '{print $3,$4,$5}'
		)

	echo "Graphics: $gpu" >> ~/Desktop/$serial.txt

	local bus=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep "Bus:" \
		| awk '{print $2}'
		)

	echo "Connection: $bus" >> ~/Desktop/$serial.txt

	local slot=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep "Slot:" \
		| awk '{print $2}'
		)
	
	echo "Slot: $slot" >> ~/Desktop/$serial.txt
	
	local laneWidth=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep "PCIe Lane Width:" \
		| awk '{print $4}'
		)

	echo "PCIe Lane Width: $laneWidth" >> ~/Desktop/$serial.txt

	local gpuVRAM=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep "VRAM" \
		| awk '{print $1,$2,$3,$4,$5,$6}'
		)

	echo "$gpuVRAM" >> ~/Desktop/$serial.txt

	local vendor=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep "Vendor:" \
		| awk '{print $2}'
		)

	echo "Manufacturer: $vendor" >> ~/Desktop/$serial.txt
	
	local metal=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
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
		| tail -30 \
		| grep "Display Type:" \
		| awk '{print $3}'
		)

	echo "Display Type: $dispType" >> ~/Desktop/$serial.txt

	local dispRes=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep "UI Looks like:" \
		| awk '{print $4,$5,$6}'
		)

	echo "Display Resolution: $dispRes" >> ~/Desktop/$serial.txt # doesn't work yet

	local framebuffer=$(
		system_profiler SPDisplaysDataType \
		| grep -A 7 "Displays" \
		| grep "Framebuffer Depth:" \
		| awk '{print $3,$4,$5,$6,$7}'
		)

	echo "Framebuffer Depth: $framebuffer" >> ~/Desktop/$serial.txt
	
	dispConnection=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep "Connection Type:" \
		| awk '{print $3,$4,$5,$6}'
		) 
	
	echo "Connection Type: $dispConnection" >> ~/Desktop/$serial.txt

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
		| grep -A 7 "Displays" \
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
		| head -15 \
		| grep "Metal:" \
		| awk '{print $2}'
		)
	
	if [ "$metal" == "Supported," ]
		then echo "Metal: Supported" >> ~/Desktop/$serial.txt
		else echo "Metal: Not Supported" >> ~/Desktop/$serial.txt
	fi
		

	# displays info
# 	local dispType=$(
# 		system_profiler SPDisplaysDataType \
# 		| grep "Display Type" \
# 		| awk '{print $3,$4,$5}'
# 		)
# 
# 	echo "Display Type: $dispType" >> ~/Desktop/$serial.txt
# 
# 	local dispRes=$(
# 		system_profiler SPDisplaysDataType \
# 		| grep "Resolution" \
# 		| awk '{print $2,$3,$4,$5}'
# 		)
# 
# 	echo "Resolution: $dispRes" >> ~/Desktop/$serial.txt

	local dispInfo=$(
		system_profiler SPDisplaysDataType \
		| tail -30 \
		| grep -A 1 "Display Type:" \
		| awk '{print $1,$2,$3,$4,$5}'
		)
	echo "$dispInfo" >> ~/Desktop/$serial.txt


	local framebuffer=$(
		system_profiler SPDisplaysDataType \
		| grep -A 7 "Displays" \
		| grep "Framebuffer Depth:" \
		| awk '{print $3,$4,$5,$6,$7}'
		)

	echo "Framebuffer Depth: $framebuffer" >> ~/Desktop/$serial.txt

}

# contains the test conditions that determine whether a laptop has dual graphics or not
function GRAPHICSTYPETEST {

	local gfxSwitching=$(
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
	elif [ "$modelID" == "MacPro6,1" ]; then MACPROGRAPHICSINFO
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
		
		
	# tests to see if charger manufacturer is available
	if test -z "$chargerName" 
		then
			echo "Name: Not Available" > /dev/null
	else
		echo "Name: $chargerName" >> ~/Desktop/$serial.txt
	fi

			
	local chargerVendor=$(
		system_profiler SPPowerDataType \
		| grep -A 11 "AC Charger Information" \
		| grep "Manufacturer:" \
		| awk '{print $2,$3}'
		)


	# tests to see if charger information is available, notifies user if not
	if test -z "chargerVendor"
		then 
			osascript -e 'tell app "Terminal" to display notification "Charger Information not available, skipping it....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'
	elif [ "$chargerVendor" =="Apple Inc." ]
		then
			echo "Manufacturer: $chargerVendor" >> ~/Desktop/$serial.txt
	else 
		echo "Who knows" > /dev/null
	fi	
	
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


	local macproModel=$(
		system_profiler SPHardwareDataType \
		| grep "Model Identifier: MacPro6,1" \
		| awk '{print $3}'
		)

	if [ "$macproModel" = "MacPro6,1" ]
		
		then
		
			echo "GPU Switch: $gpuSwitch" >> ~/Desktop/$serial.txt
			
	else
	
		sleep 0
		
	fi


	
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

# contains instructions for printing airport interface info to report
function AIRPORTINTERFACE {

	local activeInterface=$(
		route get default \
		| grep "interface" \
		| awk '{print $2}'
		)

	echo "Active Interface: $activeInterface" >> ~/Desktop/$serial.txt


	local interfaceType=$(
		system_profiler SPNetworkDataType \
		| grep -B 5 "BSD Device Name: $activeInterface" \
		| grep "Type:" \
		| awk {'print $2'}
		)

	echo "Interface Type: $interfaceType" >> ~/Desktop/$serial.txt


	local ipv4ConfigMethod=$(
		system_profiler SPNetworkDataType \
		| grep -A 20 "Wi-Fi" \
		| grep "Configuration Method:" \
		| awk '{print $3}'
		)

	echo "Configuration Method: $ipv4ConfigMethod" >> ~/Desktop/$serial.txt


	local ipv4Address=$(
		system_profiler SPNetworkDataType \
		| grep -A 20 "Wi-Fi" \
		| grep "IPv4 Addresses:" \
		| awk '{print $3}'
		)

	echo "IPv4 Address: $ipv4Address" >> ~/Desktop/$serial.txt


	local ipv4Subnet=$(
		networksetup -getinfo Wi-Fi \
		| grep "Subnet mask:" \
		| awk '{print $3}'
		)

	echo "Subnet Mask: $ipv4Subnet" >> ~/Desktop/$serial.txt


	local routerAddr=$(
		networksetup -getinfo Wi-Fi \
		| head -5 \
		| grep "Router:" \
		| awk '{print $2}'
		)

	echo "Router: $routerAddr" >> ~/Desktop/$serial.txt


	local intMAC=$(
		ifconfig $activeInterface \
		| grep "ether" \
		| awk '{print $2}'
		)

	echo "MAC Address: $intMAC" >> ~/Desktop/$serial.txt


	local ipv6ConfigMethod=$(
		networksetup -getinfo Wi-Fi \
		| grep "IPv6:" \
		| awk '{print $2}'
		)

	echo "IPv6 Configuration Method: $ipv6ConfigMethod" >> ~/Desktop/$serial.txt


	local ipv6Addr=$(
		networksetup -getinfo Wi-Fi \
		| grep "IPv6 IP address:" \
		| awk '{print $4}'
		)

	echo "IPv6 Address: $ipv6Addr" >> ~/Desktop/$serial.txt

}

# contains instructions for printing ethernet interface info to report
function ETHERNETINTERFACE {

	local activeInterface=$(
		route get default \
		| grep "interface" \
		| awk '{print $2}'
		)

	echo "Active Interface: $activeInterface" >> ~/Desktop/$serial.txt


	local activeInterfaceType=$(
		system_profiler SPNetworkDataType \
		| grep -B 5 "BSD Device Name: $activeInterface" \
		| grep "Type:" \
		| awk '{print $2}'
		)


	echo "Interface Type: $activeInterfaceType" >> ~/Desktop/$serial.txt


	local ipv4ConfigMethod=$(
		system_profiler SPNetworkDataType \
		| head -20 \
		| grep "Configuration Method:" \
		| awk '{print $3}'
		)

	echo "IPv4 Configuration: $ipv4ConfigMethod" >> ~/Desktop/$serial.txt


	local ipv4Addr=$(
		system_profiler SPNetworkDataType \
		| head -10 \
		| grep "IPv4 Addresses:" \
		| awk '{print $3}'
		)

	echo "IPv4 Address: $ipv4Addr" >> ~/Desktop/$serial.txt


	local ipv4Subnet=$(
		system_profiler SPNetworkDataType \
		| head -15 \
		| grep -A 2 "AdditionalRoutes:" \
		| grep "SubnetMask:" \
		| awk '{print $2}'
		)

	echo "Subnet Mask: $ipv4Subnet" >> ~/Desktop/$serial.txt



	local ipv4Gateway=$(
		route get default \
		| grep "gateway:" \
		| awk '{print $2}'
		)

	echo "Gateway: $ipv4Gateway" >> ~/Desktop/$serial.txt




	local modelType=$(
		system_profiler SPHardwareDataType \
		| grep "Model Name:" \
		| awk '{print $3}'
		)


	local router1=$(
		networksetup -getinfo "Ethernet 1" \
		| head -5 \
		| grep "Router:" \
		| awk '{print $2}'
		)

	local router2=$(
		networksetup -getinfo "Ethernet 2" \
		| head -5 \
		| grep "Router:" \
		| awk '{print $2}'
		)


	case $modelType in
	
		"Mac Pro" )
		
			if [ "$router1" = "Router:" ]
			
				then
				
					echo "Router: $router2" >> ~/Desktop/output.txt
				
				else
			
					sleep 0
				
			fi
		
			;;
		
	esac


	local intMAC=$(
		ifconfig $activeInterface \
		| grep "ether" \
		| awk '{print $2}'
		)

	echo "MAC Address: $intMAC" >> ~/Desktop/$serial.txt

}

# contains instructions for selecting the proper network info function
function NETWORKINFOSTART {


	local activeInterface=$(
		route get default \
		| grep "interface" \
		| awk '{print $2}'
		)


	local activeInterfaceType=$(
		system_profiler SPNetworkDataType \
		| grep -B 5 "BSD Device Name: $activeInterface" \
		| grep "Type:" \
		| awk '{print $2}'
		)


	if [ "$activeInterfaceType" = "AirPort" ]

		then
	
			AIRPORTINTERFACE
		
	elif [ "$activeInterfaceType" = "Ethernet" ]

		then
	
			ETHERNETINTERFACE
	
	else sleep 0

	fi

}

# contains instructions for printing disk usage to report
function DISKUSAGEINFO(){

	osascript -e 'tell app "Terminal" to display notification "Calculating Disk usage....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'

	if [ "$fsType" = "APFS" ]
		
		then
		
			df -H /System/Volumes/Data \
			| awk '{printf"%-25s%-10s%-10s%-10s\n", $9,$3,$4,$5}' \
			>> ~/Desktop/$serial.txt
			
	else
	
		df -H / \
		| awk '{printf"%-25s%-10s%-10s%-10s\n", $9,$3,$4,$5}' \
		>> ~/Desktop/$serial.txt
		
	fi

}

# contains instructions for printing home folder usage to report
# this should be an external (background operation) in the next version
function USERDIRECTORYUSAGEINFO(){

	osascript -e 'tell app "Terminal" to display notification "Calculating User Directory usage....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'

	cd ~

	du -hsc * >> ~/Desktop/$serial.txt

}

# contains instructions for running a malware scan in the background 
function MALWARESCAN {

	/Volumes/diagv2/.Resources/DetectX\ Swift.app/Contents/MacOS/DetectX\ Swift search > /tmp/mssfiles/malwarescan.txt &

	echo $! > /tmp/mssfiles/detectxpid.txt

	detectxPID=$(
		cat /tmp/mssfiles/detectxpid.txt
		)
	
}

# contains instructions for extracting previous 72 hours of shutdown cause logs
function SHUTDOWNLOG {

	log show --predicate 'eventMessage contains "Previous shutdown cause"' --last 14d --style compact \
	| awk '{print $1,$2,$7,$8,$9}' > "/tmp/mssfiles/shutdownlog.txt" &

	echo $! > /tmp/mssfiles/shutdownlogpid.txt

	shutdownLogPID=$(
		cat /tmp/mssfiles/shutdownlogpid.txt
		)
		
	sleep 30; osascript -e 'tell app "Terminal" to display notification "Exporting logs..... This might take a moment." with title "Diagnostic Tool v2.2 - The Mac Support Store"'

	sleep 10; osascript -e 'tell app "Terminal" to display notification "Concatenating logs....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'

		
	wait $shutdownLogPID

}

# contains instructions for playing an audio sample to test the speakers
function SOUNDTEST {

	osascript -e 'tell app "Terminal" to display dialog "Sound Test will now begin" with title "Diagnostic Tool v2.2 - The Mac Support Store" buttons {"Gotcha"} with icon caution giving up after 5' &> /dev/null

	osascript -e 'set volume output volume 100' &> /dev/null

	afplay /Volumes/diagv2/.Resources/audiotest.m4a &

}

# contains instructions for opening Photo Booth app to test the camera
function CAMERATEST {

	# opens photo booth in the background
	open -a Photo\ Booth -g

	osascript -e 'tell app "Terminal" to display dialog "Hey Super Tech, make sure that webcam works" with title "Diagnostic Tool v2.2 - The Mac Support Store" buttons {"Got it"} with icon stop giving up after 5' &> /dev/null


}

# contains instructions for opening DriveDx and notifying user to save the report
function DRIVEDX {

	osascript -e 'tell app "Terminal" to display notification "Opening DriveDx....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'

	/Volumes/diagv2/.Resources/DriveDx.app/Contents/MacOS/DriveDx &

	sleep 2;

	osascript -e 'tell app "Terminal" to display dialog "Hey Super Tech, make sure you save that DriveDx report" with title "Diagnostic Tool v2.2 - The Mac Support Store" buttons {"Got it"} with icon stop giving up after 5' &> /dev/null

}

# contains instructions that determine which output should run, based on macOS version
# function OUTPUTSTART {
# 
# 	local swVers=$(
# 		system_profiler SPSoftwareDataType \
# 		| grep "System Version:" \
# 		| awk '{print $4}'
# 		)
# 
# 
# 	mkdir ~/Desktop/outFiles
# 
# 
# 	case $swVers in
# 	
# 		11.*.*)
# 		
# 			JSONOUTPUT 2> /dev/null
# 			
# 			;;
# 	
# 		10.15.*)
# 		
# 			JSONOUTPUT 2> /dev/null
# 		
# 			;;
# 	
# 		*) 
# 		
# 			XMLOUTPUT 2> /dev/null
# 		
# 			;;
# 	
# 	esac
# 
# 	osascript -e 'tell app "Terminal" to display notification "Exporting your system profile....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'
# 
# }
# 
# contains instructions for exporting system profile in json format, macOS Catalina and up ONLY
# function JSONOUTPUT {
# 
# 	system_profiler -json SPHardwareDataType > ~/Desktop/outFiles/hardware.json
# 	
# 	system_profiler -json SPSoftwareDataType > ~/Desktop/outFiles/software.json
# 	
# 	system_profiler -json SPAudioDataType > ~/Desktop/outFiles/audio.json
# 	
# 	system_profiler -json SPBluetoothDataType > ~/Desktop/outFiles/bluetooth.json
# 	
# 	system_profiler -json SPCameraDataType > ~/Desktop/outFiles/camera.json
# 	
# 	system_profiler -json SPCardReaderDataType > ~/Desktop/outFiles/cardReader.json
# 	
# 	system_profiler -json iBridgeDataType > ~/Desktop/outFiles/ibridge.json
# 	
# 	system_profiler -json SPDiagnosticsDataType > ~/Desktop/outFiles/diagnostics.json
# 	
# 	system_profiler -json SPDisabledSoftwareDataType > ~/Desktop/outFiles/disabledSW.json
# 	
# 	system_profiler -json SPDiscBurningDataType > ~/Desktop/outFiles/discBurn.json
# 	
# 	system_profiler -json SPFibreChannelDataType > ~/Desktop/outFiles/fibreChannel.json
# 	
# 	system_profiler -json SPFireWireDataType > ~/Desktop/outFiles/firewire.json
# 	
# 	system_profiler -json SPFirewallDataType > ~/Desktop/outFiles/firewall.json
# 	
# 	system_profiler -json SPFrameworksDataType > ~/Desktop/outFiles/frameworks.json
# 	
# 	system_profiler -json SPDisplaysDataType > ~/Desktop/outFiles/displays.json
# 	
# 	system_profiler -json SPInstallHistoryDataType > ~/Desktop/outFiles/installHistory.json
# 	
# 	system_profiler -json SPInternationalDataType > ~/Desktop/outFiles/intl.json
# 	
# 	system_profiler -json SPNetworkLocationsDataType > ~/Desktop/outFiles/locations.json
# 	
# 	system_profiler -json SPManagedClientDataType > ~/Desktop/outFiles/profiles.json
# 	
# 	system_profiler -json SPMemoryDataType > ~/Desktop/outFiles/memory.json
# 	
# 	system_profiler -json SPNVMeDataType > ~/Desktop/outFiles/nvme.json
# 	
# 	system_profiler -json SPNetworkDataType > ~/Desktop/outFiles/network.json
# 	
# 	system_profiler -json SPPCIDataType > ~/Desktop/outFiles/pci.json
# 	
# 	system_profiler -json SPPowerDataType > ~/Desktop/outFiles/power.json
# 	
# 	system_profiler -json SPPrintersDataType > ~/Desktop/outFiles/printers.json
# 	
# 	system_profiler -json SPSerialATADataType > ~/Desktop/outFiles/sata.json
# 	
# 	system_profiler -json SPSmartCardsDataType > ~/Desktop/outFiles/smartCard.json
# 	
# 	system_profiler -json SPStartupItemDataType > ~/Desktop/outFiles/startupItems.json
# 	
# 	system_profiler -json SPStorageDataType > ~/Desktop/outFiles/storage.json
# 	
# 	system_profiler -json SPThunderboltDataType > ~/Desktop/outFiles/thunderbolt.json
# 	
# 	system_profiler -json SPUSBDataType > ~/Desktop/outFiles/usb.json
# 	
# 	system_profiler -json SPAirPortDataType > ~/Desktop/outFiles/airport.json
# 
# }
# 
# contains instructions for exporting system profile in xml format, for macOS Mojave and earlier ONLY
# function XMLOUTPUT {
# 
# 	system_profiler -xml SPHardwareDataType > ~/Desktop/outFiles/hardware.xml
# 	
# 	system_profiler -xml SPSoftwareDataType > ~/Desktop/outFiles/software.xml
# 	
# 	system_profiler -xml SPAudioDataType > ~/Desktop/outFiles/audio.xml
# 	
# 	system_profiler -xml SPBluetoothDataType > ~/Desktop/outFiles/bluetooth.xml
# 	
# 	system_profiler -xml SPCameraDataType > ~/Desktop/outFiles/camera.xml
# 	
# 	system_profiler -xml SPCardReaderDataType > ~/Desktop/outFiles/cardReader.xml
# 	
# 	system_profiler -xml iBridgeDataType > ~/Desktop/outFiles/ibridge.xml
# 	
# 	system_profiler -xml SPDiagnosticsDataType > ~/Desktop/outFiles/diagnostics.xml
# 	
# 	system_profiler -xml SPDisabledSoftwareDataType > ~/Desktop/outFiles/disabledSW.xml
# 	
# 	system_profiler -xml SPDiscBurningDataType > ~/Desktop/outFiles/discBurn.xml
# 	
# 	system_profiler -xml SPFibreChannelDataType > ~/Desktop/outFiles/fibreChannel.xml
# 	
# 	system_profiler -xml SPFireWireDataType > ~/Desktop/outFiles/firewire.xml
# 	
# 	system_profiler -xml SPFirewallDataType > ~/Desktop/outFiles/firewall.xml
# 	
# 	system_profiler -xml SPFrameworksDataType > ~/Desktop/outFiles/frameworks.xml
# 	
# 	system_profiler -xml SPDisplaysDataType > ~/Desktop/outFiles/displays.xml
# 	
# 	system_profiler -xml SPInstallHistoryDataType > ~/Desktop/outFiles/installHistory.xml
# 	
# 	system_profiler -xml SPInternationalDataType > ~/Desktop/outFiles/intl.xml
# 	
# 	system_profiler -xml SPNetworkLocationsDataType > ~/Desktop/outFiles/locations.xml
# 	
# 	system_profiler -xml SPManagedClientDataType > ~/Desktop/outFiles/profiles.xml
# 	
# 	system_profiler -xml SPMemoryDataType > ~/Desktop/outFiles/memory.xml
# 	
# 	system_profiler -xml SPNVMeDataType > ~/Desktop/outFiles/nvme.xml
# 	
# 	system_profiler -xml SPNetworkDataType > ~/Desktop/outFiles/network.xml
# 	
# 	system_profiler -xml SPPCIDataType > ~/Desktop/outFiles/pci.xml
# 	
# 	system_profiler -xml SPPowerDataType > ~/Desktop/outFiles/power.xml
# 	
# 	system_profiler -xml SPPrintersDataType > ~/Desktop/outFiles/printers.xml
# 	
# 	system_profiler -xml SPSerialATADataType > ~/Desktop/outFiles/sata.xml
# 	
# 	system_profiler -xml SPSmartCardsDataType > ~/Desktop/outFiles/smartCard.xml
# 	
# 	system_profiler -xml SPStartupItemDataType > ~/Desktop/outFiles/startupItems.xml
# 	
# 	system_profiler -xml SPStorageDataType > ~/Desktop/outFiles/storage.xml
# 	
# 	system_profiler -xml SPThunderboltDataType > ~/Desktop/outFiles/thunderbolt.xml
# 	
# 	system_profiler -xml SPUSBDataType > ~/Desktop/outFiles/usb.xml
# 	
# 	system_profiler -xml SPAirPortDataType > ~/Desktop/outFiles/airport.xml
# 	
# }




# contains the core elements of this program
function MAIN {

	# sends the user a notification prompt that the diagnostic is beginning with a prompt and a 5 second timeout
	osascript -e 'tell app "Terminal" to display dialog "Running your diagnostic, please wait." with title "Diagnostic Tool v2.2 - The Mac Support Store" buttons {"Right on!"} default button 1 with icon note giving up after 5' &> /dev/null



	# makes temp folder to write external function output to
	mkdir /tmp/mssfiles

	SHUTDOWNLOG & # backgrounds this function and moves on
	
	MALWARESCAN & # backgrounds this function and moves on

	CAMERATEST

	clear && echo -ne '----------------------------------[0%]\r'


	# grab serial number and create report named $serial.txt
	serial=$(
		system_profiler SPHardwareDataType \
		| grep "Serial Number (system)" \
		| awk '{print $4}'
		)

	echo "Diagnostic Tool v2.2 -- The Mac Support Store" \
	> ~/Desktop/$serial.txt

	echo >> ~/Desktop/$serial.txt

	echo "----------------" >> ~/Desktop/$serial.txt




	# system overview
	echo "System Profile:" >> ~/Desktop/$serial.txt


	PRODUCTDESCRIPTION


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
	
	# FileVault disk encryption status
	filevault=$(
		fdesetup status
		)
	
	echo "FileVault: $filevault" >> ~/Desktop/$serial.txt


	clear && echo -ne '####------------------------------[10%]\r'


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

	# hyper-threading readout not available on every software version
	# so this saves the report from containing a blank space if not available
	if test -z "$procThread"
		then
			sleep 0
	else 
		echo "Hyper-Threading Technology: $procThread" >> ~/Desktop/$serial.txt
	fi	



	osascript -e 'tell app "Terminal" to display notification "Generating your report....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'


	# progress bar
	clear && echo -ne '#######---------------------------[15%]\r'



	# memory info section
	modelType=$(
		system_profiler SPHardwareDataType \
		| grep "Model Name:" \
		| awk '{print $3}'
		)

	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Memory Info:" >> ~/Desktop/$serial.txt

	MEMORYINFOSTART




	# graphics info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Graphics & Displays:" >> ~/Desktop/$serial.txt

	GRAPHICSINFOSTART




	# power info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Power Info:" >> ~/Desktop/$serial.txt

	POWERINFOSTART



	clear && echo -ne '#########-------------------------[20%]\r'


	# prompts user and runs sound test in background
	SOUNDTEST &





	# wireless signal sample
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Wireless Statistics:" >> ~/Desktop/$serial.txt

	osascript -e 'tell app "Terminal" to display notification "Taking a Wi-Fi sample....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'


	WIRELESSSIGNALINFO


	# progress bar
	clear && echo -ne '#############---------------------[30%]\r'


	# wireless interface info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Network Info:" >> ~/Desktop/$serial.txt


	NETWORKINFOSTART




	# opens drive dx and prompts user to save report
	DRIVEDX &



	clear && echo -ne '################------------------[35%]\r'


	# bluetooth info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Bluetooth:" >> ~/Desktop/$serial.txt

	btMan=$(
		system_profiler SPBluetoothDataType \
		| head -15 \
		| grep "Manufacturer" \
		| awk '{print $2}'
		)

	echo "Manufacturer: $btMan" >> ~/Desktop/$serial.txt


	bluetoothRevision=$(
		system_profiler SPBluetoothDataType \
		| head -30 \
		| grep "LMP Version:" \
		| awk '{print $3}'
		)

	echo "Revision: $bluetoothRevision" >> ~/Desktop/$serial.txt

	btPower=$(
		system_profiler SPBluetoothDataType \
		| grep "Bluetooth Power" \
		| awk '{print $3}'
		)

	echo "Power: $btPower" >> ~/Desktop/$serial.txt

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
	
	
	autoSeekKeyboard=$(
		system_profiler SPBluetoothDataType \
		| head -40 \
		| grep "Auto Seek Keyboard:" \
		| awk '{print $4}'
		)
	
	echo "Auto Seek Keyboard: $autoSeekKeyboard" >> ~/Desktop/$serial.txt
		
	
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


	clear && echo -ne '###################---------------[40%]\r'


	# runs the system profiler to export data for aws
	# currently not in use
	# OUTPUTSTART &



	# disk info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Disk Overview:" >> ~/Desktop/$serial.txt

	diskType=$(
		system_profiler SPStorageDataType \
		| head -20 \
		| grep "Medium Type" \
		| awk '{print $3}'
		)



	# storage medium readout not available on PCI-driven MacPro5,1
	# so this saves the report from containing a blank space if not available
	if test -z "$diskType"
		then
			sleep 0
	else 
		echo "Storage Medium: $diskType" >> ~/Desktop/$serial.txt
	fi	



	fsType=$(
		system_profiler SPStorageDataType \
		| head -20 \
		| grep "File System:" \
		| awk '{print $3}'
		)


	case $fsType in

		APFS)

			echo "File System: $fsType" >> ~/Desktop/$serial.txt ;;
	
		Journaled)

			echo "File System: Journaled HFS" >> ~/Desktop/$serial.txt ;;

		* )

			sleep 0 ;;

	esac


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

	clear && echo -ne '######################------------[50%]\r'



	# location readout not always available, needs further testing
	# so this saves the report from containing a blank space if not available
	if test -z "$attachmentLocation"
		then
			sleep 0
	else 
		echo "Internal: $attachmentLocation" >> ~/Desktop/$serial.txt
	fi	



	DISKUSAGEINFO

	clear && echo -ne '#######################-----------[55%]\r'



	# progress bar
	clear && echo -ne '#######################-----------[60%]\r'




	# user directory usage
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Home Folder Usage:" >> ~/Desktop/$serial.txt

	USERDIRECTORYUSAGEINFO


	clear && echo -ne '##########################--------[70%]\r'


	# print malware scan results to report
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Malware Scan:" >> ~/Desktop/$serial.txt

	sleep 5; osascript -e 'tell app "Terminal" to display notification "Scanning for malware....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'


	clear && echo -ne '###########################-------[75%]\r'


	wait $detectxPID

	cat "/tmp/mssfiles/malwarescan.txt" >> ~/Desktop/$serial.txt


	# currently not in use
	# wait OUTPUTFILES


	clear && echo -ne '#############################-----[85%]\r'


	# print shutdown cause log to report
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Previous Shutdown Log Summary:" >> ~/Desktop/$serial.txt

	clear && echo -ne '###############################---[90%]\r'


	wait SHUTDOWNLOG

	cat "/tmp/mssfiles/shutdownlog.txt" >> ~/Desktop/$serial.txt

	# progress bar
	clear && echo -ne '##################################[100%]\r'
	echo -ne '\n'
	clear


	# cleanup functions
	osascript -e 'tell app "Terminal" to display notification "Cleaning up....." with title "Diagnostic Tool v2.2 - The Mac Support Store"'

	rm -rf /tmp/mssfiles
	
	killall DriveDx
	
	killall Photo\ Booth

	hdiutil detach /Volumes/diagv2

}

MAIN 2> /dev/null





killall Terminal





