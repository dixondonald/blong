//
//  ViewController.m
//  Blong
//
//  Created by Ziggy on 3/14/16.
//  Copyright © 2016 Ziggy. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <GameKit/GameKit.h>
@import GoogleMobileAds;
#import <StoreKit/StoreKit.h>


@interface ViewController () <UICollisionBehaviorDelegate, GKGameCenterControllerDelegate, GADInterstitialDelegate, SKProductsRequestDelegate, SKPaymentTransactionObserver>

-(void)authenticateLocalPlayer;
-(void)reportScore;
-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard;

@property(nonatomic, strong) NSString *leaderboardIdentifier;
@property(nonatomic, assign) BOOL gameCenterEnabled;

@property(nonatomic, strong) GADInterstitial *interstitial;

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
@property (nonatomic, strong) UIImage *anim;

@property (nonatomic, strong) NSArray *angles;
@property (nonatomic) float ballSpeed;

@property(nonatomic, strong) AVAudioPlayer *backgroundMusic;
@property (nonatomic, strong) NSURL *musicFile;

@property(nonatomic, strong) AVAudioPlayer *titleSpeech;
@property (nonatomic, strong) NSURL *speechFile;

@property(nonatomic, strong) AVAudioPlayer *endSound;
@property (nonatomic, strong) NSURL *soundFile;

@property(nonatomic, strong) AVAudioPlayer *countSpeech;
@property (nonatomic, strong) NSURL *countFile;

@property (nonatomic, strong) UILabel *countLabel;
@property (nonatomic, strong) UILabel *scoreLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) UIButton *easyButton;
@property (nonatomic, strong) UIButton *mediumButton;
@property (nonatomic, strong) UIButton *hardButton;
@property (nonatomic, strong) UIButton *harderButton;
@property (nonatomic, strong) UIButton *hardestButton;
@property (nonatomic, strong) UIButton *gcButton;
@property (nonatomic, strong) UIButton *IAPButton;
@property (nonatomic, strong) UIButton *restoreButton;

@property BOOL areAdsRemoved;
@property BOOL isBall;
@property BOOL isExtraBall;
@property BOOL isThirdBall;

@property NSInteger gameCount;

@property NSInteger ballAmount;
@property NSInteger count;
@property NSInteger score;

@property NSTimer *bgTimer;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self authenticateLocalPlayer];
    
    self.interstitial = [self createAndLoadInterstitial];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.gameCount = [defaults integerForKey:@"HighScore"];

    self.areAdsRemoved = [[NSUserDefaults standardUserDefaults] boolForKey:@"areAdsRemoved"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.animator = [[UIDynamicAnimator new] initWithReferenceView:self.view];
    
    self.angles = [[NSArray alloc] initWithObjects:@1.0f, @2.5f, @4.0f, @5.35f, @7.0f, @8.5f, @10.15f, @11.75f, nil];
    self.bgView = [[UIImageView alloc] initWithImage:[UIImage animatedImageNamed:@"pong-" duration:.75f]
];
    self.bgView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:self.bgView];
    self.anim = [UIImage animatedImageNamed:@"pongbg-" duration:1.0f];
    
    [self createMenu];


    CGRect countRect = CGRectMake(self.view.frame.size.width / 2 - 25, self.view.frame.size.height / 2 - 25, 50, 50);
    self.countLabel = [[UILabel alloc] initWithFrame:countRect];
    self.countLabel.textColor = [UIColor whiteColor];
    self.countLabel.textAlignment = NSTextAlignmentCenter;
    self.countLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:50];
    [self.view addSubview:self.countLabel];

    CGRect scoreRect = CGRectMake(self.view.frame.size.width / 2 - 25, 10, 50, 40);
    self.scoreLabel = [[UILabel alloc] initWithFrame:scoreRect];
    self.scoreLabel.textColor = [UIColor whiteColor];
    self.scoreLabel.textAlignment = NSTextAlignmentCenter;
    self.scoreLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    self.score = 0;
    [self.view addSubview:self.scoreLabel];

    self.collisionBehavior = [[UICollisionBehavior alloc] init];
    self.collisionBehavior.collisionDelegate = self;
    self.collisionBehavior.translatesReferenceBoundsIntoBoundary = NO;
    [self.collisionBehavior addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(1, 1) toPoint:CGPointMake(self.view.frame.size.width - 1, 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"bottom" fromPoint:CGPointMake(1, self.view.frame.size.height - 1) toPoint:CGPointMake(self.view.frame.size.width - 1, self.view.frame.size.height - 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"right" fromPoint:CGPointMake(self.view.frame.size.width - 1, 1) toPoint:CGPointMake(self.view.frame.size.width - 1, self.view.frame.size.height - 1)];
    [self.collisionBehavior addBoundaryWithIdentifier:@"left" fromPoint:CGPointMake(1, 1) toPoint:CGPointMake(1, self.view.frame.size.height - 1)];
        [self.animator addBehavior:self.collisionBehavior];
    
}

-(void)viewWillAppear:(BOOL)animated {
    [self bgChange];
}

- (GADInterstitial *)createAndLoadInterstitial {
    self.interstitial =
    [[GADInterstitial alloc] initWithAdUnitID:@"ca-app-pub-3940256099942544/4411468910"];
    self.interstitial.delegate = self;
    [self.interstitial loadRequest:[GADRequest request]];
    return self.interstitial;
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)interstitial {
    self.interstitial = [self createAndLoadInterstitial];
}

- (void)displayAd {
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
    }
}

