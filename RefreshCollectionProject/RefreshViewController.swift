//
//  RefreshViewController.swift
//  RefreshCollectionProject
//
//  Created by grkim on 2022/11/24.
//

import UIKit

class RefreshViewController: UIViewController {
    @IBOutlet weak var collectionView: RefreshCollectionView!
    
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
    
    private var _bottomRefresher: BottomRefreshControl?
    var bottomRefresher: BottomRefreshControl {
        get {
            if let bottomRefresher = _bottomRefresher {
                return bottomRefresher
            } else {
                let refresher = BottomRefreshControl()
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
        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        self.collectionView.refreshControl = self.refresher
        self.collectionView.btRefreshControl = self.bottomRefresher
        
        // footer view
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 100))
        footerView.backgroundColor = .red

        let indicatorView = UIActivityIndicatorView(style: .large)
        indicatorView.color = .black
        indicatorView.backgroundColor = .green

        footerView.addSubview(indicatorView)

        indicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            indicatorView.centerXAnchor.constraint(equalTo: footerView.centerXAnchor),
            indicatorView.centerYAnchor.constraint(equalTo: footerView.centerYAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 50),
            indicatorView.heightAnchor.constraint(equalToConstant: 50)
        ])
//
//        self.collectionView.footerView = footerView
//        self.collectionView.addSubview(self.bottomRefresher)
//
//        self.collectionView.bounces = true
//        self.collectionView.alwaysBounceVertical = true
    }
}

extension RefreshViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let delayInSeconds = DispatchTime.now() + .milliseconds(1)

        DispatchQueue.main.asyncAfter(deadline: delayInSeconds) {
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.collectionView.refresh_setContentOffset(scrollView.contentOffset, animated: true)
    }
}

extension RefreshViewController: UICollectionViewDataSource {
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

extension RefreshViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 100)
    }
}
