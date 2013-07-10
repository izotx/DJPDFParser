//
//  PDFPreview.m
//  DJPDFParser
//
//  Created by Janusz Chudzynski on 6/25/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "PDFPreview.h"
#import "PDFParser.h"
#import "Macro.h"
#import "PDFGenerator.h"

@interface PDFPreview()<UIGestureRecognizerDelegate>
{
    PDFParser * pdf;  // used for parsing and displaying pages of pdf
    //gestures used for interacting with pdf
    
    UISwipeGestureRecognizer * swipeLeft;
    UISwipeGestureRecognizer * swipeRight;
    UISwipeGestureRecognizer * curlUp;
    UISwipeGestureRecognizer * curlDown;
    UIPinchGestureRecognizer * pinchGesture;
    UIPanGestureRecognizer   * panGesture;
    UITapGestureRecognizer   * tapGesture;
    
    UIImage * screenshot;
    NSMutableArray * screenshots;
    
    NSOperation * blockOperation;
    int pageCounter;// =0;
    
    float scale;
}
@end

@implementation PDFPreview
int pageNr;

/*
 Custom init method:
 pass here the path to the pdf file you would like to display.
 */
- (id)initWithFrame:(CGRect)frame andFilePath:(NSString *)_filePath;
{
    self = [super initWithFrame:frame];

    if (self) {
        // Initialization code
        pdf = [[PDFParser alloc]initWithFilePath:_filePath];
        pdf.box = self.bounds;
        pageNr = 1;
        self.userInteractionEnabled = YES;
        swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(viewSwiped:)];
        swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        swipeLeft.delegate = self;
        swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(viewSwiped:)];
        swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
        swipeRight.delegate = self;

        curlUp = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(viewSwiped:)];
        curlUp.direction = UISwipeGestureRecognizerDirectionUp;
        curlUp.delegate = self;
        
        curlDown = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(viewSwiped:)];
        curlDown.direction = UISwipeGestureRecognizerDirectionDown;
        curlDown.delegate = self;
        
        pinchGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(viewPinched:)];
        pinchGesture.scale = 1;
        pinchGesture.delegate = self;


        tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(viewTapOn:)];
        tapGesture.numberOfTapsRequired = 2;
        
        panGesture= [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(viewPanned:)];
        
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        
        //initial scale
        scale = 1;
        
        [self addGestureRecognizer:swipeLeft];
        [self addGestureRecognizer:swipeRight];
        [self addGestureRecognizer:curlUp];
        [self addGestureRecognizer:curlDown];
        [self addGestureRecognizer:tapGesture];
        
        [self addGestureRecognizer:pinchGesture];
       // [self addGestureRecognizer:panGesture];
        
        screenshots = [[NSMutableArray alloc]initWithCapacity:0];
       
        NSOperationQueue * queue = [[NSOperationQueue alloc]init];
        queue.maxConcurrentOperationCount  = 8;
        self.queue = queue;
        blockOperation = [[NSOperation alloc]init];
        pageCounter = 1;
    }
    return self;
}

