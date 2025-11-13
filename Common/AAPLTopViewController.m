//
//  AAPLTopViewController.m
//  MetalFlame
//
//  Created by Evgeny Baskakov on 7/16/17.
//  Copyright © 2017 Evgeny Baskakov. All rights reserved.
//

#import "AAPLViewController.h"
#import "AAPLTopViewController.h"

@interface AAPLTopViewController ()
@end

@implementation AAPLTopViewController {
#if TARGET_OS_IOS || TARGET_OS_TV
    __weak IBOutlet UIView *buttonBox;
    __weak IBOutlet UIButton *createButton;
    __weak IBOutlet UIButton *playButton;
    AAPLViewController *drawableViewController;
#endif
}

- (IBAction)createAction:(id)sender {
#if TARGET_OS_IOS || TARGET_OS_TV
    [drawableViewController show:YES];
    buttonBox.hidden = YES;
#endif
}

- (IBAction)playAction:(id)sender {
#if TARGET_OS_IOS || TARGET_OS_TV
    [drawableViewController show:NO];
    buttonBox.hidden = YES;
#endif
}

- (void)viewDidLoad
{
    [super viewDidLoad];

#if TARGET_OS_IOS || TARGET_OS_TV
    self.view.backgroundColor = [UIColor clearColor];

    for(UIViewController *child in self.childViewControllers) {
        if([child isKindOfClass:[AAPLViewController class]]) {
            drawableViewController = (AAPLViewController*)child;
            break;
        }
    }
#endif
}

#if TARGET_OS_IOS || TARGET_OS_TV

#pragma mark - undo redo

- (void)enableUndo {
    [drawableViewController enableUndo];
}

- (void)enableRedo {
    [drawableViewController enableRedo];
}

- (void)disableUndo {
    [drawableViewController disableUndo];
}

- (void)disableRedo {
    [drawableViewController disableRedo];
}

#pragma mark - Menu controls

- (void)showMainMenu {
    buttonBox.hidden = NO;
}

#pragma mark - iOS properties

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#endif

@end
