#import <AVFoundation/AVFoundation.h>
#import "GPUImage.h"
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
  }
  return self;
}

- (void)startCamera {
  GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
  
  GPUImageSaturationFilter *satFilter = [[GPUImageSaturationFilter alloc] init];
  GPUImageRotationFilter *rotationFilter = [[GPUImageRotationFilter alloc] initWithRotation:kGPUImageRotateRight];
  satFilter.saturation = 0.0;
  
  GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
  contrastFilter.contrast = 2.0;
  
  GPUImagePixellateFilter *pixellateFilter = [[GPUImagePixellateFilter alloc] init];
  pixellateFilter.fractionalWidthOfAPixel = 1.0 / 35.0;
  
  GPUImageView *filterView = [[GPUImageView alloc] initWithFrame:superTextArtView_.bounds];
  [superTextArtView_ addSubview:filterView];
  
  [videoCamera addTarget:rotationFilter];
  [rotationFilter addTarget:satFilter];
  [satFilter addTarget:contrastFilter];
  [contrastFilter addTarget:pixellateFilter];
  [pixellateFilter addTarget:filterView];
  
  [videoCamera startCameraCapture];
}

- (void)dealloc {
  [button_ release];
  [bufferPreview_ release];
  [super dealloc];
}

@end
