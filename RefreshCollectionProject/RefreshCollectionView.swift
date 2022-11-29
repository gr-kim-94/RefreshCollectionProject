//
//  UICollectionView+Refresh.swift
//  RefreshCollectionProject
//
//  Created by grkim on 2022/11/24.
//

import UIKit

fileprivate let kDefaultTriggerRefreshVerticalOffset: CGFloat = 120
let kMinRefershTime: CGFloat = 0.5

class RefreshCollectionView: UICollectionView {
    // Context
    private lazy var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    private var beginRefreshingDate: Date?
    private var adjustBottomInset: Bool?
    private var wasTracking: Bool?
    private var refreshed: Bool?
    // end
    
    var btRefreshControl: BottomRefreshControl? {
        didSet {
            if let _ = self.btRefreshControl {
                self.btRefreshControl?.delegate = self
                self.initTableView()
            }
        }
    }
    
    // MARK: - Init
    convenience init() {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        self.init(frame: .zero, collectionViewLayout: layout)
        self.initView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initView()
    }
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        self.initView()
    }
    
    func initView() {
        self.wasTracking = self.isTracking
        self.refreshed = false
    }
    
    func initTableView() {
        self.tableView.removeFromSuperview()
        self.tableView = UITableView(frame: .zero, style: .plain)
        
        guard let btRefreshControl = self.btRefreshControl else { return }
        
        self.tableView.isUserInteractionEnabled = false
        self.tableView.backgroundColor = .clear
        self.tableView.separatorStyle = .none
        self.tableView.transform = CGAffineTransformMakeRotation(.pi)
        self.tableView.backgroundColor = UIColor(red: drand48(), green: drand48(), blue: drand48(), alpha: 0.5)
        self.tableView.addSubview(btRefreshControl)
        
        if let _ = self.superview {
            self.insertTableView()
        }
    }
    
    func insertTableView() {
        self.superview?.insertSubview(self.tableView, aboveSubview: self)

        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        
        let left = NSLayoutConstraint(item: tableView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0.0)
        let right = NSLayoutConstraint(item: tableView, attribute: .right, relatedBy: .equal, toItem: self, attribute: .right, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: -self.contentInset.bottom)
        let height = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: kDefaultTriggerRefreshVerticalOffset)
        
        tableView.addConstraint(height)
        self.superview?.addConstraints([left, right, bottom])
    }
    
    func checkRefreshingTimeAndPerformBlock(_ block: @escaping ()->()) {
        if let date = self.beginRefreshingDate {
            let timeSinceLastRefresh = Date().timeIntervalSince(date)
            if timeSinceLastRefresh > kMinRefershTime {
                block()
            } else {
                let delayInSeconds = DispatchTime.now() + .milliseconds(Int(kMinRefershTime - timeSinceLastRefresh))
                DispatchQueue.main.asyncAfter(deadline: delayInSeconds, execute: block)
            }
        } else {
            block()
        }
    }
    
    func handleBottomBounceOffset(_ offset: CGFloat) {
        guard let btRefreshControl = self.btRefreshControl, let refreshed = self.refreshed else {
            return
        }
        
        var contentOffset = self.tableView.contentOffset
        let triggerOffset = btRefreshControl.triggerVerticalOffset2
        
        if !refreshed, (!self.isDecelerating || contentOffset.y < 0) {
            if offset < triggerOffset {
                contentOffset.y = -offset*kDefaultTriggerRefreshVerticalOffset/triggerOffset/1.5
                self.tableView.contentOffset = contentOffset
            } else if !btRefreshControl.isRefreshing {
                self.startRefresh()
            }
        }
    }
    
    func startRefresh() {
        self.beginRefreshingDate = Date()
        
        self.btRefreshControl?.beginRefreshing()
        self.btRefreshControl?.sendActions(for: .valueChanged)
        
        if let adjustBottomInset = self.adjustBottomInset,
           !self.isTracking, !adjustBottomInset {
            self.setAdjustBottomInset(true, animated: true)
        }
    }
    
    func stopRefresh() {
        self.wasTracking = self.isTracking
        
        if let adjustBottomInset = self.adjustBottomInset,
           !self.isTracking, adjustBottomInset {
            DispatchQueue.main.async {
                self.setAdjustBottomInset(false, animated: true)
            }
        }
        
        self.refreshed = self.isTracking
    }
    
    func didEndTracking() {
        guard let btRefreshControl = self.btRefreshControl else { return }
        if let adjustBottomInset = self.adjustBottomInset,
            btRefreshControl.isRefreshing, !adjustBottomInset {
            self.setAdjustBottomInset(true, animated: true)
        }
        
        if let adjustBottomInset = self.adjustBottomInset,
           adjustBottomInset, !btRefreshControl.isRefreshing {
            self.setAdjustBottomInset(false, animated: true)
        }
    }
    
    func setAdjustBottomInset(_ adjust: Bool, animated: Bool) {
        let contentInset = self.contentInset
        self.adjustBottomInset = adjust
        
        let duration = animated ? 0 : kMinRefershTime
        UIView.animate(withDuration: TimeInterval(duration)) {
            self.contentInset = contentInset
        }
    }
    
    // MARK: Override
    override func updateConstraints() {
        if let superView = self.superview {
            if let idx = superView.constraints.firstIndex(where: { constraint in
                return (constraint.firstItem as? UITableView == self.tableView) && (constraint.secondItem as? UICollectionView == self) && (constraint.firstAttribute == .bottom)
            }) {
                superView.constraints[idx].constant = -contentInset.bottom
            }
        }
        
        super.updateConstraints()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        guard let _ = self.btRefreshControl else { return }
        
        if let _ = self.superview {
            self.insertTableView()
        } else {
            self.tableView.removeFromSuperview()
        }
    }
    
    override var contentInset: UIEdgeInsets {
        get {
            var insets = super.contentInset
            
            if let adjustBottomInset = self.adjustBottomInset, adjustBottomInset {
                insets.bottom = insets.bottom - (self.btRefreshControl?.frame.size.height ?? 0)
            }
            
            return insets
        }
        set {
            var insets = newValue
            var updateConstraints = false

            if let adjustBottomInset = self.adjustBottomInset, adjustBottomInset {
                updateConstraints = true
                insets.bottom = insets.bottom + (self.btRefreshControl?.frame.size.height ?? 0)
            }
            
            super.contentInset = insets
            
            if updateConstraints {
                self.setNeedsUpdateConstraints()
            }
        }
    }
    
    func refresh_setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
