//
//  main.swift
//  swiftMacWarranty
//
//
//

import Foundation

func usage() {
    print("Usage: getwarranty [OPTION ...] [SERIAL1 SERIAL2 ...]\n\n" +
    "List warranty information for one or more Apple devices.\n\n" +
    "If no serial number is provided on the command-line, the script will\n" +
    "assume it's running on an OS X machine and attempt to query the local\n" +
    "serial number and provide information regarding it.\n\n" +
    "Default output is \"ATTRIBUTE: value\", per line. Use the options below\n" +
    "for alternate format output.\n\n" +
    "Options:\n" +
    "-h, --help          Display this message\n" +
    "-f, --file FILE     Read serial numbers from FILE (one per line)\n" +
    "-o, --output        Save output to specified file instead of stdout\n" +
    "-c, --csv           Output in comma-separated format\n" +
    "-t, --tsv           Output in tab-separated format\n\n" +
    "Example usage:\n" +
    "Read from file, save to csv:    getwarranty -f serials.txt -o output.csv\n" +
    "Print local serial to stdout:   getwarranty\n" +
    "Several serials to stdout:      getwarranty SERIAL1 SERIAL2 SERIAL3\n")
    
    exit(0)
}

struct ModelDB {
    static var models = [String: String]()
}

func loadModelDb() -> [String: String] {
    do {
        var scriptDir:NSURL
        
        if !Process.arguments.isEmpty {
            let scriptPath = NSURL(fileURLWithPath: Process.arguments.first!)
            scriptDir = scriptPath.URLByDeletingLastPathComponent!
        }
        else {
            scriptDir = NSURL(fileURLWithPath: NSFileManager.defaultManager().currentDirectoryPath, isDirectory: true)
        }
        let modelSnippetsPath = scriptDir.URLByAppendingPathComponent("model_snippets.json")
        
        let modelData = NSData(contentsOfURL: modelSnippetsPath)
        if modelData != nil {
            let models = try NSJSONSerialization.JSONObjectWithData(modelData!, options: []) as! [String: String]
            return models
        }
    }
    catch {
        print("ERROR during loading model snippets: \(error)'")
    }
    
    return [String: String]()
}

func blankMachineDict() -> [String: String] {
    return [
        "SERIAL_ID": "",
        "PROD_DESCR": "",
        "ASD_VERSION": "",
        "EST_APPLECARE_END_DATE": "",
        "EST_MANUFACTURE_DATE": "",
        "EST_PURCHASE_DATE": "",
        "EST_WARRANTY_END_DATE": "",
        "EST_WARRANTY_STATUS": "",
        "PURCHASE_DATE": "",
        "WARRANTY_END_DATE": "",
        "WARRANTY_STATUS": "",
        "ERROR_CODE": "",
    ]
}

func appleYearOffset(dateobj: NSDate, years: Int = 0) -> NSDate {
    // Offset year by number of years
    
    return NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.Year, value: years, toDate: dateobj, options: NSCalendarOptions.init(rawValue: 0))!
}

func getSnippetFromSerial(serial: String) -> String? {
    var snippet:String
    
    switch serial.characters.count {
    case 11:
        snippet = serial.substringFromIndex(serial.endIndex.advancedBy(-3))
    case 12:
        snippet = serial.substringFromIndex(serial.endIndex.advancedBy(-4))
    case 3...4:
        snippet = serial
    default:
        return nil
    }
    
    return snippet
}

func offlineSnippetLookup(serial: String) -> String? {
    // http://support-sp.apple.com/sp/product?cc=%s&lang=en_US
    // https://km.support.apple.com.edgekey.net/kb/securedImage.jsp?configcode=%s&size=72x72
    // https://github.com/MagerValp/MacModelShelf
    // Serial Number "Snippet": http://www.everymac.com/mac-identification/index-how-to-identify-my-mac.html
    
    guard let snippet = getSnippetFromSerial(serial) else {
        return nil
    }
    
    return ModelDB.models[snippet]
}

func onlineSnippetLookup(serial: String) -> String? {

    guard let snippet = getSnippetFromSerial(serial) else {
        return nil
    }
    
    do {
        let prodXml = try NSXMLDocument(contentsOfURL: NSURL(string: "http://support-sp.apple.com/sp/product?cc=\(snippet)&lang=en_US")!, options: 0)
        return try prodXml.nodesForXPath("//configCode").first?.stringValue
    }
    catch {
        print("ERROR during online snippet lookup: \(error)'")
    }
    
    return nil
}

