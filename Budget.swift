//
//  BudgetTracker.swift
//  BudgetTracker
//
//  Created by xxp on 11/30/14.
//  Copyright (c) 2014 xxp. All rights reserved.
//

import Foundation
import CoreData

class Budget: NSManagedObject {

    @NSManaged var byweekly_salary: NSNumber
    @NSManaged var clothing_expense: NSNumber
    @NSManaged var daily_expense: NSNumber
    @NSManaged var education_expense: NSNumber
    @NSManaged var entertainment_expense: NSNumber
    @NSManaged var initial_saving_account: NSNumber
    @NSManaged var monthly_budget_allocation: NSNumber
    @NSManaged var monthly_clothing_deposit: NSNumber
    @NSManaged var monthly_education_deposit: NSNumber
    @NSManaged var monthly_entertainment_deposit: NSNumber
    @NSManaged var entertainment_fund: NSNumber
    @NSManaged var education_fund: NSNumber
    @NSManaged var clothing_fund: NSNumber
    @NSManaged var last_reset_month: NSNumber
    @NSManaged var fixed_expense: NSNumber

}
