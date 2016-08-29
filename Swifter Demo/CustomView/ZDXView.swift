//
//  ZDXMoveView.swift
//  Swifter
//
//  Created by ZDX on 16/7/26.
//  Copyright (c) 2016年 GroupFly. All rights reserved.
//

import UIKit

/******************************* 移动滑块类视图 *******************************/

/*
    本视图为通用的移动滑块类视图，适用于根据分类显示分类下的内容，可用于带内容视图和不带内容视图2种方式
    用法:
    // self.navigationController?.navigationBar.translucent = false
    moveView = ZDXMoveView(frame: self.contentView.bounds, titles: ["全部", "待付款", "待发货", "待收货", "待评价", "退款/售后"], contentViews:views)
    // moveView = ZDXMoveView(frame: CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 44), titles: ["全部", "待付款", "待发货", "待收货", "待评价", "退款/售后"])
    self.contentView.addSubview(moveView)
*/
// MARK: - 移块滚动视图

typealias MVCallback = Int -> ()                                  // 回调block
let TITLE_FONT: UIFont = UIFont.systemFontOfSize(14)            // 标题字体大小
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
    var delegate: MVCallback?
    
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
    
    deinit {
        print("\(NSStringFromClass(ZDXMoveView.self))销毁了")
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func drawRect(rect: CGRect) {
        // View重绘时调用，更新UI布局
        initWithFrame(rect)
        self.contentScrollView.contentSize = CGSizeMake(viewWidth * CGFloat(titles.count), viewHeight - TITLE_HEIGHT)
        // Frame修改后，Cell的Size也改变了，因为需要刷新布局
        self.topCollectionView.setCollectionViewLayout(self.layout, animated: false)
        // 更新滑块位置 - 修复App挂起后唤醒问题
        self.moveView.frame.size.width = self.titleTextWidth[currentIndex]
        if (currentIndex == 0) {
            self.moveView.center.x = self.titleWidth / 2
        } else {
            if let cell = self.topCollectionView.cellForItemAtIndexPath(NSIndexPath(forItem: currentIndex, inSection: 0)) {
                self.moveView.center.x = cell.center.x
            }
        }
//        print(NSStringFromCGRect(rect), terminator: "\n")
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

// MARK: 代理方法
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

/******************************* 无限循环滚动视图 *******************************/
/**
 *  考虑到此控件主要应用于广告位的循环滚动，而广告位的数据通常从网络获取，故在设计上采用：
 *  数据源协议来获取广告位视图，代理和Block均可获取点击视图的回调事件
 */
// MARK: - 广告页视图无限循环滚动视图

/// 常量
let DEFAULT_PAGE_INDICATOR_COLOR: UIColor = UIColor(white: 0.8, alpha: 1.0)
let DEFAULT_CURRENT_PAGE_INDICATOR_COLOR: UIColor = UIColor.orangeColor()

/// 分页指示器的对齐方式
public enum PageControlAlignment : Int {
    case Left
    case Center
    case Right
}

public protocol ZDXLoopScrollViewDataSource: class {
    // 获取要显示的视图
    func loopScrollView(loopScrollView: ZDXLoopScrollView, contentViewAtIndex index: Int) -> UIView
    // 获取内容视图的个数
    func numberOfContentViewsInLoopScrollView(loopScrollView: ZDXLoopScrollView) -> Int
}

@objc public protocol ZDXLoopScrollViewDelegate: NSObjectProtocol {

    // 点击某个内容视图的代理
    optional func loopScrollView(loopScrollView: ZDXLoopScrollView, didSelectContentViewAtIndex index: Int)
}

/// 无限循环滚动视图
final public class ZDXLoopScrollView: UIView {
    /// 选中时的颜色
    var pageIndicatorColor: UIColor = DEFAULT_PAGE_INDICATOR_COLOR {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 默认时的颜色
    var currentPageIndicatorColor: UIColor = DEFAULT_CURRENT_PAGE_INDICATOR_COLOR {
        didSet {
            setNeedsDisplay()
        }
    }
    /// 默认居中对齐
    var alignment: PageControlAlignment = .Center {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 单击手势
    private var tap: UIGestureRecognizer!
    /// 点击某个的回调
    var callback: MVCallback?
    weak public var delegate: ZDXLoopScrollViewDelegate?
    weak public var dataSource: ZDXLoopScrollViewDataSource? {
        didSet {
            reloadData()
        }
    }
    private var duration: NSTimeInterval = 3.0          // 滚动间隔
    private var currentPage: Int = 0                    // 当前页数
    private var totalPage: Int = 0                      // 总页数
    private var itemViews: [UIView] = []                // 显示的View
    private var timer: NSTimer?                         // 定时器
    
    /// 容器视图
    lazy private(set) var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        return scrollView
    }()
    
    /// 分页控制器
    lazy private(set) var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.userInteractionEnabled = false
        pageControl.backgroundColor = UIColor.clearColor()
        return pageControl
    }()

    
    /**
     默认初始化方法
     
     - parameter frame:                   Frame
     - parameter alignment:               分页指示器排列方式
     - parameter animationScrollDuration: 循环滚动时长
     
     - returns: Self
     */
    init(frame: CGRect, alignment: PageControlAlignment, animationScrollDuration: NSTimeInterval) {
        self.alignment = alignment
        self.duration = animationScrollDuration
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        autoresizingMask = [.FlexibleWidth]
        
        addSubview(self.scrollView)
        addSubview(self.pageControl)
        // 添加手势
        tap = UITapGestureRecognizer(target: self, action: #selector(didSelectedBackground))
        scrollView.addGestureRecognizer(tap)
        // 配置界面
        setupUI()
    }
    
    deinit {
        print("\(NSStringFromClass(ZDXLoopScrollView.self))销毁了")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 配置界面
    private func setupUI() {
        // 配置ScrollView
        scrollView.contentSize = CGSizeMake(CGRectGetWidth(bounds) * 3.0, CGRectGetHeight(bounds))
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(bounds), 0.0)
        
        // 配置PageControl
        let pageControlWidth = pageControl.sizeForNumberOfPages(totalPage).width
        var frame = CGRectMake(0, CGRectGetMaxY(bounds) - 30.0, pageControlWidth, 30.0)
        switch alignment {
        case .Left:
            frame.origin.x = 20.0
            break
        case .Center:
            frame.origin.x = (CGRectGetWidth(bounds) - pageControlWidth) / 2.0
            break
        case .Right:
            frame.origin.x = CGRectGetWidth(bounds) - pageControlWidth - 20.0;
            break
        }
        pageControl.frame = frame
    }
    
    public override func drawRect(rect: CGRect) {
        setupUI()
        reloadData()
    }
    
    /// 刷新数据
    public func reloadData() {
        endAutoLoop()
        totalPage = (dataSource?.numberOfContentViewsInLoopScrollView(self))!
        if (totalPage <= 0) {
            // 无页面不展示
            return;
        } else if (totalPage == 1) {
            // 展示页为1时，PageControl不显示，且ScrollView不滚动
            pageControl.hidden = true
            scrollView.scrollEnabled = false
        } else {
            pageControl.hidden = false
            scrollView.scrollEnabled = true
            startAutoLoop()
        }
        pageControl.numberOfPages = totalPage
        // 装载显示的Views
        setupData()
    }
    
    /// 开始自动滚动
    public func startAutoLoop() {
        guard let timer = timer where timer.valid else {
            // 不满足条件时，创建定时器
            self.timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: #selector(nextPage), userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(self.timer!, forMode: NSRunLoopCommonModes)
            return
        }
    }
    
    /// 结束自动滚动
    public func endAutoLoop() {
        guard let timer = timer where timer.valid else {
            // 不符合条件时退出
            return
        }
        timer.invalidate()
        self.timer = nil
//        if let timer = timer where timer.valid {
//            self.timer!.invalidate()
//            self.timer = nil
//        }
    }
    
    // 配置数据
    private func setupData() {
        pageControl.currentPage = currentPage
        // 移除ScrollView所有子视图
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        // 获取DataSource中的当前展示视图
        itemViews = fetchItemViewsWithCurrentPage(currentPage)
        // 添加视图到ScrollView
        addSubviewWithItemViews(itemViews)
        scrollView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0)
    }
    
    // 根据当前页数，获取当前显示所有视图 -1 0 +1
    private func fetchItemViewsWithCurrentPage(currentPage: Int) -> [UIView] {
        let priorPage = currentPage - 1 < 0 ? totalPage - 1 : currentPage - 1   // <0 则为最后一页
        let nextPage = currentPage + 1 == totalPage ? 0 : currentPage + 1       // 最大则为第一页
        
        var itemViews: [UIView] = []
        itemViews.append((dataSource?.loopScrollView(self, contentViewAtIndex: priorPage))!)
        itemViews.append((dataSource?.loopScrollView(self, contentViewAtIndex: currentPage))!)
        itemViews.append((dataSource?.loopScrollView(self, contentViewAtIndex: nextPage))!)
        return itemViews;
    }
    
    // 将当前显示的所有视图数组添加到ScrollView中
    private func addSubviewWithItemViews(itemViews: [UIView]) {
        let frame = bounds
        var i: Int = 0
        itemViews.forEach {
            $0.frame = CGRectOffset(frame, CGRectGetMaxX($0.bounds) * CGFloat(i), 0)
            scrollView.addSubview($0)
            i += 1
        }
    }

    // 翻页
    @objc private func nextPage() {
        var offset = scrollView.contentOffset
        offset.x += CGRectGetWidth(bounds)
        scrollView.setContentOffset(offset, animated: true)
    }
   
    // 点击图片
    @objc private func didSelectedBackground() {
        // 点击代理
//        print("\(#function)")
        if let callback = callback {
            callback(currentPage)
        }
       
//        let isResponse = delegate?.conformsToProtocol(ZDXLoopScrollViewDelegate)    // 判断是否实现协议，并未判断是否实现协议方法
        let SEL = delegate?.respondsToSelector(#selector(ZDXLoopScrollViewDelegate.loopScrollView(_:didSelectContentViewAtIndex:)))
        if (SEL != nil) {
            delegate?.loopScrollView!(self, didSelectContentViewAtIndex: currentPage)
        }
    }
}

// MARK: 代理方法
extension ZDXLoopScrollView: UIScrollViewDelegate {
    // 代理方法
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        let total = dataSource?.numberOfContentViewsInLoopScrollView(self)
        if (total == 0) { return }
        let x = scrollView.contentOffset.x
        // 前翻
        if (x <= 0) {
            currentPage = currentPage - 1 < 0 ? totalPage - 1 : currentPage - 1
            setupData()
        }
        // 后翻
        if (x >= CGRectGetWidth(scrollView.bounds) * 2.0) {
            currentPage = currentPage + 1 == totalPage ? 0 : currentPage + 1
            setupData()
        }
    }
    
    // 开始拖拽
    public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        endAutoLoop()
    }
    
    // 结束拖拽
    public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startAutoLoop()
    }

    // 结束滚动动画(代码滚动)
    public func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = CGRectGetWidth(scrollView.bounds)
        var toX: CGFloat = 0.0
        
        if x > 0 {
            toX = width
        } else if x > width {
            toX = width * 2.0
        } else if x > width * 2 {
            toX = width * 3
        }
        
        if toX > 0.0 {
            scrollView.contentOffset = CGPointMake(toX, 0)
        }
    }
    
    public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        
    }
}


