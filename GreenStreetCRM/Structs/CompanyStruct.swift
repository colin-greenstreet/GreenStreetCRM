//
//  CompanyStruct.swift
//  GreenStreetCRM
//
//  Created by Colin Whickman on 12/09/2018.
//  Copyright © 2018 Colin Whickman. All rights reserved.
//

import AppKit

//Declaring a new class for Company

public class CompanyStruct: NSObject {
    @objc var idCompany: Int
    @objc var company: String
    @objc var compType: String
    
    init(idCompany: Int, company: String, compType: String) {
        self.idCompany = idCompany
        self.company = company
        self.compType = compType
    }
}


