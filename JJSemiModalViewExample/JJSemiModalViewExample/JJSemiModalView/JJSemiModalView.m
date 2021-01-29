//
//  JJSemiModalView.m
//  JJSemiModalViewExample
//
//  Created by 播呗网络 on 2021/1/28.
//

#import "JJSemiModalView.h"

@interface JJSemiModalView ()

//弹出半屏框
@property (strong, nonatomic) UIView *contentView;
//弹出框背景,点击可复原
@property (strong, nonatomic) UIControl *closeControl;
//缩小视图,背面缩小的是一个图片
@property (strong, nonatomic) UIImageView *maskImageView;
//外部传入,是一个VC
@property (nonatomic, strong) UIViewController *baseViewController;


@end

@implementation JJSemiModalView

- (instancetype)initWithSize:(CGSize)size andBaseViewController:(UIViewController *)baseViewController{
    
    self = [super init];
    if (self) {
        self.frame = [UIScreen mainScreen].bounds;
        self.backgroundColor = [UIColor blackColor];
        [self addSubview:self.maskImageView];
        [self addSubview:self.closeControl];
        [self addSubview:self.contentView];
//        self.backgroundColor = [UIColor yellowColor];
        
        self.contentView.frame = [self contentViewFrameWithSize:size];
        self.baseViewController = baseViewController;
        if (baseViewController) {
            [baseViewController.view insertSubview:self atIndex:0];
            [baseViewController.view sendSubviewToBack:self];
        }
    }
    return self;
}

- (void)close{
    if (self.semiModalViewWillCloseBlock) {
        self.semiModalViewWillCloseBlock();
    }
    
    if (self.narrowedOff) {
        self.closeControl.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.25f animations:^{
            self.maskImageView.alpha = 1;
            self.contentView.frame = CGRectMake(0,
                                                self.frame.size.height,
                                                self.contentView.frame.size.width,
                                                self.contentView.frame.size.height);
        } completion:^(BOOL finished) {
            if (self.semiModalViewDidCloseBlock) {
                self.semiModalViewDidCloseBlock();
            }
            if (self.baseViewController) {
                [self.baseViewController.view sendSubviewToBack:self];
                if (self.baseViewController.navigationController) {
                    self.baseViewController.navigationController.navigationBarHidden = NO;
                }
            }
        }];
    } else {
        CATransform3D t = CATransform3DIdentity;
        t.m34 = -0.004;
        [self.maskImageView.layer setTransform:t];
        self.closeControl.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.5f animations:^{
            self.maskImageView.alpha = 1;
            self.contentView.frame = CGRectMake(0, self.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
        } completion:^(BOOL finished) {
            if (self.semiModalViewDidCloseBlock) {
                self.semiModalViewDidCloseBlock();
            }
            if (self.baseViewController) {
                if (self.baseViewController.navigationController) {
                    [self transNavigationBarToHide:NO];
                }
                [self.baseViewController.view sendSubviewToBack:self];
            }
        }];
        [UIView animateWithDuration:0.25f animations:^{
            self.maskImageView.layer.transform = CATransform3DTranslate(t, 0, -50, -50);
            self.maskImageView.layer.transform = CATransform3DRotate(t, 7/90.0 * M_PI_2, 1, 0, 0);
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25f animations:^{
                self.maskImageView.layer.transform = CATransform3DTranslate(t, 0, 0, 0);
            }];
        }];
    }
}
- (void)open{
    
    if (self.narrowedOff) {
        self.maskImageView.image = [self screenSnapshotWindow];
        if (self.baseViewController) {
            [self.baseViewController.view bringSubviewToFront:self];
        }
        self.closeControl.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.25 animations:^{
            self.maskImageView.alpha = 0.25;
            
            CGFloat screenW = CGRectGetWidth(self.frame);
            CGSize size = self.contentView.bounds.size;
            
            self.contentView.frame = CGRectMake((screenW - size.width)/2.0,
                                                [[UIScreen mainScreen] bounds].size.height - size.height,
                                                size.width,
                                                size.height);
            if (self.baseViewController) {
                if (self.baseViewController.navigationController) {
                    self.baseViewController.navigationController.navigationBarHidden = YES;
                }
            }
        }];
    } else {
        CATransform3D t = CATransform3DIdentity;
        t.m34 = -0.004;
        
        self.maskImageView.layer.transform = t;
        self.maskImageView.layer.zPosition = -10000;
        
        self.maskImageView.image = [self screenSnapshotWindow];
        if (self.baseViewController) {
            [self.baseViewController.view bringSubviewToFront:self];
        }
        self.closeControl.userInteractionEnabled = YES;
        [UIView animateWithDuration:0.5 animations:^{
            self.maskImageView.alpha = 0.25;
            CGFloat screenW = CGRectGetWidth(self.frame);
            CGSize size = self.contentView.bounds.size;
            
            self.contentView.frame = CGRectMake((screenW - size.width)/2.0,
                                                [[UIScreen mainScreen] bounds].size.height - size.height,
                                                size.width,
                                                size.height);
        }];
        
        [UIView animateWithDuration:0.25 animations:^{
            self.maskImageView.layer.transform = CATransform3DRotate(t, 7/90.0 * M_PI_2, 1, 0, 0);
            if (self.baseViewController) {
                if (self.baseViewController.navigationController) {
                    [self transNavigationBarToHide:YES];
                }
            }
        }completion:^(BOOL finished) {
            [UIView animateWithDuration:0.25f animations:^{
                self.maskImageView.layer.transform = CATransform3DTranslate(t, 0, -50, -50);
            }];
        }];
    }
}

