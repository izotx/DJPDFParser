//
//  PDFParser.m
//  DJPDFParser
//
//  Created by sadmin on 6/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "PDFParser.h"
#import "Macro.h"
#import "PDFGeneratorOperation.h"


#define fillFactor 0.9
#define ThumbSize 800
@interface PDFParser(){
    CGPDFDocumentRef document;
    NSString * filePath;
    size_t count;
    NSOperation * blockOperation;
}

@property(nonatomic, strong) NSOperationQueue *queue;
@end

@implementation PDFParser


-(id)initWithFilePath:(NSString*)filename{
    self = [super init];
    if(self){
        //document = [self MyGetPDFDocumentRef: filename];
        filePath = filename;
        blockOperation = [[NSOperation alloc]init];
        _queue = [[NSOperationQueue alloc]init];
        _queue.maxConcurrentOperationCount = 4;
        
    }
    return self;
}


//gets pdf document ref
-(CGPDFDocumentRef) MyGetPDFDocumentRef: (NSString *) fileName;{
    CFStringRef path;
    CFURLRef url;

    const char *cfileName = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
    path = CFStringCreateWithCString (NULL, cfileName,
                                      
                                      kCFStringEncodingUTF8);
    
    url = CFURLCreateWithFileSystemPath (NULL, path, // 1
                                         
                                         kCFURLPOSIXPathStyle, 0);
    
    CFRelease (path);
    CGPDFDocumentRef  _document = CGPDFDocumentCreateWithURL (url);// 2
    CFRelease(url);
    
    count = CGPDFDocumentGetNumberOfPages (_document);// 3
    
    if (count == 0) {
        
        printf("`%s' needs at least one page!", cfileName);
        
        return NULL;
        
    }
    
    return _document;
}
//returns number of pages in pdf
-(size_t)getNumberOfPages{
    if(!document){
        document  = [self MyGetPDFDocumentRef:filePath];
    }
  
    return count;
}




//Displays page in context
-(void)displayPDFPage:(CGContextRef)context andPageNumber:(size_t) pageNumber{
    
    CGPDFPageRef page;
    CGFloat scaleRatio;
    document  = [self MyGetPDFDocumentRef:filePath];
    page = CGPDFDocumentGetPage (document, pageNumber);// 2
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFBleedBox);
     
    if(pageRect.size.width/pageRect.size.height < 1.0) {
        scaleRatio = _box.size.height * fillFactor/pageRect.size.height;
    }
    else {
        scaleRatio = _box.size.width * fillFactor /pageRect.size.width;
    }
   
    CGAffineTransform pdfTransform = CGAffineTransformScale(CGAffineTransformIdentity, scaleRatio, scaleRatio);
    
    CGContextConcatCTM(context, pdfTransform);
    CGContextDrawPDFPage (context, page);// 3
    CGPDFDocumentRelease (document);// 4
}


-(UIImage *)imageForPage:(int)pageNumber {
    
    CGPDFDocumentRef _document  = [self MyGetPDFDocumentRef:filePath];
    CGPDFPageRef page = CGPDFDocumentGetPage (_document, pageNumber);
    
    
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFBleedBox);
    CGSize pageSize = pageRect.size;
    CGSize thumbSize = CGSizeMake(ThumbSize,ThumbSize);
    pageSize = thumbSize;
    
    UIGraphicsBeginImageContextWithOptions(pageSize, NO, 0.0);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextTranslateCTM(context, 0.0, pageSize.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSaveGState(context);
    
    CGAffineTransform pdfTransform = CGPDFPageGetDrawingTransform(page, kCGPDFCropBox, CGRectMake(0, 0, pageSize.width, pageSize.height), 0, true);
    CGContextConcatCTM(context, pdfTransform);
    
    CGContextDrawPDFPage(context, page);
    CGContextRestoreGState(context);
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGPDFDocumentRelease (_document);
    return resultingImage;
}

-(void)createThumbnailsWithName:(NSString *)name{
    __block int pageCount = [self getNumberOfPages];
    int totalCount = [self getNumberOfPages];
    __block float progress = 0.0;
    for(int i =1; i<totalCount;i++){
    PDFGeneratorOperation * generator = [[PDFGeneratorOperation alloc]initWithPageNumber:i andPDFParser:self andName:name
                                             
                                                                          andCompletionBlock:^(UIImage * image)
                                             {
                                             }];
        generator.completionBlock =^{
            //decrease count of
            
            pageCount--;
            progress = 100 * (totalCount - pageCount)/totalCount*1.0f;
            NSLog(@"%.1f%%",progress);
            
        };
        [blockOperation addDependency:generator];
        [_queue addOperation:generator];
    }
    [_queue addOperation: blockOperation];
    
    [blockOperation setCompletionBlock:^(){
        NSLog(@"Completed ");
        
    }];
    
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