- (void)startGame {
    [self.backgroundMusic stop];
    self.ballAmount = 0;
    [self removeMenu];
    [self createPaddles];
    [self startTimer];
}

#define kRemoveAdsProductIdentifier @"pongulator_remove_ads"

- (void)removeAds:(UIButton*)sender {
    NSLog(@"User requests to remove ads");
    
    if([SKPaymentQueue canMakePayments]){
        NSLog(@"User can make payments");
        
        SKProductsRequest *productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:[NSSet setWithObject:kRemoveAdsProductIdentifier]];
        productsRequest.delegate = self;
        [productsRequest start];
        
    }
    else{
        NSLog(@"User cannot make payments due to parental controls");
    }
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response{
    SKProduct *validProduct = nil;
    NSUInteger count = [response.products count];
    if(count > 0){
        validProduct = [response.products objectAtIndex:0];
        NSLog(@"Products Available!");
        [self purchase:validProduct];
    }
    else if(!validProduct){
        NSLog(@"No products available");
        //this is called if your product id is not valid, this shouldn't be called unless that happens.
    }
}

- (void)purchase:(SKProduct *)product{
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)restorePurchase:(UIButton*)sender {
    //this is called when the user restores purchases, you should hook this up to a button
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}


- (void) paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
    NSLog(@"received restored transactions: %lu", (unsigned long)queue.transactions.count);
    for(SKPaymentTransaction *transaction in queue.transactions){
        if(transaction.transactionState == SKPaymentTransactionStateRestored){
            //called when the user successfully restores a purchase
            NSLog(@"Transaction state -> Restored");
            
            //if you have more than one in-app purchase product,
            //you restore the correct product for the identifier.
            //For example, you could use
            //if(productID == kRemoveAdsProductIdentifier)
            //to get the product identifier for the
            //restored purchases, you can use
            //
            //NSString *productID = transaction.payment.productIdentifier;
            [self doRemoveAds];
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            break;
        }
    }   
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions{
    for(SKPaymentTransaction *transaction in transactions){
        switch(transaction.transactionState){
            case SKPaymentTransactionStatePurchasing: NSLog(@"Transaction state -> Purchasing");
                //called when the user is in the process of purchasing, do not add any of your own code here.
                break;
            case SKPaymentTransactionStatePurchased:
                //this is called when the user has successfully purchased the package (Cha-Ching!)
                [self doRemoveAds]; //you can add your code for what you want to happen when the user buys the purchase here, for this tutorial we use removing ads
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                NSLog(@"Transaction state -> Purchased");
                break;
            case SKPaymentTransactionStateRestored:
                NSLog(@"Transaction state -> Restored");
                //add the same code as you did from SKPaymentTransactionStatePurchased here
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //called when the transaction does not finish
                if(transaction.error.code == SKErrorPaymentCancelled){
                    NSLog(@"Transaction state -> Cancelled");
                    //the user cancelled the payment ;(
                }
                [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
                break;
        }
    }
}

- (void)doRemoveAds{
    self.areAdsRemoved = YES;
    self.IAPButton.hidden = YES;
    self.IAPButton.enabled = NO;
    self.restoreButton.hidden = YES;
    self.restoreButton.enabled = NO;
    [[NSUserDefaults standardUserDefaults] setBool:self.areAdsRemoved forKey:@"areAdsRemoved"];
    //use NSUserDefaults so that you can load whether or not they bought it
    //it would be better to use KeyChain access, or something more secure
    //to store the user data, because NSUserDefaults can be changed.
    //You're average downloader won't be able to change it very easily, but
    //it's still best to use something more secure than NSUserDefaults.
    //For the purpose of this tutorial, though, we're going to use NSUserDefaults
    [[NSUserDefaults standardUserDefaults] synchronize];
}



- (void)gcOpen:(UIButton*)sender {
    [self showLeaderboardAndAchievements:YES];
}

- (void)easyStart:(UIButton*)sender {
    self.leaderboardIdentifier = @"easy_leaderboard";
    self.ballSpeed = .10;
    self.musicFile = [[NSBundle mainBundle] URLForResource:@"pongulator110"
                                             withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicFile
                                                                  error:nil];
    self.backgroundMusic.volume = .3;
    self.backgroundMusic.numberOfLoops = -1;
    
    [self startGame];
}

- (void)mediumStart:(UIButton*)sender {
    self.leaderboardIdentifier = @"medium_leaderboard";
    self.ballSpeed = .12;
    self.musicFile = [[NSBundle mainBundle] URLForResource:@"pongulator120"
                                             withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicFile
                                                                  error:nil];
    self.backgroundMusic.volume = .3;
    self.backgroundMusic.numberOfLoops = -1;
    
    [self startGame];
}

- (void)hardStart:(UIButton*)sender {
    self.leaderboardIdentifier = @"hard_leaderboard";
    self.ballSpeed = .14;
    self.musicFile = [[NSBundle mainBundle] URLForResource:@"pongulator130"
                                             withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicFile
                                                                  error:nil];
    self.backgroundMusic.volume = .3;
    self.backgroundMusic.numberOfLoops = -1;
    [self startGame];
}

- (void)harderStart:(UIButton*)sender {
    self.leaderboardIdentifier = @"harder_leaderboard";
    self.ballSpeed = .16;
    self.musicFile = [[NSBundle mainBundle] URLForResource:@"pongulator140"
                                             withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicFile
                                                                  error:nil];
    self.backgroundMusic.volume = .3;
    self.backgroundMusic.numberOfLoops = -1;
    [self startGame];
}

- (void)hardestStart:(UIButton*)sender {
    self.leaderboardIdentifier = @"hardest_leaderboard";
    self.ballSpeed = .18;
    self.musicFile = [[NSBundle mainBundle] URLForResource:@"pongulator150"
                                             withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicFile
                                                                  error:nil];
    self.backgroundMusic.volume = .3;
    self.backgroundMusic.numberOfLoops = -1;
    [self startGame];
}

- (void)gameRetry:(UIButton*)sender {
    [self.retryButton removeFromSuperview];
    [self.menuButton removeFromSuperview];
    [self startTimer];
}

- (void)gameMenu:(UIButton*)sender {
    self.scoreLabel.text = @"";
    [self removePaddles];
    [self.retryButton removeFromSuperview];
    [self.menuButton removeFromSuperview];
    [self createMenu];
}


- (void)createPaddles {
    CGRect leftPaddleRect = CGRectMake(5, self.view.bounds.size.height / 2 - 30, 40, 60);
    self.leftPaddleView = [[UIView alloc] initWithFrame:leftPaddleRect];
    self.leftPaddleView.backgroundColor = [UIColor whiteColor];
    [self.leftPaddleView setAlpha:0.85];
    self.leftPaddleView.layer.cornerRadius = 2;
    [self.view addSubview:self.leftPaddleView];
    
    CGRect rightPaddleRect = CGRectMake(self.view.bounds.size.width - 45, self.view.bounds.size.height / 2 - 30, 40, 60);
    self.rightPaddleView = [[UIView alloc] initWithFrame:rightPaddleRect];
    self.rightPaddleView.backgroundColor = [UIColor whiteColor];
    [self.rightPaddleView setAlpha:0.85];
    self.rightPaddleView.layer.cornerRadius = 2;
    [self.view addSubview:self.rightPaddleView];
    
    self.leftPaddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.leftPaddleView]];
    self.leftPaddleBehavior.density = 1000;
    self.leftPaddleBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.leftPaddleBehavior];
    [self.collisionBehavior addItem:self.leftPaddleView];

    self.rightPaddleBehavior = [[UIDynamicItemBehavior alloc] initWithItems:@[self.rightPaddleView]];
    self.rightPaddleBehavior.density = 1000;
    self.rightPaddleBehavior.allowsRotation = NO;
    [self.animator addBehavior:self.rightPaddleBehavior];
    [self.collisionBehavior addItem:self.rightPaddleView];
    
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

