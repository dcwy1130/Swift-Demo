//
//  ZDXMoveView.swift
//  Swifter
//
//  Created by ZDX on 16/7/26.
//  Copyright (c) 2016年 GroupFly. All rights reserved.
//

import UIKit

/****************************************** 移动滑块类视图 ******************************************/
/*
    本视图为通用的移动滑块类视图，适用于根据分类显示分类下的内容，可用于带内容视图和不带内容视图2种方式
    用法:
    // self.navigationController?.navigationBar.translucent = false
    moveView = ZDXMoveView(frame: self.contentView.bounds, titles: ["全部", "待付款", "待发货", "待收货", "待评价", "退款/售后"], contentViews:views)
    // moveView = ZDXMoveView(frame: CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 44), titles: ["全部", "待付款", "待发货", "待收货", "待评价", "退款/售后"])
    self.contentView.addSubview(moveView)
*/

typealias Callback = Int -> ()                                  // 回调block
let TITLE_FONT: UIFont = UIFont.systemFontOfSize(15)            // 标题字体大小
let TITLE_HEIGHT: CGFloat = 44.0                                // 标题栏高度
let REUSE_IDENTIFIER: String = "ZDXCollectionViewCell"          // 重用标识符
let MOVE_VIEW_HEIGHT: CGFloat = 3.0                             // 滑块的高度
let SEPRATOR_COLOR: UIColor = UIColor(white: 0.9, alpha: 1.0)   // 分隔线颜色
let DEFAULT_SELECT_COLOR: UIColor = UIColor.orangeColor()       // 选中颜色
let DEFAULT_NORMAL_COLOR: UIColor = UIColor.darkGrayColor()     // 默认颜色

final public class ZDXMoveView: UIView {
    
    // 标题的宽度
    private var titleWidth: CGFloat!
    // 标题的高度
    private var titleHeight: CGFloat = TITLE_HEIGHT
    private(set) var viewWidth: CGFloat!
    private(set) var viewHeight: CGFloat!
    // 内容视图Frame
    private var contentFrame: CGRect!
    // 每个标题文本的宽度
    private var titleTextWidth: [CGFloat]! = []
    
    lazy private var layout: UICollectionViewFlowLayout = {
        // 构建布局
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .Horizontal
        layout.itemSize = CGSizeMake(self.titleWidth, self.titleHeight)
        return layout
    }()
    
    // 标题的容器视图
    lazy private(set) var topCollectionView: UICollectionView = {
        // 容器视图
        let collectionView = UICollectionView(frame: CGRectMake(0, 0, self.viewWidth, TITLE_HEIGHT), collectionViewLayout: self.layout)
        collectionView.backgroundColor = UIColor.whiteColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.registerClass(ZDXCollectionViewCell.self, forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizingMask = [.FlexibleWidth, .FlexibleBottomMargin]
        // 默认选中第一行
        collectionView.selectItemAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: true, scrollPosition: .None)
        return collectionView
    }()

    // 标题下的详细内容
    lazy private var contentScrollView: UIScrollView =  {
        let scrollView: UIScrollView = UIScrollView(frame: CGRectMake(0, TITLE_HEIGHT, self.viewWidth, self.viewHeight - TITLE_HEIGHT))
        scrollView.backgroundColor = UIColor.whiteColor()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.contentSize = CGSizeMake(self.viewWidth * CGFloat(self.titles.count), self.viewHeight - TITLE_HEIGHT)
        scrollView.delegate = self
        scrollView.autoresizingMask = [.FlexibleBottomMargin, .FlexibleWidth, .FlexibleHeight]
        
        // 将内容视图添加到容器中
        var i = 0
        if let contentViews = self.contentViews {
            while (i < self.contentViews!.count) {
                let itemView = self.contentViews![i]
                itemView.frame = CGRectOffset(self.contentFrame, CGRectGetMaxX(itemView.bounds) * CGFloat(i), 0)
                itemView.autoresizingMask = [.FlexibleTopMargin, .FlexibleBottomMargin, .FlexibleWidth, .FlexibleHeight]
                scrollView.addSubview(itemView)
                i += 1
            }
        }
        return scrollView
    }()
    
    // 移动滑块
    lazy private var moveView: UIView = {
        // 添加滑块
        let moveView = UIView(frame: CGRectMake(0, TITLE_HEIGHT - self.moveViewHeigth, self.titleTextWidth.first!, self.moveViewHeigth))
        // 默认第1个的位置
        moveView.center.x = self.titleWidth / 2
        moveView.backgroundColor = UIColor.orangeColor()
        moveView.autoresizingMask = .FlexibleTopMargin
        return moveView
    }()
    
    // 分隔线
    lazy private var sepratorView: UIView = {
        let sepratorView = UIView(frame: CGRectMake(0, TITLE_HEIGHT - 0.5, self.viewWidth, 0.5))
        sepratorView.backgroundColor = SEPRATOR_COLOR
        sepratorView.autoresizingMask = .FlexibleWidth
        return sepratorView
    }()
    
