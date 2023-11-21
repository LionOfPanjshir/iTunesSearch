import UIKit

var greeting = "Hello, playground"

extension Data {
    func prettyPrintedJSONString() {
        guard
            let jsonObject = try?
               JSONSerialization.jsonObject(with: self,
               options: []),
            let jsonData = try?
               JSONSerialization.data(withJSONObject:
               jsonObject, options: [.prettyPrinted]),
            let prettyJSONString = String(data: jsonData,
               encoding: .utf8) else {
                print("Failed to read JSON Object.")
                return
        }
        print(prettyJSONString)
    }
}

struct StoreItem: Codable {
    var wrapperType: String
    var kind: String
    var artistName: String
    var collectionName: String
    var trackName: String
    var artistViewUrl: URL
}

struct SearchResponse: Codable {
    let results: [StoreItem]
}

enum StoreItemError: Error, LocalizedError {
    case itemNotFound
}

func fetchItems() async throws -> [StoreItem] {
    
    var urlComponents = URLComponents(string: "https://itunes.apple.com/search?")!
    
    urlComponents.queryItems = [
        "term": "The+Killers",
        "media": "music"
    ].map { URLQueryItem(name: $0.key, value: $0.value)}
    
    let url = urlComponents
    
    /*
     guard let httpResponse = response as? HTTPURLResponse,
           httpResponse.statusCode == 200 else {
         throw PhotoInfoError.itemNotFound
     }
     
     let jsonDecoder = JSONDecoder()
     let photoInfo = try jsonDecoder.decode(PhotoInfo.self, from: data)
     return(photoInfo)
 }
     */
    
    
    let (data, response) = try await URLSession.shared.data(from: url.url!)
        
    guard let httpResponse = response as? HTTPURLResponse,
        httpResponse.statusCode == 200 else {
        throw StoreItemError.itemNotFound
        }
        
    let jsonDecoder = JSONDecoder()
    let searchResponse = try jsonDecoder.decode(SearchResponse.self, from: data)
    
    return searchResponse.results
}

Task {
    do {
        let storeItems = try await fetchItems()
        storeItems.forEach { item in
            print("""
            Wrapper Type: \(item.wrapperType)
            Kind: \(item.kind)
            Artist Name: \(item.artistName)
            Collection Name: \(item.collectionName)
            Track Name: \(item.trackName)
            Artist View URL: \(item.artistViewUrl)
            \n
            """)
        }
    } catch {
        print(error)
    }
}