//        guard let wasTracking = self.wasTracking else { return }
//
//        if wasTracking, !self.isTracking {
//            self.didEndTracking()
//        }
//
//        self.wasTracking = self.isTracking
//
//        let contentInset = self.contentInset
//        let height = self.frame.size.height
//
//        let offset = (contentOffset.y + contentInset.top + height) - max((self.contentSize.height + contentInset.bottom + contentInset.top), height)
//
//        if offset > 0 {
//            self.handleBottomBounceOffset(offset)
//        } else {
//            self.refreshed = false
//        }
        self.tableView.setContentOffset(contentOffset, animated: true)
    }
}

// MARK: BottomRefreshControlDelegate
extension RefreshCollectionView: BottomRefreshControlDelegate {
    func didEndRefreshing() {
        self.checkRefreshingTimeAndPerformBlock {
            self.btRefreshControl?.endRefreshing()
            self.stopRefresh()
        }
    }
}

// MARK: class BottomRefreshControl
protocol BottomRefreshControlDelegate {
    func didEndRefreshing()
}

class BottomRefreshControl: UIRefreshControl {
    var delegate: BottomRefreshControlDelegate?
    var triggerVerticalOffset2: CGFloat = kDefaultTriggerRefreshVerticalOffset
    
    override func endRefreshing() {
        if let delegate = self.delegate {
            delegate.didEndRefreshing()
        } else {
            super.endRefreshing()
        }
    }
}
