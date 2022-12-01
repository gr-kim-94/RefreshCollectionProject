//  https://github.com/gr-kim-94/RefreshCollectionProject
//
//  RefreshCollectionView.swift
//  RefreshCollectionProject
//
//  Created by grkim on 2022/11/28.
//

import UIKit

private let kIndicatorWidth: CGFloat = 50
private let kIndicatorHeight: CGFloat = 50

private let kBottomAnimateTimeSecond: Int = 1

private let kMinBottomViewHeight: CGFloat = kIndicatorHeight + 10
private let kMaxBottomViewHeight: CGFloat = kDefaultTriggerRefreshVerticalOffset
private let kMaxBottomViewTrackingHeight: CGFloat = kDefaultTriggerRefreshVerticalOffset * 2

private let kDefaultTriggerRefreshVerticalOffset: CGFloat = 100

class RefreshCollectionView: UICollectionView {
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
    
    var bottomView = UIView()
    private var bottomIndicatorView = UIActivityIndicatorView(style: .large)
    
    private var defaultCotentInset: UIEdgeInsets = .zero
    private var defaultIndicatorHeight: CGFloat = 0
    private var bottomViewHeight: NSLayoutConstraint?
    private var wasTracking: Bool = false
    
    var isAnimating: Bool = false
    
    var isBottomAnimating: Bool {
        self.bottomIndicatorView.isAnimating
    }
    
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
        self.refreshControl = self.refresher
        self.defaultCotentInset = self.contentInset
        
        self.bottomView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width, height: kMinBottomViewHeight))
        self.bottomView.isUserInteractionEnabled = false
        self.bottomView.isHidden = true
        
        self.bottomIndicatorView.color = .black
        self.bottomIndicatorView.hidesWhenStopped = false
        
        self.bottomView.addSubview(self.bottomIndicatorView)
        
        // Bottom Indicator LayoutConstraint
        self.bottomIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.bottomIndicatorView.centerXAnchor.constraint(equalTo: self.bottomView.centerXAnchor),
            self.bottomIndicatorView.centerYAnchor.constraint(equalTo: self.bottomView.centerYAnchor),
            self.bottomIndicatorView.widthAnchor.constraint(equalToConstant: kIndicatorWidth),
            self.bottomIndicatorView.heightAnchor.constraint(equalToConstant: kMinBottomViewHeight)
        ])
        self.superview?.insertSubview(self.bottomView, belowSubview: self)
        
        // Bottom LayoutConstraint
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
        self.startAnimating()
        
        if self.contentOffset.y <= (self.maxContentOffset.y + kMinBottomViewHeight), !self.bottomIndicatorView.isAnimating {
            self.hideBottomView()
        } else {
            if self.wasTracking, !self.isTracking, !self.bottomView.isHidden {
                self.animateChangeInset(kMinBottomViewHeight)
            }
            
            var height = max((self.contentOffset.y - self.maxContentOffset.y), kMinBottomViewHeight)
            if self.isTracking {
                height = min(height, kMaxBottomViewTrackingHeight)
            } else {
                height = min(height, kMaxBottomViewHeight)
            }
            self.bottomViewHeight?.constant = height
            
            self.showBottomView()
            
            self.wasTracking = self.isTracking
        }
    }
    
    // MARK: Refresh Control
    func hideRefreshControl() {
        if self.refresher.isRefreshing {
            self.refresher.endRefreshing()
            self.isAnimating = false
        }
    }
    
    private func startAnimating() {
        if self.refresher.isRefreshing, !self.refresher.isHidden, self.isTracking {
            self.isAnimating = true
        }
    }
    
    // MARK: Bottom View
    func showBottomView() {
        var showBottomView = self.contentOffset.y >= self.maxContentOffset.y + kMinBottomViewHeight
        
        if showBottomView, (self.wasTracking && !self.isTracking) {
            showBottomView = self.contentSize.height + defaultCotentInset.top + defaultCotentInset.bottom + self.defaultIndicatorHeight >= self.bounds.height
        }
        
        if self.contentOffset.y <= 0 {
            showBottomView = false
        }
        
        if !self.isTracking {
            showBottomView = false
        }
        
        if showBottomView {
            self.bottomView.isHidden = false
            self.startBottomAnimating()
        }
    }
    
    func hideBottomView() {
        self.bottomView.isHidden = true
        self.stopBottomAnimating()
        
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
    
    // MARK: Bottom Indicator Animating
    private func startBottomAnimating() {
        if self.contentOffset.y >= self.maxContentOffset.y + kDefaultTriggerRefreshVerticalOffset {
            self.bottomIndicatorView.startAnimating()
        }
    }
    
    private func stopBottomAnimating() {
        self.bottomIndicatorView.stopAnimating()
    }
}
