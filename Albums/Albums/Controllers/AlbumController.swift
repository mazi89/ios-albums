//
//  AlbumController.swift
//  Albums
//
//  Created by Karen Rodriguez on 4/6/20.
//  Copyright © 2020 Hector Ledesma. All rights reserved.
//

import Foundation

class AlbumController {
    
    // MARK: - Properties
    
    var albums: [Album] = []
    let baseURL: URL = URL(string: "https://ios-albums-ff76b.firebaseio.com/")!
    
    
    // MARK: - Methods
    
    func getAlbums(completion: @escaping (Error?) -> ()) {
        let requestUrl = baseURL.appendingPathExtension("json")
        
        URLSession.shared.dataTask(with: requestUrl) { data, _, error in
            if let error = error {
                NSLog("Error fetching albums : \(error)")
                completion(error)
                return
            }
            
            guard let data = data else {
                NSLog("No data returned by data task")
                completion(NSError())
                return
            }
            
            do {
                let decodedAlbums = try JSONDecoder().decode([String : Album].self, from: data)
                self.albums = Array(decodedAlbums.values)
                completion(nil)
            } catch {
                NSLog("Error decoding albums: \(error)")
                completion(error)
            }
            
        }.resume()
    }
    
    func put(album: Album, completion: @escaping (Error?) -> () ) {
        let id = album.id
        let requestURL = baseURL.appendingPathComponent(id).appendingPathExtension("json")
        
        var request = URLRequest(url: requestURL)
        request.httpMethod = "PUT"
        
        do {
            request.httpBody = try JSONEncoder().encode(album)
        } catch {
            NSLog("Error Encoding album and assigning it to httpBody")
            completion(error)
            return
        }
        
        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                NSLog("Error initiating request after encoding album : \(error)")
                completion(error)
                return
            }
            completion(nil)
        }.resume()
        
    }
    
    func createAlbum(artist: String, coverArt: [String], name: String, songs: [Song], genres: [String]) {
        let URLs = coverArt.compactMap { URL(string: $0) }
        
        let newAlbum = Album(artist: artist, coverArt: URLs, genres: genres, id: UUID().uuidString, name: name, songs: songs)
        
        self.albums.append(newAlbum)
        
        put(album: newAlbum) { (error) in
            if let error = error {
                NSLog("Error sending newly created album to the API : \(error)")
            }
        }
        
    }
    
    func testDecodingExampleAlbum() {
        let urlPath = Bundle.main.url(forResource: "exampleAlbum", withExtension: "json")!
        let codedData = try! Data(contentsOf: urlPath)
        
        let decoder = JSONDecoder()
        
        
        
        do {
            let data = try decoder.decode(Album.self, from: codedData)
            print(data)
        } catch {
            print(error)
        }
    }
    
    func testEncodingExampleAlbum() {
        
        let urlPath = Bundle.main.url(forResource: "exampleAlbum", withExtension: "json")!
        let codedData = try! Data(contentsOf: urlPath)
        
        let decoder = JSONDecoder()
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        do {
            let data = try decoder.decode(Album.self, from: codedData)
            let encoded = try encoder.encode(data)
            let dataAsString = String(data: encoded, encoding: .utf8)!
            print(dataAsString)
        } catch {
            print(error)
        }
    }
}
