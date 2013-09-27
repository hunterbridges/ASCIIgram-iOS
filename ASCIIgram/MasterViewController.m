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
    self.textArtView = [[TextArtView alloc] init];
    [self.textArtView fitToScreen];
    
    TextArtView *frame =
        [[TextArtView alloc] initWithContentsOfTextFile:@"MenuBarFrame"];
    frame.top = 1;
    [self.textArtView addSubTextArtView:frame];
    
    TextArtView *header =
        [[TextArtView alloc] initWithContentsOfTextFile:@"Header"];
    header.top = 1;
    [self.textArtView addSubTextArtView:header];
    
    TAStatusBarView *status = [[TAStatusBarView alloc] init];
    [self.textArtView addSubTextArtView:status];
    
    self.camButton =
        [[TextArtView alloc] initWithContentsOfTextFile:@"CameraButton"];
    self.camButton.top = 28;
    self.camButton.left = 15;
    self.camButton.delegate = self;
    [self.textArtView addSubTextArtView:self.camButton];
      
    self.view = self.textArtView;
      
  }
  return self;
}

- (void)textArtViewWasClicked:(TextArtView *)view {
  if ([view isEqual:self.camButton]) {
    TextArtCameraView *cameraView = [[TextArtCameraView alloc] init];
    cameraView.top = 1;
    [self.textArtView addSubTextArtView:cameraView];
    [cameraView startCamera];
  }
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
