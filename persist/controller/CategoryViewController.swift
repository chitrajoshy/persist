//
//  CategoryViewController.swift
//  persist
//
//  Created by Chitra Hari on 22/08/19.
//  Copyright © 2019 Chitra Hari. All rights reserved.
//

import UIKit
import  CoreData

class CategoryViewController: UITableViewController {
    
var categories = [Category]()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()
       
    }

    // MARK: - Table view data source


    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return categories.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        cell.textLabel?.text = categories[indexPath.row].name
        
        return cell
    }
    
    @IBAction func btnAddWorks(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert1 = UIAlertController(title: "Add new To Dos", message: "", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Add", style: .default) { (action1) in
            let newCategory = Category(context: self.context)
            newCategory.name = textField.text!
            self.categories.append(newCategory)
            self.saveCategories()
            self.tableView.reloadData()
            
        }
        
        alert1.addAction(action1)
        alert1.addTextField { (alertTextField) in
            textField.placeholder = "Add a new To Dos "
            textField = alertTextField
        }
        present(alert1, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       performSegue(withIdentifier: "goToItems", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! ViewController
        if let indexPath = tableView.indexPathForSelectedRow{
            destinationVC.selectedCategory = categories[indexPath.row]
        }
    }
    
    func saveCategories() {
        do {
            try context.save()
        } catch {
            print("Error saving category \(error)")
        }
        tableView.reloadData()
    }
    func loadCategories() {
        let request : NSFetchRequest<Category> = Category.fetchRequest()
        do {
            categories = try context.fetch(request)
        } catch {
            print("Error loading categories \(error) ")
        }
        tableView.reloadData()
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            context.delete(categories[indexPath.row])
            categories.remove(at: indexPath.row)
            tableView.reloadData()
    }
    }
    
    
}