- (void)createMenu {
    
    self.speechFile = [[NSBundle mainBundle] URLForResource:@"pongulatorspeech"
                                             withExtension:@"mp3"];
    self.titleSpeech = [[AVAudioPlayer alloc] initWithContentsOfURL:self.speechFile
                                                                        error:nil];
    self.titleSpeech.volume = .5;
    self.titleSpeech.numberOfLoops = 0;
    [self.titleSpeech play];
    
    
    double delayInSeconds = .6;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    
    self.musicFile = [[NSBundle mainBundle] URLForResource:@"pongulatormenu"
                                             withExtension:@"mp3"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:self.musicFile
                                                                  error:nil];
    self.backgroundMusic.volume = .3;
    self.backgroundMusic.numberOfLoops = -1;
    [self.backgroundMusic play];
        
        CGRect easyRect = CGRectMake(self.view.frame.size.width / 2 - 90, self.view.frame.size.height / 2 - 80, 180, 40);
        self.easyButton = [[UIButton alloc] initWithFrame:easyRect];
        [self.easyButton addTarget:self
                            action:@selector(easyStart:)
                  forControlEvents:UIControlEventTouchUpInside];
        //    [self.easyButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:.5]];
        //    [self.easyButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.easyButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.easyButton setTitle:@"EASY" forState:UIControlStateNormal];
        self.easyButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        [self.view addSubview:self.easyButton];
        
        CGRect mediumRect = CGRectMake(self.view.frame.size.width / 2 - 90, self.view.frame.size.height / 2 - 30, 180, 40);
        self.mediumButton = [[UIButton alloc] initWithFrame:mediumRect];
        [self.mediumButton addTarget:self
                              action:@selector(mediumStart:)
                    forControlEvents:UIControlEventTouchUpInside];
        //    [self.mediumButton setBackgroundColor:[UIColor whiteColor]];
        //    [self.mediumButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.mediumButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.mediumButton setTitle:@"MEDIUM" forState:UIControlStateNormal];
        self.mediumButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        [self.view addSubview:self.mediumButton];
        
        CGRect hardRect = CGRectMake(self.view.frame.size.width / 2 - 90, self.view.frame.size.height / 2 + 20, 180, 40);
        self.hardButton = [[UIButton alloc] initWithFrame:hardRect];
        [self.hardButton addTarget:self
                            action:@selector(hardStart:)
                  forControlEvents:UIControlEventTouchUpInside];
        //    [self.hardButton setBackgroundColor:[UIColor whiteColor]];
        //    [self.hardButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.hardButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.hardButton setTitle:@"HARD" forState:UIControlStateNormal];
        self.hardButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        [self.view addSubview:self.hardButton];
        
        CGRect harderRect = CGRectMake(self.view.frame.size.width / 2 - 90, self.view.frame.size.height / 2 + 70, 180, 40);
        self.harderButton = [[UIButton alloc] initWithFrame:harderRect];
        [self.harderButton addTarget:self
                              action:@selector(harderStart:)
                    forControlEvents:UIControlEventTouchUpInside];
        //    [self.harderButton setBackgroundColor:[UIColor whiteColor]];
        //    [self.harderButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [self.harderButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.harderButton setTitle:@"HARDER" forState:UIControlStateNormal];
        self.harderButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        [self.view addSubview:self.harderButton];
        
        CGRect hardestRect = CGRectMake(self.view.frame.size.width / 2 - 100, self.view.frame.size.height / 2 + 120, 200, 40);
        self.hardestButton = [[UIButton alloc] initWithFrame:hardestRect];
        [self.hardestButton addTarget:self
                               action:@selector(hardestStart:)
                     forControlEvents:UIControlEventTouchUpInside];
        //    [self.hardestButton setBackgroundColor:[UIColor whiteColor]];
        //    [self.hardestButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [self.hardestButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [self.hardestButton setTitle:@"HARDEST" forState:UIControlStateNormal];
        self.hardestButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
        [self.view addSubview:self.hardestButton];
        
    });
    
    CGRect gcRect = CGRectMake(self.view.frame.size.width -122, self.view.frame.size.height - 28, 120, 25);
    self.gcButton = [[UIButton alloc] initWithFrame:gcRect];
    [self.gcButton addTarget:self
                        action:@selector(gcOpen:)
              forControlEvents:UIControlEventTouchUpInside];
    //    [self.gcButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:.5]];
    //    [self.gcButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.gcButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.gcButton setTitle:@"gamecenter" forState:UIControlStateNormal];
    self.gcButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25];
    [self.view addSubview:self.gcButton];
    

    CGRect IAPRect = CGRectMake(2, self.view.frame.size.height - 48, 120, 25);
    self.IAPButton = [[UIButton alloc] initWithFrame:IAPRect];
    [self.IAPButton addTarget:self
                       action:@selector(removeAds:)
             forControlEvents:UIControlEventTouchUpInside];
    //    [self.IAPButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:.5]];
    //    [self.IAPButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.IAPButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [self.IAPButton setTitle:@"remove ads" forState:UIControlStateNormal];
    self.IAPButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:25];
    [self.view addSubview:self.IAPButton];
    
    if (self.areAdsRemoved) {
        self.IAPButton.hidden = YES;
        self.IAPButton.enabled = NO;
    }
    

    CGRect restoreRect = CGRectMake(2, self.view.frame.size.height - 23, 138, 20);
    self.restoreButton = [[UIButton alloc] initWithFrame:restoreRect];
    [self.restoreButton addTarget:self
                       action:@selector(restorePurchase:)
             forControlEvents:UIControlEventTouchUpInside];
    //    [self.IAPButton setBackgroundColor:[UIColor colorWithWhite:1 alpha:.5]];
    //    [self.IAPButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.restoreButton.titleLabel setTextAlignment:NSTextAlignmentLeft];
