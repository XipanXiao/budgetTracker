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
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        let managedContext = managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Budget")

        var error: NSError?
        
        let fetchedResults =
        managedContext.executeFetchRequest(fetchRequest,
            error: &error) as [NSManagedObject]?
        
        if let results = fetchedResults {
            if (results.count > 0) {
                budget = results[0] as Budget
            }
        } else {
        }
        
        if (budget == nil) {
            budget = NSEntityDescription.insertNewObjectForEntityForName("Budget", inManagedObjectContext: self.managedObjectContext!) as Budget
        }
        
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
        if (budget.monthly_budget == 0) {
            budget.monthly_budget = 2000
            budget.monthly_clothing_deposit = 200
            budget.monthly_education_deposit = 100
            budget.monthly_entertainment_deposit = 100
            budget.monthly_furniture_deposit = 100
            
            budget.monthly_income = 7370
            budget.saving =
                48000 - budget.monthly_income.doubleValue -
                budget.monthly_budget.doubleValue
        }

        monthlyReset()

        budgetLabel.text = "Budget balance (\(budget.balance.doubleValue)/\(budget.monthly_budget.doubleValue)):"
        budgetBalance.progress = Float(budget.balance.doubleValue/budget.monthly_budget.doubleValue)
        
        savingLabel.text = "Saving balance (\(budget.saving.doubleValue)):"
        savingBalance.progress = budget.saving.floatValue/nextLevel(budget.saving);
        
        savingFundLabel.text = budget.saving.stringValue

        entertainFundLabel.text = budget.entertainment_balance.stringValue
        educationFundLabel.text = budget.education_balance.stringValue
        clothingFundLabel.text = budget.clothing_balance.stringValue
        furnitureFundLabel.text = budget.furniture_balance.stringValue
        
        var error : NSError?
        managedObjectContext?.save(&error)
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

        var variousDeposit = budget.monthly_clothing_deposit.doubleValue +
            budget.monthly_education_deposit.doubleValue +
            budget.monthly_entertainment_deposit.doubleValue +
            budget.monthly_furniture_deposit.doubleValue
        
        budget.saving =
            budget.saving.doubleValue +
            budget.balance.doubleValue +
            budget.monthly_income.doubleValue -
            variousDeposit
        
        budget.balance = budget.monthly_budget
        
        budget.education_balance =
            budget.education_balance.doubleValue +
            budget.monthly_education_deposit.doubleValue
        
        budget.entertainment_balance =
            budget.entertainment_balance.doubleValue +
            budget.monthly_entertainment_deposit.doubleValue
        
        budget.clothing_balance =
            budget.clothing_balance.doubleValue +
            budget.monthly_clothing_deposit.doubleValue

        budget.furniture_balance =
            budget.furniture_balance.doubleValue +
            budget.monthly_furniture_deposit.doubleValue
        
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
            budget.balance = budget.balance.doubleValue - spending
            break;
        case categoryDataSource.categories[1]://education
            budget.education_balance = budget.education_balance.doubleValue - spending
            break;
        case categoryDataSource.categories[2]://clothing
            budget.clothing_balance = budget.clothing_balance.doubleValue - spending
            break;
        case categoryDataSource.categories[3]://entertainment
            budget.entertainment_balance = budget.entertainment_balance.doubleValue - spending
            break;
        case categoryDataSource.categories[4]://furniture
            budget.furniture_balance = budget.furniture_balance.doubleValue - spending
            break;
        case categoryDataSource.categories[5]://fixed
            budget.saving = budget.saving.doubleValue - spending
            break;
        default:
            break
        }

        initUIData()
    }
}

