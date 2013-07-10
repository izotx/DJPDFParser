//
//  DJViewController.m
//  DJPDFParser
//
//  Created by sadmin on 6/23/13.
//  Copyright (c) 2013 DJMobileInc. All rights reserved.
//

#import "DJViewController.h"
#import "PDFPreview.h"
#import "Macro.h"
#import "DJAppDelegate.h"

@interface DJViewController (){
    PDFPreview * pdf;
}
@end

@implementation DJViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

-(void)viewDidAppear:(BOOL)animated{
    [self addPDF];
}


-(void)addPDF{
    DJAppDelegate *appDelegate = (DJAppDelegate *) ApplicationDelegate;
    NSString * path;
    if(appDelegate.url){
        path = [appDelegate.url absoluteString];
    }
    else{
        path = [[NSBundle mainBundle]pathForResource:@"ios5" ofType:@"pdf"];
    }
    
    pdf = [[PDFPreview alloc]initWithFrame:self.view.bounds andFilePath:path];
    pdf.getAllPages = NO;
    [self.view addSubview:pdf];
     
    
}


- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self addPDF];
//    [pdf setNeedsDisplay];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"receive memory warning in view controller");
    [pdf.queue cancelAllOperations];
   
}

@end
