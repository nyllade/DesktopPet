#import <Cocoa/Cocoa.h>

static BOOL WriteIcon(NSString *sourcePath, NSString *outputPath, NSInteger pixels) {
    NSImage *source = [[NSImage alloc] initWithContentsOfFile:sourcePath];
    if (!source) return NO;

    NSBitmapImageRep *rep = [[NSBitmapImageRep alloc]
        initWithBitmapDataPlanes:NULL
                      pixelsWide:pixels
                      pixelsHigh:pixels
                   bitsPerSample:8
                 samplesPerPixel:4
                        hasAlpha:YES
                        isPlanar:NO
                  colorSpaceName:NSCalibratedRGBColorSpace
                    bitmapFormat:NSBitmapFormatAlphaNonpremultiplied
                     bytesPerRow:0
                    bitsPerPixel:0];
    if (!rep) return NO;

    [NSGraphicsContext saveGraphicsState];
    NSGraphicsContext *context = [NSGraphicsContext graphicsContextWithBitmapImageRep:rep];
    context.imageInterpolation = NSImageInterpolationHigh;
    [NSGraphicsContext setCurrentContext:context];
    [[NSColor clearColor] setFill];
    NSRectFill(NSMakeRect(0, 0, pixels, pixels));

    CGFloat margin = pixels * 0.09;
    CGFloat sourceWidth = source.size.width;
    CGFloat sourceHeight = source.size.height;
    CGFloat scale = MIN((pixels - margin * 2) / sourceWidth, (pixels - margin * 2) / sourceHeight);
    CGFloat width = sourceWidth * scale;
    CGFloat height = sourceHeight * scale;
    NSRect dest = NSMakeRect((pixels - width) / 2.0, (pixels - height) / 2.0, width, height);

    [source drawInRect:dest
              fromRect:NSZeroRect
             operation:NSCompositingOperationSourceOver
              fraction:1.0
        respectFlipped:NO
                 hints:@{ NSImageHintInterpolation: @(NSImageInterpolationHigh) }];
    [NSGraphicsContext restoreGraphicsState];

    NSData *data = [rep representationUsingType:NSBitmapImageFileTypePNG properties:@{}];
    return [data writeToFile:outputPath atomically:YES];
}

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        if (argc != 3) {
            fprintf(stderr, "usage: GenerateAppIcon source.png output.iconset\n");
            return 2;
        }

        NSString *sourcePath = [NSString stringWithUTF8String:argv[1]];
        NSString *iconsetPath = [NSString stringWithUTF8String:argv[2]];
        NSFileManager *fm = NSFileManager.defaultManager;
        [fm removeItemAtPath:iconsetPath error:nil];
        if (![fm createDirectoryAtPath:iconsetPath withIntermediateDirectories:YES attributes:nil error:nil]) {
            fprintf(stderr, "could not create iconset\n");
            return 1;
        }

        NSArray<NSDictionary *> *icons = @[
            @{@"name": @"icon_16x16.png", @"pixels": @16},
            @{@"name": @"icon_16x16@2x.png", @"pixels": @32},
            @{@"name": @"icon_32x32.png", @"pixels": @32},
            @{@"name": @"icon_32x32@2x.png", @"pixels": @64},
            @{@"name": @"icon_128x128.png", @"pixels": @128},
            @{@"name": @"icon_128x128@2x.png", @"pixels": @256},
            @{@"name": @"icon_256x256.png", @"pixels": @256},
            @{@"name": @"icon_256x256@2x.png", @"pixels": @512},
            @{@"name": @"icon_512x512.png", @"pixels": @512},
            @{@"name": @"icon_512x512@2x.png", @"pixels": @1024}
        ];

        for (NSDictionary *icon in icons) {
            NSString *path = [iconsetPath stringByAppendingPathComponent:icon[@"name"]];
            if (!WriteIcon(sourcePath, path, [icon[@"pixels"] integerValue])) {
                fprintf(stderr, "could not write %s\n", path.UTF8String);
                return 1;
            }
        }
    }
    return 0;
}
