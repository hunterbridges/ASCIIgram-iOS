#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "GPUImage.h"
#import "TextArtCameraView.h"


@interface TextArtCameraView ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) GPUImageVideoCamera *videoCamera;
@property (nonatomic, strong) GPUImageFilter *filter;

@end

const int kcharWidth = 35;
const int kcharHeight = 21;


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
  
  [sampleFilter forceProcessingAtSize:CGSizeMake(kcharWidth, kcharHeight)];

  [preparedFilter addTarget:cannyFilter];
  [cannyFilter addTarget:sampleFilter];
  [sampleFilter addTarget:invertFilter];
  
  self.filter = invertFilter;
  
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

- (void)sampleCamera {
  self.timer = nil;
  NSLog(@"Processing");
  
  UIImage *image = [self.filter imageFromCurrentlyProcessedOutput];
  
  NSData* pixelData = (__bridge NSData*) CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
  unsigned char* pixelBytes = (unsigned char*)[pixelData bytes];
  
  NSMutableString *m = [[NSMutableString alloc] init];
//  char *pixelChars = calloc((pixelData.length / 4) + 1, sizeof(char));
  int index = 0;
  int lines = 0;
  // Take away the red pixel, assuming 32-bit RGBA
  for(int i = 0; i < pixelData.length; i += 4) {
    uint8_t red = pixelBytes[i];
    if (index++ % kcharWidth == 0)  {
      lines++;
      [m appendString:@"\n"];
    }
    [m appendFormat:@"%c", [self charForPixel:red]];
  }
  
  NSLog(@"Pix (tot: %i, chars: %i, lines: %i):\n %@", pixelData.length, index, lines, m);
  
  self.asciiImageView.image = image;
  
  // Use a timer here to get a slight pause and to not overflow the stack
  self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5
                                                target:self
                                              selector:@selector(sampleCamera)
                                              userInfo:nil
                                               repeats:NO];
}

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

@end
