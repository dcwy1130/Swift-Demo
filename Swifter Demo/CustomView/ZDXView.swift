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

typealias MVCallback = (Int) -> ()                                  // 回调block
let TITLE_FONT: UIFont = UIFont.systemFont(ofSize: 14)            // 标题字体大小
let TITLE_HEIGHT: CGFloat = 44.0                                // 标题栏高度
let REUSE_IDENTIFIER: String = "ZDXCollectionViewCell"          // 重用标识符
let MOVE_VIEW_HEIGHT: CGFloat = 3.0                             // 滑块的高度
let SEPRATOR_COLOR: UIColor = UIColor(white: 0.9, alpha: 1.0)   // 分隔线颜色
let DEFAULT_SELECT_COLOR: UIColor = UIColor.orange       // 选中颜色
let DEFAULT_NORMAL_COLOR: UIColor = UIColor.darkGray     // 默认颜色

final public class ZDXMoveView: UIView {
    
    // 标题的宽度
    fileprivate var titleWidth: CGFloat!
    // 标题的高度
    fileprivate var titleHeight: CGFloat = TITLE_HEIGHT
    fileprivate(set) var viewWidth: CGFloat!
    fileprivate(set) var viewHeight: CGFloat!
    // 内容视图Frame
    fileprivate var contentFrame: CGRect!
    // 每个标题文本的宽度
    fileprivate var titleTextWidth: [CGFloat]! = []
    
    lazy fileprivate var layout: UICollectionViewFlowLayout = {
        // 构建布局
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0.0
        layout.minimumLineSpacing = 0.0
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: self.titleWidth, height: self.titleHeight)
        return layout
    }()
    
    // 标题的容器视图
    lazy fileprivate(set) var topCollectionView: UICollectionView = {
        // 容器视图
        let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.viewWidth, height: TITLE_HEIGHT), collectionViewLayout: self.layout)
        collectionView.backgroundColor = UIColor.white
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.register(ZDXCollectionViewCell.self, forCellWithReuseIdentifier: REUSE_IDENTIFIER)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleBottomMargin]
        // 默认选中第一行
        collectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: UICollectionViewScrollPosition())
        return collectionView
    }()
    
    // 标题下的详细内容
    lazy fileprivate var contentScrollView: UIScrollView =  {
        let scrollView: UIScrollView = UIScrollView(frame: CGRect(x: 0, y: TITLE_HEIGHT, width: self.viewWidth, height: self.viewHeight - TITLE_HEIGHT))
        scrollView.backgroundColor = UIColor.white
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.contentSize = CGSize(width: self.viewWidth * CGFloat(self.titles.count), height: self.viewHeight - TITLE_HEIGHT)
        scrollView.delegate = self
        scrollView.autoresizingMask = [.flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
        
        // 将内容视图添加到容器中
        var i = 0
        if let contentViews = self.contentViews {
            while (i < self.contentViews!.count) {
                let itemView = self.contentViews![i]
                itemView.frame = self.contentFrame.offsetBy(dx: itemView.bounds.maxX * CGFloat(i), dy: 0)
                itemView.autoresizingMask = [.flexibleTopMargin, .flexibleBottomMargin, .flexibleWidth, .flexibleHeight]
                scrollView.addSubview(itemView)
                i += 1
            }
        }
        return scrollView
    }()
    
    // 移动滑块
    lazy fileprivate var moveView: UIView = {
        // 添加滑块
        let moveView = UIView(frame: CGRect(x: 0, y: TITLE_HEIGHT - self.moveViewHeigth, width: self.titleTextWidth.first!, height: self.moveViewHeigth))
        // 默认第1个的位置
        moveView.center.x = self.titleWidth / 2
        moveView.backgroundColor = UIColor.orange
        moveView.autoresizingMask = .flexibleTopMargin
        return moveView
    }()
    
    // 分隔线
    lazy fileprivate var sepratorView: UIView = {
        let sepratorView = UIView(frame: CGRect(x: 0, y: TITLE_HEIGHT - 0.5, width: self.viewWidth, height: 0.5))
        sepratorView.backgroundColor = SEPRATOR_COLOR
        sepratorView.autoresizingMask = .flexibleWidth
        return sepratorView
    }()
    
    fileprivate var moveViewHeigth: CGFloat = MOVE_VIEW_HEIGHT  // 滑块的高度
    // public 在 module 之外也访问
    public fileprivate(set) var titles:[String]                 // 所有的标题
    public fileprivate(set) var contentViews:[UIView]?          // 所有的内容视图，和标题一一对应
    fileprivate var currentIndex = 0                            // 当前选中索引，默认为0
    
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
        backgroundColor = UIColor.white
        autoresizingMask = [.flexibleHeight, .flexibleWidth]
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
        backgroundColor = UIColor.white
        autoresizingMask = [.flexibleWidth]
        // 获取初始值
        initWithFrame(frame)
        addSubview(self.topCollectionView)
        addSubview(self.sepratorView)
        self.topCollectionView.addSubview(self.moveView)
    }
    
    deinit {
        // print("\(NSStringFromClass(ZDXMoveView.self))销毁了")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func draw(_ rect: CGRect) {
        // View重绘时调用，更新UI布局
        initWithFrame(rect)
        self.contentScrollView.contentSize = CGSize(width: viewWidth * CGFloat(titles.count), height: viewHeight - TITLE_HEIGHT)
        // Frame修改后，Cell的Size也改变了，因为需要刷新布局
        self.topCollectionView.setCollectionViewLayout(self.layout, animated: false)
        // 更新滑块位置 - 修复App挂起后唤醒问题
        self.moveView.frame.size.width = self.titleTextWidth[currentIndex]
        if (currentIndex == 0) {
            self.moveView.center.x = self.titleWidth / 2
        } else {
            if let cell = self.topCollectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) {
                self.moveView.center.x = cell.center.x
            }
        }
        //        print(NSStringFromCGRect(rect), terminator: "\n")
    }
    
    fileprivate func initWithFrame(_ frame: CGRect) {
        self.viewWidth = frame.width
        self.viewHeight = frame.height
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
        self.contentFrame = CGRect(x: 0, y: 0, width: self.viewWidth, height: self.viewHeight - TITLE_HEIGHT)
        self.layout.itemSize = CGSize(width: self.titleWidth, height: self.titleHeight)
        // 先清空，再计算文本宽度
        self.titleTextWidth.removeAll()
        for text in self.titles {
            let t:NSString = text as NSString
            let rect = t.boundingRect(with: CGSize(width: self.titleWidth, height: CGFloat.greatestFiniteMagnitude), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName : TITLE_FONT], context: nil)
            // 将标题文本的宽度添加进去
            self.titleTextWidth.append(rect.width)
        }
    }
    
    /**
     此方法只有在标题数量为5个及以下，方才有效
     
     - parameter index: 要跳转的下标位置
     */
    func moveToIndex(_ index: Int) {
        if (currentIndex != index) {
            self.topCollectionView.selectItem(at: IndexPath(row: Int(index), section: 0), animated: true, scrollPosition: .centeredHorizontally)
            
            let indexPath: IndexPath = IndexPath(row: index, section: 0)
            if (self.topCollectionView.cellForItem(at: indexPath) != nil) {
                self.moveToIndexPath(indexPath)
            } else {
                // 延迟执行
                let delayTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
                DispatchQueue.main.asyncAfter(deadline: delayTime, execute: {
                    self.moveToIndexPath(indexPath)
                })
            }
            self.delegate?(index)
            self.currentIndex = index
        }
    }
    
    final fileprivate class ZDXCollectionViewCell: UICollectionViewCell {
        var titleLabel: UILabel!
        var selectedColor: UIColor!
        var normalColor: UIColor!
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: frame.width, height: frame.height))
            self.titleLabel.autoresizingMask = [.flexibleHeight, .flexibleWidth]
            self.titleLabel.textColor = UIColor.darkGray
            self.titleLabel.textAlignment = NSTextAlignment.center
            self.titleLabel.font = TITLE_FONT
            self.titleLabel.lineBreakMode = .byTruncatingMiddle
            self.contentView.addSubview(self.titleLabel)
        }
        override var isSelected: Bool {
            didSet {
                titleLabel.textColor = isSelected ? self.selectedColor : self.normalColor
            }
        }
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

