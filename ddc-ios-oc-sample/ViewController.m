//
//  ViewController.m
//  ddc-ios-oc-sample
//
//  Created by Shifeng Wang on 19/12/2017.
//  Copyright © 2017 dynamsoft. All rights reserved.
//

#import "ViewController.h"
#import "domain.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    terminalView.preferredMaxLayoutWidth = self.view.frame.size.width - 40;
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        domain(^(NSString* str){
            // a simple way show log, but not secure
            NSString* nstr = [terminalView text];
            nstr = [nstr stringByAppendingString:str];
            [terminalView setText:nstr];
        });
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
