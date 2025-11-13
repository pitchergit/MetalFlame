/*
Copyright © 2017 Evgeny Baskakov. All Rights Reserved.
*/

#import "AAPLViewController.h"
#import "AAPLTopViewController.h"
#import "AAPLRenderer.h"

@import Metal;
@import simd;
@import MetalKit;

#if TARGET_OS_IOS || TARGET_OS_TV
@interface AAPLViewController ()
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *space1;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *space2;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *space3;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *undoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *space4;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *redoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *space5;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *flameButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *space6;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sparkButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *space7;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *paletteButton;
#else
@interface AAPLViewController ()
#endif
@property (nonatomic, weak) MTKView *metalView;
@property (nonatomic, strong) AAPLRenderer *renderer;
@end

@implementation AAPLViewController {
#if TARGET_OS_IOS || TARGET_OS_TV
    UIImage *_backImage;
    UIImage *_saveImage;
    UIImage *_undoImage;
    UIImage *_disabledUndoImage;
    UIImage *_redoImage;
    UIImage *_disabledRedoImage;
    UIImage *_pencilImage;
    UIImage *_flameImage;
    UIImage *_sparkImage;
    UIImage *_paletteImage;
#endif
    NSMutableArray *_createToolbarItems;
    NSMutableArray *_playToolbarItems;
    bool _persistentDraw;
}

