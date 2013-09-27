#import <UIKit/UIKit.h>
#import "TextArtViewDelegate.h"

@class TextArtView;

@interface MasterViewController : UIViewController <TextArtViewDelegate>;

@property (nonatomic, strong) TextArtView *textArtView;
@property (nonatomic, strong) TextArtView *camButton;

@end
