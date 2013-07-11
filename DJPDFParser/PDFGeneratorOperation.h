//
//  PDFGenerator.h
//  DJPDFParser
//
//  Created by Janusz Chudzynski on 7/9/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import <Foundation/Foundation.h>
@class PDFParser;

@interface PDFGeneratorOperation : NSOperation
typedef void (^DJCompletionBlock)(UIImage *);
-(id)initWithPageNumber:(int)page andPDFParser:(PDFParser *)parser andName:(NSString *)folder andCompletionBlock:(DJCompletionBlock)block;

@property int pageCounter;
@property (strong, nonatomic) DJCompletionBlock djcompletionBlock;

@end
