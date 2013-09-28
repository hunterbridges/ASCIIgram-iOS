#import "TextArtView.h"

@interface TextArtCameraView : TextArtView;

@property (nonatomic, strong) TextArtView *button;
@property (nonatomic, strong) TextArtView *video;
@property (nonatomic, assign) BOOL capturing;

- (void)startCamera;

@end
