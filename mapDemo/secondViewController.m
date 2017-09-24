//
//  secondViewController.m
//  mapDemo
//
//  Created by xingzhi on 16/5/17.
//  Copyright © 2016年 xingzhi. All rights reserved.
//

#import "secondViewController.h"


/**
 *  主屏的宽
 */
#define DEF_SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

/**
 *  主屏的高
 */
#define DEF_SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height


@interface secondViewController ()
@property (nonatomic, strong) UIButton *btn;//点击的按钮
@property (nonatomic, strong) UIView *back;//背景图
@property (nonatomic, strong) UIView *popback;
@property (nonatomic, strong) void (^buttonClickBlock) (NSInteger idx);
@property (nonatomic, strong) UIImageView *imageview1;


@end

@implementation secondViewController
- (UIImageView *)imageview1 {
    if (!_imageview1) {
        self.imageview1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        _imageview1.backgroundColor = [UIColor redColor];
        _imageview1.layer.cornerRadius = 50;
        _imageview1.layer.masksToBounds = YES;
    }
    return _imageview1;
}
- (UIView *)back {
    if (!_back) {
        self.back = [[UIView alloc]initWithFrame:CGRectMake(0, 0, DEF_SCREEN_WIDTH, DEF_SCREEN_HEIGHT)];
        _back.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.3];
    }
    return _back;
}


- (UIView *)popback {
    if (!_popback) {
        self.popback = [[UIView alloc] initWithFrame:CGRectMake(50, 30, DEF_SCREEN_WIDTH - 2 * 30, DEF_SCREEN_WIDTH - 2 * 30)];
        _popback.layer.cornerRadius = DEF_SCREEN_WIDTH / 2 - 30;
        _popback.layer.masksToBounds = YES;
        _popback.backgroundColor = [UIColor clearColor];
    }
    return _popback;
}



- (UIButton *)btn {
    if (!_btn) {
        self.btn = [[UIButton alloc] initWithFrame:CGRectMake(50, 150, 66, 66)];
        [_btn setBackgroundColor:[UIColor redColor]];
        _btn.layer.cornerRadius = 33;
        [self.btn setImage:[UIImage imageNamed:@"切图-93"] forState:UIControlStateNormal];
        _btn.layer.masksToBounds = YES;
        
    }
    return _btn;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.btn];
    [self.btn addTarget:self action:@selector(handelCenter:) forControlEvents:UIControlEventTouchUpInside];
    
    
}

- (void)handelCenter:(UIButton *)sender {
    [self.view addSubview:self.back];
    _back.backgroundColor = [[UIColor darkGrayColor]colorWithAlphaComponent:0.5];
    UITapGestureRecognizer *tapBack = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(WithtapBackClick1)];
    [self.back addGestureRecognizer:tapBack];
    [self.back addSubview:self.popback];
    self.popback.center =  CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    
    [self.back addSubview:self.imageview1];
    self.imageview1.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    self.imageview1.image = [UIImage imageNamed:@"切图-93"];
 [self animatedLoadIcons:@[
                           //添加自己的图片
                           
                           
                           
                              [UIImage imageNamed:@"图层-0"],
                            [UIImage imageNamed:@"图层-0"],
                              [UIImage imageNamed:@"图层-0"],
                              [UIImage imageNamed:@"图层-0"],
                              [UIImage imageNamed:@"图层-0"],
                              [UIImage imageNamed:@"图层-0"],

                              ] start:0 layoutDegree:M_PI * 2];
    
    
    
    
    __block secondViewController *weakSelf = self;
    [self setButtonClickBlock:^(NSInteger idx) {
    //写你要实现的东西
        
        
        
        
        

        NSLog(@"button %@ clicked !",@(idx));
        NSLog(@"第%d个按钮被点击", sender.tag - 100);
        [weakSelf.back removeFromSuperview];
    }];
}



-(void)WithtapBackClick1{
    //  灰色背景的点击方法 ===  手势
    [self.back removeFromSuperview];
}


- (void)animatedLoadIcons:(NSArray<UIImage*>*)icons start:(CGFloat)start layoutDegree:(CGFloat)layoutDegree
{
    CGFloat raduis = self.view.frame.size.width / 2 - 30;
    [icons enumerateObjectsUsingBlock:^(UIImage * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        UIButton* button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [button setImage:obj forState:UIControlStateNormal];
        button.tintColor = [UIColor greenColor];;
        [self.back addSubview:button];
        
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        button.alpha = 0;
        button.tag = idx + 9998;
        button.transform = CGAffineTransformMakeScale(0.5, 0.5);
        button.center = self.popback.center;
          self.popback.center =  CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
        [UIView animateWithDuration:0.2
                              delay:0.02
             usingSpringWithDamping:0.5
              initialSpringVelocity:5
                            options:UIViewAnimationOptionCurveLinear
                         animations:^{
                             button.alpha = 1;
                            button.transform = CGAffineTransformIdentity;
                             button.center = CGPointMake(self.popback.center.x + raduis * sin(start + layoutDegree/icons.count*idx), self.popback.center.y + raduis * cos(start + layoutDegree/icons.count*idx));
                             button.backgroundColor = [UIColor redColor];
                         } completion:^(BOOL finished) {
                             
                         }];
    }];
 
}

- (void)buttonClick:(id)sender
{
    if (self.buttonClickBlock) {
        self.buttonClickBlock([sender tag] - 9998);
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
