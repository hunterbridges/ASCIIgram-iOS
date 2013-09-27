#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
#import "TextArtCameraView.h"

@implementation TextArtCameraView

- (id)init {
  self = [super init];
  if (self) {
    [self resetCanvasWithFilename:@"MenuBarFrame" andSizeToo:YES];
    self.button =
        [[TextArtView alloc] initWithContentsOfTextFile:@"SmallCameraButton"];
    self.button.top = 29;
    self.button.left = 18;
  }
  return self;
}

- (void)startCamera {
  GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
  
  GPUImageSaturationFilter *satFilter = [[GPUImageSaturationFilter alloc] init];
  satFilter.saturation = 0.0;
  
  GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
  contrastFilter.contrast = 2.0;
  
  GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
  pixellateFilter.fractionalWidthOfAPixel = 1.0 / 35.0;
  
  GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:self.superTextArtView.bounds];
  [self.superTextArtView addSubview:filterView];
  
  [satFilter addTarget:contrastFilter];
  [contrastFilter addTarget:pixellateFilter];
  [pixellateFilter addTarget:filterView];
  
  [videoCamera startCameraCapture];
}


@end
