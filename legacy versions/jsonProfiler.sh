#! /bin/bash

function json {
system_profiler -json SPHardwareDataType > hardware.json
system_profiler -json SPSoftwareDataType > software.json
system_profiler -json SPAudioDataType > audio.json
system_profiler -json SPBluetoothDataType > bluetooth.json
system_profiler -json SPCameraDataType > camera.json
system_profiler -json SPCardReaderDataType > cardReader.json
system_profiler -json iBridgeDataType > ibridge.json
system_profiler -json SPDiagnosticsDataType > diagnostics.json
system_profiler -json SPDisabledSoftwareDataType > disabledSW.json
system_profiler -json SPDiscBurningDataType > discBurn.json
system_profiler -json SPFibreChannelDataType > fibreChannel.json
system_profiler -json SPFireWireDataType > firewire.json
system_profiler -json SPFirewallDataType > firewall.json
system_profiler -json SPFrameworksDataType > frameworks.json
system_profiler -json SPDisplaysDataType > displays.json
system_profiler -json SPInstallHistoryDataType > installHistory.json
system_profiler -json SPInternationalDataType > intl.json
system_profiler -json SPNetworkLocationsDataType > locations.json
system_profiler -json SPManagedClientDataType > profiles.json
system_profiler -json SPMemoryDataType > memory.json
system_profiler -json SPNVMeDataType > nvme.json
system_profiler -json SPNetworkDataType > network.json
system_profiler -json SPPCIDataType > pci.json
system_profiler -json SPPowerDataType > power.json
system_profiler -json SPPrintersDataType > printers.json
system_profiler -json SPSerialATADataType > sata.json
system_profiler -json SPSmartCardsDataType > smartCard.json
system_profiler -json SPStartupItemDataType > startupItems.json
system_profiler -json SPStorageDataType > storage.json
system_profiler -json SPThunderboltDataType > thunderbolt.json
system_profiler -json SPUSBDataType > usb.json
system_profiler -json SPAirPortDataType > airport.json
}
function xml {
system_profiler -xml SPHardwareDataType > hardware.xml
system_profiler -xml SPSoftwareDataType > software.xml
system_profiler -xml SPAudioDataType > audio.xml
system_profiler -xml SPBluetoothDataType > bluetooth.xml
system_profiler -xml SPCameraDataType > camera.xml
system_profiler -xml SPCardReaderDataType > cardReader.xml
system_profiler -xml iBridgeDataType > ibridge.xml
system_profiler -xml SPDiagnosticsDataType > diagnostics.xml
system_profiler -xml SPDisabledSoftwareDataType > disabledSW.xml
system_profiler -xml SPDiscBurningDataType > discBurn.xml
system_profiler -xml SPFibreChannelDataType > fibreChannel.xml
system_profiler -xml SPFireWireDataType > firewire.xml
system_profiler -xml SPFirewallDataType > firewall.xml
system_profiler -xml SPFrameworksDataType > frameworks.xml
system_profiler -xml SPDisplaysDataType > displays.xml
system_profiler -xml SPInstallHistoryDataType > installHistory.xml
system_profiler -xml SPInternationalDataType > intl.xml
system_profiler -xml SPNetworkLocationsDataType > locations.xml
system_profiler -xml SPManagedClientDataType > profiles.xml
system_profiler -xml SPMemoryDataType > memory.xml
system_profiler -xml SPNVMeDataType > nvme.xml
system_profiler -xml SPNetworkDataType > network.xml
system_profiler -xml SPPCIDataType > pci.xml
system_profiler -xml SPPowerDataType > power.xml
system_profiler -xml SPPrintersDataType > printers.xml
system_profiler -xml SPSerialATADataType > sata.xml
system_profiler -xml SPSmartCardsDataType > smartCard.xml
system_profiler -xml SPStartupItemDataType > startupItems.xml
system_profiler -xml SPStorageDataType > storage.xml
system_profiler -xml SPThunderboltDataType > thunderbolt.xml
system_profiler -xml SPUSBDataType > usb.xml
system_profiler -xml SPAirPortDataType > airport.xml
}

# mkdir ~/Desktop/outfiles
# cd ~/Desktop/outfiles

swVers=$(system_profiler SPSoftwareDataType | grep "System Version:" | awk '{print $3,$4}')

while true; do
	if [[ "$swVers" >= 10.14.* ]]
# 	if (( $swVers == 10.15* ))
# 	then function json
	then echo "it worked"; break
# else function xml
	else echo "it might not have worked"; break
	fi
done