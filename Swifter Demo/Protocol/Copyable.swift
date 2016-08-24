//
//  Copyable.swift
//  Swifter Demo
//
//  Created by Mac on 16/7/12.
//  Copyright (c) 2016年 GroupFly. All rights reserved.
//

import Foundation

// 接口中的Self应用，实现接口本身的类型
protocol Copyable {
    // 接口中使用的类型是实现这个接口本身的类型，Self包括实现该接口的类型本身及其子类
//    func clamp(copyableToClamp: Self) -> Self
    
//    func copy() -> Self
}

class MyClass: Copyable {
    
    var num = 10
    
//    func copy() -> Self {
//        // 要求返回一个抽象的、表示当前类型的 Self
//        let result = self.dynamicType.init()
//        result.num = num
//        return result
//    }
}

class MySubClass: MyClass {
//    override func copy() -> Self {
//        let result = self.dynamicType.init()
//        result.num = num + 1000
//        return result
//    }
}


