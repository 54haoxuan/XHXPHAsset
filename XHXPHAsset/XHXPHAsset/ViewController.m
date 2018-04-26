//
//  ViewController.m
//  XHXPHAsset
//
//  Created by KAOPU on 2018/4/24.
//  Copyright © 2018年 KAOPU. All rights reserved.
//

#import "ViewController.h"

#import "KPFirstAlbumCell.h"
#import "KPOtherAlbumCell.h"
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSDate+XHXExtension.h"

static NSString *const FirstAlbumCell = @"firstAlbumCell";
static NSString *const OtherAlbumCell = @"otherAlbumCell";

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

/** collectionView */
@property (nonatomic, weak) UICollectionView *collectionView;


/**装图片的数组*/
@property (nonatomic, strong) NSMutableArray *imagesArray;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self getOriginalImages];
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat collectionW = self.view.frame.size.width;
    CGFloat collectionH = self.view.frame.size.height;
    CGRect frame = CGRectMake(0, 0, collectionW, collectionH);
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    collectionView.delegate = self;
    collectionView.dataSource = self;
    [self.view addSubview:collectionView];
    self.collectionView = collectionView;
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KPFirstAlbumCell class]) bundle:nil] forCellWithReuseIdentifier:FirstAlbumCell];
    [collectionView registerNib:[UINib nibWithNibName:NSStringFromClass([KPOtherAlbumCell class]) bundle:nil] forCellWithReuseIdentifier:OtherAlbumCell];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 20;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.item == 0 && self.imagesArray.count) {
        KPFirstAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:FirstAlbumCell forIndexPath:indexPath];
        cell.picArray = self.imagesArray;
        cell.backgroundColor = [UIColor redColor];
        return cell;
    }else{
        KPOtherAlbumCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:OtherAlbumCell forIndexPath:indexPath];
        cell.backgroundColor = [UIColor blueColor];
        return cell;
    }
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.item == 0 && self.imagesArray.count) {
        return CGSizeMake(self.view.frame.size.width-20, 200);
    }else{
        return CGSizeMake((self.view.frame.size.width - 30)*0.5, (self.view.frame.size.width - 30)*0.5);
    }
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsMake(0, 10, 0, 10);
}
//1.获得所有相簿的原图
- (void)getOriginalImages
{
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:YES];
    }
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    // 遍历相机胶卷,获取大图
    [self enumerateAssetsInAssetCollection:cameraRoll original:YES];
}

//2.获得所有相簿中的缩略图
- (void)getThumbnailImages
{
    // 获得所有的自定义相簿
    PHFetchResult<PHAssetCollection *> *assetCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    // 遍历所有的自定义相簿
    for (PHAssetCollection *assetCollection in assetCollections) {
        [self enumerateAssetsInAssetCollection:assetCollection original:NO];
    }
    // 获得相机胶卷
    PHAssetCollection *cameraRoll = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil].lastObject;
    [self enumerateAssetsInAssetCollection:cameraRoll original:NO];
}

/**
 *  遍历相簿中的所有图片
 *  @param assetCollection 相簿
 *  @param original        是否要原图
 */
- (void)enumerateAssetsInAssetCollection:(PHAssetCollection *)assetCollection original:(BOOL)original
{
    [self.imagesArray removeAllObjects];
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    // 同步获得图片, 只会返回1张图片
    options.synchronous = NO;
    // 获得某个相簿中的所有PHAsset对象
    PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:fetchOptions];
    
    for (PHAsset *asset in assets) {
        if (self.imagesArray.count >= 5) break;
        if (asset.creationDate.isToday && asset.mediaType == PHAssetMediaTypeImage) {//今天并且是图片类型
            // 是否要原图
            CGSize size = original ? CGSizeMake(asset.pixelWidth, asset.pixelHeight) : CGSizeZero;
            // 从asset中获得图片
            [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                [self.imagesArray addObject:result];
            }];
        }
    }
}

#pragma mark - lazy
- (NSMutableArray *)imagesArray{
    if (!_imagesArray) {
        _imagesArray = [[NSMutableArray alloc] init];
    }
    return _imagesArray;
}



@end
