//
//  Defines.h
//  RHCCore
//
//  Created by sunyuping on 14-3-6.
//  Copyright (c) 2014年 sunyuping. All rights reserved.
//

#ifndef RHCCore_Defines_h
#define RHCCore_Defines_h

/*
 * 通过RGB创建UIColor
 */
#define RGBCOLOR(r,g,b) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define RGBACOLOR(r,g,b,a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

/*
 *屏幕宽度
 */
#define SCREEN_WIDTH ([[UIScreen mainScreen]bounds].size.width)

/*
 *屏幕高度
 */
#define SCREEN_HEIGHT ([[UIScreen mainScreen]bounds].size.height)

/*
 * iPhone 屏幕尺寸
 */
#define PHONE_SCREEN_SIZE (CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT - PHONE_STATUSBAR_HEIGHT))

/*
 * iPhone statusbar 高度
 */
#define PHONE_STATUSBAR_HEIGHT 20

/*
 * iPhone 默认导航条高度
 */
#define PHONE_NAVIGATIONBAR_HEIGHT 44.0f
#define PHONE_NAVIGATIONBAR_IOS7_HEIGHT 64.0f
// tabBar高度
#define PHONE_CUSTOM_TABBAR_HEIGHT 50.0f

#define HEIGHT_FOR_THEAM 18


#define PHONE_CUSTOM_TABBAR_SHOW_HEIGHT 67.5f

// 默认列表高度
#define GROUP_TABLE_CELL_DEFAULT_HEIGHT 45.0f


#define RECORD_PUBLISHER_HEIGHT 201.0f

//英文状态下键盘的高度
#define PUBLISH_ENGISH_KEYBOARD_TOP 216.0


#define WHITE_SPACE 39.0f
#define STATUS_BAR_HEIGHT 20.0f

/*
 * iPhone 屏幕减去状态栏和导航条后剩余的高度
 */
#define PHONE_CONTENT_HEIGHT (SCREEN_HEIGHT - PHONE_STATUSBAR_HEIGHT - PHONE_NAVIGATIONBAR_HEIGHT)


#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]

#define UIColorFromRGBA(rgbValue, alphaValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]


//////////////////////////
// 文件存放目录
#define kChatFileDir @"chatfile"
#define kPersistDir  @"persist"
#define kPostImageFileDir @"post/image"
#define kPostSoundFileDir @"post/voice"
#define kAudioCacheDir  @"audio_cache"
#define kImageEditCacheDir @"imageEditCache"

#define kSuperImageRatio 2.9 // 超长图比例 3:1
#define kHighQualityMaxLength 1080 // 高清图片定宽或高





//下拉刷新个人主页动画的Key
#define kUserProfilePullAnimationKey @"kUserProfilePullAnimationKey"

//默认多语言表
#define RS_CURRENT_LANGUAGE_TABLE  [[NSUserDefaults standardUserDefaults] objectForKey:@"LanguageSwtich"]?[[NSUserDefaults standardUserDefaults] objectForKey:@"LanguageSwtich"]:@"zh-Hans"

#endif
