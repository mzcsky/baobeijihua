//
//  GalleryPictureLK.m
//  baby
//
//  Created by zhang da on 14-3-21.
//  Copyright (c) 2014年 zhang da. All rights reserved.
//

#import "GalleryPictureLK.h"
#import "MemContainer.h"

@implementation GalleryPictureLK

@dynamic _id, galleryId, pictureId, index;

+ (NSString *)primaryKey {
    return @"_id";
}

+ (NSDictionary *)mapping {
    static NSDictionary *map = nil;
    if (!map) {
        map = [@{
                 @"_id": @"id"
                 } retain];
    }
    return map;
}
//获取照片
+ (NSArray *)getPicturesForGallery:(long)galleryId {
    return [[MemContainer me] getObjects:[NSPredicate predicateWithFormat:@"galleryId = %ld", galleryId]
                                   clazz:[GalleryPictureLK class]
                                 orderBy:@"index asc", nil];
}

@end
