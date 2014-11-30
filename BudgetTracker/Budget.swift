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

    @NSManaged var byweekly_salary: NSDecimalNumber
    @NSManaged var clothing_expense: NSDecimalNumber
    @NSManaged var daily_expense: NSDecimalNumber
    @NSManaged var education_expense: NSDecimalNumber
    @NSManaged var entertainment_expense: NSDecimalNumber
    @NSManaged var initial_saving_account: NSDecimalNumber
    @NSManaged var monthly_budget_allocation: NSDecimalNumber
    @NSManaged var monthly_clothing_deposit: NSDecimalNumber
    @NSManaged var monthly_education_deposit: NSDecimalNumber
    @NSManaged var monthly_entertainment_deposit: NSDecimalNumber

}
