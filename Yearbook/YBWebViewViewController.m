//
//  YBWebViewViewController.m
//  Yearbook
//
//  Created by Urmil Setia on 15/12/2016.
//  Copyright © 2016 Mars IS. All rights reserved.
//

#import "YBWebViewViewController.h"

@interface YBWebViewViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webViewForAction;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) NSURL *loadURL;
@end

@implementation YBWebViewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *doneBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneBtnPressed:)];
    self.navigationItem.rightBarButtonItem = doneBtn;
    [self.loadingIndicator startAnimating];
    self.webViewForAction.delegate = self;
    [self.webViewForAction loadRequest:[NSURLRequest requestWithURL:self.loadURL]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [self.loadingIndicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadAction:(NSURL *)URL{
    self.loadURL = URL;
}

-(void)doneBtnPressed:(id)sender {
    [self performSegueWithIdentifier:@"dismisswebView" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
