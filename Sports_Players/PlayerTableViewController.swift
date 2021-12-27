//
//  PlayerTableViewController.swift
//  Sports_Players
//
//  Created by Mac on 23/05/1443 AH.
//

import UIKit
import CoreData

class PlayerTableViewController: UITableViewController {

    let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           
           var sport : SportEntity!
           var players = [PlayerEntity]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        title = sport.name
                
               fetchAllItems()
    
    }


    func fetchAllItems(){
                
                let result:NSFetchRequest<PlayerEntity> = PlayerEntity.fetchRequest()

                let requestPredicate = NSPredicate(format: "ANY sports == %@", sport )
                result.predicate = requestPredicate
                
                do {
                    players = try managedObjectContext.fetch(result)
                    }catch{
                        print(error)
                        }
                tableView.reloadData()
            }
    @IBAction func addPlayerButton(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Player", message: "Add a new Player", preferredStyle: .alert)
                    alert.addTextField { (textFieldName) in
                        textFieldName.placeholder = "Write your player name here"
                    }
                    alert.addTextField { (textFieldAge) in
                        textFieldAge.placeholder = "Write your player age here"
                    }
                    alert.addTextField { (textFieldHeight) in
                        textFieldHeight.placeholder = "Write your player height here"
                    }
                    
                    alert.addAction(UIAlertAction(title: "Cancel", style: .default) {
                        UIAlertAction -> Void in
                    })
                    
                    alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { [weak alert] (_) in
                        if let playerName = alert?.textFields?[0] ,
                           let playerAge = alert?.textFields?[1],
                           let playerHeight = alert?.textFields?[2]{
                            
                            //Save to coredata
                            let newPlayer = PlayerEntity(context: self.managedObjectContext)
                            
                            guard let playerName = playerName.text else {return }
                            newPlayer.name = playerName
                            
                            guard let playerAge = Int64(playerAge.text!) else {return }
                            newPlayer.age = playerAge

                            guard let playerHieght = Double(playerHeight.text!)else {return }
                            newPlayer.height = playerHieght
                          
                            self.sport.addToPlayers(newPlayer)
                    
                            if self.managedObjectContext.hasChanges{
                                do {
                                    try self.managedObjectContext.save()
                                    
                                }catch{
                                    print("Error")
                                    
                                    print(error.localizedDescription)
                                }
                            }
                            
                            self.fetchAllItems()
                        }
                        
                    }))
                    self.present(alert, animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
                return players.count
            }

            
            override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PlayerCell", for: indexPath)
                
                guard let sportName = players[indexPath.row].name else {return cell}
                cell.textLabel?.text = "\(sportName) - \(players[indexPath.row].age) - \(players[indexPath.row].height)"

                return cell
            }
        
            // Override to support editing the table view.
            override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
                
                let item = players[indexPath.row]
                managedObjectContext.delete(item)
                
                do {
                    try managedObjectContext.save()
                    
                }catch{
                    print(error.localizedDescription)
                }
                players.remove(at: indexPath.row)
                tableView.reloadData()
            }
        override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
               
                let alert = UIAlertController(title: "Edit Player", message: "Edit your Player Info", preferredStyle: .alert)
                
                alert.addTextField { (textFieldName) in
                    textFieldName.text = self.players[indexPath.row].name
                }
                alert.addTextField { (textFieldAge) in
                    textFieldAge.text = "\(self.players[indexPath.row].age)"
                }
                alert.addTextField { (textFieldHeight) in
                    textFieldHeight.text  = "\(self.players[indexPath.row].height)"
                }
                
                alert.addAction(UIAlertAction(title: "Cancel", style: .default) {
                    UIAlertAction -> Void in
                })
                
                alert.addAction(UIAlertAction(title: "Edit", style: .default, handler: { [weak alert] (_) in
                    if let playerName = alert?.textFields?[0] ,
                       let playerAge = alert?.textFields?[1],
                       let playerHeight = alert?.textFields?[2]{
                        
                        //edit core data
                        let item = self.players[indexPath.row]
                        guard let sportName = playerName.text else {return}
                        item.name = sportName
                        guard let playerAge = Int64(playerAge.text!) else {return }
                        item.age = playerAge
                        guard let playerHieght = Double(playerHeight.text!)else {return }
                        item.height = playerHieght
                        
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
                        for sport in self.players{
                            print(sport.name!)
                        }
                        
                    }
                    
                }))
                
                
                self.present(alert, animated: true, completion: nil)
            }
}