// MARK: - 定时器扩展
extension NSTimer {
    /**
     *  暂停
     */
    func pause() {
        if (valid) {
            fireDate = NSDate.distantFuture()
        }
    }
    
    /**
     *  重启
     */
    func restart() {
        if (valid) {
            fireDate = NSDate()
        }
    }
    
    /**
     *  延迟启动
     */
    func restartAfterTimeInterval(interval: NSTimeInterval) {
        if (valid) {
            fireDate = NSDate(timeIntervalSinceReferenceDate: interval)
        }
    }
}




/******************************* App启动后的广告页 *******************************/
/**
 *  App启动后停留几秒的广告页，一般为调用网络接口展示
 */

// Advertisement Page View
// MARK: - 广告页视图

typealias APVCallback = (Int) -> ()
let DEFAULT_DURATION: Int = 4                   // 广告持续4秒
let COUNTDOWN_SIZE: CGSize = CGSizeMake(60, 30)   // 数字（矩形）
let ANNULAR_SIZE: CGSize = CGSizeMake(50, 50)   // 环形（圆形）
let ADVERTISEMENT_PAGE_IMAGE_NAME: String = "AdvertisementPageImage"    // 广告图片缓存名称

/// 跳过按钮的对齐方式
public enum SkipControlAlignment : Int {
    case LeftTop        // 左上角
    case RightTop       // 右上角
    case LeftBottom     // 左下角
    case RightBottom    // 右下角
}