//    [self.restoreButton.titleLabel setLineBreakMode:NSLineBreakByCharWrapping];
    [self.restoreButton setTitle:@"restore purchase" forState:UIControlStateNormal];
    self.restoreButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:20];
    [self.view addSubview:self.restoreButton];

    if (self.areAdsRemoved) {
        self.restoreButton.hidden = YES;
        self.restoreButton.enabled = NO;
    }
    
    CGRect titleRect = CGRectMake(self.view.frame.size.width / 2 - 250, 10, 500, 75);
    self.titleLabel = [[UILabel alloc] initWithFrame:titleRect];
    self.titleLabel.textColor = [UIColor colorWithRed:(255/255.0) green:(255/255.0) blue:(255/255.0) alpha:.90];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.font = [UIFont fontWithName:@"Futura" size:65];
    self.titleLabel.text = @"PONGULATOR";
    self.score = 0;
    [self.view addSubview:self.titleLabel];

    
    
}

-(void)removeMenu {
    [self.restoreButton removeFromSuperview];
    [self.IAPButton removeFromSuperview];
    [self.gcButton removeFromSuperview];
    [self.titleLabel removeFromSuperview];
    [self.easyButton removeFromSuperview];
    [self.mediumButton removeFromSuperview];
    [self.hardButton removeFromSuperview];
    [self.harderButton removeFromSuperview];
    [self.hardestButton removeFromSuperview];
}

