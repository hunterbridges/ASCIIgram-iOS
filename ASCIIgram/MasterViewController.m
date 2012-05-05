#import "MasterViewController.h"
#import "TextArtView.h"
#import "TAStatusBarView.h"
#import "TextArtViewDelegate.h"
#import "TextArtCameraView.h"

@implementation MasterViewController

- (void)didReceiveMemoryWarning {
}

- (id)init {
  self = [super init];
  if (self) {
    view_ = [[TextArtView alloc] init];
    [view_ fitToScreen];
    
    self.view = view_;
    
    TextArtView *frame =
        [[TextArtView alloc] initWithContentsOfTextFile:@"MenuBarFrame"];
    frame.top = 1;
    [view_ addSubTextArtView:frame];
    [frame release];
    
    TextArtView *header =
        [[TextArtView alloc] initWithContentsOfTextFile:@"Header"];
    header.top = 1;
    [view_ addSubTextArtView:header];
    [header release];
    
    TAStatusBarView *status = [[TAStatusBarView alloc] init];
    [view_ addSubTextArtView:status];
    [status release];
    
    camButton_ =
        [[TextArtView alloc] initWithContentsOfTextFile:@"CameraButton"];
    camButton_.top = 28;
    camButton_.left = 15;
    camButton_.delegate = self;
    [view_ addSubTextArtView:camButton_];
  }
  return self;
}

- (void)textArtViewWasClicked:(TextArtView *)view {
  if ([view isEqual:camButton_]) {
    TextArtCameraView *cameraView = [[TextArtCameraView alloc] init];
    cameraView.top = 1;
    [view_ addSubTextArtView:cameraView];
    [cameraView startCamera];
    [cameraView release];
  }
}

- (void)dealloc {
  [view_ release];
  [camButton_ release];
  [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
}

- (void)viewDidUnload {
  [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:
    (UIInterfaceOrientation)interfaceOrientation {
  return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
