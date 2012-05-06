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
  capturing_ = YES;
  AVCaptureSession *captureSession = [[AVCaptureSession alloc] init];
  captureSession.sessionPreset = AVCaptureSessionPresetHigh;
  
  AVCaptureDevice *photoCaptureDevice =
      [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
  
  NSError *error = nil;
  AVCaptureDeviceInput *videoInput =
      [AVCaptureDeviceInput deviceInputWithDevice:photoCaptureDevice
                                            error:&error];
  if(videoInput){
    [captureSession addInput:videoInput];
  }
  
  AVCaptureVideoDataOutput *videoOutput =
      [[AVCaptureVideoDataOutput alloc] init];
  NSDictionary *rgbOutputSettings =
      [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCMPixelFormat_32BGRA]
                                  forKey:(id)kCVPixelBufferPixelFormatTypeKey];
  [videoOutput setVideoSettings:rgbOutputSettings];
  
  dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
  [videoOutput setSampleBufferDelegate:self queue:queue];
  
  if(videoOutput){
    [captureSession addOutput:videoOutput];
  }
  
  [captureSession startRunning];
  
  AVCaptureVideoPreviewLayer *previewLayer =
      [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
  previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
  previewLayer.frame = superTextArtView_.bounds;
}

-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
  if (capturing_){
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)attachments];
    
    UIImage *newFrame = [[UIImage alloc] initWithCIImage:ciImage];
  }
}

- (void)dealloc {
  [button_ release];
  [super dealloc];
}

@end
