//
//  ViewModel.swift
//  YoutubeSearch
//
//  Created by Emanuel Peña Aguilar on 15/10/14.
//  Copyright (c) 2014 Macrominds. All rights reserved.
//

import Foundation
protocol ViewModelDelegate: class {
  func searchResultsDidChange()
  func searchDidFailWithError(error: NSError)
}

class ViewModel {
  private var youtubeClient = YoutubeClient()
  private var items :[YoutubeClient.SearchItem]?
  weak var delegate :ViewModelDelegate!
  
  private var _query: NSString?
  var query: NSString? {
    get {
      return _query
    }
    set {
      _query = newValue
      if (_query?.length > 0) {
        self.youtubeClient.search(_query!, success: { (searchResults) -> Void in
          self.items = searchResults
          self.delegate.searchResultsDidChange()
          }, failure: { (error) -> Void in
            self.delegate.searchDidFailWithError(error)
        })
      }
    }
  }
  
  init (delegate:ViewModelDelegate) {
    self.delegate = delegate
  }
}