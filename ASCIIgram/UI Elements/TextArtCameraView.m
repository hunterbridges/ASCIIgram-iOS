#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "TextArtCameraView.h"
#import "AsciiConverter.h"
#import "ImageToAsciiConverter.h"

// #define DEBUG_IMAGE
// #define FRAME_RATE

@interface TextArtCameraView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) UIImageView *asciiImageView;
@property (nonatomic, strong) NSDate *lastFrame;
@property (nonatomic, strong) AsciiConverter* converter;

@end

@implementation TextArtCameraView

- (id)init {
  self = [super init];
  if (self) {
    self.converter = [[ImageToAsciiConverter alloc] initWithWidth:41 andHeight:28];
    
    [self resetCanvasWithFilename:@"MenuBarFrame" andSizeToo:YES];
    self.button = [[TextArtView alloc] initWithContentsOfTextFile:@"SmallCameraButton"];
    self.button.top = 29;
    self.button.left = 18;
    [self addSubTextArtView:self.button];

    self.video = [[TextArtView alloc] initWithContentsOfTextFile:@"Video"];
    self.video.top = 1;
    self.video.left = 1;
    [self addSubTextArtView:self.video];
  }
  return self;
}

- (void)startCamera {
#ifdef DEBUG_IMAGE
  CGRect bounds = self.superTextArtView.bounds;
  self.asciiImageView = [[UIImageView alloc] initWithFrame:bounds];
  self.asciiImageView.contentMode = UIViewContentModeScaleAspectFit;
  [self.superTextArtView addSubview:self.asciiImageView];
#endif
  
  // Create custom GPUImage camera
  self.videoCamera = [[GPUImageVideoCamera alloc]
                      initWithSessionPreset:AVCaptureSessionPresetLow
                             cameraPosition:AVCaptureDevicePositionBack];
                      
  self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
  [self.videoCamera addTarget:self.converter.filter];
  
  // Begin showing video camera stream
  [self.videoCamera startCameraCapture];
  
  // Get that
  [self sampleCamera];

}

- (void)scheduleSample {
  // Use a timer here to get a slight pause and to not overflow the stack
  self.timer = [NSTimer scheduledTimerWithTimeInterval:0
                                                target:self
                                              selector:@selector(sampleCamera)
                                              userInfo:nil
                                               repeats:NO];
  
}

- (void)sampleCamera {
  self.timer = nil;
  
#ifdef FRAME_RATE
  if (self.lastFrame) {
    NSDate *now = [NSDate date];
    NSLog(@"Frame rate: %f", 1.0 / [now timeIntervalSinceDate:self.lastFrame]);
  }
  self.lastFrame = [NSDate date];
#endif
  
  UIImage *image = [self.filter imageFromCurrentlyProcessedOutput];
  if (image == nil) {
    [self scheduleSample];
    return;
  }
  
  NSString *asciiString = [self.converter convert:image];
  if (asciiString) {
    [self.video resetCanvasWithString:asciiString andSizeToo:YES];
#ifdef DEBUG_IMAGE
    self.asciiImageView.image = image;
    NSLog(@"Processing:\n%@\n\n", asciiString);
#endif
  }
  
  [self scheduleSample];
}


/*
*/
@end