#pragma mark - View Controller Methods

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if TARGET_OS_IOS || TARGET_OS_TV
    _backImage = [[UIImage imageNamed:@"back"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _saveImage = [[UIImage imageNamed:@"save"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _undoImage = [[UIImage imageNamed:@"undo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _disabledUndoImage = [UIImage imageNamed:@"undo"];
    _redoImage = [[UIImage imageNamed:@"redo"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _disabledRedoImage = [UIImage imageNamed:@"redo"];
    _pencilImage = [[UIImage imageNamed:@"pencil"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _flameImage = [[UIImage imageNamed:@"flame"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _sparkImage = [[UIImage imageNamed:@"spark"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    _paletteImage = [[UIImage imageNamed:@"palette"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    _createToolbarItems = [NSMutableArray arrayWithCapacity:15];
    
    [_createToolbarItems addObject:_space1];
    [_createToolbarItems addObject:_backButton];
    [_createToolbarItems addObject:_space2];
    [_createToolbarItems addObject:_saveButton];
    [_createToolbarItems addObject:_space3];
    [_createToolbarItems addObject:_undoButton];
    [_createToolbarItems addObject:_space4];
    [_createToolbarItems addObject:_redoButton];
    [_createToolbarItems addObject:_space5];
    [_createToolbarItems addObject:_flameButton];
    [_createToolbarItems addObject:_space6];
    [_createToolbarItems addObject:_paletteButton];
    [_createToolbarItems addObject:_space7];
    [_createToolbarItems addObject:_sparkButton];

    _playToolbarItems = [NSMutableArray arrayWithCapacity:5];
    
    [_playToolbarItems addObject:_space1];
    [_playToolbarItems addObject:_backButton];
    [_playToolbarItems addObject:_space2];
    [_playToolbarItems addObject:_sparkButton];
    [_playToolbarItems addObject:_space3];

    _backButton.image = _backImage;
    _saveButton.image = _saveImage;
    _undoButton.image = _undoImage;
    _redoButton.image = _redoImage;
    _flameButton.image = _flameImage;
    _paletteButton.image = _paletteImage;
    _sparkButton.image = _sparkImage;

    _toolbar.hidden = YES;
    
    [self disableRedo];
    [self disableUndo];
#endif
}

- (void)show:(bool)persistentDraw {
    if(_metalView == nil) {
        _metalView = (MTKView *)self.view;
        [self setupView];
    }
    else {
        // TODO: clear and reuse the existing metal view
    }
    
    _persistentDraw = persistentDraw;
    
#if TARGET_OS_IOS || TARGET_OS_TV
    self.metalView.multipleTouchEnabled = _persistentDraw ? NO : YES;

    [self configureToolbar];
    
    [_renderer show:_persistentDraw];
    
    // Set red color for pencil mode
    _renderer.pencilColor = [UIColor redColor];
    
    _toolbar.hidden = NO;
    _metalView.hidden = NO;
#endif
}

- (void)hide {
#if TARGET_OS_IOS || TARGET_OS_TV
    [_renderer hide];

    _toolbar.hidden = YES;
    _metalView.hidden = YES;
#endif
}

#if TARGET_OS_IOS || TARGET_OS_TV
- (void)configureToolbar {
    NSArray *items;
    
    if(_persistentDraw) {
        items = _createToolbarItems;
    }
    else {
        items = _playToolbarItems;
    }

    [_toolbar setItems:items animated:NO];
}

- (void)enableUndo {
    _undoButton.image = _undoImage;
    _undoButton.enabled = true;
}

- (void)enableRedo {
    _redoButton.image = _redoImage;
    _redoButton.enabled = true;
}

- (void)disableUndo {
    _undoButton.image = _disabledUndoImage;
    _undoButton.tintColor = [UIColor grayColor];
    _undoButton.enabled = false;
}

- (void)disableRedo {
    _redoButton.image = _disabledRedoImage;
    _redoButton.tintColor = [UIColor grayColor];
    _redoButton.enabled = false;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}
#endif

#pragma mark - Setup Methods

- (void)setupView
{
    _metalView.device = MTLCreateSystemDefaultDevice();
    NSAssert(_metalView.device, @"no default metal device");
    
    _metalView.colorPixelFormat = MTLPixelFormatBGRA8Unorm;
    _metalView.clearColor = MTLClearColorMake(0, 0, 0, 1);

#if TARGET_OS_IOS || TARGET_OS_TV
    _renderer = [[AAPLRenderer alloc] initWithView:_metalView viewController:(AAPLTopViewController*)self.parentViewController];
#else
    _renderer = [[AAPLRenderer alloc] initWithView:_metalView];
#endif

#if TARGET_OS_IOS || TARGET_OS_TV
    self.metalView.userInteractionEnabled = YES;
    
    [self becomeFirstResponder];
#else
    [NSEvent addLocalMonitorForEventsMatchingMask:NSEventMaskKeyDown handler:^(NSEvent *event) {
        [self keyDown:event];
        return event;
    }];
#endif
}

#if TARGET_OS_IOS || TARGET_OS_TV

#pragma mark - Toolbar controls

- (IBAction)backAction:(id)sender {
    [self hide];
    
    [(AAPLTopViewController*)self.parentViewController showMainMenu];
}

- (IBAction)saveAction:(id)sender {
    _toolbar.hidden = YES;
    
    [_renderer saveImage];
    
    _toolbar.hidden = NO;
}

- (IBAction)undoAction:(id)sender {
    [_renderer undo];
}

- (IBAction)redoAction:(id)sender {
    [_renderer redo];
}

- (IBAction)flameAction:(id)sender {
    NSAssert(_persistentDraw, @"only can change flame mode in persistent mode");
    
    if(_renderer.pencilMode) {
        _flameButton.image = _flameImage;
        _renderer.pencilMode = false;
    }
    else {
        _flameButton.image = _pencilImage;
        _renderer.pencilMode = true;
        // Set red color when switching to pencil mode
        _renderer.pencilColor = [UIColor redColor];
    }
}

- (IBAction)sparkAction:(id)sender {
    [_renderer shakeFlame];
}

- (IBAction)paletteAction:(id)sender {
    // TODO: Implement color palette picker
    // For now, cycle through some preset colors
    static int colorIndex = 0;
    NSArray *colors = @[
        [UIColor redColor],
        [UIColor orangeColor],
        [UIColor yellowColor],
        [UIColor greenColor],
        [UIColor blueColor],
        [UIColor purpleColor],
        [UIColor magentaColor]
    ];
    
    if (_renderer.pencilMode) {
        colorIndex = (colorIndex + 1) % colors.count;
        _renderer.pencilColor = colors[colorIndex];
    }
}

#endif

#pragma mark - Interaction (Touch / Mouse) Handling

- (void)stopCurrentDrawing {
    [_renderer stopCurrentDrawing];
}

- (CGPoint)locationInGridForLocationInView:(CGPoint)point
{
    CGSize viewSize = self.view.frame.size;
    CGFloat normalizedWidth = point.x / viewSize.width;
    CGFloat normalizedHeight = point.y / viewSize.height;
    CGFloat gridX = round(normalizedWidth * self.renderer.gridSize.width);
    CGFloat gridY = round(normalizedHeight * self.renderer.gridSize.height);
    return CGPointMake(gridX, gridY);
}

- (void)activateRandomCellsForPoint:(CGPoint)point
{
    // Translate between the coordinate space of the view and the game grid,
    // then forward the request to the compute phase to do the real work
    CGPoint gridLocation = _persistentDraw ? point : [self locationInGridForLocationInView:point];
    [self.renderer activateRandomCellsInNeighborhoodOfCell:gridLocation];
}

#if TARGET_OS_IPHONE
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        [self activateRandomCellsForPoint:location];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self.view];
        [self activateRandomCellsForPoint:location];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.renderer stopPointActivation];
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    if (motion == UIEventSubtypeMotionShake ) {
        [_renderer shakeFlame];
    }
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
}
#else
- (void)mouseDown:(NSEvent *)event {
    // Translate the cursor position into view coordinates, accounting for the fact that
    // App Kit's default window coordinate space has its origin in the bottom left
    CGPoint location = [self.view convertPoint:[event locationInWindow] fromView:nil];
    location.y = self.view.bounds.size.height - location.y;
    [self activateRandomCellsForPoint:location];
}

- (void)mouseDragged:(NSEvent *)event {
    // Translate the cursor position into view coordinates, accounting for the fact that
    // App Kit's default window coordinate space has its origin in the bottom left
    CGPoint location = [self.view convertPoint:[event locationInWindow] fromView:nil];
    location.y = self.view.bounds.size.height - location.y;
    [self activateRandomCellsForPoint:location];
}

- (void)mouseUp:(NSEvent *)event {
    [self.renderer stopPointActivation];
}

- (void)keyDown:(NSEvent *)event {
    [super keyDown:event];

    if(event.keyCode == 49) {
        [_renderer shakeFlame];
    }
}
#endif

@end
