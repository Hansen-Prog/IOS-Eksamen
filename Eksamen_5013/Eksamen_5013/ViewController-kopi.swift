//
//  ViewController.swift
//  Exam_5013
//
//

import UIKit


//From:https://www.hackingwithswift.com/example-code/uikit/how-to-load-a-remote-image-url-into-uiimageview
extension UIImageView {
    func load(url: URL) {
        DispatchQueue.global().async { [weak self] in
            if let data = try? Data(contentsOf: url) {
                if let image = UIImage(data: data) {
                    DispatchQueue.main.async {
                        self?.image = image
                    }
                }
            }
        }
    }
}

class ViewController: UIViewController,UITableViewDataSource, UITableViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
        
    @IBOutlet weak var albumList: UITableView!
    
    @IBOutlet weak var albumCol: UICollectionView!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    //variables we want to send with segue to other views
    var albumId : String?
    
    var image : String?
    
    var album : String?
    
    var artist : String?
    
    var year : String?
    
    //array of struct from most loved album api
    var loved = [mostLoved]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        albumCol.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        let Colcell = UINib(nibName: "customColCell", bundle: nil)
        
        let Listcell = UINib(nibName: "customListCell", bundle: nil)
        
        
        albumList.register(Listcell, forCellReuseIdentifier: "tableCell")
        
        albumCol.register(Colcell, forCellWithReuseIdentifier: "collectionItem")
        
        requestMostLoved()
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loved.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      return  CGSize(width: 150, height: 130)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let arrayOf = Array(loved)
        
        
        let row = arrayOf[indexPath.row]
        
        image = row.strAlbumThumb
        albumId = row.idAlbum
        artist = row.strArtist
        album = row.strAlbum
        year = row.intYearReleased
        
        //performs segue after global variables are set, then prepare() sends those to given controller
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
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionItem", for: indexPath) as! customColCellView
        
        let arrayOf = Array(loved)
        
        
        let row = arrayOf[indexPath.row]
        
        cell.backgroundColor = #colorLiteral(red: 0.1185116544, green: 0.1135028973, blue: 0.117935963, alpha: 1)
        
        
        cell.artist.text = row.strArtist
        cell.artist.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        cell.album.text = row.strAlbum
        cell.album.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        //extention to load urls, found on line 13
        cell.image.load(url: URL(string: row.strAlbumThumb!)!)
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return loved.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(80.0)
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tableCell", for: indexPath) as! customListCellView
        
        let arrayOf = Array(loved)
        
        let row = arrayOf[indexPath.row]
        
        cell.album.text = row.strAlbum
        cell.artist.text = row.strArtist
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let arrayOf = Array(loved)
        
        
        let row = arrayOf[indexPath.row]
        
        image = row.strAlbumThumb
        albumId = row.idAlbum
        artist = row.strArtist
        album = row.strAlbum
        year = row.intYearReleased
        
        self.performSegue(withIdentifier: "detailView", sender: self)
    }
    
    /*using segment controller to switch between tableview and collectionview*/
    @IBAction func segSwitch(_ sender: UISegmentedControl) {
        if(segment.selectedSegmentIndex == 0){
            albumList.isHidden = true
            albumCol.isHidden = false
        }
        else if(segment.selectedSegmentIndex == 1){
            albumCol.isHidden = true
            albumList.isHidden = false
        }
    }
    
    func requestMostLoved() {
        
        let url = URL(string: "https://theaudiodb.com/api/v1/json/1/mostloved.php?format=album")!
        let task = URLSession.shared.dataTask(with: url, completionHandler: { data, response, error
            
            in guard let data = data else {return}
            
            do {
                //Decoding the response as a Dictionary
                let decoder = JSONDecoder()
                let jsonDict = try decoder.decode([String: [mostLoved]].self, from: data)
                //gets the array data within the dictionary "loved"
                if let albumData = jsonDict["loved"] {
                    
                    //Populating an array to hold the data
                    self.loved = albumData
                    
                    //reload data like this
                    DispatchQueue.main.async { [weak self] in
                        self?.albumCol.reloadData()
                        self?.albumList.reloadData()
                    }
                }
                
            } catch let parseErr {
                print("parsing went wrong", parseErr)
            }
        })
        task.resume()
    }

}

