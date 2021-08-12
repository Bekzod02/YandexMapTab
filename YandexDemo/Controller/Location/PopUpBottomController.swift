//
//  PopUpBottomController.swift
//  YandexDemo
//
//  Created by sabgames on 03.08.2021.
//



import UIKit
import YandexMapsMobile


class PopUpBottomController: BottomPopupViewController  {
    
    var searchManager = SearchManager()
    var delegate: SearchDelegate?
    var searchResultString: String? = ""
    
    
    var addressTable: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    var searchModules: [SearchModule]? {
        didSet {
            OperationQueue.main.addOperation {
                self.addressTable.reloadData()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        // PopUPSearchBar
        let popupSearchBur = UISearchBar()
        popupSearchBur.delegate = self
        popupSearchBur.searchBarStyle = .minimal
        popupSearchBur.backgroundColor = .white
        popupSearchBur.placeholder = "Search"
        popupSearchBur.layer.cornerRadius = 20
        popupSearchBur.layer.masksToBounds = true
        //mySearchBar.endEditing(true)
        view.addSubview(popupSearchBur)
        popupSearchBur.translatesAutoresizingMaskIntoConstraints = false
        popupSearchBur.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        popupSearchBur.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        popupSearchBur.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        
        // TableView
        
        view.addSubview(addressTable)
        addressTable.delegate = self
        addressTable.dataSource = self
        addressTable.backgroundColor = .white
        addressTable.separatorStyle = .none
        addressTable.topAnchor.constraint(equalTo: popupSearchBur.bottomAnchor, constant: 10).isActive = true
        addressTable.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        addressTable.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        addressTable.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        addressTable.register(PopupTableViewCell.self, forCellReuseIdentifier: PopupTableViewCell.identifier)
//        addressTable.estimatedRowHeight = 100
//        addressTable.rowHeight = UITableView.automaticDimension
        
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        addressTable.estimatedRowHeight = 100
//        addressTable.rowHeight = UITableView.automaticDimension
//    }
    
    override func getPopupTopCornerRadius() -> CGFloat {
        return 12
    }
    
    override func getPopupHeight() -> CGFloat {
        
        let height = UIScreen.main.bounds.height - 70
        return height    }
}


extension PopUpBottomController: UITableViewDelegate, UITableViewDataSource {
    
    private func filterAndModifyTextAttributes(searchStringCharacters: String, completeStringWithAttributedText: String) -> NSMutableAttributedString {

        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: completeStringWithAttributedText)
        let pattern = searchStringCharacters.lowercased()
        let range: NSRange = NSMakeRange(0, completeStringWithAttributedText.count)
        var regex = NSRegularExpression()
        do {
            regex = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options())
            regex.enumerateMatches(in: completeStringWithAttributedText.lowercased(), options: NSRegularExpression.MatchingOptions(), range: range) {
                (textCheckingResult, matchingFlags, stop) in
                let subRange = textCheckingResult?.range
                let attributes : [NSAttributedString.Key : Any] = [.font : UIFont.boldSystemFont(ofSize: 16),.foregroundColor: UIColor.black ]
                attributedString.addAttributes(attributes, range: subRange!)
            }
        }catch{
            print(error.localizedDescription)
        }
        return attributedString
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchModules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PopupTableViewCell.identifier, for: indexPath) as! PopupTableViewCell
        cell.locationLabel.attributedText = self.filterAndModifyTextAttributes(searchStringCharacters: self.searchResultString ?? "", completeStringWithAttributedText: (searchModules?[indexPath.item].locationAdress!)!)
        cell.searchModule = searchModules?[indexPath.item]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("\(indexPath.item)")
        tableView.deselectRow(at: indexPath, animated: true)
        let latDouble = Double((searchModules?[indexPath.item].lat)!)
        let lonDouble = Double((searchModules?[indexPath.item].lon)!)
        delegate?.searchAndMove(langitude: latDouble!, longitude: lonDouble!)
        dismiss(animated: true, completion: nil)
        addressTable.reloadData()
    }


}

extension PopUpBottomController: UISearchBarDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchResultString = searchBar.text
        if searchText == "" {
            searchModules = [SearchModule]()
            addressTable.reloadData()
        } else if searchBar.text!.count > 2 {
            if let location = searchBar.text {
                searchManager.fetchLocation(locationName: location) { searchResult in
                    DispatchQueue.main.async {
                        self.searchModules = searchResult
                        self.addressTable.reloadData()
                    }
                }
            }
            
        }
        
        
        
        
//        else if let location = searchBar.text?.count > 2{
//            searchResultString = location
//            print(location.count)
//            searchManager.fetchLocation(locationName: location) { searchResult in
//                DispatchQueue.main.async {
//                    self.searchModules = searchResult
//                    self.addressTable.reloadData()
//                }
//            }
//        }
        
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.endEditing(true)
        view.endEditing(true)
        addressTable.reloadData()
    }
 
}





