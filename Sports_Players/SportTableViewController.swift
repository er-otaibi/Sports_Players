//
//  ViewController.swift
//  Sports_Players
//
//  Created by Mac on 23/05/1443 AH.
//

import UIKit
import CoreData

class SportTableViewController: UITableViewController {
    
    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    var sports = [SportEntity]()
    var sportImageData = Data.init()
    var sportImageIndexPath : IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        fetchAllItemsCoreData()
    }
    
    func fetchAllItemsCoreData(){
        
        let itemRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SportEntity")
        do {
            let results = try managedObjectContext.fetch(itemRequest)
            sports = results as! [SportEntity]
            for sport in sports {
                print("spaort name: \(sport.name)")
                print("spaort image: \(sport.image)")
            }
        } catch {
            print("\(error)")
        }
        self.tableView.reloadData()
    }
    @IBAction func addSportButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Sport", message: "Add a new sport", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Write your sport name here"
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) {
            UIAlertAction -> Void in
        })
        
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields?[0]{
                print("User text: \(textField.text!)")
                
                //Save to coredata
                let thing = NSEntityDescription.insertNewObject(forEntityName: "SportEntity", into: self.managedObjectContext) as! SportEntity
                thing.name = textField.text
                
                thing.image =  Data.init()
                self.sports.append(thing)
                
                if self.managedObjectContext.hasChanges{
                    do {
                        try self.managedObjectContext.save()
                        
                    }catch{
                        print("Error")
                        
                        print(error.localizedDescription)
                    }
                }
                self.tableView.reloadData()
                
                //print
                print("Add Sport:")
                for sport in self.sports{
                    print(sport.name!)
                }
                
            }
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return sports.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SportCell", for: indexPath) as! CustomSportTableViewCell
        
        cell.sportName.text = sports[indexPath.row].name
        guard let image = sports[indexPath.row].image else{return cell }
        print("image byte \(image)")
        if !image.isEmpty{
            cell.imageButton.isHidden = true
            cell.sportImageView.isHidden = false
            cell.sportImageView.image = UIImage(data: image)
            
            
        }else{
            cell.imageButton.isHidden = false
            cell.sportImageView.isHidden = true
        }
        cell.delegate = self
        cell.indexPath = indexPath
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segue", sender: sports[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        let alert = UIAlertController(title: "Edit Sport", message: "Edit your sport name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Write your sport name here"
            textField.text = self.sports[indexPath.row].name
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .default) {
            UIAlertAction -> Void in
        })
        
        alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak alert] (_) in
            if let textField = alert?.textFields?[0] {
                print("TextField text: \(self.sports[indexPath.row].name)")
                print("User text: \(textField.text!)")
                
                //edit core data
                let item = self.sports[indexPath.row]
                
                item.name = textField.text
                
                if self.managedObjectContext.hasChanges{
                    do {
                        try self.managedObjectContext.save()
                        
                    }catch{
                        print("Error")
                        
                        print(error.localizedDescription)
                    }
                }
                self.tableView.reloadData()
                
                //print
                for sport in self.sports{
                    print(sport.name!)
                }
                
            }
            
        }))
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let item = sports[indexPath.row]
        managedObjectContext.delete(item)
        
        do {
            try managedObjectContext.save()
            
        }catch{
            print(error.localizedDescription)
        }
        sports.remove(at: indexPath.row)
        tableView.reloadData()
        
    }
    
    
    
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destination = segue.destination as! PlayerTableViewController
        if let sender = sender as? SportEntity {
            destination.sport = sender
        }
        
    }
}

extension SportTableViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey(rawValue: "UIImagePickerControllerEditedImage")] as? UIImage {
            print("-------------------------")
            
            guard let jpegImageData = image.jpegData(compressionQuality: 1.0) else{return}
            //  let pngImageData  = image.pngData()
            sportImageData = jpegImageData
            //edit core data
            let item = self.sports[sportImageIndexPath!.row]
            
            item.image = sportImageData
            print("sportImageData - saveImage")
            print(sportImageData)
            
            if self.managedObjectContext.hasChanges{
                do {
                    try self.managedObjectContext.save()
                    
                }catch{
                    print("Error")
                    
                    print(error.localizedDescription)
                }
            }
            self.tableView.reloadData()
            
            
            
            print("sportImageData - imagePickerController")
            print(sportImageData)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

extension SportTableViewController : SportDelegate {
    
    
    func saveImage(by controller: CustomSportTableViewCell, with image: String, at indexPath: IndexPath?) {
        
        print("saveImage")
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc,animated:true)
        sportImageIndexPath = indexPath
        
        
    }
    
}
