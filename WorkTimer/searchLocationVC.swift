//
//  searchLocationVC.swift
//  WorkTimer
//
//  Created by taeyoung on 2023/02/22.
//

import Foundation
import GooglePlaces
import UIKit

class searchLocationVC : UIViewController {
    
    private var tableView: UITableView!
    private var tableDataSource: GMSAutocompleteTableDataSource!
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
            searchBar.showsCancelButton = true
            searchBar.placeholder = "주소를 입력해주세요."
        }
    }
    @IBOutlet weak var locationTableView: UITableView! {
        didSet {
            tableDataSource = GMSAutocompleteTableDataSource()
            tableDataSource.delegate = self
            locationTableView.delegate = tableDataSource
            locationTableView.dataSource = tableDataSource
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}

extension searchLocationVC : GMSAutocompleteTableDataSourceDelegate {
    func didUpdateAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        locationTableView.reloadData()
    }
    
    func didRequestAutocompletePredictions(for tableDataSource: GMSAutocompleteTableDataSource) {
        locationTableView.reloadData()
    }
    
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didAutocompleteWith place: GMSPlace) {
        for sub in self.view.subviews {
            if let subview = sub as? UITableView {
                sub.removeFromSuperview()
                break
            }
        }
        
        searchBar.endEditing(true)
        searchBar.text = ""
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didFailAutocompleteWithError error: Error) {
        print("ERROR : \(error.localizedDescription)")
    }
    
    func tableDataSource(_ tableDataSource: GMSAutocompleteTableDataSource, didSelect prediction: GMSAutocompletePrediction) -> Bool {
        UserDefaultsManager.destinationLocation = prediction.attributedFullText.string
        self.dismiss(animated: true)
        return true
     }
        
    
}

extension searchLocationVC : UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
           view.addSubview(locationTableView)
       }
       
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        for sub in self.view.subviews {
        if let subview = sub as? UITableView {
                sub.removeFromSuperview()
                break
            }
        }
        searchBar.endEditing(true)
        searchBar.text = ""
        
        self.dismiss(animated: true)
       }
       
       func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
           // Update the GMSAutocompleteTableDataSource with the search text.
           tableDataSource.sourceTextHasChanged(searchText)
       }
}
