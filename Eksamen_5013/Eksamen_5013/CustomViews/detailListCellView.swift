//
//  detailListView.swift
//  Eksamen_5013
//
//

import Foundation
import UIKit
import CoreData

class detailListCellView : UITableViewCell {
    
    var didFavorite : Bool = false
    
    @IBOutlet weak var track: UILabel!
    
    @IBOutlet weak var duration: UILabel!
    
    
    @IBOutlet weak var trackNum: UILabel!
    
    
    @IBOutlet weak var favoriteBtn: UIButton!
    
    var artistName: String?
    
    var trackId: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        

        if(didFavorite == true){
            favoriteBtn.setImage( UIImage(systemName: "star.fill"), for: .normal)
        } else {
            favoriteBtn.setImage(UIImage(systemName: "star"), for: .normal)
        }
    }
    
    
    //since ios reuses cells, we want them to have the default state of an unadded track
    override func prepareForReuse() {
        super.prepareForReuse()
        favoriteBtn.isEnabled = true
        favoriteBtn.setImage( UIImage(systemName: "star"), for: .normal)

    }
    
    
    
    //populating coreData when star is pressed, and disabling that star
    @IBAction func addFavorite(_ sender: Any) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let userEntity = NSEntityDescription.entity(forEntityName: "Favorite", in: managedContext)!
        
        let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
        
        if(didFavorite == false){
            favoriteBtn.isEnabled = false
            favoriteBtn.setImage( UIImage(systemName: "star.fill"), for: .normal)
            didFavorite = true
            user.setValue(trackId, forKey: "idTrack")
            user.setValue(track.text!, forKey: "strTrack")
            user.setValue(duration.text!, forKey: "intDuration")
            user.setValue(didFavorite, forKey: "isFavorite")
            user.setValue(artistName, forKey: "artistStr")
            do{
                try managedContext.save()
            } catch let error as NSError {
                print(error)
            }
            print(track.text!)
        } else {
            favoriteBtn.setImage( UIImage(systemName: "star"), for: .normal)
            didFavorite = false
        }
    }
}
