//
//  FMRoutes.swift
//  FMRoute
//
//  Created by Aaron on 2018/7/10.
//  Copyright © 2018 Fitmao. All rights reserved.
//

import UIKit

typealias FMRoutesHandler = ([String: Any]) -> Bool


class FMRouter: NSObject {
    
    public enum PresentType {
        case push
        case present
    }
    
    /// 获取全局 Scheme
    public static var global: FMRouter {
        return self.routes(for: FMRoutesGlobalSchemeKey)
    }
    
    /// 路由表
    public var routes: [String: [Any?]] = [:]
    
    /// Scheme
    public var scheme: String = ""
    
    /// 初始化路由表，如果 Scheme 不存在，同时注册一个 Scheme
    static public func routes(for scheme: String) -> FMRouter {
        let map = FMRouter.RouterMap
        
        if map.map[scheme] == nil {
            map.map[scheme] = [:]
        }
        
        let router = FMRouter(scheme)
        
        return router
    }
    
    private override init() {
    }
    
    private init(_ scheme: String) {
        self.scheme = scheme
        routes = FMRouter.RouterMap.map[scheme]!
    }
    
    /// 添加一个路由，优先级为 0
    public func addRoute(_ pattern: String, routesHandler: @escaping FMRoutesHandler) {
        self.addRoute(pattern, priority: 0, routesHandler: routesHandler)
    }
    
    /// 添加一个跳转型路由，优先级为 0
    public func addRoute(_ pattern: String, routesHandler: @escaping FMRoutesHandler, viewController: UIViewController) {
        self.addRoute(pattern, priority: 0, routesHandler: routesHandler, viewController: viewController)
    }
    
    /// 添加一个路由，优先级默认为 0
    /// - parameters:
    ///     - pattern:
    ///         路由参数，作为后续路由跳转的参数列表
    ///
    ///         以下是一些标准的路由参数：
    ///
    ///         ```
    ///         /user/login/:username
    ///         /:username/:password
    ///         /info/:phoneNumber
    ///         ```
    ///     - priority: 优先级，目前版本暂时无任何功能
    ///     - routesHandler: 完成路由跳转之后的闭包回调
    public func addRoute(_ pattern: String, priority: Int = 0, routesHandler: @escaping FMRoutesHandler, viewController: UIViewController? = nil) {
        let paramArr: [Any?] = [routesHandler, viewController]
        self.routes[pattern] = paramArr
        
        FMRouter.RouterMap.map[scheme] = self.routes
    }
    
    /// 路由到指定的 URL
    /// - parameters:
    ///     - url:
    ///         URLs 要符合 RFC 1808, RFC 1738, 和 RFC 2732 标准，即能够被 NSURL 识别的 URLs。
    ///
    ///         以下是一些符合标准的 URLs：
    ///         ```
    ///         myapp://user/login/fitmao
    ///         http://ViewControllerA/TagA
    ///         com.fitmao.routesapp://info/name?token=123abc
    ///         ```
    public func route(to url: URL?) -> Bool {
        guard let url = url else {
            print("URL 初始化失败，请检查你的 URL 是否符合标准，或中文字符没有被编码。")
            return false
        }
        
        let keys = self.routes.allKeys
        for key in keys {
            let request = FMRouterRequest(url: url, pattern: key)
            if request.isMatched {
                if let closure = self.routes[key]![FMRouter.FMRoutesHandlerIndex] as? FMRoutesHandler {
                    
                    /// 在配置该闭包时你需要返回一个 `Bool` 值来帮助 FMRouter 判断能否进行跳转
                    /// 如果你认为参数有异常那么可以返回 `false`，此时即使有匹配的路由，FMRouter 也不会进行跳转。
                    if closure(request.matchedPatterns) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    /// 跳转到指定的路由
    /// 使用此方法需要使用 `addRoute(pattern:routesHandler:viewController:)` 设置路由的跳转根控制器。
    /// - parameters:
    ///     - viewController: 这是一个需要遵守 `ModelManager` 协议的控制器，如果没有遵守该协议将没有跳转路由后自动配置参数的能力。同时你的控制器类需要将能够被自动设置的属性设置为动态属性。
    public func route(to url: URL?,
                      for viewController: UIViewController & ModelManager,
                      presentStyle: PresentType) -> Bool {
        guard let url = url else {
            print("URL 初始化失败，请检查你的 URL 是否符合标准，或中文字符没有被编码。")
            return false
        }
        
        let keys = self.routes.allKeys
        for key in keys {
            let request = FMRouterRequest(url: url, pattern: key)
            if request.isMatched {
                if let closure = self.handler(with: key) {
                    if closure(request.matchedPatterns) {
                        let matchedKeys = request.matchedPatterns.allKeys
                        let matchedValues = request.matchedPatterns.allValues
                        viewController.setValues(keys: matchedKeys, values: matchedValues)
                        
                        if let rootVC = self.viewController(with: key) {
                            self.present(viewController: viewController,
                                         for: rootVC,
                                         style: presentStyle)
                        }
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    /// 当你的控制器类没有遵守 `ModelManager` 协议时请使用该方法。
    public func route(to url: URL?,
                      for viewController: UIViewController,
                      presentStyle: PresentType) -> Bool {
        guard let url = url else {
            print("URL 初始化失败，请检查你的 URL 是否符合标准，或中文字符没有被编码。")
            return false
        }
        
        let keys = self.routes.allKeys
        for key in keys {
            let request = FMRouterRequest(url: url, pattern: key)
            if request.isMatched {
                if let closure = self.handler(with: key) {
                    if closure(request.matchedPatterns) {
                        if let rootVC = self.viewController(with: key) {
                            self.present(viewController: viewController,
                                         for: rootVC,
                                         style: presentStyle)
                        }
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // MARK: - Private function
    private func handler(with key: String) -> FMRoutesHandler? {
        return self.routes[key]![FMRouter.FMRoutesHandlerIndex] as? FMRoutesHandler
    }
    
    private func viewController(with key: String) -> UIViewController? {
        return self.routes[key]![FMRouter.FMRoutesViewControllerIndex] as? UIViewController
    }
    
    private func present(viewController: UIViewController, for rootViewController: UIViewController, style: PresentType) {
        switch style {
        case .push:
            if let navigationController = rootViewController as? UINavigationController {
                navigationController.pushViewController(viewController, animated: true)
            } else {
                rootViewController.navigationController?.pushViewController(viewController, animated: true)
            }
        case .present:
            rootViewController.present(viewController, animated: true, completion: nil)
        }
    }
}


/// 包装地图字典
class FMRouterMap: NSObject {
    public var map: [String: [String: [Any?]]] = [:]
}


extension FMRouter {
    /// 全局路由地图
    public static let RouterMap: FMRouterMap = FMRouterMap()
}

extension FMRouter {
    private static let FMRoutesGlobalSchemeKey = "FMRoutesGlobalSchemeKey"
    private static let FMRoutesHandlerIndex: Int = 0
    private static let FMRoutesViewControllerIndex: Int = 1
}
