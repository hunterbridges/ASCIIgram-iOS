//
//  BasicAsciiConverter.m
//  ASCIIgram
//
//  Created by Jeff Rafter on 10/1/13.
//  Copyright (c) 2013 Meedeor, LLC. All rights reserved.
//

#import "BasicAsciiConverter.h"

@interface BasicAsciiConverter()

@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) char *asciiFrame;

@end

@implementation BasicAsciiConverter

- (id)initWithWidth:(int)width andHeight:(int)height {
  self = [super init];
  if (self) {
    // Precalcing the width and height give us some dramatic improvements
    self.width = width;
    self.height = height;
    
    // The pixel data has rgba but we only need red since it is grayscale
    // We also need newlines for every line and a null terminator
    self.asciiFrame = calloc((self.width + 1) * self.height, sizeof(char));
    
    self.filter = [[GPUImageFilter alloc] init];
    [self.filter prepareForImageCapture];
    
    // GPUImageLowPassFilter *lowPass = [[GPUImageLowPassFilter alloc] init];
    GPUImageLanczosResamplingFilter *sampleFilter = [[GPUImageLanczosResamplingFilter alloc] init];
    GPUImageBrightnessFilter *brightFilter = [[GPUImageBrightnessFilter alloc] init];
    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
    GPUImageSaturationFilter *satFilter = [[GPUImageSaturationFilter alloc] init];
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];
    
    [sampleFilter forceProcessingAtSize:CGSizeMake(self.width, self.height)];

    brightFilter.brightness = 0.2;
    contrastFilter.contrast = 3.0;
    satFilter.saturation = 0;
    
    [self.filter addTarget:sampleFilter];
    [sampleFilter addTarget:brightFilter];
    [brightFilter addTarget:contrastFilter];
    [contrastFilter addTarget:satFilter];
    [satFilter addTarget:gammaFilter];

    self.output = gammaFilter;
  
  }
  return self;
}


- (NSString *)convert:(UIImage *)image
{
  NSData* pixelData = (__bridge NSData*) CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
  unsigned char* pixelBytes = (unsigned char*)[pixelData bytes];
  int index = 0;
  
  // Take away the red pixel, assuming 32-bit RGBA
  for(int i = 0; i < pixelData.length; i += 4) {
    uint8_t red = pixelBytes[i];
    if (index > 0 && index % self.width == 0)  {
      self.asciiFrame[index++] = (char)10;
      continue;
    }
    self.asciiFrame[index++] = [self charForPixel:red];
  }
  
  if (!index) return nil;
  
  // Construct an NSString from the chars
  return [[NSString alloc] initWithCString:self.asciiFrame encoding:NSASCIIStringEncoding];
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
