//
//  ViewController.swift
//  BudgetTracker
//
//  Created by xxp on 11/29/14.
//  Copyright (c) 2014 xxp. All rights reserved.
//

import UIKit
import CoreData

class CategoryDataSource: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    let categories = ["Daily", "Education", "Clothing", "Entertainment", "Fixed"]
    var categoryLabel: UITextField
    
    init(categoryLabel: UITextField) {
        self.categoryLabel = categoryLabel
    }
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return categories[row]
    }
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryLabel.text = categories[row]
    }
}

class ViewController: UIViewController {
    @IBOutlet weak var dateLabel: UITextField!
    @IBOutlet weak var category: UITextField!
    @IBOutlet weak var expenseInput: UITextField!
    @IBOutlet weak var budgetBalance: UIProgressView!
    @IBOutlet weak var savingBalance: UIProgressView!
    @IBOutlet weak var savingLabel: UILabel!
    @IBOutlet weak var budgetLabel: UILabel!
    @IBOutlet weak var expense: UITextField!
    @IBOutlet weak var entertainFundLabel: UILabel!
    @IBOutlet weak var educationFundLabel: UILabel!
    @IBOutlet weak var clothingFundLabel: UILabel!
    @IBOutlet weak var savingFundLabel: UILabel!

    var categoryDataSource: CategoryDataSource!
    var budget: Budget!
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        }
        else {
            return nil
        }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let newItem = NSEntityDescription.insertNewObjectForEntityForName("Budget", inManagedObjectContext: self.managedObjectContext!) as Budget

        budget = newItem
        initUI()
    }
    
    func initUI() {
        categoryDataSource = CategoryDataSource(categoryLabel: category)
        var categoryPickerView: UIPickerView = UIPickerView()
        categoryPickerView.dataSource = categoryDataSource
        categoryPickerView.delegate = categoryDataSource
        category.inputView = categoryPickerView
        category.text = categoryDataSource.categories[0]

        var DatePickerView: UIDatePicker = UIDatePicker()
        DatePickerView.datePickerMode = UIDatePickerMode.Date
        dateLabel.inputView = DatePickerView
        DatePickerView.addTarget(self, action: Selector("dateChanged:"), forControlEvents: UIControlEvents.ValueChanged)
        dateLabel.text = dateToString(NSDate())
        
        initUIData()
    }
    
    func nextLevel(value: NSNumber) -> NSNumber {
        if(value <= 0) {
            return 10.0;
        }

        return powf(10,round(log10(value)))
    }
    
    func initUIData() {
        if (budget.monthly_budget_allocation == 0) {
            budget.monthly_budget_allocation = 2000
            budget.monthly_clothing_deposit = 200
            budget.monthly_education_deposit = 100
            budget.monthly_entertainment_deposit = 100
            budget.initial_saving_account = 45000
            budget.byweekly_salary = 3650
        } else {
            monthlyReset()
        }

        budgetLabel.text = "Budget balance (\(budget.daily_expense.doubleValue)/\(budget.monthly_budget_allocation.doubleValue)):"
        budgetBalance.progress = budget.daily_expense/budget.monthly_budget_allocation
        
        savingLabel.text = "Saving balance (\(budget.initial_saving_account.doubleValue)):"
        savingBalance.progress = budget.initial_saving_account/nextLevel(budget.initial_saving_account);
        
        entertainFundLabel.text = budget.entertainment_fund.stringValue
        educationFundLabel.text = budget.education_fund.stringValue
        clothingFundLabel.text = budget.clothing_fund.stringValue
        savingFundLabel.text = budget.initial_saving_account.stringValue
        
    }
    
    func monthInfo() -> (Int, Int) {
        let flags: NSCalendarUnit = .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit
        let date = NSDate()
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        return (components.month, components.day)
    }
    
    func monthlyReset() -> Bool {
        let (month, day) = monthInfo()
        if (day != 1 || month == budget.last_reset_month.integerValue) {
            return false
        }

        var lastDailyBalance = budget.monthly_budget_allocation.doubleValue - budget.daily_expense
        var variousDeposit = budget.monthly_clothing_deposit.doubleValue +
            budget.monthly_education_deposit +
            budget.monthly_entertainment_deposit
        
        budget.initial_saving_account =
            budget.initial_saving_account +
            budget.byweekly_salary * 2 +
            lastDailyBalance -
            budget.fixed_expense -
            variousDeposit
        
        budget.education_fund =
            budget.education_fund.doubleValue +
            budget.monthly_education_deposit -
            budget.education_expense
        
        budget.entertainment_fund =
            budget.entertainment_fund.doubleValue +
            budget.monthly_entertainment_deposit -
            budget.entertainment_expense
        
        budget.clothing_fund =
            budget.clothing_fund.doubleValue +
            budget.monthly_clothing_deposit -
            budget.clothing_expense
        
        budget.daily_expense = 0
        budget.fixed_expense = 0
        budget.education_expense = 0
        budget.clothing_expense = 0
        budget.entertainment_expense = 0

        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dateToString(date: NSDate) -> NSString {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        return dateFormatter.stringFromDate(date)
    }

    @IBAction func dateChanged(datePicker: UIDatePicker!) {
        dateLabel.text = dateToString(datePicker.date)
    }
    @IBAction func viewTapped(sender : AnyObject) {
        dateLabel.resignFirstResponder()
        category.resignFirstResponder()
        expenseInput.resignFirstResponder()
    }

    @IBAction func onAddExpense(sender: AnyObject) {
        var spending = NSString(string: expense.text).doubleValue
        switch (category.text) {
        case categoryDataSource.categories[0]://daily
            budget.daily_expense = budget.daily_expense + spending
            break;
        case categoryDataSource.categories[1]://education
            budget.education_expense = budget.education_expense + spending
            break;
        case categoryDataSource.categories[2]://clothing
            budget.clothing_expense = budget.clothing_expense + spending
            break;
        case categoryDataSource.categories[3]://entertainment
            budget.entertainment_expense = budget.entertainment_expense + spending
            break;
        case categoryDataSource.categories[4]://fixed
            budget.fixed_expense = budget.fixed_expense + spending
            break;
        default:
            break
        }

        initUIData()
    }
}

