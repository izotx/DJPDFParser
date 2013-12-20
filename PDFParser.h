//
//  PDFParser.h
//  DJPDFParser
//
//  Created by sadmin on 6/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DJPDFPage;

@interface PDFParser : NSObject
typedef void (^ThumbnailsGeneratedBlock)();

-(id)initWithFilePath:(NSString*)filename;
-(size_t)getNumberOfPages;

-(void)createThumbnailsWithName:(NSString *)name;
-(UIImage *)imageForPage:(int)pageNumber sized:(CGSize)size;
-(void) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath;
-(void)extractPages;


//for observing KVO
@property (readonly) float progress;
@property(nonatomic) BOOL completed;


@property (nonatomic,strong) DJPDFPage * processedPage;


@end