- (void)transNavigationBarToHide:(BOOL)hide{
    if (hide) {
        CGRect frame = self.baseViewController.navigationController.navigationBar.frame;
        [self setNavigationBarOriginY:-frame.size.height animated:NO];
    } else {
        [self setNavigationBarOriginY:[self getStatusBarHight] animated:NO];
    }
}

- (void)setNavigationBarOriginY:(CGFloat)y animated:(BOOL)animated{
    CGFloat statusBarHeight         = [self getStatusBarHight]; //状态栏高度
    UIWindow *keyWindow             = [UIApplication sharedApplication].keyWindow;
    UIView *appBaseView             = keyWindow.rootViewController.view;
    CGRect viewControllerFrame      = [appBaseView convertRect:appBaseView.bounds toView:keyWindow];
    CGFloat overwrapStatusBarHeight = statusBarHeight - viewControllerFrame.origin.y;
    CGRect frame                    = self.baseViewController.navigationController.navigationBar.frame;
    frame.origin.y                  = y;
    CGFloat navBarHiddenRatio       = overwrapStatusBarHeight > 0 ? (overwrapStatusBarHeight - frame.origin.y) / overwrapStatusBarHeight : 0;
    CGFloat alpha                   = MAX(1.f - navBarHiddenRatio, 0.000001f);
    [UIView animateWithDuration:animated ? 0.1 : 0 animations:^{
        self.baseViewController.navigationController.navigationBar.frame = frame;
        NSUInteger index = 0;
        for (UIView *view in self.baseViewController.navigationController.navigationBar.subviews) {
            index++;
            if (index == 1 || view.hidden || view.alpha <= 0.0f) continue;
            view.alpha = alpha;
        }
        UIColor *tintColor = self.baseViewController.navigationController.navigationBar.tintColor;
        if (tintColor) {
            self.baseViewController.navigationController.navigationBar.tintColor = [tintColor colorWithAlphaComponent:alpha];
        }
    }];
}

- (UIImage *)screenSnapshotWindow{
    
    UIView *view = [UIApplication sharedApplication].keyWindow;
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, 0);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImage * img = [[UIImage alloc] initWithData:UIImageJPEGRepresentation(image, 0.8)];
    return img;
}



- (CGRect)contentViewFrameWithSize:(CGSize)size{
    
    if (size.height > [UIScreen mainScreen].bounds.size.height) {
        size.height = [UIScreen mainScreen].bounds.size.height;
    }
    if (size.width > [UIScreen mainScreen].bounds.size.width) {
        size.width = [UIScreen mainScreen].bounds.size.width;
    }
    return CGRectMake((CGRectGetWidth(self.frame)-size.width)/2.0, CGRectGetHeight(self.frame), size.width, size.height);
}

- (CGFloat)getStatusBarHight {
   CGFloat statusBarHeight = 0;
   if (@available(iOS 13.0, *)) {
       UIStatusBarManager *statusBarManager = [UIApplication sharedApplication].windows.firstObject.windowScene.statusBarManager;
       statusBarHeight = statusBarManager.statusBarFrame.size.height;
   } else {
       statusBarHeight = [UIApplication sharedApplication].statusBarFrame.size.height;
   }
   return statusBarHeight;
}

- (UIView *)contentView{
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:CGRectZero];
        _contentView.backgroundColor = [UIColor redColor];
    }
    return _contentView;
}

- (UIControl *)closeControl{
    if (_closeControl == nil) {
        _closeControl = [[UIControl alloc] initWithFrame:self.bounds];
        _closeControl.userInteractionEnabled = NO;
        [_closeControl addTarget:self action:@selector(close) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeControl;
}

- (UIImageView *)maskImageView{
    if (_maskImageView == nil) {
        _maskImageView = [[UIImageView alloc] initWithFrame:self.bounds];
    }
    return _maskImageView;
}


@end