- (void)retryMenu {
    
    CGRect retryRect = CGRectMake(self.view.frame.size.width / 2 - 125, self.view.frame.size.height / 2 - 60, 250, 80);
    self.retryButton = [[UIButton alloc] initWithFrame:retryRect];
    [self.retryButton addTarget:self
                        action:@selector(gameRetry:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.retryButton setTitle:@"RETRY" forState:UIControlStateNormal];
    self.retryButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:60];
    [self.view addSubview:self.retryButton];

    CGRect menuRect = CGRectMake(self.view.frame.size.width / 2 - 150, self.view.frame.size.height / 2 + 20, 300, 40);
    self.menuButton = [[UIButton alloc] initWithFrame:menuRect];
    [self.menuButton addTarget:self
                        action:@selector(gameMenu:)
              forControlEvents:UIControlEventTouchUpInside];
    [self.menuButton setTitle:@"MAIN MENU" forState:UIControlStateNormal];
    self.menuButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:40];
    [self.view addSubview:self.menuButton];

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

- (void)removePaddles {
    [self.animator removeBehavior:self.leftPaddleBehavior];
    [self.animator removeBehavior:self.rightPaddleBehavior];
    [self.collisionBehavior removeItem:self.leftPaddleView];
    [self.collisionBehavior removeItem:self.rightPaddleView];
    [self.leftPaddleView removeFromSuperview];
    [self.rightPaddleView removeFromSuperview];
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
    NSInteger offset = arc4random() % self.angles.count;
    float randomAngle = [self.angles [offset] floatValue];
    self.pushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.ballView] mode:UIPushBehaviorModeInstantaneous];
    self.pushBehavior.angle = randomAngle;
    self.pushBehavior.magnitude = self.ballSpeed;
    self.pushBehavior.active = YES;
    [self.animator addBehavior:self.pushBehavior];
}