/// 跳过按钮的样式
/// 跳过按钮的对齐方式
public enum SkipControlStyle : Int {
    case CountDown      // 倒计时（矩形）
    case Annular        // 环形（圆形）
}

final public class ZDXAdvertisementPageView: UIView {
    private var alignment: SkipControlAlignment
    private var style: SkipControlStyle
    private var duration: Int
    private var imageURL: NSURL
    
    private var imageView: UIImageView!                 // 背景广告图片
    private var skipView: UIView!                       // 跳过视图
    private var countDownLabel: UILabel?                // 倒计时
    private var timer: NSTimer!                         // 定时器
    private var progressView: ZDXRoundProgressView?     // 环形进度视图
    /// 广告图片缓存路径
    lazy private(set) var cachePath: String = {
        var cachePath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true).last!
        var cachepathNS = cachePath as NSString
        cachepathNS = cachepathNS.stringByAppendingPathComponent(ADVERTISEMENT_PAGE_IMAGE_NAME)
        cachePath = cachepathNS as String
        return cachePath
    }()
    var delegate: APVCallback?                          // 点击回调  0是视图消失   1是广告页
    
    init(frame: CGRect, SkipControlAlignment alignment: SkipControlAlignment, SkipControlStyle style: SkipControlStyle, Duration duration: Int, ImageURL imageURL: NSURL, addToView aView: UIView) {
        // 检查ImageURL是否有效
//        var error: NSError?
//        // 只能用于检查本地文件路径
//        if !imageURL.checkResourceIsReachableAndReturnError(&error) {
//            print("Error: \(error)")
//            return nil
//        }
        self.alignment = alignment
        self.style = style
        self.imageURL = imageURL
        self.duration = duration
        if (duration <= 0 ) {
            self.duration = DEFAULT_DURATION
        }
        super.init(frame: frame)
        backgroundColor = UIColor.whiteColor()
        if (self.style == .CountDown) {
            timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        } else {
            timer = NSTimer.scheduledTimerWithTimeInterval(Double(self.duration) / 100.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            self.duration = 100
        }
        NSRunLoop.currentRunLoop().addTimer(timer, forMode: NSRunLoopCommonModes)
        timer.pause()
        // 配置界面
        setupUI()
        aView.addSubview(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("\(NSStringFromClass(ZDXAdvertisementPageView.self))销毁了")
    }
    
    func setupUI() {
        let frame = bounds
        // 广告图片视图
        imageView = UIImageView(frame: frame)
        addSubview(imageView)
        // 点击广告图片的Button
        let backgroundBtn = UIButton(frame: frame)
        backgroundBtn.tag = 1
        backgroundBtn.addTarget(self, action: #selector(choose), forControlEvents: .TouchUpInside)
        addSubview(backgroundBtn)
        // 设置广告图片，保证始终有图片显示，不然会短暂出现空白页
        if let image = imageWithCache() {
            imageView.image = image
        }
        setupImageView()
        
        // 跳转视图
        var skipViewFrame: CGRect = CGRectZero
        let skipViewSize: CGSize = style == .CountDown ? COUNTDOWN_SIZE : ANNULAR_SIZE
        var skipViewOrigin: CGPoint = CGPointZero
        let spacing: CGFloat = 10.0
        let statusBarHeight: CGFloat = 20.0
        switch alignment {
            case .LeftTop:
                skipViewOrigin.x = spacing
                skipViewOrigin.y = spacing + statusBarHeight
                break
            case .RightTop:
                skipViewOrigin.x = CGRectGetWidth(frame) - skipViewSize.width - spacing
                skipViewOrigin.y = spacing + statusBarHeight
                break
            case .LeftBottom:
                skipViewOrigin.x = spacing
                skipViewOrigin.y = CGRectGetHeight(frame) - skipViewSize.height - spacing
                break
            case .RightBottom:
                skipViewOrigin.x = CGRectGetWidth(frame) - skipViewSize.width - spacing
                skipViewOrigin.y = CGRectGetHeight(frame) - skipViewSize.height - spacing
                break
        }
        skipViewFrame.size = skipViewSize
        skipViewFrame.origin = skipViewOrigin
        skipView = UIView(frame: skipViewFrame)
        addSubview(skipView)
        // 设置跳转视图内容
        setupSkipView()
    }
    
    // 设置广告图片内容，最好设计一张图片放在本地，以供无网络时可以看到广告图
    private func setupImageView() {
        // 1.将网络图片下载下来
        let request: NSURLRequest = NSURLRequest(URL: imageURL)
        let session: NSURLSession = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            var image: UIImage? = nil
            if (error != nil) {
                // 2.1 网络异常，从缓存里读取
                image = self.imageWithCache()
            } else {
                // 2.2.1 网络正常，读取返回数据
                if let JSONData = data {
                    // 2.2.1.1 返回数据为图片，缓存到本地
                    if let imageTemp = UIImage(data: JSONData) {
                        image = imageTemp
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
//                            print("Path: \(self.cachePath)")
                            if (JSONData.writeToFile(self.cachePath, atomically: true)) {
                                print("Cache Success")
                            } else {
                                print("Cache Failure")
                            }
                        })
                    } else {
                        // 2.2.1.1 返回数据不为图片，读取缓存数据
                        image = self.imageWithCache()
                    }
                } else {
                    //2.2.2 网络正常，无返回数据，读取缓存数据
                    image = self.imageWithCache()
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), {
                if let APImage = image {
                    // 3.设置图片
                    self.imageView.image = APImage
                    self.timer.restart()
                } else {
                    self.dismiss()
                }
            })
        }
        task.resume()
    }
    
    // 获取缓存数据
    private func imageWithCache() -> UIImage? {
        var image: UIImage? = nil
        if let imageData = NSData(contentsOfFile: cachePath) {
            image = UIImage(data: imageData)
        }
        return image
    }
    
    // 设置跳转视图内容
    private func setupSkipView() {
        // 背景图
        self.skipView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7 )
        self.skipView.layer.cornerRadius = CGRectGetHeight(self.skipView.frame) / 2.0
        self.skipView.layer.masksToBounds = true
        
        // 跳过按钮
        let skipButton: UIButton = UIButton(frame: self.skipView.bounds)
        skipButton.tag = 0
        skipButton.addTarget(self, action: #selector(choose), forControlEvents: .TouchUpInside)
        self.skipView.addSubview(skipButton)
        
        // Label
        let skipLabel: UILabel = UILabel()
        var skipRect: CGRect = self.skipView.bounds
        skipLabel.text = "跳过"
        skipLabel.textAlignment = .Center
        skipLabel.textColor = UIColor.whiteColor()
        skipLabel.font = UIFont.boldSystemFontOfSize(15.0)
        
        if (self.style == .CountDown) {
            let skipViewFrame = self.skipView.bounds
            var countDownRect: CGRect = CGRectZero
            CGRectDivide(skipViewFrame, &skipRect, &countDownRect, CGRectGetWidth(skipViewFrame) / 3.0 * 2.0, .MinXEdge)
            skipLabel.font = UIFont.boldSystemFontOfSize(13.0)
            // 倒计时
            self.countDownLabel = UILabel(frame: countDownRect)
            self.countDownLabel!.text = "\(self.duration)"
//            self.countDownLabel!.textAlignment = .Center
            self.countDownLabel!.textColor = UIColor.orangeColor()
            self.countDownLabel!.font = UIFont.boldSystemFontOfSize(13.0)
            self.skipView.addSubview(self.countDownLabel!)
        } else {
            self.progressView = ZDXRoundProgressView(frame: CGRectMake(1, 1, CGRectGetWidth(self.skipView.bounds) - 2, CGRectGetHeight(self.skipView.bounds) - 2))
            self.skipView.addSubview(self.progressView!)
        }
        skipLabel.frame = skipRect
        self.skipView.addSubview(skipLabel)
    }
    
    // 倒计时方法
    @objc private func countDown() {
        if (self.duration <= 0) {
            // 停止倒计时，消失
            self.dismiss()
        } else {
            if (self.style == .CountDown) {
                self.countDownLabel!.text = "\(self.duration)"
            } else {
                // 环形
                self.progressView?.progress = CGFloat(self.duration)
            }
            self.duration -= 1
        }
    }
    
    // 选择按钮
    @objc private func choose(btn: UIButton) {
        if (self.delegate != nil) {
            self.delegate!(btn.tag) // 0 跳过 1 广告页
        }
        self.dismiss()
    }
    
    // 消失动画
    @objc private func dismiss() {
        if (self.timer.valid) {
            self.timer.invalidate()
            self.timer = nil
        }
        UIView.animateWithDuration(0.8, delay:0, options:.CurveLinear, animations: {
                self.layer.opacity = 0.0
                self.transform = CGAffineTransformMakeScale(1.3, 1.3) })
        { (finished) in self.removeFromSuperview() }
    }
    
    // MARK 环形视图
    final class ZDXRoundProgressView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.clearColor()
            userInteractionEnabled = false
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var progress: CGFloat = 100.0 {
            didSet {
                self.setNeedsDisplay()
            }
        }
        
        override func drawRect(rect: CGRect) {
            // 清除绘图
            let context = UIGraphicsGetCurrentContext()
            CGContextClearRect(context, rect)
            
//            // 背景
//            // 传的是正方形，因此就可以绘制出圆了
//            let path = UIBezierPath(roundedRect: rect, cornerRadius: CGRectGetWidth(self.bounds) / 2)
//            let fillColor = UIColor.blackColor()
//            fillColor.set()
//            path.fill()
//            path.stroke()
            
            let lineWidth: CGFloat = 2.0
            let center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect))
            let radius = (CGRectGetWidth(self.bounds) - lineWidth) / 2
            let startAngle = CGFloat(-1 / 2 * M_PI) // -1/2𝝿
            // 只用改变结束弧度即可
            // (-5/2𝝿) -> (-2𝝿) -> (-3/2𝝿) -> (-𝝿) -> (-1/2𝝿)
            let endAngle = startAngle - CGFloat(self.progress / 100.0 * 2.0 * CGFloat(M_PI))
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.lineCapStyle = .Round
            path.lineJoinStyle = .Round
            path.lineWidth = lineWidth;
            let strokeColor = UIColor.whiteColor()
            strokeColor.set()
            path.stroke()
        }
        
        // 角度转换成弧度
        private func degreesToRadians(degrees: CGFloat) -> CGFloat {
            return ((CGFloat(M_PI) * degrees) / CGFloat(180.0))
        }
    }
}





































































