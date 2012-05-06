#import "TextArtView.h"

@interface TextArtCameraView : TextArtView {
  TextArtView *button_;
  BOOL capturing_;
  UIImage *buffer_;
  UIImageView *bufferPreview_;
}

- (void)startCamera;

@end
