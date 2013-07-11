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
#import "PDFParser.h"
#import "DataSource.h"

@interface DJViewController ()<UICollectionViewDelegate>{
    PDFPreview * pdf;
    PDFParser * parser;
    NSString * path;
}
@property (strong,nonatomic) UICollectionView * cv;
@property(strong,nonatomic) UIScrollView * scrollView;
@property (strong, nonatomic) IBOutlet UIButton *parseButton;
@property (strong, nonatomic) DataSource * datasource;
@property (strong,nonatomic) NSMutableArray * itemsList;

@end

@implementation DJViewController
- (IBAction)parse:(id)sender {
    [parser createThumbnailsWithName:@"PDFName"];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    DJAppDelegate *appDelegate = (DJAppDelegate *) ApplicationDelegate;
    
    if(appDelegate.url){
        path = [appDelegate.url absoluteString];
    }
    else{
        path = [[NSBundle mainBundle]pathForResource:@"ios5" ofType:@"pdf"];
    }
    parser = [[PDFParser alloc]initWithFilePath:path];
    _itemsList = [[NSMutableArray alloc]initWithCapacity:0];
    
    
}

-(void)viewDidAppear:(BOOL)animated{
    [self addPDF];
    [self.view addSubview:self.parseButton];
}

-(void)configureColectionView{
    _cv = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ViewWidth(self.view), 200)];
    [self.view addSubview:_cv];
    // get initial items. let's say 20?
    NSError * error;
    NSFileManager * fm = [NSFileManager defaultManager];
    NSString * folder = [DOCUMENT_FOLDER stringByAppendingPathComponent:@"PDFName"];
   NSArray * files  = [fm contentsOfDirectoryAtPath:folder error:&error];
    if(error){
        NSLog(@"Error while accessing files %@",[error debugDescription]);
    }
    NSLog(@"Files %@",files);

    //_datasource = [[DataSource alloc]initWithItems:<#(NSArray *)#> cellIdentifier:<#(NSString *)#> configureCellBlock:<#^(id cell, id item, id indexPath)block#>]
    
    
    
}

-(void)addPDF{
       
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
