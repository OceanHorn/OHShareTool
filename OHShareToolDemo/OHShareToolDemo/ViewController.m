//
//  ViewController.m
//  OHShareToolDemo
//
//  Created by 郭玉富 on 16/5/5.
//  Copyright © 2016年 郭玉富. All rights reserved.
//

#import "ViewController.h"
#import "OHShareTool.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [[OHShareTool sharedTool] shareTitle:@"dede" text:@"dede" shareURL:@"dede" imageURL:@"dd" delegate:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