    private var moveViewHeigth: CGFloat = MOVE_VIEW_HEIGHT  // 滑块的高度
    // public 在 module 之外也访问
    public private(set) var titles:[String]                 // 所有的标题
    public private(set) var contentViews:[UIView]?          // 所有的内容视图，和标题一一对应
    private var currentIndex = 0                            // 当前选中索引，默认为0
    
    /// 选中时的颜色
    var selectedColor: UIColor = DEFAULT_SELECT_COLOR
    /// 默认时的颜色
    var normalColor: UIColor = DEFAULT_NORMAL_COLOR
    /// 点击某个的回调
    var delegate: Callback?
    
    /**
     默认初始化方法：带内容
     
     - parameter frame:        显示的视图内容，建议为全屏显示
     - parameter titles:       显示的所有标题
     - parameter contentViews: 显示标题下的内容
     
     - returns: self
     */
    init(frame: CGRect, titles: [String], contentViews: [UIView]) {
        self.titles = titles
        self.contentViews = contentViews
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        // 获取初始值
        initWithFrame(frame)        
        addSubview(self.topCollectionView)
        addSubview(self.sepratorView)
        addSubview(self.contentScrollView)
        self.topCollectionView.addSubview(self.moveView)
    }
    
    /**
     默认初始化方法：不带内容
     
     - parameter frame:  显示的视图内容，建议高度为44
     - parameter titles: 显示的所有标题
     
     - returns: self
     */
    init(frame: CGRect, titles: [String]) {
        self.titles = titles
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        autoresizingMask = [.FlexibleWidth]
        // 获取初始值
        initWithFrame(frame)
        addSubview(self.topCollectionView)
        addSubview(self.sepratorView)
        self.topCollectionView.addSubview(self.moveView)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func drawRect(rect: CGRect) {
        // View重绘时调用，更新UI布局
        initWithFrame(rect)
        self.contentScrollView.contentSize = CGSizeMake(self.viewWidth * CGFloat(self.titles.count), self.viewHeight - TITLE_HEIGHT)
        // Frame修改后，Cell的Size也改变了，因为需要刷新布局
        self.topCollectionView.setCollectionViewLayout(self.layout, animated: true)
        // 更新滑块位置
        self.moveView.center.x = self.titleWidth / 2
        print(NSStringFromCGRect(rect), terminator: "\n")
    }
    
    private func initWithFrame(frame: CGRect) {
        self.viewWidth = CGRectGetWidth(frame)
        self.viewHeight = CGRectGetHeight(frame)
        // 标题的宽度
        self.titleWidth = {
            var width: CGFloat
            if (self.titles.count > 5 ) {
                width = self.viewWidth / 5
            } else {
                width = self.viewWidth / CGFloat(self.titles.count)
            }
            return width
         }()
        self.contentFrame = CGRectMake(0, 0, self.viewWidth, self.viewHeight - TITLE_HEIGHT)
        self.layout.itemSize = CGSizeMake(self.titleWidth, self.titleHeight)
        // 先清空，再计算文本宽度
        self.titleTextWidth.removeAll()
        for text in self.titles {
            let t:NSString = text
            let rect = t.boundingRectWithSize(CGSizeMake(self.titleWidth, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : TITLE_FONT], context: nil)
            // 将标题文本的宽度添加进去
            self.titleTextWidth.append(CGRectGetWidth(rect))
        }
    }
    
    /**
     此方法只有在标题数量为5个及以下，方才有效
     
     - parameter index: 要跳转的下标位置
     */
    func moveToIndex(index: Int) {
        if (currentIndex != index) {
            let indexPath: NSIndexPath = NSIndexPath(forRow: index, inSection: 0)
            if (self.topCollectionView.cellForItemAtIndexPath(indexPath) != nil) {
                moveToIndexPath(indexPath)
            }
            self.delegate?(index)
            currentIndex = index
        }
    }
    
    final private class ZDXCollectionViewCell: UICollectionViewCell {
        var titleLabel: UILabel!
        var selectedColor: UIColor!
        var normalColor: UIColor!
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.titleLabel = UILabel(frame: CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame)))
            self.titleLabel.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
            self.titleLabel.textColor = UIColor.darkGrayColor()
            self.titleLabel.textAlignment = NSTextAlignment.Center
            self.titleLabel.font = TITLE_FONT
            self.titleLabel.lineBreakMode = .ByTruncatingMiddle
            self.contentView.addSubview(self.titleLabel)
        }
        override var selected: Bool {
            didSet {
                titleLabel.textColor = selected ? self.selectedColor : self.normalColor
            }
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate 系列方法
extension ZDXMoveView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: ZDXCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(REUSE_IDENTIFIER, forIndexPath: indexPath) as! ZDXCollectionViewCell
        cell.titleLabel.text = self.titles[indexPath.row] as String
        cell.selectedColor = self.selectedColor
        cell.normalColor = self.normalColor
        let textColor = cell.selected ? self.selectedColor : self.normalColor
        cell.titleLabel.textColor = textColor
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
        moveToIndex(indexPath.row)
        self.contentScrollView.setContentOffset(CGPointMake(CGFloat(indexPath.row) * self.viewWidth, 0), animated: true)
    }
    
    // 移动滑块
    private func moveToIndexPath(indexPath: NSIndexPath) {
        if let cell = self.topCollectionView.cellForItemAtIndexPath(indexPath) {
            UIView.animateWithDuration(0.3, animations: {
                self.moveView.frame.size.width = self.titleTextWidth[indexPath.row]
                self.moveView.center.x = cell.center.x
            })
        }
    }
    
    // 拖拽代理
    public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.isMemberOfClass(UIScrollView)) {
            let index = ceil(targetContentOffset.memory.x / CGRectGetWidth(scrollView.bounds))
            moveToIndex(Int(index))
            self.topCollectionView.selectItemAtIndexPath(NSIndexPath(forRow: Int(index), inSection: 0), animated: true, scrollPosition: .CenteredHorizontally)
        }
    }
}

