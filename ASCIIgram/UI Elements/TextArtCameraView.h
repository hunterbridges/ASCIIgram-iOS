#import "TextArtView.h"

@interface TextArtCameraView : TextArtView;

@property (nonatomic, strong) TextArtView *button;
@property (nonatomic, assign) BOOL capturing;
@property (nonatomic, strong) UIImage *buffer;
@property (nonatomic, strong) UIImageView *bufferPreview;

- (void)startCamera;

@end
