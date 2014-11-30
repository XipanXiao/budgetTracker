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
    let categories = ["Daily", "Education", "Clothing", "Entertainment"]
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
        }

        budgetLabel.text = "Budget balance (\(budget.daily_expense.doubleValue)/\(budget.monthly_budget_allocation.doubleValue)):"
        budgetBalance.progress = budget.daily_expense/budget.monthly_budget_allocation
        
        savingLabel.text = "Saving balance (\(budget.initial_saving_account.doubleValue)):"
        savingBalance.progress = budget.initial_saving_account/nextLevel(budget.initial_saving_account);
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
            budget.daily_expense = NSNumber(double: budget.daily_expense.doubleValue + spending)
            break;
        case categoryDataSource.categories[1]://education
            budget.education_expense = NSNumber(double: budget.education_expense.doubleValue + spending)
            break;
        case categoryDataSource.categories[2]://clothing
            budget.clothing_expense = NSNumber(double: budget.clothing_expense.doubleValue + spending)
            break;
        case categoryDataSource.categories[3]://entertainment
            budget.entertainment_expense = NSNumber(double: budget.entertainment_expense.doubleValue + spending)
            break;
        default:
            break
        }

        initUIData()
    }
}