/****************************************** 无限循环滚动视图 ******************************************/
/**
 *  考虑到此控件主要应用于广告位的循环滚动，而广告位的数据通常从网络获取，故在设计上采用：
 *  数据源协议来获取广告位视图，代理和Block均可获取点击视图的回调事件
 */

/// 常量
let DEFAULT_PAGE_INDICATOR_COLOR: UIColor = UIColor(white: 0.8, alpha: 1.0)
let DEFAULT_CURRENT_PAGE_INDICATOR_COLOR: UIColor = UIColor.orangeColor()

/// 分页指示器的对齐方式
public enum PageControlAlignment : Int {
    case Left
    case Center
    case Right
}

public protocol ZDXLoopScrollViewDataSource: NSObjectProtocol {
    // 获取要显示的视图
    func loopScrollView(loopScrollView: ZDXLoopScrollView, contentViewAtIndex index: Int) -> UIView
    // 获取内容视图的个数
    func numberOfContentViewsInLoopScrollView(loopScrollView: ZDXLoopScrollView) -> Int
}

public protocol ZDXLoopScrollViewDelegate: NSObjectProtocol {
    // 点击某个内容视图的代理
    func loopScrollView(loopScrollView: ZDXLoopScrollView, didSelectContentViewAtIndex index: Int)
}

/// 无限循环滚动视图
final public class ZDXLoopScrollView: UIView {
    /// 选中时的颜色
    var pageIndicatorColor: UIColor = DEFAULT_PAGE_INDICATOR_COLOR
    /// 默认时的颜色
    var currentPageIndicatorColor: UIColor = DEFAULT_CURRENT_PAGE_INDICATOR_COLOR
    /// 点击某个的回调
    var callback: Callback?
    
    weak public var dataSource: ZDXLoopScrollViewDataSource?
    weak public var delegate: ZDXLoopScrollViewDelegate?
    
    var alignment: PageControlAlignment = .Center
    var duration: NSTimeInterval = 3.0
    
    /// 容器视图
    lazy private(set) var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.delegate = self

        return scrollView
    }()
    
    /// 分页控制器
//    lazy private(set) var pageControl: UIPageControl = {
//        let pageControl = UIPageControl(frame: self.bounds)
//        pageControl
//        
//        return pageControl
//    }()
    
    init(frame: CGRect, alignment: PageControlAlignment, animationScrollDuration: NSTimeInterval) {
        self.alignment = alignment
        self.duration = animationScrollDuration
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        // 获取初始值
//        initWithFrame(frame)
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

    
    
    
    
    
    
    
    
//    // 当duration<=0时，默认不自动滚动
//    - (id)initWithFrame:(CGRect)frame animationScrollDuration:(NSTimeInterval)duration;
//    
//    - (void)reloadData;
    
//    /** 开始自动循环滚动 */
//    - (void)startAutoLoop;
//    /** 结束自动循环滚动 */
//    - (void)endAutoLoop;
//    /** 刷新数据 */
//    - (void)reloadData;
    
}

extension ZDXLoopScrollView: UIScrollViewDelegate {
    
}


// MARK: - 定时器扩展
extension NSTimer {
    /**
     *  暂停
     */
    func pause() {
        if (self.valid) {
            self.fireDate = NSDate.distantFuture()
        }
    }
    
    /**
     *  重启
     */
    func restart() {
        if (self.valid) {
            self.fireDate = NSDate()
        }
    }
    
    /**
     *  延迟启动
     */
    func restartAfterTimeInterval(interval: NSTimeInterval) {
        if (self.valid) {
            self.fireDate = NSDate(timeIntervalSinceReferenceDate: interval)
        }
    }
}

















































































