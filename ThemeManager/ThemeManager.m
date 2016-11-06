//
//  ThemeManager.m
//  ThemeManager
//
//  Created by FH on 16/11/6.
//  Copyright © 2016年 FH. All rights reserved.
//

#import "ThemeManager.h"
//#import "UIColor+YYAdd.h"

// 皮肤路径
#define ThemeStyleCongfigFile @"styleConfig.plist"
#define Bundle_Of_ThemeResource @"ThemeResource"
#define Bundle_Path_Of_ThemeResource [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:Bundle_Of_ThemeResource] // resource资源目录路径(打包后的地址) + .ThemeResource

// NSUserDefault
#define _UD [NSUserDefaults standardUserDefaults]

// 当前主题
#define CURRENT_THEME_STYLE @"current_theme_style"

// 16进制颜色转换
#define UIColorFromHexWithAlpha(hexValue,a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0 blue:((float)(hexValue & 0xFF))/255.0 alpha:a]


static ThemeManager *themeManager;

@interface ThemeManager ()
@property (nonatomic, assign) ThemeStyle currentThemeStyle;
@property (nonatomic, copy) NSString *themeResourcePath; // 皮肤路径
@property (nonatomic, strong) NSDictionary *currentStyleConfig; // 皮肤的plist文件
@end

@implementation ThemeManager

+ (instancetype)shareThemeManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        themeManager = [[self alloc] init];
        
    });
    return themeManager;
}

- (instancetype)init {
    if (themeManager == nil) {
        if (self = [super init]) {
            // 初始化style
            if ([_UD objectForKey:CURRENT_THEME_STYLE]) {
                _currentThemeStyle = [[_UD objectForKey:CURRENT_THEME_STYLE] integerValue];
            } else {
                _currentThemeStyle = ThemeStyleLight;
            }
            NSLog(@"当前是[%@]皮肤", _currentThemeStyle == ThemeStyleLight ? @"亮色" : @"深色");
            
            [self configThemePath];
            [self configStyleConfig];
        }
        return self;
    }
    return themeManager;
}

- (ThemeStyle)currentThemeStyle {
    return _currentThemeStyle;
}

#pragma mark - 配置换肤
- (void)configThemePath { // 配置皮肤路径
    switch (_currentThemeStyle) {
        case ThemeStyleDark:
            _themeResourcePath = [Bundle_Path_Of_ThemeResource stringByAppendingPathComponent:@"dark"];
            break;
        case ThemeStyleLight:
            _themeResourcePath = [Bundle_Path_Of_ThemeResource stringByAppendingPathComponent:@"light"];
    }
}

- (void)configStyleConfig { // 配置皮肤设置, 获取plist文件
    NSString *configPath = [self.themeResourcePath stringByAppendingPathComponent:ThemeStyleCongfigFile];
    _currentStyleConfig = [NSDictionary dictionaryWithContentsOfFile:configPath];
}

#pragma mark - 切换皮肤
- (void)changeThemeStyle:(ThemeStyle)style {
    _currentThemeStyle = style;
    
    NSLog(@"切换为[%@]皮肤", _currentThemeStyle == ThemeStyleLight ? @"亮色" : @"深色");
    
    [self configThemePath];         // 重新获取路径
    [self configStyleConfig];       // 重新获取配置文件
    [self clearThemeImageCache];    // 清理之前的缓存
    
    [_UD setObject:@(_currentThemeStyle) forKey:CURRENT_THEME_STYLE];
    [_UD synchronize];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:THEME_STYLE_CHANGE_NOTIFICATION object:@(_currentThemeStyle)];
}

#pragma mark - 获取皮肤图片
+ (UIImage *)themeImageWithName:(NSString *)imageName {
    if (imageName == nil || [imageName isEqualToString:@""]) {
        return nil;
    }
    
    // 皮肤路径(dark/light) + 图片名称
    NSString *imagePath = [[[ThemeManager shareThemeManager] themeResourcePath] stringByAppendingPathComponent:imageName];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:imagePath]) {
        imagePath = [imagePath stringByAppendingPathComponent:@"@2x.png"];
    }
    return [UIImage imageWithContentsOfFile:imagePath];
}

