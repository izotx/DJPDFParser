//
//  PDFGenerator.m
//  DJPDFParser
//
//  Created by Janusz Chudzynski on 7/9/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "PDFGeneratorOperation.h"
#import "PDFParser.h"
#import "Macro.h"

@interface PDFGeneratorOperation()
  @property(nonatomic,strong) PDFParser * pdf;
  @property (nonatomic, strong) NSString * folder;
@end

@implementation PDFGeneratorOperation

-(id)initWithPageNumber:(int)page andPDFParser:(PDFParser *)parser andName:(NSString *)folder andCompletionBlock:(DJCompletionBlock)block{
    self = [super init];
    if(self)
    {
        _pageCounter = page;
        _folder = folder;
        _pdf = parser;
        _djcompletionBlock = [block copy];
        
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if (self.isCancelled)
            return;
            UIImage * im =   [_pdf imageForPage:_pageCounter sized:CGSizeMake(800, 600)];
        if(im){
            _djcompletionBlock(im,_pageCounter);
        }
        if (self.isCancelled)
            return;
            NSString * folderPath = [DOCUMENT_FOLDER stringByAppendingPathComponent:_folder];
        
        NSFileManager * manager = [NSFileManager defaultManager];
        BOOL isDir;
        if(![manager fileExistsAtPath:folderPath isDirectory:&isDir])
        {   NSError * e;
            
                [manager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&e];
        }
        
        [_pdf saveImage:im withFileName: [NSString stringWithFormat:@"image%d",_pageCounter] ofType:@"jpg" inDirectory:folderPath];
    }
}



@end
