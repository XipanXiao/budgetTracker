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
    let categories = ["Daily", "Education", "Clothing", "Entertainment", "Furniture", "Fixed"]
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
    @IBOutlet weak var furnitureFundLabel: UILabel!

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
    
    func nextLevel(value: NSNumber) -> Float {
        if(value.doubleValue <= 0) {
            return 10.0;
        }

        return powf(10,round(log10(value.floatValue)))
    }
    
    func initUIData() {
        if (budget.monthly_budget_allocation == 0) {
            budget.monthly_budget_allocation = 2000
            budget.monthly_clothing_deposit = 200
            budget.monthly_education_deposit = 100
            budget.monthly_entertainment_deposit = 100
            budget.monthly_furniture_deposit = 100
            
            budget.byweekly_salary = 3685
            budget.initial_saving_account =
                48000 - budget.byweekly_salary.doubleValue * 2 -
                budget.monthly_budget_allocation.doubleValue
        }

        monthlyReset()

        budgetLabel.text = "Budget balance (\(budget.daily_expense.doubleValue)/\(budget.monthly_budget_allocation.doubleValue)):"
        budgetBalance.progress = Float(budget.daily_expense.doubleValue/budget.monthly_budget_allocation.doubleValue)
        
        savingLabel.text = "Saving balance (\(budget.initial_saving_account.doubleValue)):"
        savingBalance.progress = budget.initial_saving_account.floatValue/nextLevel(budget.initial_saving_account);
        
        entertainFundLabel.text = budget.entertainment_fund.stringValue
        educationFundLabel.text = budget.education_fund.stringValue
        clothingFundLabel.text = budget.clothing_fund.stringValue
        savingFundLabel.text = budget.initial_saving_account.stringValue
        furnitureFundLabel.text = budget.furniture_fund.stringValue  
    }
    
    func monthInfo() -> (Int, Int) {
        let flags: NSCalendarUnit = .DayCalendarUnit | .MonthCalendarUnit | .YearCalendarUnit
        let date = NSDate()
        let components = NSCalendar.currentCalendar().components(flags, fromDate: date)
        return (components.month, components.day)
    }
    
    func monthlyReset() -> Bool {
        let (month, day) = monthInfo()
        if (budget.last_reset_month.integerValue != 0 &&
            (day != 1 || month == budget.last_reset_month.integerValue)) {
            return false
        }

        var lastDailyBalance = budget.monthly_budget_allocation.doubleValue - budget.daily_expense.doubleValue
        var variousDeposit = budget.monthly_clothing_deposit.doubleValue +
            budget.monthly_education_deposit.doubleValue +
            budget.monthly_entertainment_deposit.doubleValue +
            budget.monthly_furniture_deposit.doubleValue
        
        budget.initial_saving_account =
            budget.initial_saving_account.doubleValue +
            budget.byweekly_salary.doubleValue * 2 +
            lastDailyBalance -
            budget.fixed_expense.doubleValue -
            variousDeposit
        
        budget.education_fund =
            budget.education_fund.doubleValue +
            budget.monthly_education_deposit.doubleValue -
            budget.education_expense.doubleValue
        
        budget.entertainment_fund =
            budget.entertainment_fund.doubleValue +
            budget.monthly_entertainment_deposit.doubleValue -
            budget.entertainment_expense.doubleValue
        
        budget.clothing_fund =
            budget.clothing_fund.doubleValue +
            budget.monthly_clothing_deposit.doubleValue -
            budget.clothing_expense.doubleValue

        budget.furniture_fund =
            budget.furniture_fund.doubleValue +
            budget.monthly_furniture_deposit.doubleValue -
            budget.furniture_expense.doubleValue
        
        budget.daily_expense = 0
        budget.fixed_expense = 0
        budget.education_expense = 0
        budget.clothing_expense = 0
        budget.entertainment_expense = 0
        budget.furniture_expense = 0

        budget.last_reset_month = month
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
            budget.daily_expense = budget.daily_expense.doubleValue + spending
            break;
        case categoryDataSource.categories[1]://education
            budget.education_expense = budget.education_expense.doubleValue + spending
            break;
        case categoryDataSource.categories[2]://clothing
            budget.clothing_expense = budget.clothing_expense.doubleValue + spending
            break;
        case categoryDataSource.categories[3]://entertainment
            budget.entertainment_expense = budget.entertainment_expense.doubleValue + spending
            break;
        case categoryDataSource.categories[4]://furniture
            budget.furniture_expense = budget.furniture_expense.doubleValue + spending
            break;
        case categoryDataSource.categories[5]://fixed
            budget.fixed_expense = budget.fixed_expense.doubleValue + spending
            break;
        default:
            break
        }

        initUIData()
    }
}

