//
//  BottomCollectionView.swift
//  RefreshCollectionProject
//
//  Created by grkim on 2022/11/28.
//

import UIKit

fileprivate let kIndicatorWidth: CGFloat = 50
fileprivate let kIndicatorHeight: CGFloat = 50

fileprivate let kMinBottomViewHeight: CGFloat = kIndicatorHeight + 10

fileprivate let kDefaultTriggerRefreshVerticalOffset: CGFloat = 100

class BottomCollectionView: UICollectionView {
    var bottomView = UIView()
    var bottomIndicatorView = UIActivityIndicatorView(style: .large)
    
    var defaultCotentInset: UIEdgeInsets = .zero
    var bottomViewHeight: NSLayoutConstraint?
    var wasTracking: Bool = false
    
    var maxContentOffset: CGPoint {
        CGPoint(
            x: self.contentSize.width - self.bounds.width + self.contentInset.right,
            y: self.contentSize.height - self.bounds.height + defaultCotentInset.bottom)
    }
    
    // MARK: init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initView()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.initView()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initView()
    }
    
    func initView() {
        self.defaultCotentInset = self.contentInset
        
        self.bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: kMinBottomViewHeight))
        self.bottomView.isUserInteractionEnabled = false
        self.bottomView.isHidden = true
        
//        self.bottomView.backgroundColor = .red
        
        self.bottomIndicatorView.color = .black
//        self.bottomIndicatorView.backgroundColor = .green
        self.bottomIndicatorView.hidesWhenStopped = false
        
        self.bottomView.addSubview(self.bottomIndicatorView)
        
        self.bottomIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.bottomIndicatorView.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor),
            self.bottomIndicatorView.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor),
            self.bottomIndicatorView.widthAnchor.constraint(equalToConstant: kIndicatorWidth),
            self.bottomIndicatorView.heightAnchor.constraint(equalToConstant: kMinBottomViewHeight)
        ])
        
        //        self.superview?.insertSubview(self.bottomView, belowSubview: self)
        self.superview?.addSubview(self.bottomView)
        
        self.bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        let left = NSLayoutConstraint(item: self.bottomView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: self.bottomView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: self.bottomView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -defaultCotentInset.bottom)
        let height = NSLayoutConstraint(item: self.bottomView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kMinBottomViewHeight)
        
        self.bottomViewHeight = height
        self.bottomView.addConstraint(height)
        self.superview?.addConstraints([left, right, bottom])
    }
    
    func changedContentOffset() {
        if self.contentOffset.y <= (self.maxContentOffset.y + kMinBottomViewHeight), !self.bottomIndicatorView.isAnimating {
            self.hideBottomView()
        } else {
            if self.wasTracking, !self.isTracking, !self.bottomView.isHidden {
                self.animateChangeInset(kMinBottomViewHeight)
            }
            
            self.wasTracking = self.isTracking
            
            self.bottomViewHeight?.constant = max((self.contentOffset.y - self.maxContentOffset.y), kMinBottomViewHeight)
            self.showBottomView()
        }
    }
    
    func showBottomView() {
        var showBottomView = self.contentOffset.y >= self.maxContentOffset.y + kMinBottomViewHeight
        
        if showBottomView {
            showBottomView = self.contentSize.height + defaultCotentInset.top + defaultCotentInset.bottom + kIndicatorHeight >= self.bounds.height
        }
        
        if showBottomView {
            self.bottomView.isHidden = false
            self.startAnimating()
        }
    }
    
    func hideBottomView() {
        self.bottomView.isHidden = true
        self.stopAnimating()
        
        if self.contentInset.bottom != self.defaultCotentInset.bottom {
            self.animateChangeInset(self.defaultCotentInset.bottom)
        }
    }
    
    // MARK: Content Insets - Bottom Change Animating
    private func animateChangeInset(_ bottom: CGFloat) {
        let newInsets = UIEdgeInsets(top: self.defaultCotentInset.top, left: self.defaultCotentInset.left, bottom: bottom, right: self.defaultCotentInset.right)
        
        UIView.animate(withDuration: 0.5) {
            self.contentInset = newInsets
        }
    }
    
    // MARK: Indicator Animating
    private func startAnimating() {
        if self.contentOffset.y >= self.maxContentOffset.y + kDefaultTriggerRefreshVerticalOffset {
            self.bottomIndicatorView.startAnimating()
        }
    }
    
    private func stopAnimating() {
        self.bottomIndicatorView.stopAnimating()
    }
}
