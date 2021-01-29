//
//  ViewController.m
//  JJSemiModalViewExample
//
//  Created by 播呗网络 on 2021/1/28.
//

#import "ViewController.h"
#import "JJSemiModalView.h"

@interface ViewController ()
@property (nonatomic, strong) JJSemiModalView *normalModalView;
@property (nonatomic, strong) JJSemiModalView *narrowedModalView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIView *backView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    backView.backgroundColor = [UIColor whiteColor];
    [self.view insertSubview:backView atIndex:0];
    
    self.title = @"JJSemiModalView";
    self.view.backgroundColor = [UIColor whiteColor];
    self.normalModalView = [[JJSemiModalView alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, 300) andBaseViewController:self];
//    self.normalModalView.contentView.backgroundColor = [UIColor yellowColor];
    self.normalModalView.narrowedOff = YES;
   
    self.narrowedModalView = [[JJSemiModalView alloc] initWithSize:CGSizeMake(self.view.bounds.size.width, 300) andBaseViewController:self];
//    self.narrowedModalView.contentView.backgroundColor = [UIColor redColor];
    
}
- (IBAction)normalClick:(UIButton *)sender {
    [self.normalModalView open];

}

- (IBAction)narrowedClick:(UIButton *)sender {
    [self.narrowedModalView open];

}

@end
