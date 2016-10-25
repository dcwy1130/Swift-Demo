//
//  ViewController.swift
//  Swifter Demo
//
//  Created by ZDX on 16/7/12.
//  Copyright (c) 2016年 GroupFly. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController, ZDXLoopScrollViewDataSource, ZDXLoopScrollViewDelegate {
    var titleLabel: UILabel!
    var moveView: ZDXMoveView!
    var loopScrollView: ZDXLoopScrollView!
    var imageNames: [String] = ["2", "3", "4", "5", "6"]
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var label: UILabel!
    
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        // 销毁
        loopScrollView.endAutoLoop()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let childVCs = (1..<6).map {  UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewController" + "\($0)") }
        childVCs.forEach(self.addChildViewController)
        1.stride(to: 9, by: 2)
        
//        test1()
//        test2()
//        test3()
//        test4()
//        test5()
//        test6()
//        test7()
//        test8()
//        test9()
        test10()
//        test11()
//        test12()
//        test13()
        
        titleLabel = {
            let label = UILabel(frame: CGRectMake(150, 30, 60, 40))
            label.textColor = UIColor.redColor()
            label.text = "Title"
//            self.view.addSubview(label)
            return label
            }()
    }
    
    func test1() {
        _ = MySubClass()
//        object.num = 100
        
//        let newObject = object.copy()
//        object.num = 200

//        println(object.num)
//        println(newObject.num)
        
//        for aView in self.view.subviews {
//            if aView is UIView {
//                println("YES\(aView)")
//            } else {
//                println("NO\(aView)")
//            }
//        }
    }
    
    // as! 关键字做强制类型转换  as? 类型转换失败返回 nil is 进行自省
    func test2() {
        // 1.遍历时转换
        for object in self.view.subviews {
            // as? 在类型不匹配及转换失败时返回 nil
            if let view = object as? UIView {
                view.backgroundColor = UIColor.redColor()
            } else {
                view.backgroundColor = UIColor.greenColor()
            }
        }
        
        // 2.转换后遍历
        if let subviews = self.view.subviews as? [UIView] {
            for view in subviews {
                view.backgroundColor = UIColor.yellowColor()
            }
        }
        
        // 3.强制转换后遍历（前提是数组元素必须一致）
        for view in self.view.subviews {
            view.backgroundColor = UIColor.blueColor()
        }
    }
    
    func test3() {
        // 不会选择 printPet(dog: Dog) 版本，需对输入类型做判断
        printThem(Dog(), Cat())
        // Meow Pet
    }
    
    func test4() {
        let foo = PropertyCheckClass()
//        foo.date = foo.date.dateByAddingTimeInterval(10086)
        foo.date = foo.date.dateByAddingTimeInterval(100_000_000)
    }
    
    func test5() {
//        delay(2) { print("2 秒后输出") }
        // 如果要取消，先保留一个对Task的引用，然后调用cancel
        let task = delay(5) { print("拨打 110", terminator: "") }
        cancel(task)
    }
    
    private var myContext = 0
    
    func test6() {
        myObject = KVOMyClass()
        print("初始化 MyClass，当前日期: \(myObject.date)")
        myObject.addObserver(self, forKeyPath: "date", options: .New, context: &myContext)
        
        delay(3) {
            self.myObject.date = NSDate()
        }
    }
    
    func test7() {
        let classP1: PropertyCheckClass = PropertyCheckClass()
        let classP2: PropertyCheckClass = PropertyCheckClass()
        // 实现了 == 操作符
        if (classP1 == classP2) {
            print("P 结果：相等")
        } else {
            
        }
        
        let classK1: KVOMyClass = KVOMyClass()
//        var classK2: KVOMyClass = KVOMyClass()
        // 未实现 == 操作符，则调用NSObject的isEqual方法
        if (classK1 === classK1) {
            print("K 结果：相等")
        } else {
            
        }
    }
    
    // Swizzle 应用
    func test8() {
        
    }
    

    
    // lazy方法
    func test9() {
        
        let aView: UIView = UIView(frame: CGRectMake(0, 0, 100, 100))
        aView.backgroundColor = UIColor.redColor()
        self.view.addSubview(aView)
        // 延时执行须是类方法
        [ViewController .performSelector(#selector(ViewController.perform(_:)), withObject: aView, afterDelay: 3.0)]
        
        // lazy 延时加载方法
        let data = 1...10
//        data.lazy.map
        let result = data.map { // func map<U>(transform: (T) -> U) -> [U]
            (i: Int) -> Int in
            print("正在处理 \(i)")
            return i * 2
        }
        print("准备访问结果")
        for i in result {
            print("操作后结果为 \(i)")
        }
        print("操作完毕", terminator: "")
        
        // 无穷大
        Double.infinity
        // 未定义或错误运算
        Double.NaN
    }
    
    class func perform(aView: UIView) -> Void {
        UIView.animateWithDuration(0.3) {
            aView.transform = CGAffineTransformTranslate(aView.transform, 100, 100)
        }
    }
    
    
    func test10() {
        var views: Array<UIView> = []
        for VC in self.childViewControllers{
            let vc = VC 
            views.append(vc.view)
        }
//        self.navigationController?.navigationBar.translucent = false
//        moveView = ZDXMoveView(frame: self.contentView.bounds, titles: ["全部", "待付款", "待发货", "待收货", "待评价", "退款/售后"], contentViews:views)
        moveView = ZDXMoveView(frame: CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 44), titles: ["全部", "待付款", "待发货", "待收货", "待评价", "退款/售后"])
//        print(NSStringFromCGRect(moveView.bounds), terminator: "")
        self.contentView.addSubview(moveView)
        moveView.delegate = { [weak self] (index: Int) in
            print("点了第\(index)个")
            // 弱引用
            if let strongSelf = self {
                strongSelf.label.text = "点了第\(index)个"
            }
        }
        
        loopScrollView = ZDXLoopScrollView(frame: CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), 200), alignment: .Center, animationScrollDuration: 3.0)
        loopScrollView.dataSource = self
        loopScrollView.delegate = self
        loopScrollView.callback = {
            print("点了第\($0)个")
        }
