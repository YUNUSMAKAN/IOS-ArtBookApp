//
//  ViewController.swift
//  ArtBookProject
//
//  Created by MAKAN on 12.04.2020.
//  Copyright © 2020 YUNUS MAKAN. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    @IBOutlet weak var tableview: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    var selectedPainting = ""
    var selectedPaintingId :UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
      
        tableview.dataSource = self
        tableview.delegate = self
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addButtonClicked))
        getData()
      
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "NewData"), object: nil)
    }
    
    
    
   @objc func getData(){
    
    nameArray.removeAll(keepingCapacity: false)
    idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(fetchRequest)
            if results.count > 0 {
            for result in results as! [NSManagedObject] {
                if let name = result.value(forKey: "name") as? String {
                    self.nameArray.append(name)
                }
                
                if let id = result.value(forKey: "id") as? UUID {
                    self.idArray.append(id)
                }
                self.tableview.reloadData()
                
            }
            }
        } catch {
            print("Error")
        }
    }
    
    @objc func addButtonClicked(){
        selectedPainting = ""
        performSegue(withIdentifier: "todetailsVC", sender: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
       return cell
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "todetailsVC" {
            let destinationVC = segue.destination as! DetailsVC
            destinationVC.choosenPainting = selectedPainting
            destinationVC.choosenPaintingId = selectedPaintingId
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) { // bir seye tiklandiginda segue yapmak icin kullaniriz.
        selectedPainting = nameArray[indexPath.row]
        selectedPaintingId = idArray[indexPath.row]
        performSegue(withIdentifier: "todetailsVC", sender: nil)
    }
     
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Paintings")
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let id = result.value(forKey: "id") as? UUID {
                        if id ==  idArray[indexPath.row]{
                            context.delete(result)
                            nameArray.remove(at: indexPath.row)
                            idArray.remove(at: indexPath.row)
                            self.tableview.reloadData()
                            do {
                                try context.save()
                            } catch  {
                                print("error")
                            }
                            break
                        }
                    }
                    
                }
                }
            } catch {
                print("Error")
            }
        }
        
        
    }
    
    
    
    
    
}


