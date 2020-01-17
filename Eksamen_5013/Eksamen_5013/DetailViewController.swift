//
//  DetailViewController.swift
//  Eksamen_5013
//
//

import Foundation
import UIKit
import CoreData

class DetailViewController : UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var detailImage: UIImageView!
    
    
    @IBOutlet weak var detailTable: UITableView!
    
    @IBOutlet weak var artistLabel: UILabel!
    
    
    @IBOutlet weak var albumLabel: UILabel!
    
    
    @IBOutlet weak var yearLabel: UILabel!
    
    //variables populated through segue
    var imgSource : String?
    
    var albumSource : Int?
    
    var albumStr : String?
    
    var artistStr : String?
    
    var yearStr : String?
    
    //array of struct from tracks in album api
    var songs = [tracks]()
    
    override func viewWillAppear(_ animated: Bool) {
        detailTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //in some cases, when you search for albums the albumThumb is either null or an empty string, we need to handle it like this
        if(imgSource != nil && !(imgSource ?? "").isEmpty){
            
            detailImage.load(url: URL(string: imgSource!)!)
            
        }
        else {
           detailImage.load(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/600px-No_image_available.svg.png")!)
        }
        artistLabel.text = artistStr
        albumLabel.text = albumStr
        yearLabel.text = yearStr
        
        let Trackcell = UINib(nibName: "detailListCell", bundle: nil)
        
        detailTable.register(Trackcell, forCellReuseIdentifier: "tableCell")
        
        
        requestTracks()
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! detailListCellView
        
        let arrayOf = Array(songs)
        
        let row = arrayOf[indexPath.row]
        
        cell.trackNum.text = "\(row.intTrackNumber)."
        cell.track.text = row.strTrack
        cell.duration.text = toMinutesSeconds(duration: row.intDuration)
        cell.artistName = artistStr
        cell.trackId = row.idTrack
        
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        
        let managedContext = appDelegate?.persistentContainer.viewContext
        
        let favTrack = NSFetchRequest<NSFetchRequestResult>(entityName: "Favorite")
        
        //if a track within an album is contained in coreData, show filled star and disable the button, since we already have a delete function in favoriteview
        do{
            let result = try managedContext?.fetch(favTrack)
            for data in result as! [NSManagedObject] {
                if(data.value(forKey: "idTrack") as? String == cell.trackId && data.value(forKey: "isFavorite") as! Bool == true){
                    cell.favoriteBtn.setImage( UIImage(systemName: "star.fill"), for: .normal)
                    cell.favoriteBtn.isEnabled = false
                }
            }
        } catch {
            print("could not fetch")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func toMinutesSeconds(duration: String)-> String{
        let time = Int(duration)!/1000
        
        let timeFormatter = DateComponentsFormatter()
        timeFormatter.allowedUnits = [.minute, .second]
        
        let actualTimeFormat = timeFormatter.string(from: TimeInterval(time))!
        
        return actualTimeFormat
    }
    
    func requestTracks() {
        
        //same process as in requestMostLoves(), but we do now request trackData instead with a different struct "track" from SongsAlbum.swift
        let url = URL(string: "https://theaudiodb.com/api/v1/json/1/track.php?m=\(albumSource!)")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error
            
            in guard let data = data else {return}
            
            do {
                let decoder = JSONDecoder()
                let jsonDict = try decoder.decode([String: [tracks]].self, from: data)
                if let trackData = jsonDict["track"] {
                    
                    self.songs = trackData
                    
                    DispatchQueue.main.async {[weak self] in
                        self?.detailTable.reloadData()
                    }
                    print(self.songs)
                }
                
            } catch let parseErr {
                print("parsing went wrong", parseErr)
            }
        })
        task.resume()
    }
    
}
