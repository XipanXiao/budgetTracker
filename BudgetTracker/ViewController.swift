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
        print(categories.count)
        return categories.count
    }
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        print(categories[row])
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
    var categoryDataSource: CategoryDataSource!
    
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

        initUI(newItem)
    }
    
    func initUI(budget: Budget) {
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dateToString(date: NSDate) -> NSString {
        var dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "YYYY-MM-dd"
        //dateFormatter.timeStyle = NSDateFormatterStyle.ShortStyle
        
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
}

