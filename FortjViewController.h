//
//  FortjViewController.h
//  mapDemo
//
//  Created by CMH-mac on 16/6/4.
//  Copyright © 2016年 xingzhi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>

typedef void(^moveBlock)(AMapPOI *location);
typedef void(^geocodeSearch)(NSString *nameKey);



@interface FortjViewController : UIViewController

@property (nonatomic,retain) MAUserLocation *currentLocation;//当前位置

@property (nonatomic,retain) NSString *currentCity;//当前参数
@property (nonatomic,copy) geocodeSearch geocodeSearch;

@property (nonatomic,copy) moveBlock moveBlock;
@property (nonatomic,assign) NSString *isSelected;//是否点击了搜索，点击之前都是只能匹配
@property (nonatomic,assign) NSString *isName;//是否点击了搜索，点击之前都是只能匹配


@end
