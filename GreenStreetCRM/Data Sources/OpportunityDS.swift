//
//  OpportunityDS.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 19/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import Cocoa
import SQLite3

class OppDataModel {
    
    static let oppSharedInstance = OppDataModel()
    
    var db: OpaquePointer?
    
    let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("GreenStreetCRM.db")
    
    let selectOppStatement = "SELECT IDOPPORTUNITY, COMPANY, LISTNAME, OPPNAME, OPPSTATUS FROM OPPORTUNITY INNER JOIN COMPANY ON COMPANY.IDCOMPANY = OPPORTUNITY.IDCOMPANY INNER JOIN CONTACT ON CONTACT.IDCONTACT = OPPORTUNITY.IDCONTACT ORDER BY COMPANY;"
    
    let deleteOppStatement = "delete from opportunity where idopportunity = ?;"
    
    let maxSelectStatement = "select max(idopportunity) from opportunity;"
    
    let insertStatement = "insert into opportunity (idopportunity, idcontact, idcompany, oppname, oppstatus ) values (?, ?, ?, ?, ?);"
    
    let getContactPrimarySelect = "select idcontact from contact where listname = ?;"
    
    let getCompPrimarySelect = "select idcompany from company where company = ?;"
    
    let getOppPrimarySelect = "select idopportunity from opportunity where oppname = ?;"
    
    let getSingleOpp = "SELECT IDOPPORTUNITY, COMPANY, LISTNAME, OPPNAME, OPPSTATUS FROM OPPORTUNITY INNER JOIN COMPANY ON COMPANY.IDCOMPANY = OPPORTUNITY.IDCOMPANY INNER JOIN CONTACT ON CONTACT.IDCONTACT = OPPORTUNITY.IDCONTACT WHERE IDOPPORTUNITY = ?;"
    
    let updateString = "update opportunity set idcompany = ?, idcontact = ?, oppname = ?, oppstatus = ? where idopportunity = ?;"
    
    let chkActions = "select idaction from action where idopportunity = ?;"
    
    var oppArray: Array<OpportunityStruct> = []
    
    var oppIndex: Array<String> = []
    
    var nxtIdOpportunity: Int32 = 0
    
    var ind99 = 2
    
    private init() {
        
        if sqlite3_open(fileURL.path, &db) == SQLITE_OK {
            
        } else {
            
        }
        
        getOpportunity()
}

