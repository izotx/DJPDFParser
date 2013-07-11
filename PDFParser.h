//
//  PDFParser.h
//  DJPDFParser
//
//  Created by sadmin on 6/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PDFParser : NSObject
typedef void (^THumbnailsGeneratedBlock)();

-(id)initWithFilePath:(NSString*)filename;
-(size_t)getNumberOfPages;
//Get PDF
-(CGPDFDocumentRef) MyGetPDFDocumentRef: (NSString *) fileName;
-(void)displayPDFPage:(CGContextRef)context andPageNumber:(size_t) pageNumber;
-(void)createThumbnailsWithName:(NSString *)name;

-(UIImage *)imageForPage:(int)pageNumber;
-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;

@property CGRect  box;
@end
