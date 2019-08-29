//
//  ViewController.swift
//  persist
//
//  Created by Chitra Hari on 19/08/19.
//  Copyright © 2019 Chitra Hari. All rights reserved.
//

import UIKit
import CoreData


class ViewController: UITableViewController {

    var itemArray = [Item]()
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var selectedCategory : Category? {
       
        didSet {
            fetchData()
        }
    }


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        print(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
        
        
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArray.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ToDoItemCell", for: indexPath)
        cell.textLabel?.text = itemArray[indexPath.row].title
//        cell.detailTextLabel?.text = itemArray[indexPath.row].title
        if itemArray[indexPath.row].data == true {
            cell.accessoryType = .checkmark
        }else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print (indexPath.row)
        
        itemArray[indexPath.row].data = !itemArray[indexPath.row].data
        
        saveData()
        
        tableView.deselectRow(at: indexPath, animated: true)
    
    }
    
    @IBAction func buttonAdd(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        let alert = UIAlertController(title: "add New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add item", style: .default) { (action) in
            print(textField.text!)
            
            let newItem = Item(context: self.context)
            newItem.title = textField.text!
            newItem.data = false
            newItem.parentCategory = self.selectedCategory
            self.itemArray.append(newItem)
            self.saveData()
            
            print("array updated")
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func saveData() {
        do{
            try context.save()
        }catch {
            print("error saving data\(error)")
        }
        tableView.reloadData()
    }
    
    func fetchData(with request : NSFetchRequest<Item> = Item.fetchRequest(),predicate : NSPredicate? = nil) {
//        let request : NSFetchRequest<Item> = Item.fetchRequest()

//let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        let categoryPredicate = NSPredicate(format: "parentCategory.name MATCHES %@", selectedCategory!.name!)
        if let additionPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [categoryPredicate,additionPredicate])
            
        } else {
            request.predicate = categoryPredicate
        }


        do {
            itemArray = try context.fetch(request)
        } catch {
            print("error fetching data")
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            context.delete(itemArray[indexPath.row])
            itemArray.remove(at: indexPath.row)
            tableView.reloadData()
            saveData()
        }
    }
    
}
//    mark : searchBar func
extension ViewController : UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        let request : NSFetchRequest<Item> = Item.fetchRequest()
        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
//        let predicate = NSPredicate(format: "title CONTAINS %@", searchBar.text!)
//        [cd] used for avoiding case sensitive
        request.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        fetchData(with: request, predicate: predicate)
        
        
    }
    //    mark : method to return orginal list after search
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            fetchData()
    }
}

}