    //Function to get the next number to be used when performing an insert
    func getMaxID() -> Int32
    {
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, maxSelectStatement, -1, &queryStatement, nil) == SQLITE_OK {
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                let ido: Int32 = sqlite3_column_int(queryStatement, 0)
                nxtIdOpportunity = ido + 1
               
            }
            
        }
        
        sqlite3_finalize(queryStatement)
        
        return nxtIdOpportunity
        
    }
    
    //Function to get all opportunities from db
    func getOpportunity() {
        
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, selectOppStatement, -1, &queryStatement, nil) == SQLITE_OK {
            while sqlite3_step(queryStatement) == SQLITE_ROW {
                let opid = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let company = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let listName = String(cString: queryResultCol2!)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
                let oppName = String(cString: queryResultCol3!)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
                let oppStatus = String(cString: queryResultCol4!)
                
                let opp = OpportunityStruct(idOpportunity: 0, idContact: 0, idCompany: 0, company: "", listName: "", oppDesc: "", oppStatus: "")
                
                opp.idOpportunity = Int(opid)
                opp.company = company
                opp.listName = listName
                opp.oppDesc = oppName
                opp.oppStatus = oppStatus
                
                oppArray.append(opp)
                oppIndex.append(oppName)
            }
        }
        
        sqlite3_finalize(queryStatement)
    }
    
    //method to delete record
    //Accepts an id parameter
    func deleteRecord(_ id: Int) {
        
        var deleteStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, deleteOppStatement, -1, &deleteStatement, nil) == SQLITE_OK {
            
            
            sqlite3_bind_int(deleteStatement, 1, Int32(id))
            
            
            if sqlite3_step(deleteStatement) == SQLITE_DONE {
                
            } else {
                
            } } else {
            
        }
        sqlite3_finalize(deleteStatement)
        
        
    }
    
    //Function to return a single opportunity record
    
    func getSingleOpportunity(io: Int) -> OpportunityStruct {
        
        var queryStatement: OpaquePointer? = nil
        let opp = OpportunityStruct.init(idOpportunity: 0, idContact: 0, idCompany: 0, company: "", listName: "", oppDesc: "", oppStatus: "")
        
        if sqlite3_prepare_v2(db, getSingleOpp, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(io))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                let ido = sqlite3_column_int(queryStatement, 0)
                let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
                let companyName = String(cString: queryResultCol1!)
                let queryResultCol2 = sqlite3_column_text(queryStatement, 2)
                let listName = String(cString: queryResultCol2!)
                let queryResultCol3 = sqlite3_column_text(queryStatement, 3)
                let oppDesc = String(cString: queryResultCol3!)
                let queryResultCol4 = sqlite3_column_text(queryStatement, 4)
                let oppStatus = String(cString: queryResultCol4!)
                
                opp.idOpportunity = Int(ido)
                opp.company = companyName
                opp.listName = listName
                opp.oppDesc = oppDesc
                opp.oppStatus = oppStatus
                
                
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return opp
    }
    
    //Function to insert a opportunity based on a opportunity struct passed in as parameter
    func insert(opportunity: OpportunityStruct) {
        var insStatement: OpaquePointer? = nil
        
        if sqlite3_prepare_v2(db, insertStatement, -1, &insStatement, nil) == SQLITE_OK {
            
            let io: Int32 = Int32(opportunity.idOpportunity)
            let idc: Int32 = Int32(opportunity.idCompany)
            let idcn: Int32 = Int32(opportunity.idContact)
            let od: NSString = opportunity.oppDesc as NSString
            let os: NSString = opportunity.oppStatus as NSString
            
            
            
            sqlite3_bind_int(insStatement, 1, io)
            sqlite3_bind_int(insStatement, 2, idcn)
            sqlite3_bind_int(insStatement, 3, idc)
            sqlite3_bind_text(insStatement, 4, od.utf8String, -1, nil)
            sqlite3_bind_text(insStatement, 5, os.utf8String, -1, nil)
            
            
            if sqlite3_step(insStatement) == SQLITE_DONE {
                
                
            }
            sqlite3_finalize(insStatement)
            
            oppArray.removeAll()
            oppIndex.removeAll()
            getOpportunity()
            
        }
        
    }
    
    func updateOpportunity(opportunity: OpportunityStruct) {
        
        var updateStatement: OpaquePointer? = nil
        let io: Int32 = Int32(opportunity.idOpportunity)
        let idc: Int32 = Int32(opportunity.idCompany)
        let idcn: Int32 = Int32(opportunity.idContact)
        let on: NSString = opportunity.oppDesc as NSString
        let os: NSString = opportunity.oppStatus as NSString
        
        
        if sqlite3_prepare_v2(db, updateString, -1, &updateStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(updateStatement, 5, io)
            sqlite3_bind_int(updateStatement, 1, idc)
            sqlite3_bind_int(updateStatement, 2, idcn)
            sqlite3_bind_text(updateStatement, 3, on.utf8String, -1, nil)
            sqlite3_bind_text(updateStatement, 4, os.utf8String, -1, nil)
            
            
            if sqlite3_step(updateStatement) == SQLITE_DONE {
                
            } else {
                
            } } else {
            
        }
        sqlite3_finalize(updateStatement)
        
        oppArray.removeAll()
        oppIndex.removeAll()
        getOpportunity()
        
        
    }
    
    func getPrimaryKey(oppName: String) -> Int {
        
        var queryStatement: OpaquePointer? = nil
        var idop = 0
        let on: NSString = oppName as NSString
        
        if sqlite3_prepare_v2(db, getOppPrimarySelect, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_text(queryStatement, 1, on.utf8String, -1, nil)
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                idop = Int(sqlite3_column_int(queryStatement, 0))
                
                
            }
        }
        
        sqlite3_finalize(queryStatement)
        
        return idop
    }
    
    //Function to check for the existence of actions
    func checkActions(ic: Int) -> Int
    {
        var queryStatement: OpaquePointer? = nil
        if sqlite3_prepare_v2(db, chkActions, -1, &queryStatement, nil) == SQLITE_OK {
            
            sqlite3_bind_int(queryStatement, 1, Int32(Int(ic)))
            
            if sqlite3_step(queryStatement) == SQLITE_ROW {
                
                ind99 = 1 //we have found a record on actions
                
            } else {
                
                ind99 = 0 //there are no action records for this opportunity
                
            }
            
        }
        
        sqlite3_finalize(queryStatement)
        
        return ind99
        
    }
    
    //End class
}
