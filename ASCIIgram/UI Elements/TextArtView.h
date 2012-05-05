#import <UIKit/UIKit.h>
#import "TextArtViewDelegate.h"

@interface TextArtView : UIView {
  UILabel *canvas_;
  NSMutableArray *chars_;
  NSMutableArray *hitzones_;
  NSMutableArray *subTextArtViews_;
  NSString *name_;
  int rows_;
  int cols_;
  int top_;
  int left_;
  BOOL fillWithSpaces_;
  
  TextArtView *superTextArtView_;
  
  id<TextArtViewDelegate> delegate_;
}

- (id)initWithContentsOfTextFile:(NSString *)filename;
- (void)resetCanvasWithString:(NSString *)string andSizeToo:(BOOL)size;
- (void)resetCanvasWithFilename:(NSString *)filename andSizeToo:(BOOL)size;
- (void)fitToScreen;
- (void)drawCanvas;
- (void)addSubTextArtView:(TextArtView *)view;
- (void)drawSubTextArtView:(TextArtView *)view;
- (void)resetHitzones;
- (void)layerTextArtViewOnHitzones:(TextArtView *)view;
- (NSArray *)testTouches:(NSSet *)touches;
- (id)hitForRow:(int)row column:(int)column;

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) int rows;
@property (nonatomic, assign) int cols;
@property (nonatomic, assign) int top;
@property (nonatomic, assign) int left;
@property (nonatomic, assign) BOOL fillWithSpaces;
@property (nonatomic, readonly) NSArray *chars;
@property (nonatomic, assign) TextArtView *superTextArtView;

@property (nonatomic, assign) id<TextArtViewDelegate> delegate;

@end