// MARK: 代理方法
extension ZDXMoveView: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.titles.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ZDXCollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: REUSE_IDENTIFIER, for: indexPath) as! ZDXCollectionViewCell
        cell.titleLabel.text = self.titles[indexPath.row] as String
        cell.selectedColor = self.selectedColor
        cell.normalColor = self.normalColor
        let textColor = cell.isSelected ? self.selectedColor : self.normalColor
        cell.titleLabel.textColor = textColor
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        moveToIndex(indexPath.row)
        self.contentScrollView.setContentOffset(CGPoint(x: CGFloat(indexPath.row) * self.viewWidth, y: 0), animated: true)
    }
    
    // 移动滑块
    fileprivate func moveToIndexPath(_ indexPath: IndexPath) {
        if let cell = self.topCollectionView.cellForItem(at: indexPath) {
            UIView.animate(withDuration: 0.3, animations: {
                self.moveView.frame.size.width = self.titleTextWidth[indexPath.row]
                self.moveView.center.x = cell.center.x
            })
        }
    }
    
    // 拖拽代理
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if (scrollView.isMember(of: UIScrollView.self)) {
            let index = ceil(targetContentOffset.pointee.x / scrollView.bounds.width)
            moveToIndex(Int(index))
            self.topCollectionView.selectItem(at: IndexPath(row: Int(index), section: 0), animated: true, scrollPosition: .centeredHorizontally)
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
let DEFAULT_CURRENT_PAGE_INDICATOR_COLOR: UIColor = UIColor.orange

/// 分页指示器的对齐方式
public enum PageControlAlignment : Int {
    case left
    case center
    case right
}

@objc public protocol ZDXLoopScrollViewDataSource: NSObjectProtocol {
    // 获取要显示的视图
    func loopScrollView(_ loopScrollView: ZDXLoopScrollView, contentViewAtIndex index: Int) -> UIView
    // 获取内容视图的个数
    func numberOfContentViewsInLoopScrollView(_ loopScrollView: ZDXLoopScrollView) -> Int
}

@objc public protocol ZDXLoopScrollViewDelegate: NSObjectProtocol {
    
    // 点击某个内容视图的代理
    @objc optional func loopScrollView(_ loopScrollView: ZDXLoopScrollView, didSelectContentViewAtIndex index: Int)
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
    var alignment: PageControlAlignment = .center {
        didSet {
            setNeedsDisplay()
        }
    }
    
    /// 单击手势
    fileprivate var tap: UIGestureRecognizer!
    /// 点击某个的回调
    var callback: MVCallback?
    weak public var delegate: ZDXLoopScrollViewDelegate?
    weak public var dataSource: ZDXLoopScrollViewDataSource? {
        didSet {
            reloadData()
        }
    }
    fileprivate var duration: TimeInterval = 3.0          // 滚动间隔
    fileprivate var currentPage: Int = 0                    // 当前页数
    fileprivate var totalPage: Int = 0                      // 总页数
    fileprivate var itemViews: [UIView] = []                // 显示的View
    fileprivate var timer: Timer?                         // 定时器
    
    /// 容器视图
    lazy fileprivate(set) var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: self.bounds)
        scrollView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        return scrollView
    }()
    
    /// 分页控制器
    lazy fileprivate(set) var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.isUserInteractionEnabled = false
        pageControl.backgroundColor = UIColor.clear
        return pageControl
    }()
    
    
    /**
     默认初始化方法
     
     - parameter frame:                   Frame
     - parameter alignment:               分页指示器排列方式
     - parameter animationScrollDuration: 循环滚动时长
     
     - returns: Self
     */
    init(frame: CGRect, alignment: PageControlAlignment, animationScrollDuration: TimeInterval) {
        self.alignment = alignment
        self.duration = animationScrollDuration
        super.init(frame: frame)
        backgroundColor = UIColor.white
        autoresizingMask = [.flexibleWidth]
        
        addSubview(self.scrollView)
        addSubview(self.pageControl)
        // 添加手势
        tap = UITapGestureRecognizer(target: self, action: #selector(didSelectedBackground))
        scrollView.addGestureRecognizer(tap)
        // 配置界面
        setupUI()
    }
    
    /**
     默认初始化方法
     
     - parameter frame:                   Frame
     - parameter animationScrollDuration: 循环滚动时长
     
     - returns: Self
     */
    init(frame: CGRect, animationScrollDuration: TimeInterval) {
        self.alignment = .center
        self.duration = animationScrollDuration
        super.init(frame: frame)
        backgroundColor = UIColor.white
        autoresizingMask = [.flexibleWidth]
        
        addSubview(self.scrollView)
        addSubview(self.pageControl)
        // 添加手势
        tap = UITapGestureRecognizer(target: self, action: #selector(didSelectedBackground))
        scrollView.addGestureRecognizer(tap)
        // 配置界面
        setupUI()
    }
    
    deinit {
        // print("\(NSStringFromClass(ZDXLoopScrollView.self))销毁了")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 配置界面
    fileprivate func setupUI() {
        // 配置ScrollView
        scrollView.contentSize = CGSize(width: bounds.width * 3.0, height: bounds.height)
        scrollView.contentOffset = CGPoint(x: bounds.width, y: 0.0)
        
        // 配置PageControl
        let pageControlWidth = pageControl.size(forNumberOfPages: totalPage).width
        var frame = CGRect(x: 0, y: bounds.maxY - 30.0, width: pageControlWidth, height: 30.0)
        switch alignment {
        case .left:
            frame.origin.x = 20.0
            break
        case .center:
            frame.origin.x = (bounds.width - pageControlWidth) / 2.0
            break
        case .right:
            frame.origin.x = bounds.width - pageControlWidth - 20.0;
            break
        }
        pageControl.frame = frame
    }
    
    public override func draw(_ rect: CGRect) {
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
            pageControl.isHidden = true
            scrollView.isScrollEnabled = false
        } else {
            pageControl.isHidden = false
            scrollView.isScrollEnabled = true
            startAutoLoop()
        }
        pageControl.numberOfPages = totalPage
        // 装载显示的Views
        setupData()
    }
    
    /// 开始自动滚动
    public func startAutoLoop() {
        guard let timer = timer, timer.isValid else {
            // 不满足条件时，创建定时器
            self.timer = Timer.scheduledTimer(timeInterval: duration, target: self, selector: #selector(nextPage), userInfo: nil, repeats: true)
            RunLoop.current.add(self.timer!, forMode: RunLoopMode.commonModes)
            return
        }
        reloadData()
    }
    
    /// 结束自动滚动
    public func endAutoLoop() {
        guard let timer = timer, timer.isValid else {
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
    fileprivate func setupData() {
        pageControl.currentPage = currentPage
        // 移除ScrollView所有子视图
        scrollView.subviews.forEach { $0.removeFromSuperview() }
        // 获取DataSource中的当前展示视图
        itemViews = fetchItemViewsWithCurrentPage(currentPage)
        // 添加视图到ScrollView
        addSubviewWithItemViews(itemViews)
        scrollView.contentOffset = CGPoint(x: self.bounds.width, y: 0)
    }
    
    // 根据当前页数，获取当前显示所有视图 -1 0 +1
    fileprivate func fetchItemViewsWithCurrentPage(_ currentPage: Int) -> [UIView] {
        let priorPage = currentPage - 1 < 0 ? totalPage - 1 : currentPage - 1   // <0 则为最后一页
        let nextPage = currentPage + 1 == totalPage ? 0 : currentPage + 1       // 最大则为第一页
        
        var itemViews: [UIView] = []
        itemViews.append((dataSource?.loopScrollView(self, contentViewAtIndex: priorPage))!)
        itemViews.append((dataSource?.loopScrollView(self, contentViewAtIndex: currentPage))!)
        itemViews.append((dataSource?.loopScrollView(self, contentViewAtIndex: nextPage))!)
        return itemViews;
    }
    
    // 将当前显示的所有视图数组添加到ScrollView中
    fileprivate func addSubviewWithItemViews(_ itemViews: [UIView]) {
        let frame = bounds
        var i: Int = 0
        itemViews.forEach {
            $0.frame = frame.offsetBy(dx: $0.bounds.maxX * CGFloat(i), dy: 0)
            scrollView.addSubview($0)
            i += 1
        }
    }
    
    // 翻页
    @objc fileprivate func nextPage() {
        var offset = scrollView.contentOffset
        offset.x += bounds.width
        scrollView.setContentOffset(offset, animated: true)
    }
    
    // 点击图片
    @objc fileprivate func didSelectedBackground() {
        // 点击代理
        //        print("\(#function)")
        if let callback = callback {
            callback(currentPage)
        }
        
        //        let isResponse = delegate?.conformsToProtocol(ZDXLoopScrollViewDelegate)    // 判断是否实现协议，并未判断是否实现协议方法
        let SEL = delegate?.responds(to: #selector(ZDXLoopScrollViewDelegate.loopScrollView(_:didSelectContentViewAtIndex:)))
        if (SEL != nil) {
            delegate?.loopScrollView!(self, didSelectContentViewAtIndex: currentPage)
        }
    }
}

// MARK: 代理方法
extension ZDXLoopScrollView: UIScrollViewDelegate {
    // 代理方法
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let total = dataSource?.numberOfContentViewsInLoopScrollView(self)
        if (total == 0) { return }
        let x = scrollView.contentOffset.x
        // 前翻
        if (x <= 0) {
            currentPage = currentPage - 1 < 0 ? totalPage - 1 : currentPage - 1
            setupData()
        }
        // 后翻
        if (x >= scrollView.bounds.width * 2.0) {
            currentPage = currentPage + 1 == totalPage ? 0 : currentPage + 1
            setupData()
        }
    }
    
    // 开始拖拽
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        endAutoLoop()
    }
    
    // 结束拖拽
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        startAutoLoop()
    }
    
    // 结束滚动动画(代码滚动)
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        let width = scrollView.bounds.width
        var toX: CGFloat = 0.0
        
        if x > 0 {
            toX = width
        } else if x > width {
            toX = width * 2.0
        } else if x > width * 2 {
            toX = width * 3
        }
        
        if toX > 0.0 {
            scrollView.contentOffset = CGPoint(x: toX, y: 0)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
    }
}


// MARK: - 定时器扩展
extension Timer {
    /**
     *  暂停
     */
    func pause() {
        if (isValid) {
            fireDate = Date.distantFuture
        }
    }
    
    /**
     *  重启
     */
    func restart() {
        if (isValid) {
            fireDate = Date()
        }
    }
    
    /**
     *  延迟启动
     */
    func restartAfterTimeInterval(_ interval: TimeInterval) {
        if (isValid) {
            fireDate = Date(timeIntervalSinceReferenceDate: interval)
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
let COUNTDOWN_SIZE: CGSize = CGSize(width: 60, height: 30)   // 数字（矩形）
let ANNULAR_SIZE: CGSize = CGSize(width: 50, height: 50)   // 环形（圆形）
let ADVERTISEMENT_PAGE_IMAGE_NAME: String = "AdvertisementPageImage"    // 广告图片缓存名称

/// 跳过按钮的对齐方式
public enum SkipControlAlignment : Int {
    case leftTop        // 左上角
    case rightTop       // 右上角
    case leftBottom     // 左下角
    case rightBottom    // 右下角
}

/// 跳过按钮的样式
public enum SkipControlStyle : Int {
    case countDown      // 倒计时（矩形）
    case annular        // 环形（圆形）
}

final public class ZDXAdvertisementPageView: UIView {
    fileprivate var alignment: SkipControlAlignment
    fileprivate var style: SkipControlStyle
    fileprivate var duration: Int
    public var imageURL: URL! {
        didSet {
            // 设置图片URL后下载图片
            fetchImageURL()
        }
    }
    
    fileprivate var imageView: UIImageView!                 // 背景广告图片
    fileprivate var ADLabel:UILabel!                        // 广告字样
    fileprivate var skipView: UIView!                       // 跳过视图
    fileprivate var isCanClick: Bool                        // 是否可以点击背景
    fileprivate var countDownLabel: UILabel?                // 倒计时
    fileprivate var timer: Timer!                         // 定时器
    fileprivate var placeholderImage: UIImage               // 占位图
    fileprivate var progressView: ZDXRoundProgressView?     // 环形进度视图
    /// 广告图片缓存路径
    lazy fileprivate(set) var cachePath: String = {
        var cachePath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!
        var cachepathNS = cachePath as NSString
        cachepathNS = cachepathNS.appendingPathComponent(ADVERTISEMENT_PAGE_IMAGE_NAME) as NSString
        cachePath = cachepathNS as String
        return cachePath
    }()
    var delegate: APVCallback?                          // 点击回调  0是视图消失   1是广告页
    
    init(frame: CGRect, SkipControlAlignment alignment: SkipControlAlignment, SkipControlStyle style: SkipControlStyle, Duration duration: Int, placeholderImage: UIImage, addToView aView: UIView) {
        self.alignment = alignment
        self.style = style
        self.duration = duration
        self.placeholderImage = placeholderImage
        self.isCanClick = false
        if (duration <= 0 ) {
            self.duration = DEFAULT_DURATION
        }
        super.init(frame: frame)
        backgroundColor = UIColor.white
        if (self.style == .countDown) {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        } else {
            timer = Timer.scheduledTimer(timeInterval: Double(self.duration) / 100.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            self.duration = 100
        }
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        timer.pause()
        // 配置界面
        setupUI()
        aView.addSubview(self)
    }
    
    init(frame: CGRect, Duration duration: Int, placeholderImage: UIImage, addToView aView: UIView) {
        self.alignment = .rightTop
        self.style = .annular
        self.duration = duration
        self.placeholderImage = placeholderImage
        self.isCanClick = false
        if (duration <= 0 ) {
            self.duration = DEFAULT_DURATION
        }
        super.init(frame: frame)
        backgroundColor = UIColor.white
        if (self.style == .countDown) {
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
        } else {
            timer = Timer.scheduledTimer(timeInterval: Double(self.duration) / 100.0, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            self.duration = 100
        }
        RunLoop.current.add(timer, forMode: RunLoopMode.commonModes)
        timer.pause()
        // 配置界面
        setupUI()
        aView.addSubview(self)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // print("\(NSStringFromClass(ZDXAdvertisementPageView.self))销毁了")
    }
    
    fileprivate func setupUI() {
        UIApplication.shared.isStatusBarHidden = true
        let frame = bounds
        // 广告图片视图
        imageView = UIImageView(frame: frame)
        imageView.image = placeholderImage
        addSubview(imageView)
        // 点击广告图片的Button
        let backgroundBtn = UIButton(frame: frame)
        backgroundBtn.tag = 1
        backgroundBtn.addTarget(self, action: #selector(choose), for: .touchUpInside)
        addSubview(backgroundBtn)
        
        // 跳转视图
        var skipViewFrame: CGRect = CGRect.zero
        let skipViewSize: CGSize = style == .countDown ? COUNTDOWN_SIZE : ANNULAR_SIZE
        var skipViewOrigin: CGPoint = CGPoint.zero
        let spacing: CGFloat = 10.0
        let statusBarHeight: CGFloat = 20.0
        switch alignment {
        case .leftTop:
            skipViewOrigin.x = spacing
            skipViewOrigin.y = spacing + statusBarHeight
            break
        case .rightTop:
            skipViewOrigin.x = frame.width - skipViewSize.width - spacing
            skipViewOrigin.y = spacing + statusBarHeight
            break
        case .leftBottom:
            skipViewOrigin.x = spacing
            skipViewOrigin.y = frame.height - skipViewSize.height - spacing
            break
        case .rightBottom:
            skipViewOrigin.x = frame.width - skipViewSize.width - spacing
            skipViewOrigin.y = frame.height - skipViewSize.height - spacing
            break
        }
        skipViewFrame.size = skipViewSize
        skipViewFrame.origin = skipViewOrigin
        skipView = UIView(frame: skipViewFrame)
        skipView.isHidden = true
        addSubview(skipView)
        // 设置跳转视图内容
        setupSkipView()
        
        // 广告字样文本
        ADLabel = UILabel(frame: CGRect(x: 10, y: 10, width: 40, height: 20))
        ADLabel.text = "广告"
        ADLabel.font = UIFont.boldSystemFont(ofSize: 12.0)
        ADLabel.textColor = UIColor.white
        ADLabel.textAlignment = .center;
        ADLabel.backgroundColor = UIColor.darkGray
        ADLabel.alpha = 0.8
        ADLabel.layer.cornerRadius = 2.0
        ADLabel.layer.masksToBounds = true
        ADLabel.isHidden = true
        addSubview(ADLabel)
    }
    
    // 读取缓存数据
    public func readCacheData() {
        setupImageView(imageWithCache())
    }
    
    // 获取广告图片并缓存
    fileprivate func fetchImageURL() {
        // 缓存图片，并通过block将图片回调
        cacheData(imageURL) { self.setupImageView($0) }
    }
    
    // 设置广告图片
    fileprivate func setupImageView(_ image: UIImage?) {
        DispatchQueue.main.async(execute: {
            if let APImage = image {
                // 3.设置图片
                self.ADLabel.isHidden = false
                self.skipView.isHidden = false
                self.imageView.image = APImage
                self.isCanClick = true
                self.timer.restart()
            } else {
                // self.dismiss()
                UIApplication.shared.isStatusBarHidden = false
                self.removeFromSuperview()
            }
        })
    }
    
    public func cacheData(_ URL: Foundation.URL, completion: ((_ image: UIImage? ) -> ())?){
        // 1.将网络图片下载下来
        let request: URLRequest = URLRequest(url: URL)
        let session: URLSession = URLSession.shared
        
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) in
            var image: UIImage? = self.imageWithCache()
            if (error != nil) {
                // 2.1 网络异常，从缓存里读取
                // image = self.imageWithCache()
            } else {
                // 2.2.1 网络正常，读取返回数据
                if let JSONData = data {
                    // 2.2.1.1 返回数据为图片，缓存到本地
                    if let imageTemp = UIImage(data: JSONData) {
                        image = imageTemp
                        DispatchQueue.global(priority: DispatchQueue.GlobalQueuePriority.background).async(execute: {
                            if ((try? JSONData.write(to: Foundation.URL(fileURLWithPath: self.cachePath), options: [.atomic])) != nil) {
                                // print("Cache Success")
                            } else {
                                // print("Cache Failure")
                            }
                        })
                    } else {
                        // 2.2.1.2 返回数据不为图片，读取缓存数据
                        // image = self.imageWithCache()
                    }
                } else {
                    //2.2.2 网络正常，无返回数据，读取缓存数据
                    // image = self.imageWithCache()
                }
            }
            if let completion = completion {
                completion(image)
            }
        })
        task.resume()
    }
    
    // 获取缓存数据
    fileprivate func imageWithCache() -> UIImage? {
        var image: UIImage? = nil
        if let imageData = try? Data(contentsOf: URL(fileURLWithPath: cachePath)) {
            image = UIImage(data: imageData)
        }
        return image
    }
    
    // 设置跳转视图内容
    fileprivate func setupSkipView() {
        // 背景图
        self.skipView.backgroundColor = UIColor ( red: 0.0, green: 0.0, blue: 0.0, alpha: 0.7 )
        self.skipView.layer.cornerRadius = self.skipView.frame.height / 2.0
        self.skipView.layer.masksToBounds = true
        
        // 跳过按钮
        let skipButton: UIButton = UIButton(frame: self.skipView.bounds)
        skipButton.tag = 0
        skipButton.addTarget(self, action: #selector(choose), for: .touchUpInside)
        self.skipView.addSubview(skipButton)
        
        // Label
        let skipLabel: UILabel = UILabel()
        var skipRect: CGRect = self.skipView.bounds
        skipLabel.text = "跳过"
        skipLabel.textAlignment = .center
        skipLabel.textColor = UIColor.white
        skipLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        
        if (self.style == .countDown) {
            let skipViewFrame = self.skipView.bounds
            var countDownRect: CGRect = CGRect.zero
            // CGRectDivide(skipViewFrame, &skipRect, &countDownRect, skipViewFrame.width / 3.0 * 2.0, .minXEdge)
            let divided = skipViewFrame.divided(atDistance: skipViewFrame.width / 3.0 * 2.0, from: .maxXEdge)
            skipRect = divided.slice
            countDownRect = divided.remainder
            
            skipLabel.font = UIFont.boldSystemFont(ofSize: 13.0)
            // 倒计时
            self.countDownLabel = UILabel(frame: countDownRect)
            self.countDownLabel!.text = "\(self.duration)"
            //            self.countDownLabel!.textAlignment = .Center
            self.countDownLabel!.textColor = UIColor.orange
            self.countDownLabel!.font = UIFont.boldSystemFont(ofSize: 13.0)
            self.skipView.addSubview(self.countDownLabel!)
        } else {
            self.progressView = ZDXRoundProgressView(frame: CGRect(x: 1, y: 1, width: self.skipView.bounds.width - 2, height: self.skipView.bounds.height - 2))
            self.skipView.addSubview(self.progressView!)
        }
        skipLabel.frame = skipRect
        self.skipView.addSubview(skipLabel)
    }
    
    // 倒计时方法
    @objc fileprivate func countDown() {
        if (self.duration <= 0) {
            // 停止倒计时，消失
            self.dismiss()
        } else {
            if (self.style == .countDown) {
                self.countDownLabel!.text = "\(self.duration)"
            } else {
                // 环形
                self.progressView?.progress = CGFloat(self.duration)
            }
            self.duration -= 1
        }
    }
    
    // 选择按钮
    @objc fileprivate func choose(_ btn: UIButton) {
        if isCanClick {
            if (delegate != nil) {
                delegate!(btn.tag) // 0 跳过 1 广告页
            }
            dismiss()
        }
    }
    
    // 消失动画
    @objc public func dismiss() {
        if (self.timer.isValid) {
            self.timer.invalidate()
            self.timer = nil
        }
        UIApplication.shared.isStatusBarHidden = false
        UIView.animate(withDuration: 0.8, delay:0, options:.curveLinear, animations: {
            self.layer.opacity = 0.0
            self.transform = CGAffineTransform(scaleX: 1.3, y: 1.3) })
        { (finished) in self.removeFromSuperview() }
    }
    
    // MARK 环形视图
    final class ZDXRoundProgressView: UIView {
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.clear
            isUserInteractionEnabled = false
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        var progress: CGFloat = 100.0 {
            didSet {
                self.setNeedsDisplay()
            }
        }
        
        override func draw(_ rect: CGRect) {
            // 清除绘图
            let context = UIGraphicsGetCurrentContext()
            context!.clear(rect)
            
            //            // 背景
            //            // 传的是正方形，因此就可以绘制出圆了
            //            let path = UIBezierPath(roundedRect: rect, cornerRadius: CGRectGetWidth(self.bounds) / 2)
            //            let fillColor = UIColor.blackColor()
            //            fillColor.set()
            //            path.fill()
            //            path.stroke()
            
            let lineWidth: CGFloat = 2.0
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = (self.bounds.width - lineWidth) / 2
            let startAngle = CGFloat(-1 / 2 * M_PI) // -1/2𝝿
            // 只用改变结束弧度即可
            // (-5/2𝝿) -> (-2𝝿) -> (-3/2𝝿) -> (-𝝿) -> (-1/2𝝿)
            let endAngle = startAngle - CGFloat(self.progress / 100.0 * 2.0 * CGFloat(M_PI))
            let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
            path.lineCapStyle = .round
            path.lineJoinStyle = .round
            path.lineWidth = lineWidth;
            let strokeColor = UIColor.white
            strokeColor.set()
            path.stroke()
        }
        
        // 角度转换成弧度
        fileprivate func degreesToRadians(_ degrees: CGFloat) -> CGFloat {
            return ((CGFloat(M_PI) * degrees) / CGFloat(180.0))
        }
    }
}


/******************************* 弹出视图 *******************************/
/**
 *  用于显示应用中弹出视图的展示，包含位移（上／左／下／右）、缩放（左上／右上／左下／右下、关键帧动画效果
 *  数据源用于获取要显示的视图
 */
// MARK: - 弹出视图

/// 常量
let DEFAULT_BACKGROUND_COLOR: UIColor = UIColor(white: 0.0, alpha: 0.4)
let SCREENT_HEIGHT: CGFloat = UIScreen.main.bounds.size.height
let SCREENT_WIDTH: CGFloat = UIScreen.main.bounds.size.width

/// 动画弹出方式
public enum ZDXPopupViewAnimation : Int {
    // 关键帧
    case fadeInOut
    // 位移
    case translateLeft, translateRight, translateTop, translateBottom
    // 缩放
    case scaleLeftTop, scaleRightTop, scaleLeftBottom, scaleRightBottom
}

public protocol ZDXPopupViewDataSource: class {
    // 获取要显示的视图
    func viewForContentInPopupView(_ popupView: ZDXPopupView) -> UIView
}

@objc public protocol ZDXPopupViewDelegate: NSObjectProtocol {
    // 点击背景
    @objc optional func didSelectPopupViewBackgroud()
}

/// 弹出视图
final public class ZDXPopupView: UIView {
    public var duration: TimeInterval = 0.3                   // 动画持续时间，默认为0.3s
    public var animationType: ZDXPopupViewAnimation = .fadeInOut
    fileprivate(set) var isShow: Bool = false                       // 是否展示
    
    var callback: MVCallback?
    weak public var delegate: ZDXPopupViewDelegate?
    weak public var dataSource: ZDXPopupViewDataSource?
    
    lazy fileprivate var viewWidth: CGFloat = {
        let viewWidth = self.bounds.width
        return viewWidth
    }()
    lazy fileprivate var viewHeight: CGFloat = {
        let viewHeight = self.bounds.height
        return viewHeight
    }()
    fileprivate var contentView: UIView?                // 数据源获取的View
    fileprivate var contentViewCenter: CGPoint!         // 显示View的Center

    /**
     默认初始化方法
     
     - parameter frame:                   Frame
     - parameter animation:               弹出动画方式
     - parameter duration:                动画持续时间
     - parameter backgroundColor:         背景色
     
     - returns: Self
     */
    init(frame: CGRect, animation: ZDXPopupViewAnimation, duration: TimeInterval, backgroundColor: UIColor) {
        self.duration = duration
        self.animationType = animation
        super.init(frame: frame)
        self.backgroundColor = backgroundColor
        self.clipsToBounds = true;
    }
    
    init(frame: CGRect, animation: ZDXPopupViewAnimation, duration: TimeInterval) {
        self.duration = duration
        self.animationType = animation
        super.init(frame: frame)
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR
        self.clipsToBounds = true;
    }
    
    init(frame: CGRect, animation: ZDXPopupViewAnimation) {
        self.animationType = animation
        super.init(frame: frame)
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR
        self.clipsToBounds = true;
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = DEFAULT_BACKGROUND_COLOR
        self.clipsToBounds = true;
    }
   
    deinit {
        print("\(NSStringFromClass(ZDXPopupView.self))销毁了")
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func animation(fromeValue: NSNumber?, toValue: NSNumber, keyPath: String) -> CAAnimation {
        let basicAnimation: CABasicAnimation = CABasicAnimation()
        basicAnimation.keyPath = keyPath
        // 缩放动画
        if keyPath == "transform.scale" {
            basicAnimation.byValue = nil
            basicAnimation.fromValue = fromeValue
            basicAnimation.toValue = toValue
        } else {
            basicAnimation.toValue = nil
            if fromeValue != nil {
                basicAnimation.fromValue = fromeValue
                basicAnimation.byValue = toValue
            } else {
                basicAnimation.fromValue = 0
                basicAnimation.byValue = toValue
            }
        }
        basicAnimation.duration = duration
        return basicAnimation
    }
    
    fileprivate func setupShowAnimation() -> CAAnimation {
        let showAnimation: CAAnimation
        switch animationType {
        case .fadeInOut:
            let keyFrameAnimation: CAKeyframeAnimation = CAKeyframeAnimation()
            keyFrameAnimation.keyPath = "transform"
            keyFrameAnimation.duration = duration
            keyFrameAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 1.0)),
                                        NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0)),
                                        NSValue(caTransform3D: CATransform3DMakeScale(0.8, 0.8, 1.0)),
                                        NSValue(caTransform3D: CATransform3DIdentity),]
            keyFrameAnimation.keyTimes = [0.2, 0.5, 0.75, 1.0]
            keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            showAnimation = keyFrameAnimation            
            break
        case .translateLeft:
            showAnimation = animation(fromeValue: NSNumber(value: -viewWidth.native), toValue: NSNumber(value: viewWidth.native), keyPath: "transform.translation.x")
            break
        case .translateRight:
            showAnimation = animation(fromeValue: NSNumber(value: viewWidth.native), toValue: NSNumber(value: -viewWidth.native), keyPath: "transform.translation.x")
            break
        case .translateTop:
            showAnimation = animation(fromeValue: NSNumber(value: -viewHeight.native), toValue: NSNumber(value: viewHeight.native), keyPath: "transform.translation.y")
            break
        case .translateBottom:
            // showAnimation = animation(fromeValue: viewHeight, toValue: -(viewHeight), keyPath: "transform.translation.y")
            showAnimation = animation(fromeValue: NSNumber(value: viewHeight.native), toValue: NSNumber(value: -viewHeight.native), keyPath: "transform.translation.y")
            break
        case .scaleLeftTop:
            showAnimation = animation(fromeValue: 0.01, toValue: 1.0, keyPath: "transform.scale")
            contentView?.layer.anchorPoint = CGPoint(x: 0, y: 0)
            contentView?.layer.position = CGPoint(x: contentViewCenter.x - contentView!.frame.width / 2, y: contentViewCenter.y - contentView!.frame.height / 2)
            break
        case .scaleRightTop:
            showAnimation = animation(fromeValue: 0.01, toValue: 1.0, keyPath: "transform.scale")
            contentView?.layer.anchorPoint = CGPoint(x: 1, y: 0)
            contentView?.layer.position = CGPoint(x: contentViewCenter.x + contentView!.frame.width / 2, y: contentViewCenter.y - contentView!.frame.height / 2)
            break
        case .scaleLeftBottom:
            showAnimation = animation(fromeValue: 0.01, toValue: 1.0, keyPath: "transform.scale")
            contentView?.layer.anchorPoint = CGPoint(x: 0, y: 1)
            contentView?.layer.position = CGPoint(x: contentViewCenter.x - contentView!.frame.width / 2, y: contentViewCenter.y + contentView!.frame.height / 2)

            break
        case .scaleRightBottom:
            showAnimation = animation(fromeValue: 0.01, toValue: 1.0, keyPath: "transform.scale")
            contentView?.layer.anchorPoint = CGPoint(x: 1, y: 1)
            contentView?.layer.position = CGPoint(x: contentViewCenter.x + contentView!.frame.width / 2, y: contentViewCenter.y + contentView!.frame.height / 2)
            break
        }
        return showAnimation
    }
//    frame.origin.x = position.x - anchorPoint.x * bounds.size.width；
//    frame.origin.y = position.y - anchorPoint.y * bounds.size.height；
    
    fileprivate func setupHideAnimation() -> CAAnimation {
        let hideAnimation: CAAnimation
        switch animationType {
        case .fadeInOut:
            let keyFrameAnimation: CAKeyframeAnimation = CAKeyframeAnimation()
            keyFrameAnimation.keyPath = "transform"
            keyFrameAnimation.duration = duration
            keyFrameAnimation.values = [NSValue(caTransform3D: CATransform3DMakeScale(1.2, 1.2, 1.0)),
                                        NSValue(caTransform3D: CATransform3DMakeScale(0.01, 0.01, 0.01))]
            keyFrameAnimation.keyTimes = [0.2, 1.0]
            keyFrameAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            hideAnimation = keyFrameAnimation
            break
        case .translateLeft:
            hideAnimation = animation(fromeValue: nil, toValue: NSNumber(value: -viewWidth.native), keyPath: "transform.translation.x")
            break
        case .translateRight:
            hideAnimation = animation(fromeValue: nil, toValue: NSNumber(value: viewWidth.native), keyPath: "transform.translation.x")
            break
        case .translateTop:
            hideAnimation = animation(fromeValue: nil, toValue: NSNumber(value: -viewHeight.native), keyPath: "transform.translation.y")
            break
        case .translateBottom:
            hideAnimation = animation(fromeValue: nil, toValue: NSNumber(value: viewHeight.native), keyPath: "transform.translation.y")
            break
        case .scaleLeftTop:
            hideAnimation = animation(fromeValue: 1.0, toValue: 0.01, keyPath: "transform.scale")
            contentView?.layer.anchorPoint = CGPoint(x: 0, y: 0)
            break
        case .scaleRightTop:
            hideAnimation = animation(fromeValue: 1.0, toValue: 0.01, keyPath: "transform.scale")
            contentView?.layer.anchorPoint = CGPoint(x: 1, y: 0)
            break
        case .scaleLeftBottom:
            hideAnimation = animation(fromeValue: 1.0, toValue: 0.01, keyPath: "transform.scale")
            contentView?.layer.anchorPoint = CGPoint(x: 0, y: 1)
            break
        case .scaleRightBottom:
            hideAnimation = animation(fromeValue: 1.0, toValue: 0.01, keyPath: "transform.scale")
            contentView?.layer.anchorPoint = CGPoint(x: 1, y: 1)
            break
        }
        return hideAnimation
    }
    
    /// 显示弹出视图
    public func show() {
        // 获取数据源数据
        if contentView != nil {
            contentView!.removeFromSuperview()
            contentView = nil
        }
        contentView = dataSource?.viewForContentInPopupView(self)
        if let contentView = contentView {
            contentView.isUserInteractionEnabled = true
            contentViewCenter = contentView.center
            addSubview(contentView)
            
            // 初始状态
            contentView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            contentView.layer.position = contentViewCenter
            let showAnimation = setupShowAnimation()
            UIApplication.shared.keyWindow?.subviews.first?.addSubview(self)
            alpha = 0.0
            
            UIView.animate(withDuration: duration, animations: {
                self.alpha = 1.0
            }) 
            contentView.layer.add(showAnimation, forKey: nil)
            isShow = true
        }
    }
    
    /// 隐藏弹出视图
    public func hide() {
        if superview != nil {
            if let contentView = contentView  {
                let hideAnimation = setupHideAnimation()
                contentView.layer.add(hideAnimation, forKey: nil)
                UIView.animate(withDuration: duration,
                                           animations: { self.alpha = 0.0 },
                                           completion: { (finished) in
                                            contentView.removeFromSuperview()
                                            self.removeFromSuperview()
                                            self.isShow = false })
            }
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // 点击代理
        //        print("\(#function)")
        if let callback = callback {
            callback(0)
        } else {
            let SEL = delegate?.responds(to: #selector(ZDXPopupViewDelegate.didSelectPopupViewBackgroud))
            if (SEL == true) {
                delegate?.didSelectPopupViewBackgroud!()
            } else {
                hide()
            }
        }
    }
}


/******************************* 圆形／圆矩形View *******************************/
/**
 *  用于显示圆形／圆矩形View，可以xib属性检查器面板上设置cornerRadius borderColor borderWidth相应参数
 *  cornerRadius 为0时为正圆形，否则为圆矩形；
 *  borderColor 外环颜色
 *  borderWidth 外环宽度
 */
// MARK: -  圆形／圆矩形View

@IBDesignable
final public class EllipseView: UIControl {
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            self.setNeedsLayout()
        }
    }

    override public func draw(_ rect: CGRect) {
        if cornerRadius == 0 {
            cornerRadius = rect.width / 2.0
        }
        self.layer.masksToBounds =  true
        self.layer.cornerRadius = cornerRadius
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
    }
}
