- (void) pushExtraBall {
    NSInteger offset = arc4random() % self.angles.count;
    float randomAngle = [self.angles [offset] floatValue];
    self.extraPushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.extraBallView] mode:UIPushBehaviorModeInstantaneous];
    self.extraPushBehavior.angle = randomAngle;
    self.extraPushBehavior.magnitude = self.ballSpeed;
    self.extraPushBehavior.active = YES;
    [self.animator addBehavior:self.extraPushBehavior];
}

- (void) pushThirdBall {
    NSInteger offset = arc4random() % self.angles.count;
    float randomAngle = [self.angles [offset] floatValue];
    self.thirdPushBehavior = [[UIPushBehavior alloc] initWithItems:@[self.thirdBallView] mode:UIPushBehaviorModeInstantaneous];
    self.thirdPushBehavior.angle = randomAngle;
    self.thirdPushBehavior.magnitude = self.ballSpeed;
    self.thirdPushBehavior.active = YES;
    [self.animator addBehavior:self.thirdPushBehavior];
}

- (void) startTimer {
    self.count = 4;
    [NSTimer scheduledTimerWithTimeInterval:.4 target:self selector:@selector(countdownTimer:) userInfo:nil repeats:YES];
}

-(void) countdownTimer:(NSTimer*)timer {

    self.count--;
    self.countLabel.text = [NSString stringWithFormat:@"%ld", (long)self.count];

    self.score = 0;
    self.scoreLabel.text = [NSString stringWithFormat:@"%ld", (long)self.score];
    
    if (self.count == 3) {
        self.countFile = [[NSBundle mainBundle] URLForResource:@"pong3"
                                                 withExtension:@"mp3"];
        self.countSpeech = [[AVAudioPlayer alloc] initWithContentsOfURL:self.countFile
                                                                      error:nil];
        self.countSpeech.volume = .3;
        self.countSpeech.numberOfLoops = 0;
        [self.countSpeech play];
    }
    if (self.count == 2) {
        self.countFile = [[NSBundle mainBundle] URLForResource:@"pong2"
                                             withExtension:@"mp3"];
        self.countSpeech = [[AVAudioPlayer alloc] initWithContentsOfURL:self.countFile
                                                                      error:nil];
        self.countSpeech.volume = .3;
        self.countSpeech.numberOfLoops = 0;
        [self.countSpeech play];
    }
    if (self.count == 1) {
        self.countFile = [[NSBundle mainBundle] URLForResource:@"pong1"
                                                 withExtension:@"mp3"];
        self.countSpeech = [[AVAudioPlayer alloc] initWithContentsOfURL:self.countFile
                                                                      error:nil];
        self.countSpeech.volume = .3;
        self.countSpeech.numberOfLoops = 0;
        [self.countSpeech play];
    }
   
    
    if (self.count == 0) {
            self.countLabel.text = @"";
            [timer invalidate];
            [self.backgroundMusic play];
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
                self.soundFile = [[NSBundle mainBundle] URLForResource:@"pongulatorend"
                                                         withExtension:@"mp3"];
                self.endSound = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFile
                                                                       error:nil];
                self.endSound.volume = .5;
                self.endSound.numberOfLoops = 0;
                [self.endSound play];
                [self.backgroundMusic stop];
                self.backgroundMusic.currentTime = 0;
                
                [self reportScore];
                
                self.gameCount++;
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:self.gameCount forKey:@"HighScore"];
                [defaults synchronize];
                
                if (!self.areAdsRemoved) {
                    if (self.gameCount >= 5) {
                        [self displayAd];
                        self.gameCount = 0;
                    }
                }
                
                [self retryMenu];
            }
        }
        if (item == self.extraBallView) {
            [self removeExtraBall];
            if (self.ballAmount == 0) {
                self.soundFile = [[NSBundle mainBundle] URLForResource:@"pongulatorend"
                                                         withExtension:@"mp3"];
                self.endSound = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFile
                                                                       error:nil];
                self.endSound.volume = .5;
                self.endSound.numberOfLoops = 0;
                [self.endSound play];
                [self.backgroundMusic stop];
                self.backgroundMusic.currentTime = 0;
                
                [self reportScore];
                
                self.gameCount++;
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:self.gameCount forKey:@"HighScore"];
                [defaults synchronize];
                
                if (!self.areAdsRemoved) {
                    if (self.gameCount >= 5) {
                        [self displayAd];
                        self.gameCount = 0;
                    }
                }
                
                [self retryMenu];
            }
        }
        if (item == self.thirdBallView) {
            [self removeThirdBall];
            if (self.ballAmount == 0) {
                self.soundFile = [[NSBundle mainBundle] URLForResource:@"pongulatorend"
                                                         withExtension:@"mp3"];
                self.endSound = [[AVAudioPlayer alloc] initWithContentsOfURL:self.soundFile
                                                                       error:nil];
                self.endSound.volume = .5;
                self.endSound.numberOfLoops = 0;
                [self.endSound play];
                [self.backgroundMusic stop];
                self.backgroundMusic.currentTime = 0;
                
                [self reportScore];
                
                self.gameCount++;
                
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [defaults setInteger:self.gameCount forKey:@"HighScore"];
                [defaults synchronize];
                
                if (!self.areAdsRemoved) {
                    if (self.gameCount >= 5) {
                        [self displayAd];
                        self.gameCount = 0;
                    }
                }
            
                [self retryMenu];
            }
        }
    }
}


