//
//  OpportunityStruct.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 19/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import AppKit

//Declaring a new struct for Opportunity

public class OpportunityStruct: NSObject {
    @objc var idOpportunity: Int
    @objc var idContact: Int
    @objc var idCompany: Int
    @objc var company: String
    @objc var listName: String
    @objc var oppDesc: String
    @objc var oppStatus: String
   
    init(idOpportunity: Int, idContact: Int, idCompany: Int, company: String, listName: String, oppDesc: String, oppStatus: String) {
        self.idOpportunity = idOpportunity
        self.idContact = idContact
        self.idCompany = idCompany
        self.company = company
        self.listName = listName
        self.oppDesc = oppDesc
        self.oppStatus = oppStatus
    }
    
}
