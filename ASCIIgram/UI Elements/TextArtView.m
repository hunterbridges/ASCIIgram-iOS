#import "TextArtView.h"

@implementation TextArtView
@synthesize name = name_;
@synthesize rows = rows_;
@synthesize cols = cols_;
@synthesize top = top_;
@synthesize left = left_;
@synthesize  fillWithSpaces = fillWithSpaces_;
@synthesize chars = chars_;
@synthesize superTextArtView = superTextArtView_;
@synthesize delegate = delegate_;

- (id)init {
  self = [super init];
  if (self) {
    chars_ = [[NSMutableArray alloc] init];
    hitzones_ = [[NSMutableArray alloc] init];
    subTextArtViews_ = [[NSMutableArray alloc] init];
    
    self.backgroundColor = [UIColor whiteColor];
    
    canvas_ = [[UILabel alloc] init];
    canvas_.font = [UIFont fontWithName:@"CourierNewPSMT" size:12];
    
    canvas_.textColor = [UIColor blackColor];
    canvas_.backgroundColor = [UIColor whiteColor];
    canvas_.numberOfLines = 0;
    
    [self addSubview:canvas_];
    
    top_ = 0;
    left_ = 0;
    rows_ = 0;
    cols_ = 0;
  }
  return self;
}

- (id)initWithContentsOfTextFile:(NSString *)filename {
  self = [self init];
  if (self) {
    [self resetCanvasWithFilename:filename andSizeToo:YES];
  }
  return self;
}

- (void)resetCanvasWithFilename:(NSString *)filename andSizeToo:(BOOL)size {
  self.name = filename;
  NSString *path = [[NSBundle mainBundle] pathForResource:filename
                                                   ofType:@"txt"];
  NSString *baseScreen =
      [NSString stringWithContentsOfFile:path
                                encoding:NSUTF8StringEncoding
                                   error:nil];
  [self resetCanvasWithString:baseScreen andSizeToo:size];
  [self resetHitzones];
}

- (void)resetCanvasWithString:(NSString *)string andSizeToo:(BOOL)size {
  [chars_ removeAllObjects];
  
  NSMutableArray *rowStrings = [NSMutableArray
      arrayWithArray:[string componentsSeparatedByString:@"\n"]];
  NSMutableArray *croppedRowStrings = [NSMutableArray array];
  
  int foundRows = 0;
  int foundCols = 0;
  
  for (int idx = 0; idx < [rowStrings count] || (!size && idx < rows_); idx++) {
    NSString *obj = [rowStrings objectAtIndex:idx];
    if ([obj length]) {
      int toIndex = 0;
      if (size) {
        toIndex = [obj length] ;
        foundCols = MAX(foundCols, [obj length]);
      } else {
        toIndex = MIN(cols_, [obj length]);
      }
      NSString *newStr = [obj substringToIndex:toIndex];
      [croppedRowStrings addObject:newStr];
    } else {
      [croppedRowStrings addObject:@""];
    }
    if (size) {
      foundRows = MAX(foundRows, idx);
    }
  }
  
  if (size) {
    rows_ = foundRows;
    cols_ = foundCols;
  }
  
  [chars_ addObjectsFromArray:croppedRowStrings];
  [self resetHitzones];
  [self drawCanvas];
}

- (void)drawCanvas {
  if (superTextArtView_ == nil) {
    NSMutableString *render = [NSMutableString string];
    [chars_ enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [render appendString:obj];
      [render appendString:@"\n"];
    }];
    canvas_.text = render;
    [canvas_ sizeToFit];
  } else {
    [superTextArtView_ drawSubTextArtView:self];
  }
}

- (void)fitToScreen {
  self.frame = CGRectMake(0,
                          0,
                          [UIScreen mainScreen].bounds.size.width,
                          [UIScreen mainScreen].bounds.size.height);
  
  float rowHeight = 14.0;
  float colWidth = 7.2;
  
  rows_ = floorf(self.frame.size.height / rowHeight);
  cols_ = floorf(self.frame.size.width / colWidth);
  
  CGRect frame = CGRectMake(2,
                            2,
                            self.frame.size.width,
                            self.frame.size.height);
  canvas_.frame = frame;
  [self resetHitzones];
}

