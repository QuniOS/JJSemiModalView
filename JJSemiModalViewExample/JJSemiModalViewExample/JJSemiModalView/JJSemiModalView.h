//
//  JJSemiModalView.h
//  JJSemiModalViewExample
//
//  Created by 播呗网络 on 2021/1/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef void (^SemiModalViewWillCloseBlock)(void);
typedef void (^SemiModalViewDidCloseBlock)(void);


@interface JJSemiModalView : UIView

@property (nonatomic, copy) SemiModalViewWillCloseBlock semiModalViewWillCloseBlock;
@property (nonatomic, copy) SemiModalViewDidCloseBlock semiModalViewDidCloseBlock;


@property (nonatomic, assign) BOOL narrowedOff;

- (instancetype)initWithSize:(CGSize)size andBaseViewController:(UIViewController *)baseViewController;
- (void)close;
- (void)open;

@end

NS_ASSUME_NONNULL_END
