#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "TextArtCameraView.h"

#define DEBUG_IMAGE
// #define FRAME_RATE

@interface TextArtCameraView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) UIImageView *asciiImageView;
@property (nonatomic, assign) int frameWidth;
@property (nonatomic, assign) int frameHeight;
@property (nonatomic, assign) char *asciiFrame;
@property (nonatomic, strong) NSDate *lastFrame;

@end

@implementation TextArtCameraView

- (id)init {
  self = [super init];
  if (self) {
    self.frameWidth = 41;
    self.frameHeight = 28; // 21 is the correct size
    
    // The pixel data has rgba but we only need red since it is grayscale
    // We also need newlines for every line and a null terminator
    self.asciiFrame = calloc((self.frameWidth + 1) * self.frameHeight, sizeof(char));
    
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
  GPUImageFilter *preparedFilter = [[GPUImageFilter alloc] init];
  [preparedFilter prepareForImageCapture];
  
#ifdef DEBUG_IMAGE
  CGRect bounds = self.superTextArtView.bounds;
  self.asciiImageView = [[UIImageView alloc] initWithFrame:bounds];
  self.asciiImageView.contentMode = UIViewContentModeScaleAspectFit;
  [self.superTextArtView addSubview:self.asciiImageView];
#endif
  
//  GPUImageLowPassFilter *lowPass = [[GPUImageLowPassFilter alloc] init];
  GPUImageLanczosResamplingFilter *sampleFilter = [[GPUImageLanczosResamplingFilter alloc] init];
  GPUImageBrightnessFilter *brightFilter = [[GPUImageBrightnessFilter alloc] init];
  GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
  GPUImageSaturationFilter *satFilter = [[GPUImageSaturationFilter alloc] init];
  GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];
  
  [sampleFilter forceProcessingAtSize:CGSizeMake(self.frameWidth, self.frameHeight)];
  brightFilter.brightness = 0.2;
  contrastFilter.contrast = 3.0;
  satFilter.saturation = 0;
  
  
  [preparedFilter addTarget:sampleFilter];
  [sampleFilter addTarget:brightFilter];
  [brightFilter addTarget:contrastFilter];
  [contrastFilter addTarget:satFilter];
  [satFilter addTarget:gammaFilter];
  self.filter = gammaFilter;
  
  
  // Create custom GPUImage camera
  self.videoCamera = [[GPUImageVideoCamera alloc]
                      initWithSessionPreset:AVCaptureSessionPresetLow cameraPosition:AVCaptureDevicePositionBack];
                      
  self.videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
  [self.videoCamera addTarget:preparedFilter];
  
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
  
  NSData* pixelData = (__bridge NSData*) CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
  unsigned char* pixelBytes = (unsigned char*)[pixelData bytes];
  int index = 0;
  
  // Take away the red pixel, assuming 32-bit RGBA
  for(int i = 0; i < pixelData.length; i += 4) {
    uint8_t red = pixelBytes[i];
    if (index > 0 && index % self.frameWidth == 0)  {
      self.asciiFrame[index++] = (char)10;
      continue;
    }
    self.asciiFrame[index++] = [self charForPixel:red];
  }
  
  if (index) {
    NSString *asciiString = [[NSString alloc] initWithCString:self.asciiFrame encoding:NSASCIIStringEncoding];
    [self.video resetCanvasWithString:asciiString andSizeToo:YES];
#ifdef DEBUG_IMAGE
    self.asciiImageView.image = image;
    NSLog(@"Processing:\n%@\n\n", asciiString);
#endif
  }
  
  
  [self scheduleSample];
}

- (char)charForPixel:(int)redValue {
  // Symbols in order of visual magnitude (with escapes for \ and "
  const char *syms = " `..'~!-^,_:{};><\\(/)?*=\"%+il[]71tcjr3C&2oxvJIzL$uZ6YTO5Gsw4eyn0AVDPFfphSaU9dXbk8QqREKmWBg@H#NM";
  int len = 95.0;
  int index = round((redValue / 256.0) * len);
  return syms[len - index];
}


/*
static char BLACK = '@';
static char CHARCOAL = '#';
static char DARKGRAY = '8';
static char MEDIUMGRAY = '&';
static char MEDIUM = 'o';
static char GRAY = ':';
static char SLATEGRAY = '*';
static char LIGHTGRAY = '.';
static char WHITE = ' ';

- (char)charForPixel:(int)redValue
{
  char asciival = ' ';
 
  if (redValue >= 230)
  {
    asciival = WHITE;
  }
  else if (redValue >= 200)
  {
    asciival = LIGHTGRAY;
  }
  else if (redValue >= 180)
  {
    asciival = SLATEGRAY;
  }
  else if (redValue >= 160)
  {
    asciival = GRAY;
  }
  else if (redValue >= 130)
  {
    asciival = MEDIUM;
  }
  else if (redValue >= 100)
  {
    asciival = MEDIUMGRAY;
  }
  else if (redValue >= 70)
  {
    asciival = DARKGRAY;
  }
  else if (redValue >= 50)
  {
    asciival = CHARCOAL;
  }
  else
  {
    asciival = BLACK;
  }
  
  return asciival;
}
*/
@end
