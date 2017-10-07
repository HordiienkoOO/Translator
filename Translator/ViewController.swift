//
//  ViewController.swift
//  Translator
//
//  Created by Admin on 29.09.17.
//  Copyright © 2017 cahebu4. All rights reserved.
//


import Cocoa

class ViewController: NSViewController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var textField: NSTextView!
    @IBOutlet weak var lexemes: NSTableView!
    @IBOutlet weak var identifiers: NSTableView!
    @IBOutlet weak var constants: NSTableView!
    
    var outputTable : [(String, Int)]!
    var identifiersTable : [String]!
    var constantsTable : [String]!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lexemes.dataSource = self
        self.lexemes.delegate = self
        
        self.identifiers.dataSource = self
        self.identifiers.delegate = self
        
        self.constants.dataSource = self
        self.constants.delegate = self
        
        self.outputTable = [(String, Int)]()
        self.identifiersTable = [String]()
        self.constantsTable = [String]()
    }


    @IBAction func compileButtonTapped(sender: NSButton) {
        outputTable.removeAll()
        identifiersTable.removeAll()
        constantsTable.removeAll()
        
        
        let enteredText = textField.string
        let lines = enteredText.lines
        var pseudoLexemes = [String]()
        
        for line in lines {
            
            // All line is a COMMENT
            if line.isComment {
                print("COMMENTED LINE: \(line)")
                continue
            }
            
            // Declaration line
            if line.isDeclaration {
                pseudoLexemes.append(line.clearLine)
                continue
            }
            
            // Last part of line is a COMMENT
            let wordsInLine = line.components(separatedBy: [" ", "\t", "\n", " "])
            for word in wordsInLine {
                if word.isComment { break }
                if word == "" { continue }
                pseudoLexemes.append(word)
            }
        }
        
        self.createoutPutTableFrom(pseudoLexemes)
        
        self.lexemes.reloadData()
        self.identifiers.reloadData()
        self.constants.reloadData()
    }
    
    
    func createoutPutTableFrom(_ words: [String]) {
        for word in words {
            
            if word.isDeclaration { parseDeclarationLine(word); continue }
            if (compareWithLexemesFromTable(word)) { continue }
            parseExpression(word, declarate: false)
        }
        
    }
    
    

    // MARK: Parsing complex expression
    func parseExpression(_ exp: String, declarate: Bool) -> Void {
        if exp == "" { return }
        
        var founded = false
        var separated = false
        
        for character in exp {
            if founded { break }
            for i in 0..<OP.count {
                if String(character) == OP[i] {
                    founded = true
                    separated = true
                    
                    let components = exp.components(separatedBy: OP[i])
                    
                    for part in components {
                        parseExpression(part, declarate: declarate)
                        outputTable.append((OP[i], i+16))
                    }
                    self.outputTable.removeLast()
                }
            }
        }
        
        // MARK: Parsing if !TableValue and !Separated
        if !compareWithLexemesFromTable(exp) && !separated {
            
            if exp.isConstant {
                self.outputTable.append((exp, 32))
                if constantsTable.contains(exp) {
                    print("NEXT CONSTANT IS ALREADY IN TABLE: \(exp)")
                    return
                }
                self.constantsTable.append(exp)
                return
            }
            
            if declarate {
                
                self.outputTable.append((exp, 31))
                
                if identifiersTable.contains(exp) {
                    print("REDEFENITION OF IDENTIFIER: \(exp)")
                    _ = showAlertWith(title: "Ошибочка :)", text: "Этот идентификатор уже обьявлен:  \(exp)")
                    return
                }
                
                self.identifiersTable.append(exp)
                return
            }
            
            if identifiersTable.contains(exp) {
                self.outputTable.append((exp, 31))
                return
            }
            
            print("URESOLVED IDENTIFIER USED: \(exp)")
            _ = showAlertWith(title: "Ошибочка :)", text: "Использован необьявленный идентификатор:  \(exp)")
            self.outputTable.append((exp, 0))
        }
        
    }
    
    
    func parseDeclarationLine(_ line: String) {
        
        var expressionForDeclaration = line
        
        if line.isIntegerType {
            outputTable.append(("int", 4))
            expressionForDeclaration.removeFirst(3)
            
        } else if line.isDoubleType {
            outputTable.append(("double", 5))
            expressionForDeclaration.removeFirst(6)
        } else if line.isLabelType {
            outputTable.append(("label", 6))
            expressionForDeclaration.removeFirst(5)
        } else if line.isProgramName {
            outputTable.append(("program", 1))
            expressionForDeclaration.removeFirst(7)
        }
        
        let components = expressionForDeclaration.components(separatedBy: [" ", "\t", "\n", " "])
        for component in components {
            if compareWithLexemesFromTable(component) { continue }
            parseExpression(component, declarate: true)
        }
        
    }
    
    
    func compareWithLexemesFromTable(_ lexeme: String) -> Bool {
        var lex = false
        
        for i in 1..<lexems.count {
            if lexeme == lexems[i] {
                lex = true
                outputTable.append((lexeme, i))
            }
        }
        
        return lex
    }
    
    
    
    let lexems = [
        "err :D",       // 0
        "program",      // 1
        "{",            // 2
        "}",            // 3
        "int",          // 4
        "double",       // 5
        "label",        // 6
        "goto",         // 7
        "read",         // 8
        "write",        // 9
        "if",           // 10
        "for",          // 11
        "to",           // 12
        "by",           // 13
        "while",        // 14
        "rof",          // 15
        ">",            // 16
        "==",           // 17
        "<",            // 18
        "<=",           // 19
        ">=",           // 20
        "!=",           // 21
        "+",            // 22
        "-",            // 23
        "*",            // 24
        "/",            // 25
        "=",            // 26
        ":",            // 27
        "(",            // 28
        ")",            // 29
        ",",            // 30
        "id",           // 31
        "con",          // 32
        "lab"           // 33
    ]
    
    let OP = [
        ">",
        "==",
        "<",
        "<=",
        ">=",
        "!=",
        "+",
        "-",
        "*",
        "/",
        "=",
        ":",
        "(",
        ")",
        ","
    ]
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == lexemes { return outputTable?.count ?? 0 }
        if tableView == identifiers { return identifiersTable?.count ?? 0}
        if tableView == constants { return constantsTable?.count ?? 0}
        return 0
    }
    
    fileprivate enum CellIdentifiers {
        static let lexemeCell = "lexeme"
        static let lexemeCodeCell = "lexemeCode"
        
        static let identifierCell = "identifier"
        static let identifierCodeCell = "identifierCode"
        
        static let constantCell = "constant"
        static let constantCodeCell = "constantCode"
    }
    

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier: String = ""
        
        
        if tableColumn == lexemes.tableColumns[0] {
            text = outputTable[row].0
            cellIdentifier = CellIdentifiers.lexemeCell
        } else if tableColumn == lexemes.tableColumns[1] {
            text = String(outputTable[row].1)
            cellIdentifier = CellIdentifiers.lexemeCodeCell
        } else
        
        if tableColumn == identifiers.tableColumns[0] {
            text = identifiersTable[row]
            cellIdentifier = CellIdentifiers.identifierCell
        } else if tableColumn == identifiers.tableColumns[1] {
            text = String(row+1)
            cellIdentifier = CellIdentifiers.identifierCodeCell
        } else
        
        if tableColumn == constants.tableColumns[0] {
            text = constantsTable[row]
            cellIdentifier = CellIdentifiers.constantCell
        } else if tableColumn == constants.tableColumns[1] {
            text = String(row+1)
            cellIdentifier = CellIdentifiers.constantCodeCell
        }
        
        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
 
        return nil
    }
    
    func showAlertWith(title: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        return alert.runModal() == .alertFirstButtonReturn
    }
}

    



