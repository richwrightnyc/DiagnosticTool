#! /bin/bash

# Diagnostic Tool v2.1 beta 2

# keep an eye on outputs
# may have to work with the variable naming scheme
# something about local vs global variables

# omitted Keyboard Viewer, it did not work in the original script under 10.15
# there might be a better option out there


# contains instructions to print the full model description, if available
function PRODUCTDESCRIPTION {

	local description=$(
		/Volumes/diagv2/.Resources/warrantylookup-master/bin/swiftMacWarranty \
		| awk '/PROD_DESCR/ {print substr($0, index($0,$2))}'
		)

	if test -z "$description"
		then
			sleep 0
		else
			echo "$description" >> ~/Desktop/$serial.txt
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

	echo "Display Type: $dispType" >> ~/Desktop/$serial.txt
	
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
			osascript -e 'tell app "Terminal" to display notification "Charger Information not available, skipping it....." with title "Diagnostic Tool v2.1 - The Mac Support Store"'
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
function DISKUSAGEINFO(){

	osascript -e 'tell app "Terminal" to display notification "Calculating Disk usage....." with title "Diagnostic Tool v2.1 - The Mac Support Store"'

# 	df -H /System/Volumes/Data \
# 	| awk '{printf"%-25s%-10s%-10s%-10s\n", $9,$3,$4,$5}' \
# 	>> ~/Desktop/$serial.txt

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

	osascript -e 'tell app "Terminal" to display notification "Calculating User Directory usage....." with title "Diagnostic Tool v2.1 - The Mac Support Store"'

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

	log show --predicate 'eventMessage contains "Previous shutdown cause"' --last 72h --style compact \
	| awk '{print $1,$2,$7,$8,$9}' > "/tmp/mssfiles/shutdownlog.txt" &

	echo $! > /tmp/mssfiles/shutdownlogpid.txt

	shutdownLogPID=$(
		cat /tmp/mssfiles/shutdownlogpid.txt
		)
		
	sleep 30; osascript -e 'tell app "Terminal" to display notification "Exporting logs..... This might take a moment." with title "Diagnostic Tool v2.1 - The Mac Support Store"'

	sleep 10; osascript -e 'tell app "Terminal" to display notification "Concatenating logs....." with title "Diagnostic Tool v2.1 - The Mac Support Store"'

		
	wait $shutdownLogPID

}

# contains instructions for playing an audio sample to test the speakers
function SOUNDTEST {

	osascript -e 'tell app "Terminal" to display dialog "Sound Test will now begin" with title "Diagnostic Tool v2.1 - The Mac Support Store" buttons {"Gotcha"} with icon caution giving up after 5' &> /dev/null

	osascript -e 'set volume output volume 100' &> /dev/null

	afplay /Volumes/diagv2/.Resources/audiotest.m4a &

}

# contains instructions for opening Photo Booth app to test the camera
function CAMERATEST {

	# opens photo booth in the background
	open -a Photo\ Booth -g

	osascript -e 'tell app "Terminal" to display dialog "Hey Super Tech, make sure that webcam works" with title "Diagnostic Tool v2.1 - The Mac Support Store" buttons {"Got it"} with icon stop giving up after 5' &> /dev/null


}

# contains instructions for opening DriveDx and notifying user to save the report
function DRIVEDX {

	osascript -e 'tell app "Terminal" to display notification "Opening DriveDx....." with title "Diagnostic Tool v2.1 - The Mac Support Store"'

	/Volumes/diagv2/.Resources/DriveDx.app/Contents/MacOS/DriveDx &

	sleep 2;

	osascript -e 'tell app "Terminal" to display dialog "Hey Super Tech, make sure you save that DriveDx report" with title "Diagnostic Tool v2.1 - The Mac Support Store" buttons {"Got it"} with icon stop giving up after 5' &> /dev/null

}

# contains instructions that determine which output should run, based on macOS version
function OUTPUTSTART {

	local swVers=$(
		system_profiler SPSoftwareDataType \
		| grep "System Version:" \
		| awk '{print $4}'
		)


	mkdir ~/Desktop/outFiles


	case $swVers in
	
		11.*.*)
		
			JSONOUTPUT 2> /dev/null
			
			;;
	
		10.15.*)
		
			JSONOUTPUT 2> /dev/null
		
			;;
	
		*) 
		
			XMLOUTPUT 2> /dev/null
		
			;;
	
	esac

	osascript -e 'tell app "Terminal" to display notification "Exporting your system profile....." with title "Diagnostic Tool v2.1 - The Mac Support Store"'

}

