#import <AVFoundation/AVFoundation.h>
#import "TextArtCameraView.h"

@implementation TextArtCameraView

- (id)init {
    self = [super init];
    if (self) {
      [self resetCanvasWithFilename:@"MenuBarFrame" andSizeToo:YES];
      button_ =
          [[TextArtView alloc] initWithContentsOfTextFile:@"SmallCameraButton"];
      button_.top = 29;
      button_.left = 18;
      [self addSubTextArtView:button_];
    }
    return self;
}

- (void)startCamera {
  AVCaptureSession *session = [[AVCaptureSession alloc] init];
	session.sessionPreset = AVCaptureSessionPresetMedium;
  CALayer *viewLayer = self.superTextArtView.layer;
  AVCaptureVideoPreviewLayer *captureVideoPreviewLayer =
  [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
  captureVideoPreviewLayer.frame = self.superTextArtView.bounds;
	[viewLayer addSublayer:captureVideoPreviewLayer];
  AVCaptureDevice *device =
  [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  NSError *error = nil;
	AVCaptureDeviceInput *input =
  [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
	if (!input) {
		// Handle the error appropriately.
		NSLog(@"ERROR: trying to open camera: %@", error);
	}
	[session addInput:input];
  
	[session startRunning];
}

- (void)dealloc {
  [button_ release];
  [super dealloc];
}

@end
