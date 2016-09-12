# DxRefreshView


模仿锤子手机的下拉刷新效果.基于swift 3.0编写

demo:
---

![image](image/refresh_header.gif)

Usage:
---

```Swift
scrollView = UIScrollView(frame:self.view.bounds)
scrollView.addRefreshHeader(color: UIColor.blue) {
         //刷新数据
      }
```

刷新完成之后：

```Swift
scrollView.endRefreshing();
```

不通过下拉触发，直接开始刷新:

```Swift
scrollView.beginRefreshing();
```

应用或界面退出时，移除observer:

```Swift
scrollView.removeScrollObserver();
```