func offlineEstimatedManufacture(serial: String) -> String {
    // http://www.macrumors.com/2010/04/16/apple-tweaks-serial-number-format-with-new-macbook-pro/
    var estDate:String
    let serialLower = serial.lowercaseString

    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    switch serial.characters.count {
    case 11:
        // Old format
        let year = serialLower[serialLower.startIndex.advancedBy(2)]
        let yearSearchString = "   3456789012"
        let estYear = 2000 + yearSearchString.startIndex.distanceTo((yearSearchString.characters.indexOf(year))!)
        var yearTime = NSCalendar.currentCalendar().dateWithEra(1, year: estYear, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
        
        let week = Int(serial[serial.startIndex.advancedBy(3)..<serial.startIndex.advancedBy(5)])! - 1
        if week != 0 {
            yearTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.WeekOfYear, value: week, toDate: yearTime!, options: NSCalendarOptions.init(rawValue: 0))
        }
        
        estDate = formatter.stringFromDate(yearTime!)
    case 12:
        // New format
        let alphaYear = "cdfghjklmnpqrstvwxyz"
        let year = serialLower[serialLower.startIndex.advancedBy(3)]
        let estYear = 2010 + alphaYear.startIndex.distanceTo((alphaYear.characters.indexOf(year))!) / 2
        var yearTime = NSCalendar.currentCalendar().dateWithEra(1, year: estYear, month: 1, day: 1, hour: 0, minute: 0, second: 0, nanosecond: 0)
        
        // 1st or 2nd half of the year
        let estHalf = alphaYear.startIndex.distanceTo((alphaYear.characters.indexOf(year))!) % 2
        
        let week = serialLower[serialLower.startIndex.advancedBy(4)]
        let alphaWeek = " 123456789cdfghjklmnpqrtvwxy"
        let estWeek = alphaWeek.startIndex.distanceTo((alphaWeek.characters.indexOf(week))!) + estHalf * 26 - 1
        if estWeek != 0 {
            yearTime = NSCalendar.currentCalendar().dateByAddingUnit(NSCalendarUnit.WeekOfYear, value: estWeek, toDate: yearTime!, options: NSCalendarOptions.init(rawValue: 0))
        }
        
        estDate = formatter.stringFromDate(yearTime!)
    default:
        estDate = ""
    }
    
    return estDate
}

func offlineEstimatedApplecareEndDate(details: [String: String]) -> String {
    let manuDate  = details["EST_MANUFACTURE_DATE"]!
    let prodDescr = details["PROD_DESCR"]!

    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    if prodDescr.rangeOfString("iPhone") != nil || prodDescr.rangeOfString("iPad") != nil || prodDescr.rangeOfString("iPod") != nil {
        // iOS: Use date of manufacture + 2 years for max AppleCare coverage
        return formatter.stringFromDate(appleYearOffset(formatter.dateFromString(manuDate)!, years: 2))
    }
    else {
        // Mac: Use date of manufacture + 3 years for max AppleCare coverage
        return formatter.stringFromDate(appleYearOffset(formatter.dateFromString(manuDate)!, years: 3))
    }
}

func offlineEstimatedWarrantyEndDate(details: [String: String]) -> String {
    let manuDate  = details["EST_MANUFACTURE_DATE"]!
    
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    return formatter.stringFromDate(appleYearOffset(formatter.dateFromString(manuDate)!, years: 1))
}

func warranty(serial: String) -> [String: String] {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    var prodDict = blankMachineDict()
    prodDict["SERIAL_ID"] = serial
        
    // If it's not in the snippet database, look it up online
    let prodDescr = offlineSnippetLookup(prodDict["SERIAL_ID"]!) ?? ( onlineSnippetLookup(prodDict["SERIAL_ID"]!) ?? "" )
    if prodDescr.isEmpty {
        prodDict["ERROR_CODE"] = "Unknown model snippet"
    }
    prodDict["PROD_DESCR"] = prodDescr
        
    // Fill in some details with estimations
    prodDict["EST_MANUFACTURE_DATE"] = offlineEstimatedManufacture(serial)
    if !prodDict["EST_MANUFACTURE_DATE"]!.isEmpty {
        // Try to estimate when coverages expire
        prodDict["EST_PURCHASE_DATE"] = prodDict["EST_MANUFACTURE_DATE"]
        prodDict["EST_WARRANTY_END_DATE"] = offlineEstimatedWarrantyEndDate(prodDict)
        prodDict["EST_APPLECARE_END_DATE"] = offlineEstimatedApplecareEndDate(prodDict)
            
        if NSDate().timeIntervalSinceReferenceDate > formatter.dateFromString(prodDict["EST_APPLECARE_END_DATE"]!)!.timeIntervalSinceReferenceDate {
                prodDict["EST_WARRANTY_STATUS"] = "EXPIRED"
        }
        else if NSDate().timeIntervalSinceReferenceDate > formatter.dateFromString(prodDict["EST_WARRANTY_END_DATE"]!)!.timeIntervalSinceReferenceDate{
                prodDict["EST_WARRANTY_STATUS"] = "APPLECARE"
        }
        else {
                prodDict["EST_WARRANTY_STATUS"] = "LIMITED"
        }
    }

    return prodDict
}