- (void) ballHitPaddle {
    [self bgChange];
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

- (void)collisionBehavior:(UICollisionBehavior *)behavior beganContactForItem:(id)item1 withItem:(id)item2 atPoint:(CGPoint)p {
    
    if ((item1 == self.ballView || item2 == self.ballView) && (item1 == self.leftPaddleView || item2 == self.leftPaddleView)) {
        if (p.x > self.leftPaddleView.frame.origin.x + self.leftPaddleView.frame.size.width) {
            [self ballHitPaddle];
        }
    }
    else if ((item1 == self.ballView || item2 == self.ballView) && (item1 == self.rightPaddleView || item2 == self.rightPaddleView)) {
        if (p.x < self.rightPaddleView.frame.origin.x) {
            [self ballHitPaddle];
        }
    }
    else if ((item1 == self.extraBallView || item2 == self.extraBallView) && (item1 == self.leftPaddleView || item2 == self.leftPaddleView)) {
        if (p.x > self.leftPaddleView.frame.origin.x + self.leftPaddleView.frame.size.width) {
            [self ballHitPaddle];
        }
    }
    else if ((item1 == self.extraBallView || item2 == self.extraBallView) && (item1 == self.rightPaddleView || item2 == self.rightPaddleView)) {
        if (p.x < self.rightPaddleView.frame.origin.x) {
            [self ballHitPaddle];
        }
    }
    else if ((item1 == self.thirdBallView || item2 == self.thirdBallView) && (item1 == self.leftPaddleView || item2 == self.leftPaddleView)) {
        if (p.x > self.leftPaddleView.frame.origin.x + self.leftPaddleView.frame.size.width) {
            [self ballHitPaddle];
        }
    }
    else if ((item1 == self.thirdBallView || item2 == self.thirdBallView) && (item1 == self.rightPaddleView || item2 == self.rightPaddleView)) {
        if (p.x < self.rightPaddleView.frame.origin.x) {
            [self ballHitPaddle];
        }
    }
}

- (void)bgChange {
    [self.bgTimer invalidate];
    self.bgView.image = self.anim;
    self.bgTimer = [NSTimer scheduledTimerWithTimeInterval:.95f target:self selector:@selector(bgChangeBack) userInfo:nil repeats:NO];
}

- (void)bgChangeBack {
    self.bgView.image = [UIImage animatedImageNamed:@"pong-" duration:.75f];
    [self.bgTimer invalidate];
}

-(void)authenticateLocalPlayer{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    
    localPlayer.authenticateHandler = ^(UIViewController *viewController, NSError *error){
        if (viewController != nil) {
            [self presentViewController:viewController animated:YES completion:nil];
        }
        else{
            if ([GKLocalPlayer localPlayer].authenticated) {
                _gameCenterEnabled = YES;
                
                // Get the default leaderboard identifier.
                [[GKLocalPlayer localPlayer] loadDefaultLeaderboardIdentifierWithCompletionHandler:^(NSString *leaderboardIdentifier, NSError *error) {
                    
                    if (error != nil) {
                        NSLog(@"%@", [error localizedDescription]);
                    }
                    else{
                        _leaderboardIdentifier = leaderboardIdentifier;
                    }
                }];
            }
            
            else{
                _gameCenterEnabled = NO;
            }
        }
    };
}

-(void)reportScore{
        GKScore *score = [[GKScore alloc] initWithLeaderboardIdentifier:_leaderboardIdentifier];
    score.value = _score;
    
    [GKScore reportScores:@[score] withCompletionHandler:^(NSError *error) {
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }];
}

-(void)showLeaderboardAndAchievements:(BOOL)shouldShowLeaderboard{
    GKGameCenterViewController *gcViewController = [[GKGameCenterViewController alloc] init];
    
    gcViewController.gameCenterDelegate = self;
    
    if (shouldShowLeaderboard) {
        gcViewController.viewState = GKGameCenterViewControllerStateLeaderboards;
        gcViewController.leaderboardIdentifier = _leaderboardIdentifier;
    }
    
    [self presentViewController:gcViewController animated:YES completion:nil];
}

-(void)gameCenterViewControllerDidFinish:(GKGameCenterViewController *)gameCenterViewController
{
    [gameCenterViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
