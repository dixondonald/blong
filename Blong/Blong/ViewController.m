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
@property (nonatomic, strong) UIView *extraBallView;
@property (nonatomic, strong) UIView *thirdBallView;
@property (nonatomic, strong) UIView *leftPaddleView;
@property (nonatomic, strong) UIView *rightPaddleView;
@property (nonatomic, strong) UIPanGestureRecognizer *leftPaddleGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *rightPaddleGesture;

@property (nonatomic, strong) UICollisionBehavior *collisionBehavior;
@property (nonatomic, strong) UIPushBehavior *pushBehavior;
@property (nonatomic, strong) UIPushBehavior *extraPushBehavior;
@property (nonatomic, strong) UIPushBehavior *thirdPushBehavior;

@property (nonatomic, strong) UIDynamicItemBehavior *leftPaddleBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *rightPaddleBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *ballBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *extraBallBehavior;
@property (nonatomic, strong) UIDynamicItemBehavior *thirdBallBehavior;

@property (nonatomic, strong) UIImageView *bgView;

@property (nonatomic, strong) NSArray *angles;

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *scoreLabel;

@property BOOL isBall;
@property BOOL isExtraBall;
@property BOOL isThirdBall;

@property NSInteger ballAmount;
@property NSInteger count;
@property NSInteger score;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.animator = [[UIDynamicAnimator new] initWithReferenceView:self.view];
    self.ballAmount = 0;
    
    self.angles = [[NSArray alloc] initWithObjects:@1.0f, @2.5f, @4.0f, @5.35f, @7.0f, @8.5f, @10.15f, @11.75f, nil];
    
    self.bgView = [[UIImageView alloc] initWithImage:[UIImage animatedImageNamed:@"pong-" duration:1.0f]
];
    self.bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.bgView];
   
    
    CGRect countRect = CGRectMake(self.view.frame.size.width / 2 - 12, self.view.frame.size.height / 2 - 10, 50, 50);
    self.countLabel = [[UILabel alloc] initWithFrame:countRect];
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:40];
    [self.view addSubview:self.countLabel];

    CGRect scoreRect = CGRectMake(self.view.frame.size.width / 2 - 12, 20, 50, 50);
    self.scoreLabel = [[UILabel alloc] initWithFrame:scoreRect];
    self.scoreLabel.textColor = [UIColor whiteColor];
    self.scoreLabel.font = [UIFont fontWithName:@"Menlo-Bold" size:40];
    self.score = 0;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
    [self.view addSubview:self.scoreLabel];

    
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
    self.ballBehavior.elasticity = 1.015;
    self.ballBehavior.friction = 0;
    self.ballBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.ballBehavior];
    self.ballAmount++;
    self.isBall = YES;
    
    [self.collisionBehavior addItem:self.ballView];
    
}

- (void)createExtraBall {
    CGRect extraBallRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 16, 16);
    self.extraBallView = [[UIView alloc] initWithFrame:extraBallRect];
    self.extraBallView.backgroundColor = [UIColor whiteColor];
    self.extraBallView.layer.cornerRadius = 8;
    [self.view addSubview:self.extraBallView];
    
    self.extraBallBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.extraBallView]];
    self.extraBallBehavior.resistance = 0;
    self.extraBallBehavior.elasticity = 1.015;
    self.extraBallBehavior.friction = 0;
    self.extraBallBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.extraBallBehavior];
    self.ballAmount++;
    self.isExtraBall = YES;
    
    [self.collisionBehavior addItem:self.extraBallView];
    
}

- (void)createThirdBall {
    CGRect thirdBallRect = CGRectMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2, 16, 16);
    self.thirdBallView = [[UIView alloc] initWithFrame:thirdBallRect];
    self.thirdBallView.backgroundColor = [UIColor whiteColor];
    self.thirdBallView.layer.cornerRadius = 8;
    [self.view addSubview:self.thirdBallView];
    
    self.thirdBallBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.thirdBallView]];
    self.thirdBallBehavior.resistance = 0;
    self.thirdBallBehavior.elasticity = 1.015;
    self.thirdBallBehavior.friction = 0;
    self.thirdBallBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.thirdBallBehavior];
    self.ballAmount++;
    self.isThirdBall = YES;
    
    [self.collisionBehavior addItem:self.thirdBallView];
    
}


