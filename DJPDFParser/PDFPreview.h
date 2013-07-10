//
//  PDFPreview.h
//  DJPDFParser
//
//  Created by Janusz Chudzynski on 6/25/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PDFPreview : UIView

- (id)initWithFrame:(CGRect)frame andFilePath:(NSString *)filePath;
    @property BOOL getAllPages;
    @property(nonatomic,strong) NSOperationQueue * queue;

@end
