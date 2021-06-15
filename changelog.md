# Change-log:


# v2.2 - 6/15/21
bug fixes - big sur
- fixed graphics info section regarding metal support not printing correctly
- fixed battery info section to correctly detail the information available on big sur

changes
- reintroduced output of system profile in xml/json
- now exports relevent facets to a folder named after the host machine's serial number
    - this can be annoying if this extra output is not desiered
    - comment out "OUTPUTSTART" near the end of MAIN if this additional output is undesired



# v2.2 - In progress - 6/11/21

bug fixes - big sur
- graphics info section reporting "Metal: Not Supported" incorrectly
    - system_profiler does not include this section since it will only run on metal-supported graphics natively
    - introduced nested if statements to evaulate software version if that section is not found, needs further testing
- battery info section
    - added conditionals to fix blank prints, tested on 16-inch mbp

changes
- scaled down shutdown log to parse only 10 days instead of 14
    - still trying to find a good balance between collecting enough data and how long it takes to return data
- added boot mode printing in the system overview section
    - seems to be working but needs further testing for version compatibility
- removed version numbers from the notifications
- cleaned up the osascript prompts and their buttons



# v2.1 beta2 —update 5/24/21
improved functionality of network information printing
- conditional logic dependent on active network interface
    - support on Mac Pro needs further testing
        - there’s still some issues with network configuration info
        - it may be too variable between different machines to depend on it working 100% of the time
- fixed display type blank printing
    - will determine if display type is a TV, or print nothing
- fixed bluetooth version printing
- added the product description back from the original diag script
    - issues with this
        - on later versions of macOS the program may not run
        - to compensate, there’s a fallback that it will use the system profiler name description
- tested the script on an M1 MBA running 11.2


# v2.1 beta2 — 5/18/21
Version compatibility issues resolved
- Fixed some more blank prints on legacy versions
- Better functionality in network info printing
    - Still needs a bit of work, its not very dynamic
        - Think I broke IPv4 info
        - Need to make this conditional



# v2.1 beta — 5/17/21
Squashed some bugs
- blank spaces (still more to go)
- Double prints (probably more I haven’t thought of yet)
- Shutdown log not running sometimes
- Malware scan not running sometimes

Added support for
- Json output in macOS Catalina
    - Need to add logic for Big Sur and test it
- Xml output in legacy versions of macOS
    - Needs testing

Future versions
- Going to need to include separate functions for legacy compatibility 
- Will include logic that does something with the outFiles (json output)
- Will include a python module to parse xml output and convert it to csv
- Progress bar cleanup
    - Needs more steps so it looks more realistic
    - Adding description of progress for the bored user to read
- Background heavier functions to make better use of parallel processing
    - User directory usage (du is kind of heavy)
    - I imagine disk usage will be more expensive on rotational mediums



# v2.1 alpha — 5/10/21
Complete overhaul of the code
- Dependent functions are now properly functional-ized
    - Use local variables and global where appropriate
- Error output is suppressed from within rather than from without
- Functions to evaluate proper course for the program to run
    - These depend on multiple evaluations at different points to determine which path to completion should be followed
- Functions fork off of main where appropriate
- Wider compatibility achieved through variable functions for different machines
- Added notifications for the end user as the program progresses

Support now added for:
- Upgradeable memory
- Metal-capable graphics
- Proper display type & resolution printing
- Properly handled dual graphics MacBooks
- Properly handled dual graphics in Mac Pro 6,1
- AC Charger information
- Properly handled IPv6 configurations
- Filesystem info, ownership, device name, dev node, and attachment protocol
- FileVault status printing

Running on:
- MacBooks (13 inch & smaller models)
- MacBooks (15/16 inch & dual graphics models)
- iMac
- Mac Pro 5,1 (and possibly earlier)
- Mac Pro 6,1 (dual graphics models included)

Need to re-introduce external functions now:
- SMART stats??
    - Going to run these in the background
        - These will output to /tmp so the end user will never see them
        - These will run in parallel so that the program will be more efficient
        - The program will not exit before all of the external functions have been completed
        - The external functions will concatenate to the final report upon completion of main


