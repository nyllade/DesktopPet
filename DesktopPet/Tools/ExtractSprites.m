#import <Cocoa/Cocoa.h>
#import <ImageIO/ImageIO.h>
#import <UniformTypeIdentifiers/UniformTypeIdentifiers.h>

typedef struct {
    const char *id;
    const char *path;
} SpriteSource;

static unsigned char *CopyImageRGBA(CGImageRef image, size_t *outWidth, size_t *outHeight) {
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    size_t bytesPerRow = width * 4;
    unsigned char *data = calloc(height, bytesPerRow);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(data, width, height, 8, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);
    *outWidth = width;
    *outHeight = height;
    return data;
}

static CGRect ContentBounds(unsigned char *data, size_t width, size_t height) {
    size_t minX = width;
    size_t minY = height;
    size_t maxX = 0;
    size_t maxY = 0;
    BOOL found = NO;

    for (size_t y = 0; y < height; y++) {
        for (size_t x = 0; x < width; x++) {
            unsigned char *px = data + (y * width + x) * 4;
            if (px[3] < 16) continue;
            found = YES;
            minX = MIN(minX, x);
            minY = MIN(minY, y);
            maxX = MAX(maxX, x);
            maxY = MAX(maxY, y);
        }
    }

    if (!found) return CGRectMake(0, 0, width, height);
    size_t pad = 12;
    minX = minX > pad ? minX - pad : 0;
    minY = minY > pad ? minY - pad : 0;
    maxX = MIN(width - 1, maxX + pad);
    maxY = MIN(height - 1, maxY + pad);
    return CGRectMake(minX, minY, maxX - minX + 1, maxY - minY + 1);
}

static unsigned char *CropRGBA(unsigned char *source, size_t sourceWidth, CGRect crop, size_t *outWidth, size_t *outHeight) {
    size_t x0 = (size_t)crop.origin.x;
    size_t y0 = (size_t)crop.origin.y;
    size_t width = (size_t)crop.size.width;
    size_t height = (size_t)crop.size.height;
    unsigned char *out = calloc(width * height, 4);
    for (size_t y = 0; y < height; y++) {
        memcpy(out + y * width * 4, source + ((y0 + y) * sourceWidth + x0) * 4, width * 4);
    }
    *outWidth = width;
    *outHeight = height;
    return out;
}

static void SavePNG(unsigned char *data, size_t width, size_t height, NSString *path) {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, data, width * height * 4, NULL);
    CGImageRef image = CGImageCreate(width, height, 8, 32, width * 4, colorSpace, kCGImageAlphaLast | kCGBitmapByteOrder32Big, provider, NULL, false, kCGRenderingIntentDefault);
    NSURL *url = [NSURL fileURLWithPath:path];
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)url, (__bridge CFStringRef)UTTypePNG.identifier, 1, NULL);
    CGImageDestinationAddImage(destination, image, NULL);
    CGImageDestinationFinalize(destination);
    CFRelease(destination);
    CGImageRelease(image);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
}

static BOOL ProcessSource(SpriteSource source, NSString *outputDir) {
    NSString *input = [NSString stringWithUTF8String:source.path];
    NSURL *url = [NSURL fileURLWithPath:input];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (!imageSource) return NO;

    CGImageRef image = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);
    CFRelease(imageSource);
    if (!image) return NO;

    size_t width = 0;
    size_t height = 0;
    unsigned char *rgba = CopyImageRGBA(image, &width, &height);
    CGImageRelease(image);

    CGRect bounds = ContentBounds(rgba, width, height);
    size_t croppedWidth = 0;
    size_t croppedHeight = 0;
    unsigned char *cropped = CropRGBA(rgba, width, bounds, &croppedWidth, &croppedHeight);
    free(rgba);

    NSString *name = [NSString stringWithFormat:@"%s.png", source.id];
    NSString *output = [outputDir stringByAppendingPathComponent:name];
    SavePNG(cropped, croppedWidth, croppedHeight, output);
    free(cropped);

    printf("%s %zux%zu\n", output.UTF8String, croppedWidth, croppedHeight);
    return YES;
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc < 2) {
            fprintf(stderr, "Usage: ExtractSprites output-dir\n");
            return 2;
        }

        NSString *outputDir = [NSString stringWithUTF8String:argv[1]];
        [[NSFileManager defaultManager] createDirectoryAtPath:outputDir withIntermediateDirectories:YES attributes:nil error:nil];

        SpriteSource sources[] = {
            {"mochiCloudlet", "/Users/edabag/Downloads/Untitled Design Presentation/1.png"},
            {"ossiaNocturne", "/Users/edabag/Downloads/Untitled Design Presentation/2.png"},
            {"velvetHowl", "/Users/edabag/Downloads/Untitled Design Presentation/3.png"},
            {"nebulaNix", "/Users/edabag/Downloads/Untitled Design Presentation/4.png"},
            {"pippaOrbitpaw", "/Users/edabag/Downloads/Untitled Design Presentation/5.png"},
            {"lumaMoppet", "/Users/edabag/Downloads/Untitled Design Presentation/6.png"}
        };

        BOOL ok = YES;
        for (NSUInteger i = 0; i < sizeof(sources) / sizeof(SpriteSource); i++) {
            ok = ProcessSource(sources[i], outputDir) && ok;
        }
        return ok ? 0 : 1;
    }
}
