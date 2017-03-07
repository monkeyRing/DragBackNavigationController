# DragBackNavigationController
####全屏拖拽返回，截屏方式实现 之前项目中用到这个，参照一哥们儿写的，swift实现，直接用在项目中。

> 两种效果
* 1. 类似美团外卖的侧滑返回效果
* 2. 类似于雪球、简书的侧滑返回效果


效果图：
  * ![效果图1](https://github.com/monkeyRing/DragBackNavigationController/blob/master/images/effect1.gif)
  * ![效果图2](https://github.com/monkeyRing/DragBackNavigationController/blob/master/images/effect2.gif)

####使用方法:
很简单，就和平时给控制器添加NavigationController一样。支持StoryBoard中拖拽一个导航控制器直接将类设置为`HLNaviViewController`即可
#####目前存在已知的问题:
 ~~1.模态弹出后再push，无法正常使用.~~

##### 已知问题已解决。感谢1025271535@qq.com这位哥们的帮助.