# v2.0.4b — 5/6/21
Working on adding desktop functionality
- Conditional functions for desktop-related functions
- Fixed conditional for laptops with discreet graphics



# v2.0.4a — 5/4/21
- Added SPD memory bank info
    - Prints individual banks as well as the total ram installed like before
- Piped the shutdown log output so that its less verbose
    - Only includes time, date, and shutdown cause now
- Variable-ized the $! $pid functions properly so that there can now be multiple backgrounded processes
    - DetectX and log show both run in the background w/ wait functions
- Trying to add an evaluation function to determine the percentage of disk space used
    - Need to do some research here



# v2.0.4a — 5/3/21
- Re-organized code so that it makes more sense
    - Variables come right before their dependent functions now
- Backgrounding log function, assigning its PID to $pid
    - This way we can wait for it to complete before exiting the script
- Looking to get rid of smartmontools
    - drivedx is just so much better for human readable output
    - Sent support an email about raw value conversion
    - We may be able to use smartmon with Munin for graphing drive deterioration over time
- Discovered bug with disk available,
    - In earlier versions its not listed as “Available:” but “Free:”
    - Maybe add a conditional for this?
    - Jeff said fuck it and just worry about 10.15 and up
- Found more reliable way to check filesystem for fsck log conditional



# v2.0.4 — 4/23/21
- Added conditional statement for fsck logs
    - Will print apfs or hfs log dependent on disk0s2’s type
- Added ./jsonProfiler to run in the background at the beginning of script



# v2.0.4 — 4/22/21
- State of affairs
    - Formatting seems to be holding up well 
        - Need to see how well it holds up across different versions of macOS
    - Need to add json exporting functions
        - More research is required on AWS integrations
    - Code should be functionalized at some point
        - Ideally it should be cross-compatible across as many versions of OS X/macOS as possible
        - Different functions can be conditional depending on software version
    - Reading about Addigy
        - Looks pretty good, ability to run commands remotely
            - Would make it very easy to run diagnostic script via this avenue
        - Seems expensive, $6/month per feature according to some reviews
            - They don’t directly list their pricing model anywhere on their site
                - Only offer to submit your information to request a quote
- Additions
    - Previous shutdown cause logs included in the report
        - This slows the script down dramatically
        - Possible solution: set it to run at the beginning, and add a wait so that the program doesn’t exit before log show retrieves its data
            - This will require some research, trial & error, etc
    - File system checker logs summary added
        - Apfs only
        - Hfs is available
        - Not sure if this will make the final cut
        - Would be awesome to be able to get an idea of the state of the operating system w/o having to external boot to run tech tool
    - DetectX Swift 1.0971 — latest version included
        - No licensing requirement, commercial or otherwise, according to email from Sqwarq
        - We have to see how far back this version will work
        - It may be necessary to keep an older version on hand for backwards compatibility
            - Can add a conditional that will choose which version to run depending on the software version
        - Changed the order of operations for simplicity
            - DetectX used to run at the beginning, now it runs in the “echo” section with the rest of the information
            - Slows down the progress, but this way we don’t need to create and cleanup any additional files
    - Smartmontools for SMART stats
        - Offers command-line integrations, as well as the ability to output to json format
        - The information it provides is not nearly as comprehensive or human-readable as DriveDX was
            - We should consider other options as well
- Subtractions
    - mkdir .tmp removed
        - Previously this was included so that DetectX could run in parallel while the rest of the operations continued on, then later it could read from the separate file it created and send that to the final report
    - DriveDX removed
        - Replaced by smartmontools for monitoring SMART stats
    - Warranty check
        - Not really sure what was going on with that originally
        - There were bits and pieces that were left in the original Remote.sh that didn’t do anything
        - Might be worth some research to see if viable alternative program exists that we can use instead
    - Wireless rates
        - Re-worked to be more verbose
