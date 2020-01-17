//
//  FavoriteViewController.swift
//  Eksamen_5013
//
//

import Foundation
import UIKit
import CoreData

class FavoriteViewController : UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
    
    
    @IBOutlet weak var favoriteTable: UITableView!
    
    @IBOutlet weak var recommendedTable: UICollectionView!
    
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    var btnState = 1;
        
    //array of struct from coreData
    var favorites = [favo]()
    
    //array of struct from tasteDrive api
    var recommended = [Similar]()

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
                
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        let fetchRequest =
            NSFetchRequest<NSManagedObject>(entityName: "Favorite")
        fetchRequest.returnsObjectsAsFaults = false
        
        do {
            let favoriteEntity = try managedContext.fetch(fetchRequest)
            for fetched in favoriteEntity as [NSManagedObject] {
                //if for some reason, any parameters fetched from coreData is nil, delete it
                if((fetched.value(forKey: "idTrack") == nil)||(fetched.value(forKey: "isFavorite") == nil) || (fetched.value(forKey: "intTrackNumber") == nil)||(fetched.value(forKey: "artistStr") == nil)||(fetched.value(forKey: "strTrack") == nil)||(fetched.value(forKey: "intDuration") == nil)){
                    managedContext.delete(fetched)
                    do{
                        try managedContext.save()
                    } catch let error as NSError {
                        print(error)
                    }
                } else {
                    //inits coreData as a track and append it to favorites array
                        let track = favo.init(idTrack: fetched.value(forKey: "idTrack") as! String,isFavorite: fetched.value(forKey: "isFavorite") as! Bool, strArtist: fetched.value(forKey: "artistStr") as! String, strTrack: fetched.value(forKey: "strTrack") as! String, intDuration: fetched.value(forKey: "intDuration") as! String)
                    //removes any duplicates added when navigating to this view (since append happends every time viewWillApear runs)
                if((favorites.contains(where: {$0.strTrack == track.strTrack}))){
                    favorites.removeAll(where: {$0.strTrack == track.strTrack})
                    //we need to add again because we just removed any occurence of that track.
                    self.favorites.append(track)
                    favoriteTable.reloadData()
                } else {
                self.favorites.append(track)
                 favoriteTable.reloadData()
                }
              }
        }
            if(favorites.count != 0){recommendArtists()}
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let favoriteNib = UINib(nibName: "favoriteListCell", bundle: nil)
        
        favoriteTable.register(favoriteNib, forCellReuseIdentifier: "favoriteCell")
        
        let recommendedNib = UINib(nibName: "favoriteColCell", bundle: nil)
        
        recommendedTable.register(recommendedNib, forCellWithReuseIdentifier: "recommendCol")
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return favorites.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recommended.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = favoriteTable.dequeueReusableCell(withIdentifier: "favoriteCell", for: indexPath) as! favoriteListCellView
        
        let arrayOf = Array(favorites)
        
        let row = arrayOf[indexPath.row]
        
        cell.trackName.text = row.strTrack
        cell.orderNum.text = String("\(indexPath.row + 1).")
        cell.duration.text = row.intDuration
        cell.artist.text = row.strArtist
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = recommendedTable.dequeueReusableCell(withReuseIdentifier: "recommendCol", for: indexPath) as! favoriteColCellView
        
        let arrayOf = Array(recommended)
        
        let row = arrayOf[indexPath.row]
        
        cell.recoArtist.text = row.Name
        
        return cell
    }
    
    
    @IBAction func editMode(_ sender: Any) {
        if(btnState == 1) {
            favoriteTable.isEditing = true
            btnState = 0;
        } else {
            favoriteTable.isEditing = false
            btnState = 1;
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "delete confirmation", message: "Are you sure?", preferredStyle: .alert)
        
        if(editingStyle == .delete){
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
                        
                        let managedContext = appDelegate.persistentContainer.viewContext
                        
                        let favTrack = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
                   
                        do {
                           let tracks = try managedContext.fetch(favTrack)
                           let rowToDelete = tracks[indexPath.row] as! NSManagedObject
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
                                managedContext.delete(rowToDelete)
                                self.favorites.remove(at: indexPath.row)
                                do{
                                    try managedContext.save()
                                 } catch let error as NSError {
                                    print(error)
                                }
                                //as stated we want to recommend when we delete tracks too
                                if(self.favorites.count != 0){self.recommendArtists()}
                                tableView.reloadData()
                            }))
                            self.present(alert, animated: true)
                        } catch let error as NSError {
                            print(error)
                            
            }
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let rowToMove = favorites[sourceIndexPath.row]
        favorites.remove(at:sourceIndexPath.row)
        favorites.insert(rowToMove, at: destinationIndexPath.row)
        tableView.reloadData()
    }
    
    func recommendBasedOn(trackStruct: Array<favo>) -> String{
        
      var  artistNameArray = Array<String>()
        
        for track  in trackStruct {
            artistNameArray.append(track.strArtist.replacingOccurrences(of: " ", with: "+"))
        }
        /*returns something like this:
         An+Object%2CA+Second+Object*/
        return String(artistNameArray.joined(separator: "%2C"))
    }
    
    func recommendArtists() {
        

        let url = URL(string: "https://tastedive.com/api/similar?q=\(recommendBasedOn(trackStruct: self.favorites))")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error
            
            in guard let data = data else {return}
            
            do {
                //Decoding the response as a Dictionary of Dictionary
                let decoder = JSONDecoder()
                let jsonDict = try decoder.decode([String: [String :[Similar]]].self, from: data)
                //goes through the dictionary "similar" into "results" to get the array data
                if let recoData = jsonDict["Similar"]!["Results"]{
                    
                    //Populating an array to hold the data
                    self.recommended = recoData
                    
                    DispatchQueue.main.async { [weak self] in
                        self?.recommendedTable.reloadData()

                    }
                    print("Data",self.recommended)
                }
                
            } catch let parseErr {
                print("parsing went wrong", parseErr)
            }
        })
        task.resume()
    }
    
}
