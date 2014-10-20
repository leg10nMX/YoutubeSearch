//
//  YoutubeClient.swift
//  YoutubeSearch
//
//  Created by Emanuel Peña Aguilar on 15/10/14.
//  Copyright (c) 2014 Macrominds. All rights reserved.
//
import Foundation

class YoutubeClient {
  typealias JSONDictionary = [String:AnyObject]
  private enum Result {
    case success(result: Any)
    case failure(error: NSError)
  }
  private let searchQueue = dispatch_queue_create("YoutubeClient.SearchQueue", nil)
  private struct Constants {
    static let apiKey = "AIzaSyAZ2S1DrOGjgra13vIQKCaYwlxxZH2t-uw"
    static let items = "items"
    struct Error {
      static let errorDomain = "YoutubeClient"
      static let noItemsFound = 0
    }
  }
  class SearchItem {
    private struct Constants {
      static let videoId = "videoId"
      static let publishedAt = "publishedAt"
      static let title = "title"
      static let videoDescription = "description"
      static let thumbnails = "thumbnails"
      static let channelTitle = "channelTitle"
      static let id = "id"
      static let snippet = "snippet"
    }
    class Thumbnails {
      private struct Constants {
        static let defaultThumbnail = "default"
        static let mediumThumbnail = "medium"
        static let highThumbnail = "high"
        static let url = "url"
      }
      private func thumbnailWithName(name:String) -> String? {
        if let thumbnail = self.dictionary[name] as? JSONDictionary {
          return thumbnail[Constants.url] as String?
        }
        return nil
      }
      private let dictionary: JSONDictionary!
      var defaultThumbnail: String? {
        get {
          return thumbnailWithName(Constants.defaultThumbnail)
        }
      }
      var mediumThumbnail: String? {
        get {
          return thumbnailWithName(Constants.mediumThumbnail)
        }
      }
      var highThumbnail: String? {
        get {
          return thumbnailWithName(Constants.highThumbnail)
        }
      }
      init(dictionary: JSONDictionary) {
        self.dictionary = dictionary
      }
    }
    
    private func snippetPropertyWithName(name: String) -> AnyObject? {
      if let snippet = self.dictionary[Constants.snippet] as? JSONDictionary {
        return snippet[name]
      }
      return nil
    }
    
    var videoId: String? {
      get {
        if let id = self.dictionary[Constants.id] as? JSONDictionary {
          return id[Constants.videoId] as String?
        }
        return nil
      }
    }
    var publishedAt: String? {
      get {
        return snippetPropertyWithName(Constants.publishedAt) as String?
      }
    }
    var title: String? {
      get {
        return snippetPropertyWithName(Constants.title) as String?
      }
    }
    var videoDescription: String? {
      get {
        return snippetPropertyWithName(Constants.videoDescription) as String?
      }
    }
    var channelTitle: String? {
      get {
        return snippetPropertyWithName(Constants.channelTitle) as String?
      }
    }
    
    let thumbnails: Thumbnails?
    
    private let dictionary: JSONDictionary!
    init (dictionary: JSONDictionary) {
      self.dictionary = dictionary
      if let thumbnailDictionary = self.snippetPropertyWithName(Constants.thumbnails) as JSONDictionary? {
        self.thumbnails = Thumbnails(dictionary: thumbnailDictionary)
      }
    }
  }
  func search(query:String,success : [SearchItem] -> Void, failure : NSError -> Void) {
    dispatch_async(self.searchQueue, { () -> Void in
      
      let escapedQuery: String! = query.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
      let urlString = "https://www.googleapis.com/youtube/v3/search?part=snippet&q=\(escapedQuery)&type=video&key=\(Constants.apiKey)"
      switch self.fetchURL(NSURL(string: urlString)!) {
      case let .failure(error):
        failure(error)
        
      case let .success(jsonData):
        switch self.parseJSON(jsonData as NSData) {
        case let .failure(error):
          failure(error)
          
        case let .success(jsonDictionary):
          if let items = (jsonDictionary as? JSONDictionary)?[Constants.items] as? [JSONDictionary] {
            var adapterArray = [SearchItem]()
            for item in items {
              adapterArray.append(SearchItem(dictionary: item))
            }
            success(adapterArray)
          } else {
            failure(NSError(domain: Constants.Error.errorDomain, code: Constants.Error.noItemsFound, userInfo: nil))
          }
        }
      }
    })
  }
  
  private func fetchURL(url: NSURL) -> Result {
    var serviceError: NSError?
    let data: NSData! = NSData(contentsOfURL: url, options: NSDataReadingOptions.allZeros, error: &serviceError)
    if serviceError != nil {
      return Result.failure(error: serviceError!)
    }
    return Result.success(result: data)
  }
  
  private func parseJSON(data: NSData) -> Result {
    var jsonError : NSError?
    let dictionaryString :String! = NSString(data: data, encoding: NSUTF8StringEncoding)
    let dataDictionary = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.allZeros, error: &jsonError) as [String:AnyObject]?
    if jsonError != nil {
      return Result.failure(error: jsonError!)
    }
    return Result.success(result: dataDictionary!)
  }
}