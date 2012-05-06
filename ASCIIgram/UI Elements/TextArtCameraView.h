#import "TextArtView.h"
#import <AVFoundation/AVFoundation.h>

@interface TextArtCameraView : TextArtView
    <AVCaptureVideoDataOutputSampleBufferDelegate> {
  TextArtView *button_;
  BOOL capturing_;
}

- (void)startCamera;

@end
