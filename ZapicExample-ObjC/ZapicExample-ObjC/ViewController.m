//
//  ViewController.m
//  ZapicExample-ObjC
//
//  Created by Daniel Sarfati on 7/12/18.
//  Copyright © 2018 Zapic. All rights reserved.
//

#import "ViewController.h"
#import "Zapic/Zapic.h"

@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  // Do any additional setup after loading the view, typically from a nib.
}

- (void) viewDidAppear:(BOOL)animated{
  //  [Zapic performSelector:@selector(showDefaultPage) withObject:nil afterDelay:3];
//    [Zapic showDefaultPage];
//  [Zapic submitEvent:@{ @"Distance": @147,@"Score":@22}];
}


- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
  [Zapic showDefaultPage];
  [Zapic submitEvent:@{ @"Distance": @147,@"Score":@22}];
}


@end
