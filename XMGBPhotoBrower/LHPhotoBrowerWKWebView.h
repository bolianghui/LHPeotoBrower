//
//  LHPhotoBrowerWKWebView.h
//  XMGBPhotoBrower
//
//  Created by macbook pro on 2017/6/13.
//  Copyright © 2017年 machao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@protocol  LHPhotoBrowerWebViewDelegate<NSObject>

@optional
- (BOOL)xmgWebView:(WKWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(void (^)(WKNavigationActionPolicy))decisionHandler;
- (void)xmgWebViewDidStartLoad:(WKWebView *)webView;
- (void)xmgWebViewDidFinishLoad:(WKWebView *)webView;
- (void)xmgWebView:(WKWebView *)webView didFailLoadWithError:(NSError *)error;

@end

@interface LHPhotoBrowerWKWebView : WKWebView

/**
 如果还想监听webview的代理方法，请遵循这个代理，并实现上面的方法
 */
@property (nonatomic, weak) id<LHPhotoBrowerWebViewDelegate> wkWebViewDelegate;

@end
