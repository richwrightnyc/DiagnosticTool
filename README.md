# DiagnosticTool

A bash tool written to generate a report on a host machine, designed to assist in Mac diagnostics. Written for The Mac Support Store by Rich Wright.

# Scope
This tool is intended to help automate Macintosh diagnostics. It relies heavily on system_profiler to pull relevent information about the host machine and generates a report with this information. See the sampleOutput.txt file in the main branch for a better understanding of what it does. Eventually the goal is to port this to Swift, and compile it into a full scale application.

# Use Case
Can be run locally or remotely. Either clone the repo or download the disk image (.dmg file), attach it & run the binary executable. There may be issues on later versions of macOS with permissions, mainly that some of the external functions may need to be run separately from the program. Find them in the hidden ".Resources" folder on the disk image. The disk image contains everything needed for the program to function, all of the contents are included in this repo for transparency.

# Caveats
Depending on the macOS version, errors may be encountered with some of the functions of this tool. I've tried my best to mitigate and/or work around some of them, and this is a work in progress. If you have any feedback please drop me a line.

# Version Compatability
Tested extensively on macOS Catalina, and most outputs are generally as expected across all Mac models. However it is quite challenging to outline every caveat in every specific machine across every single software version -- so expect some bugs here and there. Again, feel free to report any bugs you may encounter, and also any ideas for improvements, etc.

# Known Issues
macOS Big Sur
- some of the outputs print blank spaces in the final report, I haven't been able to test as extensively on 11.X yet

Legacy versions of macOS/OS X
- the information system_profiler provides varies between software versions, so not every output will work on every software version
- I've gone to great length to ensure that most of the important information is printed across various machines, but most of my focus has been on later/current versions of macOS


# Thanks to

krypted for swiftwarrantylookup, find it here: https://github.com/krypted/swiftwarrantylookup

Binary Fruit for DriveDx, find it here: https://binaryfruit.com/drivedx

Sqwarq for DetectX Swift, find it here: https://sqwarq.com/detectx/
