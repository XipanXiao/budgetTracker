//
//  BudgetTracker.swift
//  BudgetTracker
//
//  Created by xxp on 12/5/14.
//  Copyright (c) 2014 xxp. All rights reserved.
//

import Foundation
import CoreData

class Budget: NSManagedObject {

    @NSManaged var balance: NSNumber
    @NSManaged var clothing_balance: NSNumber
    @NSManaged var education_balance: NSNumber
    @NSManaged var entertainment_balance: NSNumber
    @NSManaged var furniture_balance: NSNumber
    @NSManaged var last_reset_month: NSNumber
    @NSManaged var monthly_budget: NSNumber
    @NSManaged var monthly_clothing_deposit: NSNumber
    @NSManaged var monthly_education_deposit: NSNumber
    @NSManaged var monthly_entertainment_deposit: NSNumber
    @NSManaged var monthly_furniture_deposit: NSNumber
    @NSManaged var monthly_income: NSNumber
    @NSManaged var saving: NSNumber

}
