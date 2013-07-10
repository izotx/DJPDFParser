//
//  PDFParser.m
//  DJPDFParser
//
//  Created by sadmin on 6/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "PDFParser.h"
#import "Macro.h"

#define fillFactor 0.9
@interface PDFParser(){
    CGPDFDocumentRef document;
    NSString * filePath;
    
}
@end
@implementation PDFParser


-(id)initWithFilePath:(NSString*)filename{
    self = [super init];
    if(self){
        //document = [self MyGetPDFDocumentRef: filename];
        filePath = filename;
    }
    return self;
}


//gets pdf document ref
-(CGPDFDocumentRef) MyGetPDFDocumentRef: (NSString *) fileName;{
    CFStringRef path;
    
    CFURLRef url;
    size_t count;
    
    const char *cfileName = [fileName cStringUsingEncoding:NSUTF8StringEncoding];
    
    path = CFStringCreateWithCString (NULL, cfileName,
                                      
                                      kCFStringEncodingUTF8);
    
    url = CFURLCreateWithFileSystemPath (NULL, path, // 1
                                         
                                         kCFURLPOSIXPathStyle, 0);
    
    CFRelease (path);
    
    document = CGPDFDocumentCreateWithURL (url);// 2
    
    CFRelease(url);
    
    count = CGPDFDocumentGetNumberOfPages (document);// 3
    
    if (count == 0) {
        
        printf("`%s' needs at least one page!", cfileName);
        
        return NULL;
        
    }
    
    return document;
}
//returns number of pages in pdf
-(int)getNumberOfPages{
  
    document  = [self MyGetPDFDocumentRef:filePath];
   
    int pageCount = CGPDFDocumentGetNumberOfPages(document);
    CGPDFDocumentRelease (document);// 4

    return pageCount;
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

//get all pages
-(NSArray *) getAllPagesForContext:(CGContextRef )context{
    CGPDFPageRef page;
    CGFloat scaleRatio;
    document  = [self MyGetPDFDocumentRef:filePath];
    int count = CGPDFDocumentGetNumberOfPages (document);// 3
    NSMutableArray * a = [[NSMutableArray alloc]initWithCapacity:0];
    for (int i = 1; i<count; i++){
        //CGContextRef context = UIGraphicsGetCurrentContext();
        page = CGPDFDocumentGetPage (document, i);// 2
        CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFBleedBox);
        // CGRect thumbnailRect= CGRectMake(0, 0, 600, 600);
        //pageRect = thumbnailRect;
        UIGraphicsBeginImageContextWithOptions(pageRect.size, NO,0.0);

        if(pageRect.size.width/pageRect.size.height < 1.0) {
            scaleRatio = _box.size.height * fillFactor/pageRect.size.height;
        }
        else {
            scaleRatio = _box.size.width * fillFactor /pageRect.size.width;
        }
           
        CGAffineTransform pdfTransform = CGAffineTransformScale(CGAffineTransformIdentity, scaleRatio, scaleRatio);
        CGContextConcatCTM(context, pdfTransform);
        CGContextDrawPDFPage (context, page);// 3
        UIImage * im = UIGraphicsGetImageFromCurrentImageContext();
        [a addObject:im];
        UIGraphicsEndImageContext();
        [self saveImage:im withFileName:[NSString stringWithFormat:@"image%d",i] ofType:@"jpg" inDirectory:DOCUMENT_FOLDER];

    }
        CGPDFDocumentRelease (document);// 4s
    return [a copy];
}

-(UIImage *)imageForPage:(int)pageNumber {
    document  = [self MyGetPDFDocumentRef:filePath];
    
    CGPDFPageRef page = CGPDFDocumentGetPage (document, pageNumber);
    CGRect pageRect = CGPDFPageGetBoxRect(page, kCGPDFBleedBox);
    CGSize pageSize = pageRect.size;
    //CGSize thumbSize = CGSizeMake(600,600);
    //pageSize = thumbSize;
    
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
    
    return resultingImage;
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