# contains instructions for exporting system profile in json format, macOS Catalina and up ONLY
function JSONOUTPUT {

	system_profiler -json SPHardwareDataType > ~/Desktop/outFiles/hardware.json
	
	system_profiler -json SPSoftwareDataType > ~/Desktop/outFiles/software.json
	
	system_profiler -json SPAudioDataType > ~/Desktop/outFiles/audio.json
	
	system_profiler -json SPBluetoothDataType > ~/Desktop/outFiles/bluetooth.json
	
	system_profiler -json SPCameraDataType > ~/Desktop/outFiles/camera.json
	
	system_profiler -json SPCardReaderDataType > ~/Desktop/outFiles/cardReader.json
	
	system_profiler -json iBridgeDataType > ~/Desktop/outFiles/ibridge.json
	
	system_profiler -json SPDiagnosticsDataType > ~/Desktop/outFiles/diagnostics.json
	
	system_profiler -json SPDisabledSoftwareDataType > ~/Desktop/outFiles/disabledSW.json
	
	system_profiler -json SPDiscBurningDataType > ~/Desktop/outFiles/discBurn.json
	
	system_profiler -json SPFibreChannelDataType > ~/Desktop/outFiles/fibreChannel.json
	
	system_profiler -json SPFireWireDataType > ~/Desktop/outFiles/firewire.json
	
	system_profiler -json SPFirewallDataType > ~/Desktop/outFiles/firewall.json
	
	system_profiler -json SPFrameworksDataType > ~/Desktop/outFiles/frameworks.json
	
	system_profiler -json SPDisplaysDataType > ~/Desktop/outFiles/displays.json
	
	system_profiler -json SPInstallHistoryDataType > ~/Desktop/outFiles/installHistory.json
	
	system_profiler -json SPInternationalDataType > ~/Desktop/outFiles/intl.json
	
	system_profiler -json SPNetworkLocationsDataType > ~/Desktop/outFiles/locations.json
	
	system_profiler -json SPManagedClientDataType > ~/Desktop/outFiles/profiles.json
	
	system_profiler -json SPMemoryDataType > ~/Desktop/outFiles/memory.json
	
	system_profiler -json SPNVMeDataType > ~/Desktop/outFiles/nvme.json
	
	system_profiler -json SPNetworkDataType > ~/Desktop/outFiles/network.json
	
	system_profiler -json SPPCIDataType > ~/Desktop/outFiles/pci.json
	
	system_profiler -json SPPowerDataType > ~/Desktop/outFiles/power.json
	
	system_profiler -json SPPrintersDataType > ~/Desktop/outFiles/printers.json
	
	system_profiler -json SPSerialATADataType > ~/Desktop/outFiles/sata.json
	
	system_profiler -json SPSmartCardsDataType > ~/Desktop/outFiles/smartCard.json
	
	system_profiler -json SPStartupItemDataType > ~/Desktop/outFiles/startupItems.json
	
	system_profiler -json SPStorageDataType > ~/Desktop/outFiles/storage.json
	
	system_profiler -json SPThunderboltDataType > ~/Desktop/outFiles/thunderbolt.json
	
	system_profiler -json SPUSBDataType > ~/Desktop/outFiles/usb.json
	
	system_profiler -json SPAirPortDataType > ~/Desktop/outFiles/airport.json

}

