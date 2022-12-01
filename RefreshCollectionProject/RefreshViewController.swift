//
//  RefreshViewController.swift
//  RefreshCollectionProject
//
//  Created by grkim on 2022/11/24.
//

import UIKit

class RefreshViewController: UIViewController {
    @IBOutlet weak var collectionView: RefreshCollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.backgroundColor = .clear
        
        // Do any additional setup after loading the view.
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
}

// MARK: UICollectionViewDelegate
extension RefreshViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.collectionView.isAnimating {
            // request api - pre page
            let delayInSeconds = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: delayInSeconds) {
                self.collectionView.hideRefreshControl()
            }
        } else {
            self.collectionView.hideRefreshControl()
        }

        if self.collectionView.isBottomAnimating {
            // request api - next page
            let delayInSeconds = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: delayInSeconds) {
                self.collectionView.hideBottomView()
            }
        } else {
            self.collectionView.hideBottomView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.collectionView.changedContentOffset()
    }
    
}

// MARK: UICollectionViewDataSource
extension RefreshViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.identifier, for: indexPath) as! CollectionViewCell
        cell.label.text = "test \(indexPath.row)"
        cell.backgroundColor = UIColor(red: drand48(), green: drand48(), blue: drand48(), alpha: 1.0)
        return cell
    }
}

// MARK: UICollectionViewDelegateFlowLayout
extension RefreshViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 250, height: 100)
    }
}
