//
//  ViewController.m
//  WebJSTest
//
//  Created by luowei on 2018/9/10.
//  Copyright © 2018年 luowei. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>
#import "ViewController.h"

@interface ViewController () <UIWebViewDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, 2, 2)];
    [self.view addSubview:self.webView];
    self.webView.delegate = self;


    [self loadHTMLAndJS];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)btnAction:(id)sender {
    [self excuteWebJSWithFunctionName:@"hello" arguments:@[@"aaaaaaaa"]];
}



- (void)loadHTMLAndJS {
        //加载文件
        NSString *path = [[NSBundle mainBundle] pathForResource:@"test" ofType:@"js"];
        NSError *error;
        NSString *jsText = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:&error];
        if (!error) {
            [self loadHTMLWithJSText:jsText];
        }
}

- (void)loadHTMLWithJSText:(NSString *)jsText {
    NSString *HTMLString = [NSString stringWithFormat:@"<html><head><script>%@</script></head><body></body></html>", jsText];

    NSURL *fileURL = nil;
    fileURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"native.html"]];
//    [HTMLString writeToURL:fileURL atomically:YES];
    [HTMLString writeToURL:fileURL atomically:YES encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:HTMLString baseURL:fileURL];

}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self setupWebViewJSContext];
}


- (void)setupWebViewJSContext {
    self.webViewJSContext = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];

    //注册native方法
    self.webViewJSContext[@"pnu_log"] = ^(NSString *text) {
        NSLog(@"======== pnu_log:%@", text);
//        [[[UIAlertView alloc] initWithTitle:nil message:text delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    };

}


- (JSValue *)excuteWebJSWithFunctionName:(NSString *)functionName arguments:(NSArray *)arguments {
    JSValue *result = nil;
    JSValue *function = self.webViewJSContext[functionName];
    if (function) {
        result = [function callWithArguments:arguments];

    }
    return result;
}

@end
