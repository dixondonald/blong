//
//  ViewController.m
//  Blong
//
//  Created by Ziggy on 3/14/16.
//  Copyright © 2016 Ziggy. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UICollisionBehaviorDelegate>

@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIView *ballView;
@property (nonatomic, strong) UIView *paddleView;
@property (nonatomic, strong) UIView *AIPaddleView;
@property (nonatomic, strong) UIPanGestureRecognizer *paddleGesture;
@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *paddleBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *AIPaddleBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *ballBehavior;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animator = [[UIDynamicAnimator new] initWithReferenceView:self.view];
    
   
    [self createBall];
    [self pushBall];


//    self.gravityBehavior = [[UIGravityBehavior alloc] initWithItems:@[self.ballView]];
//    self.gravityBehavior.magnitude = 0.5;
//    [self.animator addBehavior:self.gravityBehavior];
   
    
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
    
    
    self.paddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.paddleView]];
    self.paddleBehavior.density = 1000;
    self.paddleBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.paddleBehavior];
    
    
    self.AIPaddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.AIPaddleView]];
    self.AIPaddleBehavior.density = 1000;
    self.AIPaddleBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.AIPaddleBehavior];
    
    
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ballView, self.paddleView, self.AIPaddleView]];
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = NO;
    [self.collisionBehavior addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(1, 1) toPoint:CGPointMake(self.view.frame.size.width - 1, 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(1, self.view.frame.size.height - 1) toPoint:CGPointMake(self.view.frame.size.width - 1, self.view.frame.size.height - 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"right" fromPoint:CGPointMake(self.view.frame.size.width - 1, 1) toPoint:CGPointMake(self.view.frame.size.width - 1, self.view.frame.size.height - 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"left" fromPoint:CGPointMake(1, 1) toPoint:CGPointMake(1, self.view.frame.size.height - 1)];
    [self.animator addBehavior:self.collisionBehavior];

    
    self.paddleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
//    [self.view addGestureRecognizer:self.paddleGesture];
    [self.paddleView addGestureRecognizer:self.paddleGesture];
    
    
}


- (void) panFired:(UIPanGestureRecognizer *)recognizer {
  //  if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint newPaddleCenter = [recognizer locationInView:self.view];
        self.paddleView.center = CGPointMake(self.paddleView.center.x, newPaddleCenter.y);
        [self.animator updateItemUsingCurrentState:self.paddleView];
  //  }
}

- (void)createBall {
    CGRect ballRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 16, 16);
    self.ballView = [[UIView alloc] initWithFrame:ballRect];
    self.ballView.backgroundColor = [UIColor blackColor];
    self.ballView.layer.cornerRadius = 8;
    [self.view addSubview:self.ballView];
    
    self.ballBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
    self.ballBehavior.resistance = 0;
    self.ballBehavior.elasticity = 1;
    self.ballBehavior.friction = 0;
    self.ballBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.ballBehavior];
    
    [self.collisionBehavior addItem:self.ballView];
    
}

- (void)removeBall {
    [self.animator removeBehavior:self.ballBehavior];
    [self.collisionBehavior removeItem:self.ballView];
    [self.ballView removeFromSuperview];
}

- (void) pushBall {
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.angle = 4.05;
    self.pushBehavior.magnitude = 0.08;
    self.pushBehavior.active = YES;
    [self.animator addBehavior:self.pushBehavior];
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
   NSString *boundary = (NSString *)identifier;
    if ([boundary isEqualToString:@"top"]) {
        NSLog(@"top hit");
    }
    else if ([boundary isEqualToString:@"bottom"]) {
        NSLog(@"bottom hit");
    }
    else if ([boundary isEqualToString:@"right"]) {
        NSLog(@"right hit");
        [self removeBall];
        [self createBall];
        [self pushBall];
    }
    else if ([boundary isEqualToString:@"left"]) {
        NSLog(@"left hit");
        [self removeBall];
        [self createBall];
        [self pushBall];
    }

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
