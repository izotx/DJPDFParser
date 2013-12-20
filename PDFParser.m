//
//  PDFParser.m
//  DJPDFParser
//
//  Created by sadmin on 6/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "PDFParser.h"
#import "PDFGeneratorOperation.h"
#import  "DJPDFPage.h"


@interface PDFParser(){
    CGPDFDocumentRef document;
    NSString * filePath;
    size_t count;
    NSOperation * blockOperation;
}
@property(nonatomic, strong) NSOperationQueue *queue;
@end

@implementation PDFParser

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if([keyPath isEqualToString:@"operationCount"]){
        if([[change objectForKey:@"new"] isEqual:@0]){
            self.completed = YES;
            NSLog(@"Completed");
        }
    }
}

-(void)clean{

    
}


-(id)initWithFilePath:(NSString*)filename{
    self = [super init];
    if(self){
        //document = [self MyGetPDFDocumentRef: filename];
        filePath = filename;
        blockOperation = [[NSOperation alloc]init];
        _queue = [[NSOperationQueue alloc]init];
        [_queue setMaxConcurrentOperationCount:3];
        [self.queue addObserver:self forKeyPath:@"operationCount" options:NSKeyValueObservingOptionNew context:nil];
       
    }
    return self;
}


//gets pdf document ref
-(CGPDFDocumentRef) CreatePDFDocumentRef: (NSString *) fileName;{
   
    const char *cfileName = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
    CFStringRef path = CFStringCreateWithCString (NULL, cfileName,
                                      
                                      kCFStringEncodingUTF8);
    
    //free((char*)cfileName);
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, path, // 1
                                         
                                         kCFURLPOSIXPathStyle, 0);
    
    CFRelease (path);
    
    CGPDFDocumentRef  _document = CGPDFDocumentCreateWithURL (url);// 2
    CFRelease(url);

    
    count = CGPDFDocumentGetNumberOfPages (_document);// 3
    
    if (count == 0) {
        NSLog(@"PDF needs at least one page");
        return NULL;
    }
    
    
    return _document;
}
//returns number of pages in pdf
-(size_t)getNumberOfPages{
    if(!document){
        document  = [self CreatePDFDocumentRef:filePath];
    }
    return count;
}


CGSize MEDSizeScaleAspectFit(CGSize size, CGSize maxSize) {
    CGFloat originalAspectRatio = size.width / size.height;
    CGFloat maxAspectRatio = maxSize.width / maxSize.height;
    CGSize newSize = maxSize;
    // The largest dimension will be the `maxSize`, and then we need to scale
    // the other dimension down relative to it, while maintaining the aspect
    // ratio.
    if (originalAspectRatio > maxAspectRatio) {
        newSize.height = maxSize.width / originalAspectRatio;
    } else {
        newSize.width = maxSize.height * originalAspectRatio;
    }
    
    return newSize;
}


-(UIImage *)imageForPage:(int)pageNumber sized:(CGSize)size{
    
    CGPDFDocumentRef _document  = [self CreatePDFDocumentRef:filePath];
    CGPDFPageRef page = CGPDFDocumentGetPage (_document, pageNumber);
    
    
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFArtBox);
    CGSize pageSize = pageRect.size;
    CGSize thumbSize = size;
    pageSize = MEDSizeScaleAspectFit(pageSize, thumbSize);
        
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextTranslateCTM(context, 0.0, pageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSaveGState(context);
    
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFArtBox, CGRectMake(0, 0, pageSize.width, pageSize.height), 0, true);
    CGContextConcatCTM(context, pdfTransform);
    
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease (_document);
    return resultingImage;
}


-(void)extractPagesUsingGCDGroup{
    
    
    dispatch_queue_t queue =
    dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
       int totalCount = [self getNumberOfPages];
       for(int i =1; i<totalCount;i++){
           dispatch_group_async(group, queue, ^{
               UIImage *  im = [self imageForPage:i sized:CGSizeMake(800, 600)];
               DJPDFPage * pdfPage = [[DJPDFPage alloc]init];
               pdfPage.img = im;
               pdfPage.index =i;
               self.processedPage =pdfPage;});
       }
    
    dispatch_group_notify(group,
                          dispatch_get_main_queue(), ^{NSLog(@"done");});
    

}


-(void)extractPagesUsingGCD{

    NSLog(@"Start");
    int totalCount = [self getNumberOfPages];
/*
    dispatch_queue_t myConcurrentDispatchQueue = dispatch_queue_create(
                                                                       "com.example.gcd.MyConcurrentDispatchQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(myConcurrentDispatchQueue, ^{
        for(int i =1; i<totalCount;i++){
            UIImage *  im = [self imageForPage:i sized:CGSizeMake(800, 600)];
            DJPDFPage * pdfPage = [[DJPDFPage alloc]init];
            pdfPage.img = im;
            pdfPage.index =i;
            self.processedPage =pdfPage;
        }
    });
    
*/
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        /*
         * some tasks here to be executed concurrently
         */
        for(int i =1; i<totalCount;i++){
            UIImage *  im = [self imageForPage:i sized:CGSizeMake(800, 600)];
            DJPDFPage * pdfPage = [[DJPDFPage alloc]init];
            pdfPage.img = im;
            pdfPage.index =i;
            self.processedPage =pdfPage;
        }
        
        /*
         * Then, execute a Block on the main dispatch queue
         */
        dispatch_async(dispatch_get_main_queue(), ^{
            /*
             * Here, some tasks that can work only on the main thread.
             */
            NSLog(@"hey! ");
        });
    });
    
}


-(void)extractPages{
    NSLog(@"Start");
    int totalCount = [self getNumberOfPages];
    for(int i =1; i<totalCount;i++){
        NSBlockOperation * bl = [[NSBlockOperation alloc]init];
        __weak NSBlockOperation * weakOperation = bl;
        __block UIImage *im;
        [bl addExecutionBlock:^{
            if(!weakOperation.isCancelled)
            {
                im = [self imageForPage:i sized:CGSizeMake(800, 600)];
                //load image to core data
            }
        }];
        [bl setCompletionBlock:^{
            DJPDFPage * pdfPage = [[DJPDFPage alloc]init];
            pdfPage.img = im;
            pdfPage.index =i;
            self.processedPage =pdfPage;
            
        }];
        [_queue addOperation:bl];
    }
}




-(void)createThumbnailsWithName:(NSString *)name{
    int totalCount = [self getNumberOfPages];
   __block int pageCount = totalCount;
    __block float progress = 0.0;
    for(int i =1; i<totalCount;i++){
    PDFGeneratorOperation * generator = [[PDFGeneratorOperation alloc]initWithPageNumber:i andPDFParser:self andName:name
                                             
                                                                            andCompletionBlock:^(UIImage * image, int l)
                                             {
                                                 pageCount--;
                                                 progress = 100 * (totalCount - pageCount)/totalCount*1.0f;
                                                 NSLog(@"%.1f%%",progress);

                                               
                                                 
                                             }];
        [_queue addOperation:generator];
    }

}


-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        [UIImagePNGRepresentation(image) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
    }
}


@end