-(void)viewTapOn:(UITapGestureRecognizer *)_tap{
    NSLog(@"Tap");
    //[self setNeedsDisplay];
//    __weak  PDFParser * weakParser = pdf;
//    __weak int pageCount = pageCounter;
//    [blockOperation addExecutionBlock:^{
//        UIImage * im =   [weakParser imageForPage:pageCount];
//        [weakParser saveImage:im withFileName: [NSString stringWithFormat:@"image%d",pageCount] ofType:@"jpg" inDirectory:DOCUMENT_FOLDER];
//    }];
//   
//    for(int i =1; i<81;i++){
//       if(
//    
//    }
//    

//    
//    [_queue addOperationWithBlock:^(){
//        for(int i =1; i<81;i++){
//            UIImage * im =   [pdf imageForPage:i];
//            [pdf saveImage:im withFileName: [NSString stringWithFormat:@"image%d",i] ofType:@"jpg" inDirectory:DOCUMENT_FOLDER];
//        }
//        [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//
//        }];
//    }];
    
// 
    
    stephan_raabe@apple.com 
  // NSMutableArray * operations = [[NSMutableArray alloc]initWithCapacity:0];
    __weak NSMutableArray * weakScreenshots = screenshots;
    for(int i =1; i<81;i++){
         PDFGenerator * generator = [[PDFGenerator alloc]initWithPageNumber:i andPDFParser:pdf andCompletionBlock:^(UIImage * image)
         {
           // [weakScreenshots addObject:image];
         }];
        [blockOperation addDependency:generator];
        [_queue addOperation:generator];
     }
    [_queue addOperation: blockOperation];
    
    [blockOperation setCompletionBlock:^(){
       // NSLog(@"Completed %@",weakScreenshots);
    
    }];
  
    
         //[blockOperation addDependency:[[operations addObject:[[PDFGenerator alloc]initWithPageNumber:i andPDFParser:pdf]];
    
////    [_queue addOperations:operations waitUntilFinished: NO];
//    if(operations.count >0){
//        NSLog(@"Dependencies: %@ %@",blockOperation.dependencies,[operations objectAtIndex:0]);
//       // for(PDFGenerator * op in operations ){
//         //   [_queue addOperation:op];
//        //}
//        
//        [_queue addOperation:blockOperation];
//    
//    
//    }
}

-(void)viewPanned:(UIPanGestureRecognizer *)_pan{
    NSLog(@"Pan Gesture");
    [self setNeedsDisplay];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    
    return YES;
}


-(void)viewPinched:(UIPinchGestureRecognizer *)_pinch{
    
    if(_pinch.scale >=0.5 ||_pinch.scale <=10.0)
    {
        scale = _pinch.scale;
        [self setNeedsDisplay];
    }

}
-(void)viewSwiped:(UISwipeGestureRecognizer *)_swipe{
    if(_swipe.direction == UISwipeGestureRecognizerDirectionRight)
    {
           [self previousPage:NO];
    }
    if(_swipe.direction == UISwipeGestureRecognizerDirectionDown)
    {
           [self previousPage:YES];
    }

    
    else if(_swipe.direction == UISwipeGestureRecognizerDirectionLeft)
    {
           [self nextPage:NO];
    }
    else if(_swipe.direction == UISwipeGestureRecognizerDirectionUp)
    {
           [self nextPage:YES];
    }
}


-(void)nextPage:(BOOL)up{
    size_t k = pdf.getNumberOfPages;
    
    UIViewAnimationOptions animationOptions =up? UIViewAnimationOptionTransitionCurlUp: UIViewAnimationOptionTransitionCurlUp;
    
    if(pageNr<k-1){
        pageNr++;
        
        [UIView transitionWithView:self duration:0.51 options:animationOptions animations:^
         {
            // self.alpha = 0;
            [self setNeedsDisplay];
         } completion:^(BOOL completed){
            if(completed){
            }
        }];
    }
}

-(void)previousPage:(BOOL)down{
    
    UIViewAnimationOptions animationOptions =down? UIViewAnimationOptionTransitionCurlDown: UIViewAnimationOptionTransitionCurlDown;
    if(pageNr>1){
        pageNr--;
        [UIView transitionWithView:self duration:0.51 options:animationOptions animations:^
         {
           [self setNeedsDisplay];
         } completion:^(BOOL completed){
             if(completed){
             }
         }];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [[UIColor whiteColor]CGColor]);
    CGContextFillRect(context, self.bounds);
    CGContextTranslateCTM(context, 0.0, self.bounds.size.height);
    CGContextScaleCTM(context, scale, -scale);
    CGPoint translation = [panGesture translationInView:self];
    CGContextTranslateCTM(context, -translation.x, translation.y);
    if(!self.getAllPages){
        [pdf displayPDFPage:context andPageNumber:pageNr];
    }else{
//        if(screenshots.count==0){
//            [_queue addOperationWithBlock:^(){
//                NSArray * im = [pdf getAllPagesForContext:context];
//               //screenshots = im;
//                [[NSOperationQueue mainQueue] addOperationWithBlock: ^ {
//                    CGContextDrawImage(context, self.bounds, [[screenshots lastObject]CGImage ]);
//                }];
//            }];
//        }
    }
}


@end
