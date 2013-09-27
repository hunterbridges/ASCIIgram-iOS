#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import "TextArtCameraView.h"

@interface TextArtCameraView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) GPUImageStillCamera *stillCamera;
@property (nonatomic, strong) GPUImageFilter *filter;

@end

@implementation TextArtCameraView

- (id)init {
  self = [super init];
  if (self) {
    [self resetCanvasWithFilename:@"MenuBarFrame" andSizeToo:YES];
    self.button =
        [[TextArtView alloc] initWithContentsOfTextFile:@"SmallCameraButton"];
    self.button.top = 29;
    self.button.left = 18;
    [self addSubTextArtView:self.button];
    self.canvas.backgroundColor = [UIColor purpleColor];
  }
  return self;
}

- (void)startCamera {
  GPUImageFilter *preparedFilter = [[GPUImageFilter alloc] init];
  [preparedFilter prepareForImageCapture];
  
  CGRect bounds = self.superTextArtView.bounds;
  self.asciiImageView = [[UIImageView alloc] initWithFrame:bounds];
  self.asciiImageView.contentMode = UIViewContentModeScaleAspectFit;
  [self.superTextArtView addSubview:self.asciiImageView];
  
  GPUImageLanczosResamplingFilter *sampleFilter = [[GPUImageLanczosResamplingFilter alloc] init];
  GPUImageCannyEdgeDetectionFilter *cannyFilter = [[GPUImageCannyEdgeDetectionFilter alloc] init];
  GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc] init];
  
  [sampleFilter forceProcessingAtSizeRespectingAspectRatio:CGSizeMake(512, 512)];
  [preparedFilter addTarget:sampleFilter];
  [sampleFilter addTarget:cannyFilter];
  [cannyFilter addTarget:invertFilter];
  
  self.filter = invertFilter;
  
  // Create custom GPUImage camera
  self.stillCamera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPresetLow cameraPosition:AVCaptureDevicePositionBack];
                      
  self.stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
  [self.stillCamera addTarget:preparedFilter];
  
  // Begin showing video camera stream
  [self.stillCamera startCameraCapture];
  
  // Get that
  [self sampleCamera];

}

- (void)sampleCamera {
  self.timer = nil;
  
  [self.stillCamera capturePhotoAsImageProcessedUpToFilter:self.filter
                                     withCompletionHandler:^(UIImage *processedImage, NSError *error){
                                       NSLog(@"Processing");
                                       self.asciiImageView.image = processedImage;
                                       self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1
                                                                                     target:self
                                                                                   selector:@selector(sampleCamera)
                                                                                   userInfo:nil
                                                                                    repeats:NO];
                                     }];
}


@end
