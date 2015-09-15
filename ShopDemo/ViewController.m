//
//  ViewController.m
//  ShopDemo
//
//  Created by David Qu on 15/9/15.
//  Copyright (c) 2015年 David Qu. All rights reserved.
//

#import "ViewController.h"
#import "LPPopup.h"

#define SCREEN_WIDTH    ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT   ([UIScreen mainScreen].bounds.size.height)

@interface ViewController ()

@property (nonatomic,strong) UIBezierPath *path;

@end

@implementation ViewController
{
    CALayer     *layer;
    UILabel     *_cntLabel;// 购物车总数量显示文本
    NSInteger    _cnt;// 总数量
    UIImageView *_imageView;// 购物车图标
    UIButton    *_btn;// 加入购物车按钮
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
     _cnt = 0;
    
    [self setUI];
    
}

- (void)setUI
{
    UIColor *customColor  = [UIColor colorWithRed:237/255.0 green:20/255.0 blue:91/255.0 alpha:1.0f];
    
    _btn = [UIButton buttonWithType:UIButtonTypeCustom];
    _btn.frame = CGRectMake(50, SCREEN_HEIGHT * 0.7, 100, 30);
    [_btn setTitle:@"加入购物车" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btn.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_btn setBackgroundImage:[UIImage imageNamed:@"ButtonRedLarge"] forState:UIControlStateNormal];
    [_btn addTarget:self action:@selector(startAnimation) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_btn];
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    _imageView.image = [UIImage imageNamed:@"TabCartSelected@2x.png"];// 购物车图标
    _imageView.center = CGPointMake(SCREEN_WIDTH-30, 25);//(270, 320);
    [self.view addSubview:_imageView];
    
    // label
    _cntLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 25, 20, 20)];
    _cntLabel.textColor = customColor;
    _cntLabel.textAlignment = NSTextAlignmentCenter;
    _cntLabel.font = [UIFont boldSystemFontOfSize:13];
    _cntLabel.backgroundColor = [UIColor whiteColor];
    _cntLabel.layer.cornerRadius = CGRectGetHeight(_cntLabel.bounds)/2;
    _cntLabel.layer.masksToBounds = YES;
    _cntLabel.layer.borderWidth = 1.0f;
    _cntLabel.layer.borderColor = customColor.CGColor;
    [self.view addSubview:_cntLabel];
    
    if (_cnt == 0) {
        _cntLabel.hidden = YES;
    }
    
    _path = [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(50, SCREEN_HEIGHT * 0.7)];
    [_path addQuadCurveToPoint:CGPointMake(SCREEN_WIDTH-50-10, 5)
                  controlPoint:CGPointMake(156, 100)];
}

- (void)startAnimation
{
    if (!layer)
    {
        UIColor *customColor  = [UIColor colorWithRed:237/255.0 green:20/255.0 blue:91/255.0 alpha:1.0f];
        
        _btn.enabled = NO;
        layer = [CALayer layer];
        layer.contents = (__bridge id)[UIImage imageNamed:@"test01.jpg"].CGImage;
        layer.contentsGravity = kCAGravityResizeAspectFill;
        layer.bounds = CGRectMake(0, 0, 50, 50);
        
        layer.masksToBounds = YES;
        layer.position = CGPointMake(50, 150);
        layer.borderColor = customColor.CGColor;
        [self.view.layer addSublayer:layer];
    }
    
    [self groupAnimation];
}

- (void)groupAnimation
{
    CAKeyframeAnimation *animation1 = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation1.path = _path.CGPath;
    animation1.rotationMode = kCAAnimationRotateAuto;
    
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    // 围绕Z轴旋转，垂直与屏幕
    animation.toValue = [ NSValue valueWithCATransform3D:
                         CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    animation.duration = 0.15;
    // 旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = 1000;
    
    CABasicAnimation *expandAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    expandAnimation.duration = 0.2f;
    expandAnimation.beginTime = 0.3f;
    expandAnimation.fromValue = [NSNumber numberWithFloat:0.3f];
    expandAnimation.toValue = [NSNumber numberWithFloat:0.4f];
    expandAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    
    CABasicAnimation *narrowAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    narrowAnimation.beginTime = 0.2f;
    narrowAnimation.fromValue = [NSNumber numberWithFloat:0.7f];
    narrowAnimation.duration = 0.3f;
    narrowAnimation.toValue = [NSNumber numberWithFloat:0.9f];
    narrowAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    
    CAAnimationGroup *groups = [CAAnimationGroup animation];
    groups.animations = @[animation1,expandAnimation,animation,narrowAnimation];
    groups.duration = 0.6f;
    groups.removedOnCompletion = NO;
    groups.fillMode = kCAFillModeForwards;
    groups.delegate = self;
    [layer addAnimation:groups forKey:@"group"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (anim == [layer animationForKey:@"group"]) {
        _btn.enabled = YES;
        [layer removeFromSuperlayer];
        layer = nil;
        _cnt++;
        if (_cnt) {
            _cntLabel.hidden = NO;
        }
        
        CATransition *animation = [CATransition animation];
        animation.duration = 0.15f;
        _cntLabel.text = [NSString stringWithFormat:@"%ld",_cnt];
        [_cntLabel.layer addAnimation:animation forKey:nil];
        
        CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
        shakeAnimation.duration = 0.15f;
        shakeAnimation.fromValue = [NSNumber numberWithFloat:-5];
        shakeAnimation.toValue = [NSNumber numberWithFloat:5];
        shakeAnimation.autoreverses = YES;
        [_imageView.layer addAnimation:shakeAnimation forKey:nil];
        
        [self showPopup:@"加入购物车成功！"];
    }
}

#pragma mark - creatLPPopup

- (void)showPopup:(NSString *)popupWithText
{
    LPPopup *popup = [LPPopup popupWithText:popupWithText];
    [popup showInView:self.view
        centerAtPoint:self.view.center
             duration:kLPPopupDefaultWaitDuration
           completion:nil];
}

@end
