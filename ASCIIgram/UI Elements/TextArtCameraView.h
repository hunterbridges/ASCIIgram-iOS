#import "TextArtView.h"

@interface TextArtCameraView : TextArtView;

@property (nonatomic, strong) TextArtView *button;
@property (nonatomic, strong) TextArtView *video;
@property (nonatomic, assign) BOOL capturing;
@property (nonatomic, strong) UIImage *buffer;
@property (nonatomic, strong) UIImageView *bufferPreview;
@property (nonatomic, strong) UIImageView *asciiImageView;

- (void)startCamera;

@end