- (void)addSubTextArtView:(TextArtView *)view {
  [subTextArtViews_ addObject:view];
  [self drawSubTextArtView:view];
  [self layerTextArtViewOnHitzones:view];
  view.superTextArtView = self;
}

- (void)drawSubTextArtView:(TextArtView *)view {
  for (int yAdjust = [chars_ count]; yAdjust < view.top + view.rows; yAdjust++){
    [chars_ addObject:@""];
  }
  for (int y = view.top; y < view.top + view.rows; y++) {
    NSMutableString *superRow;
    superRow =
        [NSMutableString stringWithString:[chars_ objectAtIndex:y]];
    NSString *subRow = [[view chars] objectAtIndex:y - view.top];
    NSRange range = NSMakeRange(view.left, subRow.length);
    if ([superRow length] < range.length) {
      for (int spaces = 0; spaces < range.length; spaces++) {
        [superRow appendString:@" "];
      }
    }
    
    [superRow replaceCharactersInRange:range withString:subRow];
    // Hit test? Only replace characters if this view is on top?
    [chars_ replaceObjectAtIndex:y withObject:superRow];
  }
  [self drawCanvas];
}

- (void)resetHitzones {
  [hitzones_ removeAllObjects];
  for (int row = 0; row < rows_; row++) {
    NSMutableArray *columns = [NSMutableArray array];
    for (int col = 0; col < cols_; col++) {
      [columns addObject:self];
    }
    [hitzones_ addObject:columns];
  }
  for (int i = 0; i < [subTextArtViews_ count]; i++) {
    TextArtView *tav = [subTextArtViews_ objectAtIndex:i];
    [self layerTextArtViewOnHitzones:tav];
  }
}

- (void)layerTextArtViewOnHitzones:(TextArtView *)view {
  for (int row = view.top; row < view.rows + view.top; row++) {
    NSMutableArray *columns = [hitzones_ objectAtIndex:row];
    for (int col = view.left; col < view.cols + view.left; col++) {
      [columns replaceObjectAtIndex:col withObject:view];
    }
  }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  //[self testTouches:touches];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  //[self testTouches:touches];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  NSArray *views = [self testTouches:touches];
  for (int i = 0; i < views.count; i++) {
    TextArtView *view = [views objectAtIndex:i];
    if (view.delegate &&
        [view.delegate respondsToSelector:@selector(textArtViewWasClicked:)]) {
      [view.delegate textArtViewWasClicked:view];
    }
  }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  
}

- (NSArray *)testTouches:(NSSet *)touches {
  NSArray *touchesArray = [touches allObjects];
  NSMutableArray *matchesArray = [NSMutableArray array];
  for (int i = 0; i < [touches count]; i++) {
    UITouch *touch = [touchesArray objectAtIndex:i];
    CGPoint location = [touch locationInView:self];
    float rowHeight = 14.0;
    float colWidth = 7.2;
    
    int row = floorf(location.y / rowHeight);
    int col = floorf(location.x / colWidth);
    TextArtView *tav = [self hitForRow:row column:col];
    if (tav) [matchesArray addObject:tav];
  }
  return matchesArray;
}

- (id)hitForRow:(int)row column:(int)column {
  if (row < 0 || column < 0) return nil;
  if (row >= rows_ || column >= cols_) return nil;
  
  TextArtView *hit = [[hitzones_ objectAtIndex:row] objectAtIndex:column];
  if (![hit isEqual:self]) {
    hit = [hit hitForRow:(row - hit.top) column:(column - hit.left)];
  }
  return hit;
}

- (void)dealloc {
  [name_ release];
  [canvas_ release];
  [chars_ release];
  [subTextArtViews_ release];
  [super dealloc];
}

@end
