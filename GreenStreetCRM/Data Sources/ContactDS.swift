//
//  ContactDS.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 15/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa
import SQLite3

class ContDataModel {
    
    static let contSharedInstance = ContDataModel()
    
    private init() {
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            
        } else {
            
        }
        
        getContact()
        
    }
    
    
    var db: OpaquePointer?
    
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GreenStreetCRM.db")
    
    let selectContactStatement = "SELECT IDCONTACT, COMPANY, LISTNAME, EMAIL, DD, MOBILE FROM Contact INNER JOIN Company ON Company.IDCOMPANY = Contact.IDCOMPANY order by listname;"
    
    let deleteContactStatement = "delete from contact where idcontact = ?;"
    
    let maxSelectStatement = "select max(idcontact) from contact;"
    
    let insertStatement = "insert into contact (idcontact, idcompany, firstname, lastname, listname, email, dd, mobile) values (?, ?, ?, ?, ?, ?, ?, ?);"
    
    let getPrimarySelect = "select idcontact from contact where listname = ?;"
    
    let getSingleContact = "SELECT IDCONTACT, contact.IDCOMPANY, COMPANY, FIRSTNAME, LASTNAME, LISTNAME, EMAIL, DD, MOBILE FROM Contact INNER JOIN Company ON Company.IDCOMPANY = Contact.IDCOMPANY where idcontact = ?;"
    
    let updateString = "update contact set idcompany = ?, firstname = ?, lastname = ?, listname = ?, email = ?, dd = ?, mobile = ? where idcontact = ?;"
    
    let getContactForCompany = "select listname from contact where idcompany = ?;"

    let chkOpps = "select idopportunity from opportunity where idcontact = ?;"
    
    var contArray: Array<ContactStruct> = []
    
    var contIndex: Array<String> = []
    
    var nxtIdContact: Int32 = 0
    
    var ind99 = 2
    
    //Function to get the next number to be used when performing an insert
    func getMaxID() -> Int32
    {
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, maxSelectStatement, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let idc: Int32 = sqlite3_column_int(queryStatement, 0)
                nxtIdContact = idc + 1
                
            }
            
        }
        
        sqlite3_finalize(queryStatement)
        
        return nxtIdContact
        
    }
    
    
    //Function to get all contacts from db
    func getContact() {
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectContactStatement, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let ctid = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let company = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let listName = String(cString: queryResultCol2!)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
                let email = String(cString: queryResultCol3!)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
                let dd = String(cString: queryResultCol4!)
                let queryResultCol5 = sqlite3_column_text(queryStatement, 5)
                let mobile = String(cString: queryResultCol5!)
                
                
                let cont = ContactStruct(idContact: 0, idCompany: 0, company: "", firstName: "", lastName: "", listName: "", email: "", DD: "", mobile: "")
                
                cont.idContact = Int(ctid)
                cont.company = company
                cont.listName = listName
                cont.email = email
                cont.DD = dd
                cont.mobile = mobile
                
                contArray.append(cont)
                contIndex.append(listName)
            } 
        }
        
        sqlite3_finalize(queryStatement)
    }
    
    //method to delete record
    //Accepts an id parameter
    func deleteRecord(_ id: Int) {
        
        var deleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, deleteContactStatement, -1, &deleteStatement, nil) == SQLITE_OK {
            
            
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
              
            } else {
                
            } } else {
            
        }
        sqlite3_finalize(deleteStatement)
        }
    
    //Function to return a single contact object
    
    func getSingleContact(ic: Int) -> ContactStruct {
        
        var queryStatement: OpaquePointer? = nil
        let con = ContactStruct.init(idContact: 0, idCompany: 0, company: "", firstName: "", lastName: "", listName: "", email: "", DD: "", mobile: "")
        
        if sqlite3_prepare_v2(db, getSingleContact, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(ic))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let id = sqlite3_column_int(queryStatement, 0)
                let ic = sqlite3_column_int(queryStatement, 1)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 2)
                let companyName = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 3)
                let firstName = String(cString: queryResultCol2!)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 4)
                let lastName = String(cString: queryResultCol3!)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 5)
                let listName = String(cString: queryResultCol4!)
                let queryResultCol5 = sqlite3_column_text(queryStatement, 6)
                let email = String(cString: queryResultCol5!)
                let queryResultCol6 = sqlite3_column_text(queryStatement, 7)
                let DD = String(cString: queryResultCol6!)
                let queryResultCol7 = sqlite3_column_text(queryStatement, 8)
                let mobile = String(cString: queryResultCol7!)
                
                con.idContact = Int(id)
                con.idCompany = Int(ic)
                con.company = companyName
                con.firstName = firstName
                con.lastName = lastName
                con.listName = listName
                con.email = email
                con.DD = DD
                con.mobile = mobile
                
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return con
        
    }
    
    //Function to insert a contact based on a contact struct passed in as parameter
    func insert(contact: ContactStruct) {
        var insStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatement, -1, &insStatement, nil) == SQLITE_OK {
            
            let ic: Int32 = Int32(contact.idContact)
            let idc: Int32 = Int32(contact.idCompany)
            let fn: NSString = contact.firstName as NSString
            let ln: NSString = contact.lastName as NSString
            let lisn: NSString = contact.listName as NSString
            let email: NSString = contact.email! as NSString
            let dd: NSString = contact.DD! as NSString
            let mob: NSString = contact.mobile! as NSString
            
            
            sqlite3_bind_int(insStatement, 1, ic)
            sqlite3_bind_int(insStatement, 2, idc)
            sqlite3_bind_text(insStatement, 3, fn.utf8String, -1, nil)
            sqlite3_bind_text(insStatement, 4, ln.utf8String, -1, nil)
            sqlite3_bind_text(insStatement, 5, lisn.utf8String, -1, nil)
            sqlite3_bind_text(insStatement, 6, email.utf8String, -1, nil)
            sqlite3_bind_text(insStatement, 7, dd.utf8String, -1, nil)
            sqlite3_bind_text(insStatement, 8, mob.utf8String, -1, nil)
            
            if sqlite3_step(insStatement) == SQLITE_DONE {
                
                
        }
        sqlite3_finalize(insStatement)
        
        contArray.removeAll()
        contIndex.removeAll()
        getContact()
            
        }
    
    }
    
    func updateContact(contact: ContactStruct) {
        
        var updateStatement: OpaquePointer? = nil
        let ic: Int32 = Int32(contact.idContact)
        let idc: Int32 = Int32(contact.idCompany)
        let fn: NSString = contact.firstName as NSString
        let ln: NSString = contact.lastName as NSString
        let lisn: NSString = contact.listName as NSString
        let email: NSString = contact.email! as NSString
        let dd: NSString = contact.DD! as NSString
        let mob: NSString = contact.mobile! as NSString
        
        if sqlite3_prepare_v2(db, updateString, -1, &updateStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(updateStatement, 8, ic)
            sqlite3_bind_int(updateStatement, 1, idc)
            sqlite3_bind_text(updateStatement, 2, fn.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 3, ln.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 4, lisn.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 5, email.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 6, dd.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 7, mob.utf8String, -1, nil)
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                
            } else {
                
            } } else {
            
            
        }
        sqlite3_finalize(updateStatement)
        
        contArray.removeAll()
        contIndex.removeAll()
        getContact()
        
    }
    
    
    func getPrimaryKey(listName: String) -> Int {
        
        var queryStatement: OpaquePointer? = nil
        var idcn = 0
        let ln: NSString = listName as NSString
        
        if sqlite3_prepare_v2(db, getPrimarySelect, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(queryStatement, 1, ln.utf8String, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                idcn = Int(sqlite3_column_int(queryStatement, 0))
               
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return idcn
    }
    
    //Function to get all contacts for a companyfrom db
    func getContactForCompany(idCompany: Int) -> Array<String> {
        
        contIndex.removeAll()
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, getContactForCompany, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(idCompany))
            
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let queryResultCol1 = sqlite3_column_text(queryStatement, 0)
                let listName = String(cString: queryResultCol1!)
                
                
                contIndex.append(listName)
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return contIndex
    }
    
    //Function to check for the existence of opportunities
    func checkOpportunities(ic: Int) -> Int
    {
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, chkOpps, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(Int(ic)))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                ind99 = 1 //we have found a record on opportunities
                
            } else {
                
                ind99 = 0 //there are no opportunity records for this contact
                
            }
            
        }
        
        sqlite3_finalize(queryStatement)
        
        return ind99
        
    }
    
    //Class end bracket
}
