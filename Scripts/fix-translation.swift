#!/usr/bin/env swift

import Foundation

guard CommandLine.arguments.count > 2 else {
    print("This helper tool replaces empty Localized Strings found in *File A*, with the ones found in *File B*")
    print("Usage: fix-translation path/to/Localizable.strings path/to/Failsafe.strings")
    exit(1)
}

/// Replaces all of the **Empty Strings** in the specified file, with the entries contained in a "Fallback Map".
///
func replaceEmptyTranslations(in filename: String, fallbackMap: [String: String]) throws {
    var encoding = String.Encoding.utf8
    let contents = try String(contentsOfFile: filename, usedEncoding: &encoding)
    var output = ""

    contents.enumerateLines { line, _ in
        let fixed = stringByFixingEmptyValue(in: line, fallbackMap: fallbackMap)
        output.append(fixed)
        output.append("\n")
    }

    try output.write(toFile: filename, atomically: true, encoding: encoding)
}

/// Fixes empty assignment strings with the value extracted from the `fallbackMap` (if needed)
///
func stringByFixingEmptyValue(in string: String, fallbackMap: [String: String]) -> String {
    let range = NSRange(location: .zero, length: string.count)
    let regexp = try! NSRegularExpression(pattern: "^\"(.*)\" = \"\";$", options: [])

    guard let match = regexp.matches(in: string, options: [], range: range).first,
        let key = extractSubstring(from: string, match: match, rangeIndex: 1),
        let fixedValue = fallbackMap[key]
        else {
            return string
    }

    return String(format: "\"%@\" = \"%@\";", key, fixedValue)
}

/// Extracts the substring from the specified TextCheckingResult Range, if possible.
///
func extractSubstring(from string: String, match: NSTextCheckingResult, rangeIndex: Int) -> String? {
    guard rangeIndex < match.numberOfRanges else {
        return nil
    }

    let range = match.range(at: 1)
    return (string as NSString).substring(with: range)
}

/// Loads a Localizations file in memory, and returns a Dictionary with its contents.
///
func loadStrings(from filename: String) throws -> [String: String] {
    let contents = try String(contentsOfFile: filename)
    let regexp = try NSRegularExpression(pattern: "^\"(.*)\" = \"(.*)\";$", options: [])
    var output = [String: String]()

    contents.enumerateLines { line, _ in
        let lineRange = NSRange(location: .zero, length: line.count)
        guard let match = regexp.matches(in: line, options: [], range: lineRange).first, match.numberOfRanges > 2 else {
            return
        }

        let foundationString = line as NSString
        let lhsRange = match.range(at: 1)
        let rhsRange = match.range(at: 2)

        let key = foundationString.substring(with: lhsRange)
        let value = foundationString.substring(with: rhsRange)

        output[key] = value
    }

    return output
}

/// Main!
///
do {
    let targetFilename = CommandLine.arguments[1]
    let fallbackFilename = CommandLine.arguments[2]

    let fallbackMap = try loadStrings(from: fallbackFilename)
    try replaceEmptyTranslations(in: targetFilename, fallbackMap: fallbackMap)
} catch {
    print(error)
}
