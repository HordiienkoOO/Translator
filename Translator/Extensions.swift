//
//  Extensions.swift
//  Translator
//
//  Created by Admin on 04.10.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//

import Foundation

extension String {
    
    var isComment : Bool {
        if !self.isEmpty {
            let clearLine = self.clearLine
            if clearLine.count > 1 {
                if clearLine.substring(with: NSRange(location: 0, length: 2)) == "//" {
                    return true
                }
            }
        }
        return false
    }
    
    
    // TODO: Check 1.2E+4, etc.
    var isConstant : Bool {
        if Double(self) != nil { return true }
     
        let components = self.components(separatedBy: ".")
        if components.count > 2 { return false }
        
        if components.count == 1 && Double(components[0]) != nil { return true }
        if Double(components[0]) != nil && Double(components[1]) != nil { return true }
        // TODO: Dobavit' mantisu
        return false
    }
    
    var isDeclaration : Bool {
        if self.isIntegerType || self.isDoubleType || self.isLabelType || self.isProgramName { return true }
        return false
    }
    
    var isProgramName : Bool {
        let clearLine = self.clearLine
        if (clearLine.count >= 7 && clearLine.substring(with: NSRange(location: 0, length: 7)) == "program") { return true }
        return false
    }
    
    var isIntegerType : Bool {
        let clearLine = self.clearLine
        if (clearLine.count >= 3 && clearLine.substring(with: NSRange(location: 0, length: 3)) == "int") { return true }
        return false
    }
    
    var isDoubleType : Bool {
        let clearLine = self.clearLine
        if (clearLine.count >= 6 && clearLine.substring(with: NSRange(location: 0, length: 6)) == "double") { return true }
        return false

    }
    
    var isLabelType : Bool {
        let clearLine = self.clearLine
        if (clearLine.count >= 3 && clearLine.substring(with: NSRange(location: 0, length: 5)) == "label") { return true }
        return false
    }
    
    var lines: [String] {
        var result: [String] = []
        enumerateLines { line, _ in result.append(line) }
        return result
    }
    
    var clearLine : String {
        return String(self.characters.filter { !"\t".characters.contains($0) })
    }
    
  
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
    
}
