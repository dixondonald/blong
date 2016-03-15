//
//  ViewController.m
//  Blong
//
//  Created by Ziggy on 3/14/16.
//  Copyright © 2016 Ziggy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView *ballView;
@property (nonatomic, strong) UIView *paddleView;
@property (nonatomic, strong) UIView *AIPaddleView;
@property (nonatomic, strong) UIPanGestureRecognizer *paddleGesture;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animator = [[UIDynamicAnimator new] initWithReferenceView:self.view];
    
    CGRect ballRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 16, 16);
    self.ballView = [[UIView alloc] initWithFrame:ballRect];
    self.ballView.backgroundColor = [UIColor blackColor];
    self.ballView.layer.cornerRadius = 8;
    [self.view addSubview:self.ballView];
    
    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.ballView]];
    [self.animator addBehavior:self.gravityBehavior];
   
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ballView]];
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = YES;
    [self.animator addBehavior:self.collisionBehavior];

    CGRect paddleRect = CGRectMake(20, self.view.bounds.size.height / 2, 10, 50);
    self.paddleView = [[UIView alloc] initWithFrame:paddleRect];
    self.paddleView.backgroundColor = [UIColor blackColor];
    self.paddleView.layer.cornerRadius = 5;
    [self.view addSubview:self.paddleView];
    
    CGRect AIPaddleRect = CGRectMake(self.view.bounds.size.width - 30, self.view.bounds.size.height / 2, 10, 50);
    self.AIPaddleView = [[UIView alloc] initWithFrame:AIPaddleRect];
    self.AIPaddleView.backgroundColor = [UIColor blackColor];
    self.AIPaddleView.layer.cornerRadius = 5;
    [self.view addSubview:self.AIPaddleView];
    
    self.paddleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
    [self.view addGestureRecognizer:self.paddleGesture];
//    [self.paddleView addGestureRecognizer:self.paddleGesture];
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    CGPoint newPaddleCenter = [recognizer locationInView:self.view];
    self.paddleView.center = CGPointMake(self.paddleView.center.x, newPaddleCenter.y);

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