// 从缓存中获取, 如果没有, 从Bundle获取
+ (UIImage *)cacheThemeImageWithName:(NSString *)imageName {
    if (imageName == nil || [imageName isEqualToString:@""]) {
        return nil;
    }
    
    // 从缓存中获取
    UIImage *image = [[[ThemeManager shareThemeManager] sdImageCache] imageFromMemoryCacheForKey:imageName];
    if (image == nil) {
        image = [ThemeManager themeImageWithName:imageName];
        
        // 加入到缓存中(磁盘 + 内存)
        [[[ThemeManager shareThemeManager] sdImageCache] storeImage:image forKey:imageName];
        return image;
    } else {
        return image;
    }
    return nil;
}

#pragma mark - 清理缓存
- (SDImageCache *)sdImageCache {
    if (_sdImageCache == nil) {
        _sdImageCache = [[SDImageCache alloc] initWithNamespace:@"ThemeResource"];
    }
    return _sdImageCache;
}

- (void)clearThemeImageCache {
    [[[ThemeManager shareThemeManager] sdImageCache] clearMemory];
}

#pragma mark - 控件颜色
- (UIColor *)colorFromConfig:(NSString *)typeKey name:(NSString *)nameKey {
    // 控件名称 + 控件颜色
    NSString *hexStr = [[self.currentStyleConfig objectForKey:typeKey] objectForKey:nameKey];
    
    // 使用YYKit转换
//    return [UIColor colorWithHexString:hexStr];
    
    // 使用自定义方法转换
    if ([hexStr hasPrefix:@"#"]) {
        hexStr = [hexStr substringFromIndex:1];
    }
    unsigned long hex = strtoul([hexStr UTF8String], 0, 16);
    return UIColorFromHexWithAlpha(hex, 1);
}

- (UIStatusBarStyle)UIStatusBarStyle {
    return [[self.currentStyleConfig objectForKey:@"StatusBarStyle"] integerValue];
}

// 导航
- (UIColor *)navigationBackgroundColor {
    return [self colorFromConfig:@"navigation" name:@"backgroundColor"];
}
- (UIColor *)navigationTintColor {
    return [self colorFromConfig:@"navigation" name:@"tintColor"];
}
- (UIColor *)navigationTitleColor {
    return [self colorFromConfig:@"navigation" name:@"titleColor"];
}

// TabBar
- (UIColor *)tabBarBackgroundColor {
    return [self colorFromConfig:@"tabBar" name:@"backgroundColor"];
}
- (UIColor *)tabBarTintColor {
    return [self colorFromConfig:@"tabBar" name:@"tintColor"];
}

// ViewController
- (UIColor *)viewControllerBackgroundColor {
    return [self colorFromConfig:@"viewController" name:@"backgroundColor"];
}
- (UIColor *)inputPlaceholderColor {
    return [self colorFromConfig:@"viewController" name:@"inputPlaceholderColor"];
}
- (UIColor *)inputTextColor {
    return [self colorFromConfig:@"viewController" name:@"inputTextColor"];
}
- (UIColor *)contentViewColor {
    return [self colorFromConfig:@"viewController" name:@"contentViewColor"];
}
- (UIColor *)contentTitleColor {
    return [self colorFromConfig:@"viewController" name:@"contentTitleColor"];
}
- (UIColor *)contentSubtitleColor {
    return [self colorFromConfig:@"viewController" name:@"contentSubtitleColor"];
}

// TableView
- (UIColor *)tableViewCellColor {
    return [self colorFromConfig:@"tableView" name:@"cellColor"];
}
- (UIColor *)tableViewCellSelectedColor {
    return [self colorFromConfig:@"tableView" name:@"cellSelectedColor"];
}
- (UIColor *)tableViewSeparatorColor {
    return [self colorFromConfig:@"tableView" name:@"separatorColor"];
}
- (UIColor *)tableViewTitleColor {
    return [self colorFromConfig:@"tableView" name:@"titleColor"];
}
- (UIColor *)tableViewSubtitleColor {
    return [self colorFromConfig:@"tableView" name:@"subtitleColor"];
}
- (UIColor *)tableViewIconColor {
    return [self colorFromConfig:@"tableView" name:@"iconColor"];
}

@end