//        self.contentView.addSubview(loopScrollView)
    }
    
    func numberOfContentViewsInLoopScrollView(loopScrollView: ZDXLoopScrollView) -> Int {
        return imageNames.endIndex
    }
    
    func loopScrollView(loopScrollView: ZDXLoopScrollView, contentViewAtIndex index: Int) -> UIView {
//        print("Rect: \(NSStringFromCGRect(loopScrollView.bounds))")
        let imageView = UIImageView(frame: loopScrollView.bounds)
        imageView.image = UIImage(named: imageNames[index])
        return imageView
    }
    
    func loopScrollView(loopScrollView: ZDXLoopScrollView, didSelectContentViewAtIndex index: Int) {
        print("\(#function) 点了第\(index)个")
    }
    
    func test11() {
        // 接收类型
        sizeof(Int)
        // 接收具体的值
        sizeofValue(Double)
        // 辅助函数
        race(state)
        
        let index:Int = 1
        let i = String(index)
        
        
        var array1: Array<UITableViewDataSource> = []
        var array2: [String] = ["", ""]
        let vc1 = ViewController1()
        array1.append(vc1)
        
        
//        print(array1)
        print(array2)
        func myMethods <T> (i: T, j: T) {
            
        }
    }
    
    func test12() {
        // 数组的应用
        let fibs = [1, 5, 6, 9, 10]
        let flag = fibs.contains { $0 < 6 }
        print(flag)
        
        // “写时复制”特性：只在必要的时候进行复制，在变更之前共享内部的存储
        var a = [1, 2, 3]
        let b = a
        a.append(4)
        print(b)
        
        // Map应用: 一个函数作用在数组每个元素上，并返回新数组包含转换后的结果
        // 提供了变换函数作为参数：将行为进行参数化的设计模式
        _ = fibs.map{ $0 * $0 }
        _ = a.findElement{ $0 > 6 }
        let accumulate = a.accumulate(0, combine: +)
        print(accumulate)
        
        
        // Filter应用:过滤符合条件的元素，并创建新数组
        _ = fibs.filter{ $0 % 2 == 0 }
        // 寻找 100 以内同时满足是偶数并且是其他数字的平方的数”
        let result = (1..<10).map{ $0 * $0 }.filter{ $0 % 2 == 0 }
        print(result)
        
        let f = result.allMatch{ $0 < 30 }
        print(f)
        
        // Reduce应用：把一个初始值以及中间值与序列中的元素进行合并的函数进行抽象
        // 例：累加
        let s = fibs.reduce(0) { total, num in total + num }
        let r = fibs.reduce(1, combine: *)
        print("S:" + "\(s)")
        print("R:" + "\(r)")
        
        // FlatMap应用：将包含数组的数组，以展平的形式放到一个单独的数组中
        // [[1, 2, 3], [4, 5, 6]] => [1, 2, 3, 4, 5, 6]
        let ranks = ["J", "Q", "K", "A"]
        let suits = ["1", "2", "3", "4"]
        // 得到元素的排列组合
        let allcombinations = suits.flatMap { suit in ranks.map { rank in (suit, rank) } }
        print("A:" + "\(allcombinations)")
        
        // forEach应用：对所有元素调用一个函数使用
        for element in [1, 2, 3] {
            print(element)
        }
        [1, 2, 3].forEach { element in
            print(element)
        }
        // 对所有元素调用一个函数
        // 例: theViews.forEach(view.addSubview)
        
        
        let fib = [1, 5, 6, 9, 10]
        // 得到的是数组的一个切片ArraySlice<Int>，数组的一种表示方式
        let fs = fib[1..<fibs.endIndex]
        // 将切片转换为数组
        let ar = Array(fs)
        print(ar)
    }
    
    func test13() {
        /*
         集合类型遵守CollectionType协议，CollectionType遵守SequenceType协议，SequenceType使用一个GeneratorType类型提供其中的元素。
         
         简单说，生成器 (generator) 知道如何产生新的值，序列知道如何创建一个生成器，而集合 (collection) 为序列添加了有意义的随机存取的方式。
         
         
         
         
         
         
         
         */
    }
    
    typealias Time = Int
    typealias Positions = [Int]
    typealias State = (time: Time, positions: Positions)
    
    let state: State = (time: 5, positions: [1, 1, 1])
    
    // 主函数
    func race(state: State) {
        draw(state)
        // 递归调用
        if (state.time > 0) {
            print("\n\n", terminator: "")
            race(runStepOfRace(state))
        }
    }
    
    // 输出结果
    func draw(state: State) {
        let outputs = state.positions.map { self.outputCar($0) }
        print(outputs.joinWithSeparator("\n"), terminator: "")
    }
    
    // 传入State, 通过计算后返回新State
    func runStepOfRace(state: State) -> State {
        let newTime = state.time - 1
        let newPositions = moveCars(state.positions)
        return (newTime, newPositions)
    }
    
    // 返回n个-字符串
    func outputCar(carPosition: Int) -> String {
        let output = (0..<carPosition).map { _ in "-" }
        return output.joinWithSeparator("")
    }
    
    // 产生随机数，如果该数>3则在原基础+1，否则不加，最后返回新的Position
    func moveCars(positions: [Int]) -> [Int] {
        return positions.map { position in (self.randomPositiveNumberUpTo(10) > 3) ? position + 1 : position }
    }
    
    func randomPositiveNumberUpTo(uppderBound: Int) -> Int {
        // arc4random_uniform 返回一个0到上界（不含）的整数
        return Int(arc4random_uniform(UInt32(uppderBound)))
    }

    
    var myObject: KVOMyClass!
    // KVO
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (context == &myContext) {
            let a = change![NSKeyValueChangeNewKey]!
            print("日期发生变化 \(a)")
        }
    }
}

