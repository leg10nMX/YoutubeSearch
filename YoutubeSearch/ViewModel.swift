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
}

class ViewModel {
  private var items :[YoutubeClient.SearchItem]?
  weak var delegate :ViewModelDelegate!
  
  init (delegate:ViewModelDelegate) {
    self.delegate = delegate
  }
}