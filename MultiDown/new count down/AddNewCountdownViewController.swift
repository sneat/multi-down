//
//  AddNewCountdownViewController.swift
//  MultiDown
//
//  Created by John Salami on 17/8/20.
//  Copyright © 2020 -. All rights reserved.
//

import UIKit
import CoreData

public protocol AddNewCountdownDelegate {
    func saveEntry(title: String, completion: Date)
}

typealias SecondOffset = (hour: Int, minute: Int, seconds: Int)

class AddNewCountdownViewController: UIViewController {
    
    @IBOutlet weak var titleField: UITextField!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet var offsetPicker: UIPickerView!
    
    var delegate: AddNewCountdownDelegate?
    var currentOffset: SecondOffset = (0, 0, 0)
    
    let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeStyle = .short
        df.dateStyle = .short
        return df
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        dateField.inputView = offsetPicker
    }
    
    @IBAction func didCancel(_ sender: Any) {
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didSave(_ sender: Any) {
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .timeZone], from: Date())
        dateComponents.hour = currentOffset.hour
        dateComponents.minute = currentOffset.minute
        dateComponents.second = currentOffset.seconds
        
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        delegate?.saveEntry(title: titleField.text ?? "", completion: date)
        presentingViewController?.dismiss(animated: true, completion: nil)
    }
}

extension AddNewCountdownViewController: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch component {
        case 0: currentOffset.hour = row
        case 1: currentOffset.minute = row
        case 2: currentOffset.seconds = row
        default: return
        }
        
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .timeZone], from: Date())
        dateComponents.hour = currentOffset.hour
        dateComponents.minute = currentOffset.minute
        dateComponents.second = currentOffset.seconds
        
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        
        dateField.text = dateFormatter.string(from: date)
    }
}

extension AddNewCountdownViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
        case 0: return 24
        default: return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch component {
        case 0: return "\(row) Hour"
        case 1: return "\(row) Min"
        case 2: return "\(row) Sec"
        default: return ""
        }
    }
}
