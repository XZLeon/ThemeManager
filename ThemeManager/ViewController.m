//
//  ViewController.m
//  ThemeManager
//
//  Created by 方赫 on 16/11/6.
//  Copyright © 2016年 FH. All rights reserved.
//

#import "ViewController.h"
#import "ThemeManager.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIView *view1;
@property (weak, nonatomic) IBOutlet UIView *view2;
@property (weak, nonatomic) IBOutlet UIView *view3;
@property (nonatomic, assign) BOOL isChanged;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _isChanged = NO;
    [self configTheme];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configTheme) name:THEME_STYLE_CHANGE_NOTIFICATION object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:THEME_STYLE_CHANGE_NOTIFICATION object:nil];
}

- (void)configTheme {
    _view1.backgroundColor = [[ThemeManager shareThemeManager] viewControllerBackgroundColor];
    _view2.backgroundColor = [[ThemeManager shareThemeManager] tabBarTintColor];
    _view3.backgroundColor = [[ThemeManager shareThemeManager] tableViewIconColor];
}


- (IBAction)themeChange:(id)sender {
    _isChanged = !_isChanged;
    [[ThemeManager shareThemeManager] changeThemeStyle:_isChanged ? ThemeStyleDark : ThemeStyleLight];
    [[NSNotificationCenter defaultCenter] postNotificationName:THEME_STYLE_CHANGE_NOTIFICATION object:nil];
}

@end
