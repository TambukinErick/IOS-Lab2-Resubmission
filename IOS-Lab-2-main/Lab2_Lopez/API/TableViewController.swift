//
//  ViewController.swift
//  API
//
//  Created by student on 3/20/23.
//

import UIKit

class TableViewController: UITableViewController {

    var searchResponse: SearchResponse?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(NSLocalizedString("tableview_title", comment: ""))
        makeAPICall { searchResponse in
            self.searchResponse = searchResponse
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = searchResponse?.Search[17].films[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let stuff = searchResponse?.Search[17].films
        let mediaCount = (stuff?.count ?? 0)
        return mediaCount
    }
    
    func makeAPICall(completion: @escaping (SearchResponse?) -> Void) {
        print("start API call")
        
        let domain = "https://api.disneyapi.dev/character"
        let searchQuery = "Donald%20Duck"
        guard let url = URL(string: "\(domain)?name=\(searchQuery)") else {
            completion(nil)
            return
        }
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            var searchResponse: SearchResponse?
            defer {completion(searchResponse)}
            if let error = error {
                print("Error with API call: \(error)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode)
            else {
                print("Error with the response (\(String(describing: response))")
                return
            }
            if let data = data,
               let response = try? JSONDecoder().decode(SearchResponse.self, from: data)
            {
                print("success")
                searchResponse = response
            } else {
                print("Something is wrong with decoding, probably.")
            }
        }
        task.resume()
    }
}

struct SearchResponse: Codable {
    let Search: [DisneyData]

    enum CodingKeys: String, CodingKey {
        case Search = "data"
    }
}

struct DisneyData: Codable {
    let id: Int
    let films: [String]
    let shortFilms: [String]
    let tvShows: [String]

    enum CodingKeys: String, CodingKey {
        case id = "_id"
        case films
        case shortFilms
        case tvShows
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.films = try container.decode([String].self, forKey: .films)
        self.shortFilms = try container.decode( [String].self, forKey: .shortFilms)
        self.tvShows = try container.decode([String].self, forKey: .tvShows)
    }
}
