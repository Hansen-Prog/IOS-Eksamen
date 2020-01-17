//
//  searchController.swift
//  Eksamen_5013
//
//

import Foundation
import UIKit

class searchViewController : UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var searchCollection: UICollectionView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    //variables we want to send with segue
    var albumId : String?
    
    var image : String?
    
    var album : String?
    
    var artist : String?
    
    var year : String?
    
    var globalSearch : String?
    
    //array of struct from most loved album api
    var albums = [mostLoved]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchCollection.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let searchCell = UINib(nibName: "customColCell", bundle: nil)
        
        searchCollection.register(searchCell, forCellWithReuseIdentifier: "searchCell")
        
    }
    
    //on device, the keyboard blocks the tabbar. We then have to make sure the user can close it.
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "searchCell", for: indexPath) as! customColCellView
               
               let arrayOf = Array(albums)
               
               let row = arrayOf[indexPath.row]
        

               cell.backgroundColor = #colorLiteral(red: 0.1185116544, green: 0.1135028973, blue: 0.117935963, alpha: 1)
               cell.album.text = row.strAlbum
               cell.artist.text = row.strArtist
               if(row.strAlbumThumb != nil && !(row.strAlbumThumb ?? "").isEmpty){
                   
                   cell.image.load(url: URL(string: row.strAlbumThumb!)!)
                   
               }
               else{
                cell.image.load(url: URL(string: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ac/No_image_available.svg/600px-No_image_available.svg.png")!)
           }

               
               return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return  CGSize(width: 150, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        let arrayOf = Array(albums)
        
        let row = arrayOf[indexPath.row]
        
        image = row.strAlbumThumb
        albumId = row.idAlbum
        artist = row.strArtist
        album = row.strAlbum
        year = row.intYearReleased
        
        self.performSegue(withIdentifier: "detailView", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        let vc = segue.destination as! DetailViewController
        vc.imgSource = image
        vc.albumSource = Int(albumId!)
        vc.artistStr = artist
        vc.albumStr = album
        vc.yearStr = year
    }
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        //since we are directly searching in the url, we need to allow ascii characters for spacebar and such
        globalSearch = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        requestAlbums()
        if(searchText.isEmpty){
            albums.removeAll()
            searchCollection.reloadData()
        }
    }
    
    
    
    func requestAlbums() {
        
        let url = URL(string: "https://theaudiodb.com/api/v1/json/1/searchalbum.php?a=\(globalSearch!)")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error
            
            in guard let data = data else {return}
            
            do {
                //Decoding the response as a Dictionary
                //reusing the mostLoved struct, because the albumdata is the same
                let decoder = JSONDecoder()
                let jsonDict = try decoder.decode([String: [mostLoved]].self, from: data)
                if let albumData = jsonDict["album"] {
                    
                    self.albums = albumData
                    
                    DispatchQueue.main.async {[weak self] in
                        self?.searchCollection.reloadData()
                    }
                    print(self.albums)
                }
                
            } catch let parseErr {
                print("parsing went wrong", parseErr)
            }
        })
        task.resume()
    }
    
    
}