let ReuseIdentifier: String = "CellReuseIdentifier"
extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: ReuseIdentifier)
        }
        cell?.textLabel?.text = "第\(indexPath.row)行"
        return cell!
    }
}

class Pet {}
class Cat: Pet {}
class Dog: Pet {}

func printPet(pet: Pet) {
    print("Pet")
}

func printPet(cat: Cat) {
    print("Meow")
}

func printPet(dog: Dog) {
    print("Bark")
}

func printThem(pet: Pet, _ cat: Cat) {
    printPet(cat)
    //    printPet(pet)
    // 对输入类型做判断
    if let aCat = pet as? Cat {
        printPet(aCat)
    } else if let aDog = pet as? Dog {
        printPet(aDog)
    }
}

/// 属性检查 
class PropertyCheckClass: Equatable {
    let oneYearInSecond: NSTimeInterval = 365 * 24 * 60 * 60
    var date: NSDate {
        // 在 willSet 和 didSet 中我们分别可以使用 newValue 和 oldValue 来获取将要设定的和已经设定的值。
        willSet {
            let d = date
            print("即将将日期从 \(d) 设定至 \(newValue)", terminator: "")
        }
        didSet {
            // 超过1年时将拦截，设置值的验证
            if date.timeIntervalSinceNow > oneYearInSecond {
                print("设定的时间太晚了！", terminator: "")
                date = NSDate().dateByAddingTimeInterval(oneYearInSecond)
            }
            print("已经将日期从 \(oldValue) 设定至 \(date)", terminator: "")
        }
    }
    init() {
        date = NSDate()
    }
}

func ==(lhs: PropertyCheckClass, rhs: PropertyCheckClass) -> Bool {
    return lhs.date == rhs.date
}

// 延时调用
typealias Task = (cancel: Bool) -> Void