- (void)removeBall {
    [self.animator removeBehavior:self.ballBehavior];
    [self.collisionBehavior removeItem:self.ballView];
    [self.ballView removeFromSuperview];
    self.ballAmount--;
    self.isBall = NO;
}

- (void)removeExtraBall {
    [self.animator removeBehavior:self.extraBallBehavior];
    [self.collisionBehavior removeItem:self.extraBallView];
    [self.extraBallView removeFromSuperview];
    self.ballAmount--;
    self.isExtraBall = NO;
}

- (void)removeThirdBall {
    [self.animator removeBehavior:self.thirdBallBehavior];
    [self.collisionBehavior removeItem:self.thirdBallView];
    [self.thirdBallView removeFromSuperview];
    self.ballAmount--;
    self.isThirdBall = NO;
}

- (void) pushBall {
    float randomAngle = [self.angles[arc4random_uniform(self.angles.count)] floatValue];
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.angle = randomAngle;
    self.pushBehavior.magnitude = 0.11;
    self.pushBehavior.active = YES;
    [self.animator addBehavior:self.pushBehavior];
}

- (void) pushExtraBall {
    float randomAngle = [self.angles[arc4random_uniform(self.angles.count)] floatValue];
    self.extraPushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.extraBallView] mode:UIPushBehaviorModeInstantaneous];
    self.extraPushBehavior.angle = randomAngle;
    self.extraPushBehavior.magnitude = 0.11;
    self.extraPushBehavior.active = YES;
    [self.animator addBehavior:self.extraPushBehavior];
}

- (void) pushThirdBall {
    float randomAngle = [self.angles[arc4random_uniform(self.angles.count)] floatValue];
    self.thirdPushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.thirdBallView] mode:UIPushBehaviorModeInstantaneous];
    self.thirdPushBehavior.angle = randomAngle;
    self.thirdPushBehavior.magnitude = 0.11;
    self.thirdPushBehavior.active = YES;
    [self.animator addBehavior:self.thirdPushBehavior];
}



- (void) startTimer {
    self.count = 4;
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(countdownTimer:) userInfo:nil repeats:YES];
}

-(void) countdownTimer:(NSTimer*)timer{

    self.count--;
    self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)self.count];
    self.score = 0;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
        if (self.count == 0) {
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
        if (item == self.ballView) {
            [self removeBall];
            if (self.ballAmount == 0) {
                [self startTimer];
                
            }
        }
        if (item == self.extraBallView) {
            [self removeExtraBall];
            if (self.ballAmount == 0) {
                [self startTimer];
                
            }
        }
        if (item == self.thirdBallView) {
            [self removeThirdBall];
            if (self.ballAmount == 0) {
                [self startTimer];
                
            }
        }

    }
}

