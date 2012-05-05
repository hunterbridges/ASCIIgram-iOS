#import <UIKit/UIKit.h>
#import "TextArtViewDelegate.h"

@class TextArtView;
@interface MasterViewController : UIViewController <TextArtViewDelegate> {
  TextArtView *view_;
  TextArtView *camButton_;
}
@end
