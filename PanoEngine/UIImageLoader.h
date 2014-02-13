#import <UIKit/UIKit.h>

@protocol UIImageLoader <NSObject>
@required
- (UIImage *)loadImageWithAssetID:(NSString *)assetID;

@end
