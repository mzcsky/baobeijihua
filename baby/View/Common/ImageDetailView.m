//
//  ImageDetailView.m
//  baby
//
//  Created by zhang da on 14-4-2.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "ImageDetailView.h"

@implementation ImageDetailView


- (void)dealloc {
    [indicator release];

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];
	
	if (self) {
        
        holder = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        holder.backgroundColor = [UIColor blackColor];
        holder.delegate = self;
        holder.showsHorizontalScrollIndicator = NO;
        holder.showsVerticalScrollIndicator = NO;
        holder.alwaysBounceHorizontal = YES;
        holder.alwaysBounceVertical = YES;
        holder.maximumZoomScale = 3.0;
        holder.minimumZoomScale = 1.0;
        holder.contentInset = UIEdgeInsetsMake(30, 30, 30, 30);
        
        [self addSubview:holder];
        [holder release];
        
		imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        imageView.backgroundColor = [UIColor clearColor];
        imageView.userInteractionEnabled = YES;
        [holder addSubview:imageView];
        holder.contentSize = imageView.frame.size;
        [imageView release];
        
        indicator = [[UIActivityIndicatorView alloc]
                     initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.hidesWhenStopped = YES;
        indicator.frame = CGRectMake(frame.size.width/3, frame.size.height/3, frame.size.width/3, frame.size.height/3);
        indicator.userInteractionEnabled = NO;
        
        [self addSubview:indicator];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        tap.cancelsTouchesInView = YES;
        [holder addGestureRecognizer:tap];
        [tap release];
	}
	
	return self;
}


//子视图布局
- (void)layoutSubviews  {
    //基础视图布局约束
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    boundsSize.width = boundsSize.width - holder.contentInset.left - holder.contentInset.right;
    boundsSize.height = boundsSize.height - holder.contentInset.top - holder.contentInset.bottom;
    
    CGRect frameToCenter = imageView.frame;
    
//     center horizontally  水平
    if (frameToCenter.size.width < boundsSize.width)
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    else
        frameToCenter.origin.x = 0;
    
    // center vertically  垂直
    if (frameToCenter.size.height < boundsSize.height)
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    else
        frameToCenter.origin.y = 0;
    
#if kDebugImageHolder
    DLog(@"image view frame: %@", NSStringFromCGRect(frameToCenter));
#endif
    
    imageView.frame = frameToCenter;
}



#pragma mark utilities
//最大最小缩放
- (void)setMaxMinZoomScalesForCurrentBounds {
    CGSize boundsSize = self.bounds.size;
    boundsSize.width = boundsSize.width - holder.contentInset.left - holder.contentInset.right;
    boundsSize.height = boundsSize.height - holder.contentInset.top - holder.contentInset.bottom;
    
    CGSize imageSize = imageView.bounds.size;
    
    CGFloat minScale = 1, maxScale = 1;
    
    CGFloat xScale = boundsSize.width / imageSize.width, yScale = boundsSize.height / imageSize.height;
    if (xScale > 1 && yScale > 1) {
        maxScale = MAX(xScale, yScale);
    } else {
        minScale = MIN(xScale, yScale);
    }
    
    holder.maximumZoomScale = maxScale;
    holder.minimumZoomScale = minScale;
}
    //设置图片
- (void)setImage:(UIImage *)image {
    // reset our zoomScale to 1.0 before doing any further calculations 在进行任何进一步的计算之前，我们将缩放比例缩放至1
    holder.zoomScale = 1.0;
    holder.contentOffset = CGPointZero;
    
    // make a new UIImageView for the new image 做一个新的图像
    NSLog(@"%@", NSStringFromCGSize(image.size));
    imageView.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    imageView.image = image;
    
    holder.contentSize = image.size;
    
    //调用最大最小缩放
    [self setMaxMinZoomScalesForCurrentBounds];
    holder.zoomScale = holder.minimumZoomScale;
    
    [self layoutSubviews];
}
//2  图像路径
- (void)setImagePath:(NSString *)imagePath {
    [indicator startAnimating];//开始动画
//从磁盘获取图片
    [IMG getImage:imagePath callback:^(NSString *url, UIImage *image) {
        if ([imagePath isEqualToString:url]) {//图像路径
            
            [self setImage:image];
            
            [indicator stopAnimating];//停止动画
        }
    }];

}

- (UIImage *)image {
    return imageView.image;
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    // the zoom rect is in the content view's coordinates.
    //    At a zoom scale of 1.0, it would be the size of the imageScrollView's bounds.
    //    As the zoom scale decreases, so more content is visible, the size of the rect grows.
    zoomRect.size.height = self.frame.size.height / scale;
    zoomRect.size.width  = self.frame.size.width  / scale;
    
    // choose an origin so as to get the right center.
    zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
    
    return zoomRect;
}

- (void)singleTap:(UIGestureRecognizer *)gestureRecognizer {
    [self removeFromSuperview];
    
}



#pragma mark uiscrollview delegate
//滚动视图，缩放视图
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}
//滚动视图的缩放
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	[self centerImage];
}

- (void)centerImage {
	CGFloat offsetX = (holder.bounds.size.width > holder.contentSize.width)?
	(holder.bounds.size.width - holder.contentSize.width) * 0.5 : 0.0;
    CGFloat offsetY = (holder.bounds.size.height > holder.contentSize.height)?
	(holder.bounds.size.height - holder.contentSize.height) * 0.5 : 0.0;
    
	imageView.center = CGPointMake(holder.contentSize.width * 0.5 + offsetX,
							 holder.contentSize.height * 0.5 + offsetY);
}
@end
