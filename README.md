# DiagnosticTool

written for The Mac Support Store by Rich Wright

# Scope
This tool is intended to help automate Macintosh diagnostics. It relies heavily on system_profiler to pull relevent information about the host machine and generates a report with this information.

# Use Case
Can be used in person or in remote diagnostic applications.

# Caveats
Depending on the macOS version, errors may be encountered with some of the functions of this tool. I've tried my best to mitigate and/or work around some of them, and this is a work in progress.

# Version Compatability
Tested extensively on macOS Catalina, and most outputs are generally as expected across all Mac models. However it is quite challenging to outline every caveat in every specific machine across every single software version -- so expect some bugs here and there.

# Known Issues
macOS Big Sur
- some of the outputs print blank spaces in the final report, I haven't been able to test as extensively on 11.X yet

Legacy versions of macOS/OS X
- the information system_profiler provides varies between software versions, so not every output will work on every software version
- I've gone to great length to ensure that most of the important information is printed across various machines, but most of my focus has been on later/current versions of macOS