-(void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id)item1 withItem:(id)item2 atPoint:(CGPoint)p{
    
    if ((item1 == self.ballView || item2 == self.ballView) && (item1 == self.leftPaddleView || item2 == self.leftPaddleView)) {
        if (p.x > self.leftPaddleView.frame.origin.x + self.leftPaddleView.frame.size.width) {
            [self bgChange];
            NSLog(@"left hit");
            self.score++;
            self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
            if (self.score % 10 == 0) {
                if (self.isBall == NO) {
                    [self createBall];
                    [self pushBall];
                }
                else if (self.isExtraBall == NO) {
                    [self createExtraBall];
                    [self pushExtraBall];
                }
                else if (self.isThirdBall == NO) {
                    [self createThirdBall];
                    [self pushThirdBall];
                }
            }
        }
    }
    else if ((item1 == self.ballView || item2 == self.ballView) && (item1 == self.rightPaddleView || item2 == self.rightPaddleView)) {
        if (p.x < self.rightPaddleView.frame.origin.x) {
            [self bgChange];
            NSLog(@"right hit");
            self.score++;
            self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
            if (self.score % 10 == 0) {
                if (self.isBall == NO) {
                    [self createBall];
                    [self pushBall];
                }
                else if (self.isExtraBall == NO) {
                    [self createExtraBall];
                    [self pushExtraBall];
                }
                else if (self.isThirdBall == NO) {
                    [self createThirdBall];
                    [self pushThirdBall];
                }
            }
            
        }
    }
    else if ((item1 == self.extraBallView || item2 == self.extraBallView) && (item1 == self.leftPaddleView || item2 == self.leftPaddleView)) {
        if (p.x > self.leftPaddleView.frame.origin.x + self.leftPaddleView.frame.size.width) {
            [self bgChange];
            NSLog(@"left hit");
            self.score++;
            self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
            if (self.score % 10 == 0) {
                if (self.isBall == NO) {
                    [self createBall];
                    [self pushBall];
                }
                else if (self.isExtraBall == NO) {
                    [self createExtraBall];
                    [self pushExtraBall];
                }
                else if (self.isThirdBall == NO) {
                    [self createThirdBall];
                    [self pushThirdBall];
                }
            }
            
        }
    }
    else if ((item1 == self.extraBallView || item2 == self.extraBallView) && (item1 == self.rightPaddleView || item2 == self.rightPaddleView)) {
        if (p.x < self.rightPaddleView.frame.origin.x) {
            [self bgChange];
            NSLog(@"right hit");
            self.score++;
            self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
            if (self.score % 10 == 0) {
                if (self.isBall == NO) {
                    [self createBall];
                    [self pushBall];
                }
                else if (self.isExtraBall == NO) {
                    [self createExtraBall];
                    [self pushExtraBall];
                }
                else if (self.isThirdBall == NO) {
                    [self createThirdBall];
                    [self pushThirdBall];
                }
            }
            
        }
    }
    else if ((item1 == self.thirdBallView || item2 == self.thirdBallView) && (item1 == self.leftPaddleView || item2 == self.leftPaddleView)) {
        if (p.x > self.leftPaddleView.frame.origin.x + self.leftPaddleView.frame.size.width) {
            [self bgChange];
            NSLog(@"left hit");
            self.score++;
            self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
            if (self.score % 10 == 0) {
                if (self.isBall == NO) {
                    [self createBall];
                    [self pushBall];
                }
                else if (self.isExtraBall == NO) {
                    [self createExtraBall];
                    [self pushExtraBall];
                }
                else if (self.isThirdBall == NO) {
                    [self createThirdBall];
                    [self pushThirdBall];
                }
            }
        }
    }
    else if ((item1 == self.thirdBallView || item2 == self.thirdBallView) && (item1 == self.rightPaddleView || item2 == self.rightPaddleView)) {
        if (p.x < self.rightPaddleView.frame.origin.x) {
            [self bgChange];
            NSLog(@"right hit");
            self.score++;
            self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
            if (self.score % 10 == 0) {
                if (self.isBall == NO) {
                    [self createBall];
                    [self pushBall];
                }
                else if (self.isExtraBall == NO) {
                    [self createExtraBall];
                    [self pushExtraBall];
                }
                else if (self.isThirdBall == NO) {
                    [self createThirdBall];
                    [self pushThirdBall];
                }
            }
        }
    }
    
}

- (void)bgChange {
//    self.bgView.image = [UIImage animatedImageNamed:@"pongbg-" duration:1.0f];
    [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(bgChangeBack) userInfo:nil repeats:NO];
}

- (void)bgChangeBack
{
//    self.bgView.image = [UIImage animatedImageNamed:@"pong-" duration:1.0f];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
