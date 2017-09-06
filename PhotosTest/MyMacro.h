//
//  MyMacro.h
//  JS
//
//  Created by Scofield on 16/3/31.
//  Copyright © 2016年 谢航. All rights reserved.
//

#ifndef MyMacro_h
#define MyMacro_h

/**
 * 屏幕比例
 */
#define ScreenHeight_scale ScreenHeight/667
#define ScreenWidth_scale ScreenWidth/375

#define ScreenHeight [[UIScreen mainScreen] bounds].size.height
#define ScreenWidth [[UIScreen mainScreen] bounds].size.width

/**
 * 颜色
 */
#define XHRGB(R,G,B,A) [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:A]
#define XHColor(color) [UIColor color]

/**
 * 字号
 */
#define XHFont(font) [UIFont systemFontOfSize:font*ScreenHeight_scale]

/**
 * 图片
 */
#define XHImage(imageName) [UIImage imageNamed:XHString(imageName)]


/**
 * 字符串
 */
#define XHString(string) [NSString stringWithFormat:@"%@",string]

/**
 * URL
 */
#define XHURL(url) [NSURL URLWithString:XHString(url)]

/**
 * 屏幕尺寸
 */
#define WIDTH(view) view.frame.size.width
#define HEIGHT(view) view.frame.size.height
#define X(view) view.frame.origin.x
#define Y(view) view.frame.origin.y

#define BOTTOM(view) (view.frame.origin.y + view.frame.size.height)
#define RIGHT(view) (view.frame.origin.x + view.frame.size.width)

#define HeightFromBottom(MainView,View) (MainView.frame.size.height - (View.frame.origin.y + View.frame.size.height))

#define WidthFromRight(MainView,View) (MainView.frame.size.width - (View.frame.origin.x + View.frame.size.width))

#define XToCenter(MainView,number) (MainView.frame.size.width - number)/2
#define YToCenter(MainView,number) (MainView.frame.size.height - number)/2

#endif /* MyMacro_h */
