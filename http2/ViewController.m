//
//  ViewController.m
//  http2
//
//  Created by derik on 2016/12/27.
//  Copyright © 2016年 dk. All rights reserved.
//

#import "ViewController.h"
#import "AFHTTPSessionManager.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel *resultLabel;
@property (nonatomic, strong) UIButton *normalButton;
@property (nonatomic, strong) UIButton *afnetworkingButton;
@property (nonatomic, strong) UITextView *resultTextView;
@property (nonatomic, strong) UIWebView *webView;

@end

@implementation ViewController
{
    NSURLSession *session;
    AFHTTPSessionManager *manager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    session = [NSURLSession sharedSession];
    
    manager = [AFHTTPSessionManager manager];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    manager.securityPolicy.allowInvalidCertificates = YES;
    manager.securityPolicy.validatesDomainName = NO;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", nil];
    
    self.normalButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 100, self.view.frame.size.width / 2.0f - 10, 100)];
    self.normalButton.backgroundColor = [UIColor lightGrayColor];
    [self.normalButton setTitle:@"Native" forState:UIControlStateNormal];
    [self.normalButton addTarget:self action:@selector(testHttp2WithNative) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.normalButton];
    
    self.afnetworkingButton = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.normalButton.frame) + 20, 100, self.view.frame.size.width / 2.0f - 10, 100)];
    self.afnetworkingButton.backgroundColor = [UIColor lightGrayColor];
    [self.afnetworkingButton setTitle:@"AFNetworking 3.0" forState:UIControlStateNormal];
    [self.afnetworkingButton addTarget:self action:@selector(testHttp2WithAFNetworking) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.afnetworkingButton];
    
    self.resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.afnetworkingButton.frame) + 20, self.view.frame.size.width, 30)];
    self.resultLabel.textColor = [UIColor blackColor];
    self.resultLabel.textAlignment = NSTextAlignmentCenter;
    self.resultLabel.text = @"";
    [self.view addSubview:self.resultLabel];
    
    self.resultTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.resultLabel.frame) + 20, self.view.frame.size.width, self.view.frame.size.height - (CGRectGetMaxY(self.resultLabel.frame) + 20))];
    self.resultTextView.textColor = [UIColor blackColor];
//    [self.view addSubview:self.resultTextView];
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.resultLabel.frame) + 20, self.view.frame.size.width, self.view.frame.size.height - (CGRectGetMaxY(self.resultLabel.frame) + 20))];
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)testHttp2WithNative
{
    self.resultTextView.text = @"";
    self.resultLabel.text = @"";
    [self.webView loadHTMLString:@"" baseURL:nil];
    
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    
    NSURL *url = [NSURL URLWithString:@"https://http2.akamai.com"];
    
    NSURLSessionTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        if ([str containsString:@"You are using HTTP/2 right now!"]) {
            NSLog(@"Used HTTP/2");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultLabel.text = @"Used HTTP/2";
                self.resultTextView.text = str;
                [self.webView loadHTMLString:str baseURL:nil];
            });
        }
        else {
            NSLog(@"Used HTTP1.1");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultLabel.text = @"Used HTTP1.1";
                self.resultTextView.text = str;
                [self.webView loadHTMLString:str baseURL:nil];
            });
        }
    }];
    
    [task resume];
}

- (void)testHttp2WithAFNetworking
{
    NSURL *url = [NSURL URLWithString:@"https://http2.akamai.com"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:30.0f];
    
    [[manager dataTaskWithRequest:request completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        NSString *str = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        
        if ([str containsString:@"You are using HTTP/2 right now!"]) {
            NSLog(@"Used HTTP/2");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultLabel.text = @"Used HTTP/2";
                self.resultTextView.text = str;
                [self.webView loadHTMLString:str baseURL:nil];
            });
        }
        else {
            NSLog(@"Used HTTP1.1");
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resultLabel.text = @"Used HTTP1.1";
                self.resultTextView.text = str;
                [self.webView loadHTMLString:str baseURL:nil];
            });
        }
    }] resume];
}

@end
