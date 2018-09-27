//
//  CompanyDS.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 11/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa
import SQLite3

class CompDataModel {
    
    static let compSharedInstance = CompDataModel()
    
    private init() {
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            
            print("File \(fileURL) opened OK")
        } else {
            
            print("File \(fileURL) failed to open")
        }
        
        getCompany()
    }
    
    var db: OpaquePointer?
    
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GreenStreetCRM.db")
    
    let selectCompanyStatement = "select * from company order by company;"
    
    let deleteCompanyStatement = "delete from company where idcompany = ?;"
    
    let maxSelectStatement = "select max(idcompany), company from company;"
    
    let insertStatement = "insert into company (idcompany, company, comptype) values (?, ?, ?);"
    
    let getPrimarySelect = "select idcompany from company where company = ?;"
    
    let getSingleCompany = "select * from company where idcompany = ?;"
    
    let updateString = "update company set company = ?, comptype = ? where idcompany = ?"
    
    let chkContacts = "select idcontact from contact where idcompany = ?;"
    
    var compArray: NSMutableArray = []
    
    var compIndex: Array<String> = []
    
    var nxtIdCompany: Int32 = 0
    
    var ind99 = 2
    
    
    //Function to get all companies from db
    func getCompany() {
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectCompanyStatement, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let companyName = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let companyType = String(cString: queryResultCol2!)
                let dict = ["idCompany": id, "company": companyName, "compType": companyType] as [String : Any]
                compArray.add(dict)
                compIndex.append(companyName)
            }
            
        }
        
        sqlite3_finalize(queryStatement)
    }
    
    //method to delete record
    //Accepts an id parameter
    func deleteRecord(_ id: Int) {
        
        var deleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, deleteCompanyStatement, -1, &deleteStatement, nil) == SQLITE_OK {
            
            
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                
                print("Successfully deleted row with compani \(id).")
            } else {
                print("Could not deleted row.")
            } } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(deleteStatement)
        
             
        }
    
    //Function to get the next number to be used when performing an insert
    func getMaxID() -> Int32
    {
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, maxSelectStatement, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let idc: Int32 = sqlite3_column_int(queryStatement, 0)
                nxtIdCompany = idc + 1
                
            } else {
                print("No results")
            }
            
            
        }
        
        sqlite3_finalize(queryStatement)
        
        return nxtIdCompany
    
    }

    //Function to insert a company based on a company struct passed in as parameter
    func insert(company: CompanyStruct) {
        var insStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatement, -1, &insStatement, nil) == SQLITE_OK {
            
            let ic: Int32 = Int32(company.idCompany)
            let cn: NSString = company.company as NSString
            let ct: NSString = company.compType as NSString
            
            sqlite3_bind_int(insStatement, 1, ic)
            sqlite3_bind_text(insStatement, 2, cn.utf8String, -1, nil)
            sqlite3_bind_text(insStatement, 3, ct.utf8String, -1, nil)
            
            if sqlite3_step(insStatement) == SQLITE_DONE {
                
                print("Successfully inserted row \(company).")
            } else {
                print("Could not insert row.")
            } } else {
            print("INSERT statement could not be prepared.")
        }
        sqlite3_finalize(insStatement)
        
        compArray.removeAllObjects()
        compIndex.removeAll()
        getCompany()
    }

//Function to return a single company record 
        
    func getSingleCompany(ic: Int) -> CompanyStruct {
        
        var queryStatement: OpaquePointer? = nil
        var cmp = CompanyStruct.init(idCompany: 0, company: "", compType: "")
        
        if sqlite3_prepare_v2(db, getSingleCompany, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(ic))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let companyName = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let companyType = String(cString: queryResultCol2!)
                
                cmp.idCompany = Int(id)
                cmp.company = companyName
                cmp.compType = companyType
                
            }
        }
    
        sqlite3_finalize(queryStatement)
        
        return cmp
        }
    
    func updateCompany(company: CompanyStruct) {
        
        var updateStatement: OpaquePointer? = nil
        let ic: Int32 = Int32(company.idCompany)
        let cn: NSString = company.company as NSString
        let ct: NSString = company.compType as NSString
        
        if sqlite3_prepare_v2(db, updateString, -1, &updateStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(updateStatement, 1, cn.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 2, ct.utf8String, -1, nil)
            sqlite3_bind_int(updateStatement, 3, Int32(ic))
        
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                
                print("Successfully updated row \(company).")
            } else {
                print("Could not update row.")
            } } else {
            print("update statement could not be prepared.")
        
        }
        sqlite3_finalize(updateStatement)
        
        compArray.removeAllObjects()
        compIndex.removeAll()
        getCompany()
    }
    
    func getPrimaryKey(company: String) -> Int {
        
        var queryStatement: OpaquePointer? = nil
        var idc = 0
        let cn: NSString = company as NSString
        
        if sqlite3_prepare_v2(db, getPrimarySelect, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(queryStatement, 1, cn.utf8String, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                idc = Int(sqlite3_column_int(queryStatement, 0))
                
               
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return idc
    }
    
    //Function to check for the existence of contacts
    func checkContacts(ic: Int) -> Int
    {
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, chkContacts, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(Int(ic)))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                ind99 = 1 //we have found a record on contacts
                
            } else {
                
                ind99 = 0 //there are no contact records for this company
                
            }
            
        }
        
        sqlite3_finalize(queryStatement)
        
        return ind99
        
    }
    
//class close bracket
}
