#  FMRouter

## 模块
完整的包中应该包含 FMRoutes, FMRouterRequest, FMRouterUtilities, ModelManager 四个模块。

## 使用
FMRouter 使用 Scheme 来区分路由表，每一个 Scheme 对应一张路由表，在创建一张路由表之前要先告诉 FMRouter 该路由表属于哪一个 Scheme，同时 FMRouter 提供一个全局的 Scheme（Global Scheme），对于简单的流程跳转来说可以直接使用全局 Scheme。
Scheme 和路由表的关系保存在一个全局 Map 中，一般来说这个 Map 将会常驻于内存中，所以如果 Map 过大则可能导致 App 收到系统的内存告警。

### 获取 Scheme
全局 Scheme
`let globalScheme = FMRouter.global`
自定义 Scheme
`let myScheme = FMRouter.routes(for: "MySchemeKey")`

### 创建一个路由
创建路由前需要制定路由参数，作为后续路由跳转的参数列表
以下是一些标准的路由参数：
```
    /user/login/:username
    /:username/:password
    /info/:phoneNumber
```

`/:` 符号后的 URLComponents 将作为参数的 Key 填充在被传递的参数字典中。

使用以下三个方法均能创建路由：
```
addRoute(_:routesHandler:)
addRoute(_:routesHandler:viewController:)
addRoute(_:priority:routesHandler:viewController:)
```
`viewController` 是一个根控制器，即将会跳转的控制器将基于此控制器。

Sample:
```
globalScheme.addRoute("/user/login/:username/:password") {
    (parameters) in
    return true
}
```

`parameters` 是一个字典型的变量，对于该路由，字典的结构如下：
```
{
"username": ""
"password": ""
}
```

注册好路由后，就可以进行路由跳转，使用以下方法来进行跳转：
```
route(url:)
route(url:viewController:presentStyle:)
```

两个方法均会先匹配对应的路由，如果没有匹配的路由或闭包参数返回 `false`，方法也将会返回 `false`。
`route(url:viewController:presentStyle:)` 方法使用前必须要使用 `addRoute(_:routesHandler:viewController:)` 方法配置根控制器，如果没有匹配的路由或闭包参数返回 `false`，方法会返回 `false`，并且无法跳转到指定的控制器。

## URL Scheme
在 info.plist 中添加一个 URL types 键，在数组 item 中添加一个 URL Scheme，在 URL Scheme 的 item 中添加希望使用的 URL Scheme。
完成后，重新 Run 一次工程在设备上，就可以使用刚刚添加的 URL 来完成 App 间跳转。
跳转成功后，在 AppDelegate 中使用 `application(_ app:url:options:) -> Bool` 方法获取完整的 URL，同时注册或跳转路由。
