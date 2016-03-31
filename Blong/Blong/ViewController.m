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
@property (nonatomic, strong) UIView *leftPaddleView;
@property (nonatomic, strong) UIView *rightPaddleView;
@property (nonatomic, strong) UIPanGestureRecognizer *leftPaddleGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *rightPaddleGesture;

@property (nonatomic, strong) UIGravityBehavior *gravityBehavior;
@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *leftPaddleBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *rightPaddleBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *ballBehavior;

@property (nonatomic, strong) UILabel *countLabel;
@property NSInteger count;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animator = [[UIDynamicAnimator new] initWithReferenceView:self.view];
    
    UIImageView *bgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pongbg"]];
    bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:bgView];
   
    
    CGRect countRect = CGRectMake(self.view.frame.size.width / 2 - 10, self.view.frame.size.height / 2 - 10, 50, 50);
    self.countLabel = [[UILabel alloc] initWithFrame:countRect];
    self.countLabel.textColor = [UIColor whiteColor];
    [[self countLabel] setFont:[UIFont fontWithName:@"Futura-Medium" size:40]];

    [self.view addSubview:self.countLabel];

    
    [self createBall];
    [self pushBall];
    
    
    CGRect leftPaddleRect = CGRectMake(10, self.view.bounds.size.height / 2, 40, 60);
    self.leftPaddleView = [[UIView alloc] initWithFrame:leftPaddleRect];
    self.leftPaddleView.backgroundColor = [UIColor whiteColor];
    self.leftPaddleView.layer.cornerRadius = 5;
    [self.view addSubview:self.leftPaddleView];
    
    
    CGRect rightPaddleRect = CGRectMake(self.view.bounds.size.width - 50, self.view.bounds.size.height / 2, 40, 60);
    self.rightPaddleView = [[UIView alloc] initWithFrame:rightPaddleRect];
    self.rightPaddleView.backgroundColor = [UIColor whiteColor];
    self.rightPaddleView.layer.cornerRadius = 5;
    [self.view addSubview:self.rightPaddleView];
    
    
    self.leftPaddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.leftPaddleView]];
    self.leftPaddleBehavior.density = 1000;
    self.leftPaddleBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.leftPaddleBehavior];
    
    
    self.leftPaddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.rightPaddleView]];
    self.leftPaddleBehavior.density = 1000;
    self.leftPaddleBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.leftPaddleBehavior];
    
    
    self.collisionBehavior = [[UICollisionBehavior alloc] initWithItems:@[self.ballView, self.leftPaddleView, self.rightPaddleView]];
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = NO;
    [self.collisionBehavior addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(1, 1) toPoint:CGPointMake(self.view.frame.size.width - 1, 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(1, self.view.frame.size.height - 1) toPoint:CGPointMake(self.view.frame.size.width - 1, self.view.frame.size.height - 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"right" fromPoint:CGPointMake(self.view.frame.size.width - 1, 1) toPoint:CGPointMake(self.view.frame.size.width - 1, self.view.frame.size.height - 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"left" fromPoint:CGPointMake(1, 1) toPoint:CGPointMake(1, self.view.frame.size.height - 1)];
    [self.animator addBehavior:self.collisionBehavior];

    
    self.leftPaddleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(leftPanFired:)];
    [self.leftPaddleView addGestureRecognizer:self.leftPaddleGesture];
    
    self.rightPaddleGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(rightPanFired:)];
    [self.rightPaddleView addGestureRecognizer:self.rightPaddleGesture];
    
}


- (void) leftPanFired:(UIPanGestureRecognizer *)recognizer {
        CGPoint newPaddleCenter = [recognizer locationInView:self.view];
    self.leftPaddleView.center = CGPointMake(self.leftPaddleView.center.x, newPaddleCenter.y);
        [self.animator updateItemUsingCurrentState:self.leftPaddleView];
}

- (void) rightPanFired:(UIPanGestureRecognizer *)recognizer {
    CGPoint newPaddleCenter = [recognizer locationInView:self.view];
    self.rightPaddleView.center = CGPointMake(self.rightPaddleView.center.x, newPaddleCenter.y);
    [self.animator updateItemUsingCurrentState:self.rightPaddleView];
}


- (void)createBall {
    CGRect ballRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 16, 16);
    self.ballView = [[UIView alloc] initWithFrame:ballRect];
    self.ballView.backgroundColor = [UIColor whiteColor];
    self.ballView.layer.cornerRadius = 8;
    [self.view addSubview:self.ballView];
    
    self.ballBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.ballView]];
    self.ballBehavior.resistance = 0;
    self.ballBehavior.elasticity = 1.025;
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
    self.pushBehavior.magnitude = 0.10;
    self.pushBehavior.active = YES;
    [self.animator addBehavior:self.pushBehavior];
}

- (void) startTimer {
    self.count = 4;
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(countdownTimer:) userInfo:nil repeats:YES];
}

-(void) countdownTimer:(NSTimer*)timer{

    self.count--;
    self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)self.count];
        NSLog(@"%ld", (long)self.count);
        if (self.count == 0) {
            NSLog(@"go");
            self.countLabel.text = @"";
            [timer invalidate];
            [self createBall];
            [self pushBall];
        
    }
}

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id<UIDynamicItem>)item
   withBoundaryIdentifier:(id<NSCopying>)identifier atPoint:(CGPoint)p {
   NSString *boundary = (NSString *)identifier;
    if ([boundary isEqualToString:@"right"] || [boundary isEqualToString:@"left"]) {
        [self removeBall];
        [self startTimer];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
