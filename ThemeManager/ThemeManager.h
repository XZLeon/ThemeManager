//
//  ThemeManager.h
//  ThemeManager
//
//  Created by FH on 16/11/6.
//  Copyright © 2016年 FH. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import "SDImageCache.h"
#import <UIKit/UIKit.h>

// 皮肤切换通知
#define THEME_STYLE_CHANGE_NOTIFICATION @"theme_stype_change_notification"

typedef NS_ENUM(NSUInteger, ThemeStyle) {
    ThemeStyleDark  = 0,  // 暗色
    ThemeStyleLight = 1, // 亮色
};

@interface ThemeManager : NSObject

- (void)changeThemeStyle:(ThemeStyle)style;

/* 图片缓存 */
//@property (nonatomic, strong) SDImageCache *sdImageCache;
- (void)clearThemeImageCache;

- (ThemeStyle)currentThemeStyle;
+ (instancetype)shareThemeManager;

/* 获取图片 */
+ (UIImage *)themeImageWithName:(NSString *)imageName;
+ (UIImage *)cacheThemeImageWithName:(NSString *)imageName;

/********** 主题样式 ***********/
- (UIStatusBarStyle)UIStatusBarStyle;
// 导航
- (UIColor *)navigationBackgroundColor;
- (UIColor *)navigationTintColor;
- (UIColor *)navigationTitleColor;

// TabBar
- (UIColor *)tabBarBackgroundColor;
- (UIColor *)tabBarTintColor;

// ViewController
- (UIColor *)viewControllerBackgroundColor;
- (UIColor *)inputPlaceholderColor;
- (UIColor *)inputTextColor;
- (UIColor *)contentViewColor;
- (UIColor *)contentTitleColor;
- (UIColor *)contentSubtitleColor;

// TableView
- (UIColor *)tableViewCellColor;
- (UIColor *)tableViewCellSelectedColor;
- (UIColor *)tableViewSeparatorColor;
- (UIColor *)tableViewTitleColor;
- (UIColor *)tableViewSubtitleColor;
- (UIColor *)tableViewIconColor;
@end