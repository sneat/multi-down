//
//  ViewController.swift
//  MultiDown
//
//  Created by John Salami on 17/8/20.
//  Copyright © 2020 -. All rights reserved.
//

import UIKit
import CoreData

let kModalSegue = "showaddnew"
let kCountdownReuseId = "countdown"
let kAddNewReuseId = "addnew"

class ViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    var items: [Countdown] = []
    lazy var ctx = (UIApplication.shared.delegate as! AppDelegate)
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchEntries()
    }
    
    @IBAction func toggleEditing(_ sender: UIBarButtonItem) {
        tableView.isEditing = !tableView.isEditing
        sender.title = tableView.isEditing ? "Done" : "Edit"
        
    }
}

// MARK: - table view delegate
extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: false)
        }
        guard indexPath.section == 1 else {
            return
        }
        guard let vc = storyboard?.instantiateViewController(identifier: kModalSegue) as? AddNewCountdownViewController else {
            return
        }
        vc.delegate = self
        present(vc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            remove(indexPath)
        }
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }
    
    func tableView(_ tableView: UITableView, targetIndexPathForMoveFromRowAt sourceIndexPath: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        guard sourceIndexPath.section < proposedDestinationIndexPath.section else {
            return proposedDestinationIndexPath
        }
        
        return IndexPath(row: tableView.numberOfRows(inSection: sourceIndexPath.section) - 1, section: sourceIndexPath.section)
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let t = items[sourceIndexPath.row]
        items.remove(at: sourceIndexPath.row)
        items.insert(t, at: destinationIndexPath.row)
        
        for (i, item) in items.enumerated() {
            item.setValue(i, forKey: "order")
        }
        
        let managedContext = ctx.persistentContainer.viewContext;
        do {
            try managedContext.save()
        } catch let e { print(e) }
    }
    
}

// MARK: - table view datasource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? items.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reuseId = indexPath.section == 0 ? kCountdownReuseId : kAddNewReuseId
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseId)
        
        guard let countdownCell = cell as? CountdownCell else {
            return cell!
        }
        
        countdownCell.configure(item: items[indexPath.row])
        return countdownCell
    }
}

// MARK: - core data tingz
extension ViewController: AddNewCountdownDelegate {
    func saveEntry(title: String, completion: Date) {
        let managedContext = ctx.persistentContainer.viewContext;
        guard let entity = NSEntityDescription.entity(forEntityName: "Countdown", in: managedContext) else {
            return
        }
        
        let entry = NSManagedObject(entity: entity, insertInto: managedContext)
        entry.setValue(title, forKey: "title")
        entry.setValue(completion, forKey: "completion")
        entry.setValue(items.count, forKey: "order")
        
        do {
            try managedContext.save()
            fetchEntries(updateLayout: true)
        } catch { }
    }
    
    func remove(_ indexPath: IndexPath) {
        let managedContext = ctx.persistentContainer.viewContext;
        let entry = items[indexPath.row]
        managedContext.delete(entry)
        do {
            try managedContext.save()
            fetchEntries(updateLayout: false)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        } catch { }
    }
    
    func fetchEntries(updateLayout layout: Bool = true) {
        let managedContext = ctx.persistentContainer.viewContext;
        let request: NSFetchRequest<Countdown> = Countdown.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor.init(key: "order", ascending: true)]
        request.predicate = NSPredicate(format: "completion > %@", NSDate())
        
        do {
            items = try managedContext.fetch(request)
            if layout { tableView.reloadData() }
        } catch { }
    }
}
