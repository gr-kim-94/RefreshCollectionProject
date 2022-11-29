//
//  BottomViewController.swift
//  RefreshCollectionProject
//
//  Created by grkim on 2022/11/24.
//

import UIKit

class BottomViewController: UIViewController {
    @IBOutlet weak var collectionView: BottomCollectionView!
    
    private var _refresher: UIRefreshControl?
    var refresher: UIRefreshControl {
        get {
            if let refresher = _refresher {
                return refresher
            } else {
                let refresher = UIRefreshControl()
                refresher.backgroundColor = .clear
                refresher.tintColor = .black
                
                let indicator = UIActivityIndicatorView(style: .large)
                refresher.addSubview(indicator)
                
                _refresher = refresher
                
                return refresher
            }
        }
    }
    
    private var _bottomRefresher: UIRefreshControl?
    var bottomRefresher: UIRefreshControl {
        get {
            if let bottomRefresher = _bottomRefresher {
                return bottomRefresher
            } else {
                let refresher = UIRefreshControl()
                refresher.backgroundColor = .red
                refresher.tintColor = .black
                
                let indicator = UIActivityIndicatorView(style: .large)
                refresher.addSubview(indicator)
                
                _bottomRefresher = refresher
                
                return refresher
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .clear
        
        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.refreshControl = self.refresher
    }
}

extension BottomViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.refresher.isRefreshing {
            self.refresher.endRefreshing()
        }
        
        let delayInSeconds = DispatchTime.now() + .seconds(1)

        DispatchQueue.main.asyncAfter(deadline: delayInSeconds) {
            self.collectionView.hideBottomView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.collectionView.changedContentOffset()
    }
    
}

extension BottomViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        cell.label.text = "test \(indexPath.row)"
        cell.backgroundColor = UIColor(red: drand48(), green: drand48(), blue: drand48(), alpha: 1.0)
        return cell
    }
}

extension BottomViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 100)
    }
}
