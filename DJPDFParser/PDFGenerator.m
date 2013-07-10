//
//  PDFGenerator.m
//  DJPDFParser
//
//  Created by Janusz Chudzynski on 7/9/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "PDFGenerator.h"
#import "PDFParser.h"
#import "Macro.h"

@implementation PDFGenerator

PDFParser * pdf;

-(id)initWithPageNumber:(int)page andPDFParser:(PDFParser *)parser andCompletionBlock:(DJCompletionBlock)block{
    self = [super init];
    if(self)
    {
        _pageCounter = page;
        NSLog(@" Page Counter is %d",page);
        pdf = parser;
        _djcompletionBlock = [block copy];
        
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled)
            return;
            UIImage * im =   [pdf imageForPage:_pageCounter];
        if(im){
            _djcompletionBlock(im);
        }
        if (self.isCancelled)
            return;
        
            [pdf saveImage:im withFileName: [NSString stringWithFormat:@"image%d",_pageCounter] ofType:@"jpg" inDirectory:DOCUMENT_FOLDER];
    }
}



@end