# contains instructions for exporting system profile in xml format, for macOS Mojave and earlier ONLY
function XMLOUTPUT {

	system_profiler -xml SPHardwareDataType > ~/Desktop/outFiles/hardware.xml
	
	system_profiler -xml SPSoftwareDataType > ~/Desktop/outFiles/software.xml
	
	system_profiler -xml SPAudioDataType > ~/Desktop/outFiles/audio.xml
	
	system_profiler -xml SPBluetoothDataType > ~/Desktop/outFiles/bluetooth.xml
	
	system_profiler -xml SPCameraDataType > ~/Desktop/outFiles/camera.xml
	
	system_profiler -xml SPCardReaderDataType > ~/Desktop/outFiles/cardReader.xml
	
	system_profiler -xml iBridgeDataType > ~/Desktop/outFiles/ibridge.xml
	
	system_profiler -xml SPDiagnosticsDataType > ~/Desktop/outFiles/diagnostics.xml
	
	system_profiler -xml SPDisabledSoftwareDataType > ~/Desktop/outFiles/disabledSW.xml
	
	system_profiler -xml SPDiscBurningDataType > ~/Desktop/outFiles/discBurn.xml
	
	system_profiler -xml SPFibreChannelDataType > ~/Desktop/outFiles/fibreChannel.xml
	
	system_profiler -xml SPFireWireDataType > ~/Desktop/outFiles/firewire.xml
	
	system_profiler -xml SPFirewallDataType > ~/Desktop/outFiles/firewall.xml
	
	system_profiler -xml SPFrameworksDataType > ~/Desktop/outFiles/frameworks.xml
	
	system_profiler -xml SPDisplaysDataType > ~/Desktop/outFiles/displays.xml
	
	system_profiler -xml SPInstallHistoryDataType > ~/Desktop/outFiles/installHistory.xml
	
	system_profiler -xml SPInternationalDataType > ~/Desktop/outFiles/intl.xml
	
	system_profiler -xml SPNetworkLocationsDataType > ~/Desktop/outFiles/locations.xml
	
	system_profiler -xml SPManagedClientDataType > ~/Desktop/outFiles/profiles.xml
	
	system_profiler -xml SPMemoryDataType > ~/Desktop/outFiles/memory.xml
	
	system_profiler -xml SPNVMeDataType > ~/Desktop/outFiles/nvme.xml
	
	system_profiler -xml SPNetworkDataType > ~/Desktop/outFiles/network.xml
	
	system_profiler -xml SPPCIDataType > ~/Desktop/outFiles/pci.xml
	
	system_profiler -xml SPPowerDataType > ~/Desktop/outFiles/power.xml
	
	system_profiler -xml SPPrintersDataType > ~/Desktop/outFiles/printers.xml
	
	system_profiler -xml SPSerialATADataType > ~/Desktop/outFiles/sata.xml
	
	system_profiler -xml SPSmartCardsDataType > ~/Desktop/outFiles/smartCard.xml
	
	system_profiler -xml SPStartupItemDataType > ~/Desktop/outFiles/startupItems.xml
	
	system_profiler -xml SPStorageDataType > ~/Desktop/outFiles/storage.xml
	
	system_profiler -xml SPThunderboltDataType > ~/Desktop/outFiles/thunderbolt.xml
	
	system_profiler -xml SPUSBDataType > ~/Desktop/outFiles/usb.xml
	
	system_profiler -xml SPAirPortDataType > ~/Desktop/outFiles/airport.xml
	
}

# testing case statement error
function FILESYSTEMTYPE {

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


}


function MAIN {



	# sends the user a notification prompt that the diagnostic is beginning with a prompt and a 5 second timeout
	osascript -e 'tell app "Terminal" to display dialog "Running your diagnostic, please wait." with title "Diagnostic Tool v2.1 - The Mac Support Store" buttons {"Right on!"} default button 1 with icon note giving up after 5' &> /dev/null



	# makes temp folder to write external function output to
	mkdir /tmp/mssfiles

	SHUTDOWNLOG & # backgrounds this function and moves on
	
	MALWARESCAN & # backgrounds this function and moves on

# 	CAMERATEST

	clear && echo -ne '----------------------------------[20%]\r'


	# grab serial number and create report named $serial.txt
	serial=$(
		system_profiler SPHardwareDataType \
		| grep "Serial Number (system)" \
		| awk '{print $4}'
		)

	echo "Diagnostic Tool v2.1 beta 2 -- The Mac Support Store" \
	> ~/Desktop/$serial.txt

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

	PRODUCTDESCRIPTION




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



	osascript -e 'tell app "Terminal" to display notification "Generating your report....." with title "Diagnostic Tool v2.1 - The Mac Support Store"'


	# progress bar
	clear && echo -ne '#######---------------------------[20%]\r'



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




	# prompts user and runs sound test in background
# 	SOUNDTEST &




	# wireless signal sample
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Wireless Statistics:" >> ~/Desktop/$serial.txt

	osascript -e 'tell app "Terminal" to display notification "Taking a Wi-Fi sample....." with title "Diagnostic Tool v2.1 - The Mac Support Store"'


	WIRELESSSIGNALINFO


	# progress bar
	clear && echo -ne '#############---------------------[40%]\r'


	# wireless interface info section
	echo "----------------" >> ~/Desktop/$serial.txt

	echo "Network Info:" >> ~/Desktop/$serial.txt





	activeInterface=$(
		route get default \
		| grep "interface" \
		| awk '{print $2}'
		)

	echo "Active Interface: $activeInterface" >> ~/Desktop/$serial.txt



	interfaceType=$(
		system_profiler SPNetworkDataType \
		| grep -B 5 "BSD Device Name: $activeInterface" \
		| grep "Type:" \
		| awk '{print $2}'
		)

	echo "Interface Type: $interfaceType" >> ~/Desktop/$serial.txt




}










