func delay(time:NSTimeInterval, task:() -> ()) -> Task? {
    // 延时执行（Block）方法
    func dispatch_later(block:() -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(time * Double(NSEC_PER_SEC))),
            dispatch_get_main_queue(),
            block)
    }
    
    // task 为执行的block语句块
    var closure: dispatch_block_t? = task
    // result为方法返回的Task
    var result: Task?
    
    // 延时闭包
    let delayedClosure: Task = {
        cancel in
        if let internalClosure = closure {
            if (cancel == false) {
                dispatch_async(dispatch_get_main_queue(), internalClosure)
            }
        }
        closure = nil
        result = nil
    }
    
    result = delayedClosure
    
    dispatch_later {
        if let delayedClosure = result {
            delayedClosure(cancel: false)
        }
    }
    return result
}

func cancel(task:Task?) {
    task?(cancel: true)
}

// KVO应用
class KVOMyClass: NSObject {
    // 在swift中实现KVO，将要观察对象标记为dynamic
    dynamic var date = NSDate()
}

class ClassA {
    // 延时加载 lazy修饰符
    lazy var name: String = {
        let str = "Shawn"
        return str
    }()
    // 简单化版
    lazy var firstName: String = "shawn"
}

class MyObject: NSManagedObject {
    // @NSManaged 赞同于OC中的 @dynamic
    @NSManaged var title: NSString
    
    
}

// 重载下标访问的方式简化了 JSON 操作
let JSON: Dictionary = ["menu": [
    "id": "file",
    "value": "File",
    "popup":
        [ "menuitem":
            [["value": "New", "onclick": "CreateNewDoc()"],
                ["value": "Open", "onclick": "OpenDoc()"],
                ["value": "Close", "onclick": "CloseDoc()"]]]]]

// 使用 SwiftJSON
//if let value = JSON(json)["menu"]["popup"]["menuitem"][0]["value"].string {
//    print(value)
//}

class ViewController0: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

class ViewController1: UIViewController, UITableViewDataSource {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: ReuseIdentifier)
        }
        cell?.textLabel?.text = "第\(indexPath.row)行"
        return cell!
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let VC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("ViewController0") 
        self.navigationController?.pushViewController(VC, animated: true)
    }
}

class ViewController2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.blueColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: ReuseIdentifier)
        }
        cell?.textLabel?.text = "第\(indexPath.row)行"
        return cell!
    }
}
class ViewController3: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.greenColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: ReuseIdentifier)
        }
        cell?.textLabel?.text = "第\(indexPath.row)行"
        return cell!
    }
}
class ViewController4: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cyanColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: ReuseIdentifier)
        }
        cell?.textLabel?.text = "第\(indexPath.row)行"
        return cell!
    }
}
class ViewController5: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.orangeColor()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell? = tableView.dequeueReusableCellWithIdentifier(ReuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: ReuseIdentifier)
        }
        cell?.textLabel?.text = "第\(indexPath.row)行"
        return cell!
    }
}

extension UIViewController {
    // 自定义返回按钮
    func setNavigationBackTitle(title: String) {
        // 全局导航栏设置
//        UINavigationBar.appearance().barTintColor = UIColor.redColor()          // 背景颜色
//        UINavigationBar.appearance().tintColor = UIColor.whiteColor()           // 返回字体颜色
//        UINavigationBar.appearance().titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor() , NSFontAttributeName : UIFont.systemFontOfSize(20)]                  // title标题颜色和字体

        // 单个控制器的显示，与之对应的有全局的设置
//        self.navigationController?.navigationBar.barTintColor = UIColor.redColor()  // 背景颜色
//        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()   // 返回字体颜色
//        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.whiteColor() , NSFontAttributeName : UIFont.systemFontOfSize(20)]       // title标题颜色和字体        
        let returnButtonItem = UIBarButtonItem()
        returnButtonItem.title = title;
        returnButtonItem.setTitleTextAttributes([ NSFontAttributeName : UIFont.systemFontOfSize(15)], forState: UIControlState.Normal)
        self.navigationItem.backBarButtonItem = returnButtonItem;
    }
}

enum LoginError {
    case UserNotFound, UserPasswordNotMatch
}

extension SequenceType {
    // 查找第一个符合条件的元素，match为一个函数
    func findElement(match:Generator.Element -> Bool) -> Generator.Element? {
        for element in self where match(element) {
            return element
        }
        return nil
    }
    
    // 检查序列中所有元素是否全部满足某个条件
    public func allMatch(predicate:Generator.Element -> Bool) -> Bool {
        //  对于一个条件，如果没有元素不满足它的话，那意味着所有元素都满足它
        return !self.contains{ !predicate($0) }
    }
}

extension Array {
    // 累加，并记录每步计算结果
    func accumulate<U>(initial: U, combine: (U, Element) -> U) -> [U] {
//    func accumulate<U>(initial: U, combine: (U, Element) -> U) -> [U] {
        var running = initial
        return self.map {
            running = combine(running, $0)
            return running
        }
    }
}























