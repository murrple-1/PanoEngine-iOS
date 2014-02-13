#import "PanoramaLoader.h"
#import "UIImageLoader.h"

@interface JSONPanoramaLoader : NSObject <PanoramaLoader>
{
@private
	NSDictionary *_json;
    NSObject<UIImageLoader> *_loader;
}

- (id)initWithJSON:(NSDictionary *)json andUIImageLoader:(NSObject<UIImageLoader> *)loader;

@end