func mySerial() -> [String] {
    let task = NSTask()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", "system_profiler SPHardwareDataType |grep -v tray |awk '/Serial/ {print $4}'"]
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    
    task.launch()
    task.waitUntilExit()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    if data.length > 0 {
        return String(data: data, encoding: NSUTF8StringEncoding)!.componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).filter{!$0.isEmpty}
    }
    
    return []
}

//////////////////////////////////////
// Process command line arguments
var format = "plain"
var output:String? = nil
var serials = [String]()

do {
    for var i = 1; i < Process.arguments.count; ++i {
        switch Process.arguments[i] {
        case "-h", "--help":
            usage()
        case "-f", "--file":
            serials = try String(contentsOfFile: Process.arguments[++i]).componentsSeparatedByCharactersInSet(NSCharacterSet.newlineCharacterSet()).filter{!$0.isEmpty}
        case "-o", "--output":
            output = Process.arguments[++i]
        case "-c", "--cvs":
            format = "csv"
        case "-t", "--tsv":
            format = "tsv"
        default:
            serials.append(Process.arguments[i])
        }
    }
}
catch {
    print("ERROR during parsing command line arguments: \(error)'")
    exit(0)
}

if serials.isEmpty {
    serials = mySerial()
}

//////////////////////////////////////
ModelDB.models = loadModelDb()

var warrantyDicts = [[String: String]]()

for serial in serials {
    let result = warranty(serial)
    warrantyDicts.append(result)
}

if format == "plain" {
    var plainFormat = ""
    for result in warrantyDicts {
        plainFormat += "SERIAL_ID: \(result["SERIAL_ID"]!)\n"
        plainFormat += "PROD_DESCR: \(result["PROD_DESCR"]!)\n"
        for key in result.keys.sort() {
            if !["SERIAL_ID", "PROD_DESCR", "ERROR_CODE"].contains(key) {
                plainFormat += "\(key): \(result[key]!)\n"
            }
        }
        plainFormat += "ERROR_CODE: \(result["ERROR_CODE"]!)\n\n"
    }
    
    if output != nil {
        do {
            try plainFormat.writeToFile(output!, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {
            print("ERROR during writing results to output file: \(error)'")
        }
    }
    else {
        print(plainFormat)
    }
}
else {
    var separator:String
    
    switch format {
    case "csv":
        separator = ","
    case "tsv":
        separator = "\t"
    default:
        separator = ","
    }
    
    var headers = ["SERIAL_ID", "PROD_DESCR"]
    for key in blankMachineDict().keys.sort() {
        if !["SERIAL_ID", "PROD_DESCR", "ERROR_CODE"].contains(key) {
            headers.append(key)
        }
    }
    headers.append("ERROR_CODE")
    headers = headers.map{"\"\($0.stringByReplacingOccurrencesOfString("\"", withString: "\"\""))\""}
    
    var csvLines = [String]()
    csvLines.append(headers.joinWithSeparator(separator))
    
    for result in warrantyDicts {
        var line = [result["SERIAL_ID"]!, result["PROD_DESCR"]!]
        for key in result.keys.sort() {
            if !["SERIAL_ID", "PROD_DESCR", "ERROR_CODE"].contains(key) {
                line.append(result[key]!)
            }
        }
        line.append(result["ERROR_CODE"]!)
        line = line.map{"\"\($0.stringByReplacingOccurrencesOfString("\"", withString: "\"\""))\""}
        csvLines.append(line.joinWithSeparator(separator))
    }

    if output != nil {
        do {
            try csvLines.joinWithSeparator("\n").writeToFile(output!, atomically: true, encoding: NSUTF8StringEncoding)
        }
        catch {
            print("ERROR during writing results to output file: \(error)'")
        }
    }
    else {
        print(csvLines.joinWithSeparator("\n"))
    }
}






