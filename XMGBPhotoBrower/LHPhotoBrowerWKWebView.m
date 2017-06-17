//
//  LHPhotoBrowerWKWebView.m
//  XMGBPhotoBrower
//
//  Created by macbook pro on 2017/6/13.
//  Copyright © 2017年 machao. All rights reserved.
//

#import "LHPhotoBrowerWKWebView.h"
#import "SDPhotoBrowser.h"
#import "YYWebImage.h"

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface LHPhotoBrowerWKWebView ()<WKUIDelegate,WKNavigationDelegate,SDPhotoBrowserDelegate>
{
    NSMutableArray *_imageArray;
    NSMutableArray *_imageUrlArray;
}
@property (nonatomic, assign) NSInteger index;
/// 容器视图
@property (nonatomic, strong) UIView *contenterView;
@property (nonatomic, strong) WKUserScript *userScript;
@end

@implementation LHPhotoBrowerWKWebView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _contenterView = [[UIView alloc] init];
        _contenterView.center = self.center;
        [self addSubview:_contenterView];
        [self.configuration.userContentController addUserScript:self.userScript];
        self.UIDelegate = self;
        self.navigationDelegate = self;
       
    }
    return self;
}

#pragma mark - SDPhotoBrowserDelegate

- (NSURL *)photoBrowser:(SDPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *imageName = _imageUrlArray[index];
    NSURL *url = [[NSBundle mainBundle] URLForResource:imageName withExtension:nil];
    return url;
}

- (UIImage *)photoBrowser:(SDPhotoBrowser *)browser placeholderImageForIndex:(NSInteger)index
{
    UIImageView *imageView = _imageArray[index];
    return imageView.image;
}

- (WKUserScript *)userScript
{
    if (!_userScript) {
        static  NSString * const jsGetImages =
        @"function getImages(){\
        var objs = document.getElementsByTagName(\"img\");\
        var imgScr = '';\
        for(var i=0;i<objs.length;i++){\
        imgScr = imgScr + objs[i].src + '+';\
        };\
        return imgScr;\
        };function registerImageClickAction(){\
        var imgs=document.getElementsByTagName('img');\
        var length=imgs.length;\
        for(var i=0;i<length;i++){\
        img=imgs[i];\
        img.onclick=function(){\
        window.location.href='image-preview:'+this.src}\
        }\
        }";
        _userScript = [[WKUserScript alloc] initWithSource:jsGetImages injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    }
    return _userScript;
}



#pragma mark - 导航每次跳转调用跳转
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    // 获取点击的图片
    if ([navigationAction.request.URL.scheme isEqualToString:@"image-preview"]) {
        NSString *URLpath = [navigationAction.request.URL.absoluteString substringFromIndex:[@"image-preview:" length]];

        URLpath = [URLpath stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        for (NSInteger i = 0; i<_imageUrlArray.count; i++) {
            if ([URLpath isEqualToString:_imageUrlArray[i]]) {
                _index = i;
            }
        }

        SDPhotoBrowser *browser = [[SDPhotoBrowser alloc] init];
        browser.currentImageIndex = _index;
        browser.sourceImagesContainerView = _contenterView;
        browser.imageCount = _imageUrlArray.count;
        browser.delegate = self;
        [browser show];

    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //获取图片数组
        [webView evaluateJavaScript:@"getImages()" completionHandler:^(id _Nullable result, NSError * _Nullable error) {
            NSMutableArray *imgSrcArray = [NSMutableArray arrayWithArray:[result componentsSeparatedByString:@"+"]];
            if (imgSrcArray.count >= 2) {
                [imgSrcArray removeLastObject];
            }
            _imageUrlArray = imgSrcArray;
            _imageArray = [NSMutableArray array];
            for (NSInteger i = 0; i < _imageUrlArray.count; i++) {
                UIImageView *imageView = [YYAnimatedImageView new];
                 [_imageArray addObject:imageView];
                imageView.yy_imageURL = [NSURL URLWithString:_imageUrlArray[i]];
                [_contenterView addSubview:imageView];
            }

        }];
        
        [webView evaluateJavaScript:@"registerImageClickAction();" completionHandler:^(id _Nullable result, NSError * _Nullable error) {}];
        
    });
}


@end
