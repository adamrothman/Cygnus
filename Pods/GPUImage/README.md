# GPUImage framework #

Brad Larson

http://www.sunsetlakesoftware.com

[@bradlarson](http://twitter.com/bradlarson)

contact@sunsetlakesoftware.com

## Overview ##

The GPUImage framework is a BSD-licensed iOS library that lets you apply GPU-accelerated filters and other effects to images, live camera video, and movies. In comparison to Core Image (part of iOS 5.0), GPUImage allows you to write your own custom filters, supports deployment to iOS 4.0, and has a simpler interface. However, it currently lacks some of the more advanced features of Core Image, such as facial detection.

For massively parallel operations like processing images or live video frames, GPUs have some significant performance advantages over CPUs. On an iPhone 4, a simple image filter can be over 100 times faster to perform on the GPU than an equivalent CPU-based filter.

However, running custom filters on the GPU requires a lot of code to set up and maintain an OpenGL ES 2.0 rendering target for these filters. I created a sample project to do this:

http://www.sunsetlakesoftware.com/2010/10/22/gpu-accelerated-video-processing-mac-and-ios

and found that there was a lot of boilerplate code I had to write in its creation. Therefore, I put together this framework that encapsulates a lot of the common tasks you'll encounter when processing images and video and made it so that you don't need to care about the OpenGL ES 2.0 underpinnings.

In initial benchmarks, this framework significantly outperforms Core Image when handling video, taking only 2.5 ms on an iPhone 4 to upload a frame from the camera, apply a sepia filter, and display, versus 149 ms for the same operation using Core Image. CPU-based processing takes 460 ms, making GPUImage 60X faster than Core Image on this hardware, and 184X faster than CPU-bound processing. On an iPhone 4S, GPUImage is only 13X faster than Core Image, and 102X faster than CPU-bound processing.

## License ##

BSD-style, with the full license available with the framework in License.txt.

## Technical requirements ##

- OpenGL ES 2.0: Applications using this will not run on the original iPhone, iPhone 3G, and 1st and 2nd generation iPod touches
- iOS 4.1 as a deployment target (4.0 didn't have some extensions needed for movie reading). iOS 4.3 is needed as a deployment target if you wish to show live video previews when taking a still photo.
- iOS 5.0 SDK to build
- Devices must have a camera to use camera-related functionality (obviously)
- The framework uses automatic reference counting (ARC), but should support projects using both ARC and manual reference counting if added as a subproject as explained below. For manual reference counting applications targeting iOS 4.x, you'll need add -fobjc-arc to the Other Linker Flags for your application project.

## General architecture ##

GPUImage uses OpenGL ES 2.0 shaders to perform image and video manipulation much faster than could be done in CPU-bound routines. However, it hides the complexity of interacting with the OpenGL ES API in a simplified Objective-C interface. This interface lets you define input sources for images and video, attach filters in a chain, and send the resulting processed image or video to the screen, to a UIImage, or to a movie on disk.

Images or frames of video are uploaded from source objects, which are subclasses of GPUImageOutput. These include GPUImageVideoCamera (for live video from an iOS camera), GPUImageStillCamera (for taking photos with the camera), GPUImagePicture (for still images), and GPUImageMovie (for movies). Source objects upload still image frames to OpenGL ES as textures, then hand those textures off to the next objects in the processing chain.

Filters and other subsequent elements in the chain conform to the GPUImageInput protocol, which lets them take in the supplied or processed texture from the previous link in the chain and do something with it. Objects one step further down the chain are considered targets, and processing can be branched by adding multiple targets to a single output or filter.

For example, an application that takes in live video from the camera, converts that video to a sepia tone, then displays the video onscreen would set up a chain looking something like the following:

    GPUImageVideoCamera -> GPUImageSepiaFilter -> GPUImageView

## Documentation ##

Documentation is generated from header comments using appledoc. To build the documentation, switch to the "Documentation" scheme in Xcode. You should ensure that "APPLEDOC_PATH" (a User-Defined build setting) points to an appledoc binary, available on <a href="https://github.com/tomaz/appledoc">Github</a> or through <a href="https://github.com/mxcl/homebrew">Homebrew</a>. It will also build and install a .docset file, which you can view with your favorite documentation tool.

## Built-in filters ##

### Color adjustments ###

- **GPUImageBrightnessFilter**: Adjusts the brightness of the image
  - *brightness*: The adjusted brightness (-1.0 - 1.0, with 0.0 as the default)

- **GPUImageExposureFilter**: Adjusts the exposure of the image
  - *exposure*: The adjusted exposure (-10.0 - 10.0, with 0.0 as the default)

- **GPUImageContrastFilter**: Adjusts the contrast of the image
  - *contrast*: The adjusted contrast (0.0 - 4.0, with 1.0 as the default)

- **GPUImageSaturationFilter**: Adjusts the saturation of an image
  - *saturation*: The degree of saturation or desaturation to apply to the image (0.0 - 2.0, with 1.0 as the default)

- **GPUImageGammaFilter**: Adjusts the gamma of an image
  - *gamma*: The gamma adjustment to apply (0.0 - 3.0, with 1.0 as the default)

- **GPUImageColorMatrixFilter**: Transforms the colors of an image by applying a matrix to them
  - *colorMatrix*: A 4x4 matrix used to transform each color in an image
  - *intensity*: The degree to which the new transformed color replaces the original color for each pixel

- **GPUImageRGBFilter**: Adjusts the individual RGB channels of an image
  - *red*: Normalized values by which each color channel is multiplied. The range is from 0.0 up, with 1.0 as the default.
  - *green*:
  - *blue*:

- **GPUImageHueFilter**: Adjusts the hue of an image
  - *hue*: The hue angle, in degrees. 90 degrees by default

- **GPUImageToneCurveFilter**: Adjusts the colors of an image based on spline curves for each color channel.
  - *redControlPoints*:
  - *greenControlPoints*:
  - *blueControlPoints*: The tone curve takes in a series of control points that define the spline curve for each color component. These are stored as NSValue-wrapped CGPoints in an NSArray, with normalized X and Y coordinates from 0 - 1. The defaults are (0,0), (0.5,0.5), (1,1).

- **GPUImageHighlightShadowFilter**: Adjusts the shadows and highlights of an image
  - *shadows*: Increase to lighten shadows, from 0.0 to 1.0, with 0.0 as the default.
  - *highlights*: Decrease to darken highlights, from 0.0 to 1.0, with 1.0 as the default.

- **GPUImageLookupFilter**: Uses an RGB color lookup image to remap the colors in an image. First, use your favourite photo editing application to apply a filter to lookup.png from GPUImage/framework/Resources. For this to work properly each pixel color must not depend on other pixels (e.g. blur will not work). If you need a more complex filter you can create as many lookup tables as required. Once ready, use your new lookup.png file as a second input for GPUImageLookupFilter.

- **GPUImageAmatorkaFilter**: A photo filter based on a Photoshop action by Amatorka: http://amatorka.deviantart.com/art/Amatorka-Action-2-121069631 . If you want to use this effect you have to add lookup_amatorka.png from the GPUImage Resources folder to your application bundle.

- **GPUImageMissEtikateFilter**: A photo filter based on a Photoshop action by Miss Etikate: http://miss-etikate.deviantart.com/art/Photoshop-Action-15-120151961 . If you want to use this effect you have to add lookup_miss_etikate.png from the GPUImage Resources folder to your application bundle.

- **GPUImageSoftEleganceFilter**: Another lookup-based color remapping filter. If you want to use this effect you have to add lookup_soft_elegance_1.png and lookup_soft_elegance_2.png from the GPUImage Resources folder to your application bundle.

- **GPUImageColorInvertFilter**: Inverts the colors of an image

- **GPUImageGrayscaleFilter**: Converts an image to grayscale (a slightly faster implementation of the saturation filter, without the ability to vary the color contribution)

- **GPUImageMonochromeFilter**: Converts the image to a single-color version, based on the luminance of each pixel
  - *intensity*: The degree to which the specific color replaces the normal image color (0.0 - 1.0, with 1.0 as the default)
  - *color*: The color to use as the basis for the effect, with (0.6, 0.45, 0.3, 1.0) as the default.

- **GPUImageFalseColorFilter**: Uses the luminance of the image to mix between two user-specified colors
  - *firstColor*: The first and second colors specify what colors replace the dark and light areas of the image, respectively. The defaults are (0.0, 0.0, 0.5) amd (1.0, 0.0, 0.0).
  - *secondColor*:

- **GPUImageSepiaFilter**: Simple sepia tone filter
  - *intensity*: The degree to which the sepia tone replaces the normal image color (0.0 - 1.0, with 1.0 as the default)

- **GPUImageOpacityFilter**: Adjusts the alpha channel of the incoming image
  - *opacity*: The value to multiply the incoming alpha channel for each pixel by (0.0 - 1.0, with 1.0 as the default)

- **GPUImageSolidColorGenerator**: This outputs a generated image with a solid color. You need to define the image size using -forceProcessingAtSize:
 - *color*: The color, in a four component format, that is used to fill the image.

- **GPUImageLuminanceThresholdFilter**: Pixels with a luminance above the threshold will appear white, and those below will be black
  - *threshold*: The luminance threshold, from 0.0 to 1.0, with a default of 0.5

- **GPUImageAdaptiveThresholdFilter**: Determines the local luminance around a pixel, then turns the pixel black if it is below that local luminance and white if above. This can be useful for picking out text under varying lighting conditions.

- **GPUImageAverageLuminanceThresholdFilter**: This applies a thresholding operation where the threshold is continually adjusted based on the average luminance of the scene.
  - *thresholdMultiplier*: This is a factor that the average luminance will be multiplied by in order to arrive at the final threshold to use. By default, this is 1.0.

- **GPUImageHistogramFilter**: This analyzes the incoming image and creates an output histogram with the frequency at which each color value occurs. The output of this filter is a 3-pixel-high, 256-pixel-wide image with the center (vertical) pixels containing pixels that correspond to the frequency at which various color values occurred. Each color value occupies one of the 256 width positions, from 0 on the left to 255 on the right. This histogram can be generated for individual color channels (kGPUImageHistogramRed, kGPUImageHistogramGreen, kGPUImageHistogramBlue), the luminance of the image (kGPUImageHistogramLuminance), or for all three color channels at once (kGPUImageHistogramRGB).
  - *downsamplingFactor*: Rather than sampling every pixel, this dictates what fraction of the image is sampled. By default, this is 16 with a minimum of 1. This is needed to keep from saturating the histogram, which can only record 256 pixels for each color value before it becomes overloaded.

- **GPUImageHistogramGenerator**: This is a special filter, in that it's primarily intended to work with the GPUImageHistogramFilter. It generates an output representation of the color histograms generated by GPUImageHistogramFilter, but it could be repurposed to display other kinds of values. It takes in an image and looks at the center (vertical) pixels. It then plots the numerical values of the RGB components in separate colored graphs in an output texture. You may need to force a size for this filter in order to make its output visible.

- **GPUImageAverageColor**: This processes an input image and determines the average color of the scene, by averaging the RGBA components for each pixel in the image. A reduction process is used to progressively downsample the source image on the GPU, followed by a short averaging calculation on the CPU. The output from this filter is meaningless, but you need to set the colorAverageProcessingFinishedBlock property to a block that takes in four color components and a frame time and does something with them.

- **GPUImageLuminosity**: Like the GPUImageAverageColor, this reduces an image to its average luminosity. You need to set the luminosityProcessingFinishedBlock to handle the output of this filter, which just returns a luminosity value and a frame time.

- **GPUImageChromaKeyFilter**: For a given color in the image, sets the alpha channel to 0. This is similar to the GPUImageChromaKeyBlendFilter, only instead of blending in a second image for a matching color this doesn't take in a second image and just turns a given color transparent.
- *thresholdSensitivity*: How close a color match needs to exist to the target color to be replaced (default of 0.4)
- *smoothing*: How smoothly to blend for the color match (default of 0.1)

### Image processing ###

- **GPUImageTransformFilter**: This applies an arbitrary 2-D or 3-D transformation to an image
  - *affineTransform*: This takes in a CGAffineTransform to adjust an image in 2-D
  - *transform3D*: This takes in a CATransform3D to manipulate an image in 3-D
  - *ignoreAspectRatio*: By default, the aspect ratio of the transformed image is maintained, but this can be set to YES to make the transformation independent of aspect ratio

- **GPUImageCropFilter**: This crops an image to a specific region, then passes only that region on to the next stage in the filter
  - *cropRegion*: A rectangular area to crop out of the image, normalized to coordinates from 0.0 - 1.0. The (0.0, 0.0) position is in the upper left of the image.

- **GPUImageLanczosResamplingFilter**: This lets you up- or downsample an image using Lanczos resampling, which results in noticeably better quality than the standard linear or trilinear interpolation. Simply use -forceProcessingAtSize: to set the target output resolution for the filter, and the image will be resampled for that new size.

- **GPUImageSharpenFilter**: Sharpens the image
  - *sharpness*: The sharpness adjustment to apply (-4.0 - 4.0, with 0.0 as the default)

- **GPUImageUnsharpMaskFilter**: Applies an unsharp mask
  - *blurSize*: A multiplier for the underlying blur size, ranging from 0.0 on up, with a default of 1.0
  - *intensity*: The strength of the sharpening, from 0.0 on up, with a default of 1.0

- **GPUImageFastBlurFilter**: A hardware-accelerated 9-hit Gaussian blur of an image
  - *blurPasses*: The number of times to re-apply this blur on an image. More passes lead to a blurrier image, yet they require more processing power. The default is 1.

- **GPUImageGaussianBlurFilter**: A more generalized 9x9 Gaussian blur filter
  - *blurSize*: A multiplier for the size of the blur, ranging from 0.0 on up, with a default of 1.0

- **GPUImageGaussianSelectiveBlurFilter**: A Gaussian blur that preserves focus within a circular region
  - *blurSize*: A multiplier for the size of the blur, ranging from 0.0 on up, with a default of 1.0
  - *excludeCircleRadius*: The radius of the circular area being excluded from the blur
  - *excludeCirclePoint*: The center of the circular area being excluded from the blur
  - *excludeBlurSize*: The size of the area between the blurred portion and the clear circle
  - *aspectRatio*: The aspect ratio of the image, used to adjust the circularity of the in-focus region. By default, this matches the image aspect ratio, but you can override this value.

- **GPUImageTiltShiftFilter**: A simulated tilt shift lens effect
  - *blurSize*: A multiplier for the size of the out-of-focus blur, ranging from 0.0 on up, with a default of 2.0
  - *topFocusLevel*: The normalized location of the top of the in-focus area in the image, this value should be lower than bottomFocusLevel, default 0.4
  - *bottomFocusLevel*: The normalized location of the bottom of the in-focus area in the image, this value should be higher than topFocusLevel, default 0.6
  - *focusFallOffRate*: The rate at which the image gets blurry away from the in-focus region, default 0.2

- **GPUImageBoxBlurFilter**: A hardware-accelerated 9-hit box blur of an image

- **GPUImage3x3ConvolutionFilter**: Runs a 3x3 convolution kernel against the image
  - *convolutionKernel*: The convolution kernel is a 3x3 matrix of values to apply to the pixel and its 8 surrounding pixels. The matrix is specified in row-major order, with the top left pixel being one.one and the bottom right three.three. If the values in the matrix don't add up to 1.0, the image could be brightened or darkened.

- **GPUImageSobelEdgeDetectionFilter**: Sobel edge detection, with edges highlighted in white
  - *texelWidth*:
  - *texelHeight*: These parameters affect the visibility of the detected edges

- **GPUImageCannyEdgeDetectionFilter**: This uses the full Canny process to highlight one-pixel-wide edges
  - *texelWidth*:
  - *texelHeight*: These parameters affect the visibility of the detected edges
  - *blurSize*: A multiplier for the prepass blur size, ranging from 0.0 on up, with a default of 1.0
  - *upperThreshold*: Any edge with a gradient magnitude above this threshold will pass and show up in the final result. Default is 0.4.
  - *lowerThreshold*: Any edge with a gradient magnitude below this threshold will fail and be removed from the final result. Default is 0.1.

- **GPUImageHarrisCornerDetectionFilter**: Runs the Harris corner detection algorithm on an input image, and produces an image with those corner points as white pixels and everything else black. The cornersDetectedBlock can be set, and you will be provided with a list of corners (in normalized 0..1 X, Y coordinates) within that callback for whatever additional operations you want to perform.
  - *blurSize*: The relative size of the blur applied as part of the corner detection implementation. The default is 1.0.
  - *sensitivity*: An internal scaling factor applied to adjust the dynamic range of the cornerness maps generated in the filter. The default is 5.0.
  - *threshold*: The threshold at which a point is detected as a corner. This can vary significantly based on the size, lighting conditions, and iOS device camera type, so it might take a little experimentation to get right for your cases. Default is 0.20.

- **GPUImageNobleCornerDetectionFilter**: Runs the Noble variant on the Harris corner detector. It behaves as described above for the Harris detector.
  - *blurSize*: The relative size of the blur applied as part of the corner detection implementation. The default is 1.0.
  - *sensitivity*: An internal scaling factor applied to adjust the dynamic range of the cornerness maps generated in the filter. The default is 5.0.
  - *threshold*: The threshold at which a point is detected as a corner. This can vary significantly based on the size, lighting conditions, and iOS device camera type, so it might take a little experimentation to get right for your cases. Default is 0.2.

- **GPUImageShiTomasiCornerDetectionFilter**: Runs the Shi-Tomasi feature detector. It behaves as described above for the Harris detector.
  - *blurSize*: The relative size of the blur applied as part of the corner detection implementation. The default is 1.0.
  - *sensitivity*: An internal scaling factor applied to adjust the dynamic range of the cornerness maps generated in the filter. The default is 1.5.
  - *threshold*: The threshold at which a point is detected as a corner. This can vary significantly based on the size, lighting conditions, and iOS device camera type, so it might take a little experimentation to get right for your cases. Default is 0.2.

- **GPUImageNonMaximumSuppressionFilter**: Currently used only as part of the Harris corner detection filter, this will sample a 1-pixel box around each pixel and determine if the center pixel's red channel is the maximum in that area. If it is, it stays. If not, it is set to 0 for all color components.

- **GPUImageXYDerivativeFilter**: An internal component within the Harris corner detection filter, this calculates the squared difference between the pixels to the left and right of this one, the squared difference of the pixels above and below this one, and the product of those two differences.

- **GPUImageCrosshairGenerator**: This draws a series of crosshairs on an image, most often used for identifying machine vision features. It does not take in a standard image like other filters, but a series of points in its -renderCrosshairsFromArray:count: method, which does the actual drawing. You will need to force this filter to render at the particular output size you need.
  - *crosshairWidth*: The width, in pixels, of the crosshairs to be drawn onscreen.

- **GPUImageDilationFilter**: This performs an image dilation operation, where the maximum intensity of the red channel in a rectangular neighborhood is used for the intensity of this pixel. The radius of the rectangular area to sample over is specified on initialization, with a range of 1-4 pixels. This is intended for use with grayscale images, and it expands bright regions.

- **GPUImageRGBDilationFilter**: This is the same as the GPUImageDilationFilter, except that this acts on all color channels, not just the red channel.

- **GPUImageErosionFilter**: This performs an image erosion operation, where the minimum intensity of the red channel in a rectangular neighborhood is used for the intensity of this pixel. The radius of the rectangular area to sample over is specified on initialization, with a range of 1-4 pixels. This is intended for use with grayscale images, and it expands dark regions.

- **GPUImageRGBErosionFilter**: This is the same as the GPUImageErosionFilter, except that this acts on all color channels, not just the red channel.

- **GPUImageOpeningFilter**: This performs an erosion on the red channel of an image, followed by a dilation of the same radius. The radius is set on initialization, with a range of 1-4 pixels. This filters out smaller bright regions.

- **GPUImageRGBOpeningFilter**: This is the same as the GPUImageOpeningFilter, except that this acts on all color channels, not just the red channel.

- **GPUImageClosingFilter**: This performs a dilation on the red channel of an image, followed by an erosion of the same radius. The radius is set on initialization, with a range of 1-4 pixels. This filters out smaller dark regions.

- **GPUImageRGBClosingFilter**: This is the same as the GPUImageClosingFilter, except that this acts on all color channels, not just the red channel.

- **GPUImageLowPassFilter**: This applies a low pass filter to incoming video frames. This basically accumulates a weighted rolling average of previous frames with the current ones as they come in. This can be used to denoise video, add motion blur, or be used to create a high pass filter.
  - *filterStrength*: This controls the degree by which the previous accumulated frames are blended with the current one. This ranges from 0.0 to 1.0, with a default of 0.5.

- **GPUImageHighPassFilter**: This applies a high pass filter to incoming video frames. This is the inverse of the low pass filter, showing the difference between the current frame and the weighted rolling average of previous ones. This is most useful for motion detection.
  - *filterStrength*: This controls the degree by which the previous accumulated frames are blended and then subtracted from the current one. This ranges from 0.0 to 1.0, with a default of 0.5.

- **GPUImageMotionDetector**: This is a motion detector based on a high-pass filter. You set the motionDetectionBlock and on every incoming frame it will give you the centroid of any detected movement in the scene (in normalized X,Y coordinates) as well as an intensity of motion for the scene.
  - *lowPassFilterStrength*: This controls the strength of the low pass filter used behind the scenes to establish the baseline that incoming frames are compared with. This ranges from 0.0 to 1.0, with a default of 0.5.


### Blending modes ###

- **GPUImageChromaKeyBlendFilter**: Selectively replaces a color in the first image with the second image
  - *thresholdSensitivity*: How close a color match needs to exist to the target color to be replaced (default of 0.4)
  - *smoothing*: How smoothly to blend for the color match (default of 0.1)

- **GPUImageDissolveBlendFilter**: Applies a dissolve blend of two images
  - *mix*: The degree with which the second image overrides the first (0.0 - 1.0, with 0.5 as the default)

- **GPUImageMultiplyBlendFilter**: Applies a multiply blend of two images

- **GPUImageAddBlendFilter**: Applies an additive blend of two images

- **GPUImageDivideBlendFilter**: Applies a division blend of two images

- **GPUImageOverlayBlendFilter**: Applies an overlay blend of two images

- **GPUImageDarkenBlendFilter**: Blends two images by taking the minimum value of each color component between the images

- **GPUImageLightenBlendFilter**: Blends two images by taking the maximum value of each color component between the images

- **GPUImageColorBurnBlendFilter**: Applies a color burn blend of two images

- **GPUImageColorDodgeBlendFilter**: Applies a color dodge blend of two images

- **GPUImageScreenBlendFilter**: Applies a screen blend of two images

- **GPUImageExclusionBlendFilter**: Applies an exclusion blend of two images

- **GPUImageDifferenceBlendFilter**: Applies a difference blend of two images

- **GPUImageHardLightBlendFilter**: Applies a hard light blend of two images

- **GPUImageSoftLightBlendFilter**: Applies a soft light blend of two images

- **GPUImageAlphaBlendFilter**: Blends the second image over the first, based on the second's alpha channel
  - *mix*: The degree with which the second image overrides the first (0.0 - 1.0, with 1.0 as the default)

### Visual effects ###

- **GPUImagePixellateFilter**: Applies a pixellation effect on an image or video
  - *fractionalWidthOfAPixel*: How large the pixels are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)

- **GPUImagePolarPixellateFilter**: Applies a pixellation effect on an image or video, based on polar coordinates instead of Cartesian ones
  - *center*: The center about which to apply the pixellation, defaulting to (0.5, 0.5)
  - *pixelSize*: The fractional pixel size, split into width and height components. The default is (0.05, 0.05)

- **GPUImagePolkaDotFilter**: Breaks an image up into colored dots within a regular grid
  - *fractionalWidthOfAPixel*: How large the dots are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)
  - *dotScaling*: What fraction of each grid space is taken up by a dot, from 0.0 to 1.0 with a default of 0.9.

- **GPUImageHalftoneFilter**: Applies a halftone effect to an image, like news print
  - *fractionalWidthOfAPixel*: How large the halftone dots are, as a fraction of the width and height of the image (0.0 - 1.0, default 0.05)

- **GPUImageCrosshatchFilter**: This converts an image into a black-and-white crosshatch pattern
  - *crossHatchSpacing*: The fractional width of the image to use as the spacing for the crosshatch. The default is 0.03.
  - *lineWidth*: A relative width for the crosshatch lines. The default is 0.003.

- **GPUImageSketchFilter**: Converts video to look like a sketch. This is just the Sobel edge detection filter with the colors inverted
  - *texelWidth*:
  - *texelHeight*: These parameters affect the visibility of the detected edges

- **GPUImageToonFilter**: This uses Sobel edge detection to place a black border around objects, and then it quantizes the colors present in the image to give a cartoon-like quality to the image.
  - *texelWidth*:
  - *texelHeight*: These parameters affect the visibility of the detected edges
  - *threshold*: The sensitivity of the edge detection, with lower values being more sensitive. Ranges from 0.0 to 1.0, with 0.2 as the default
  - *quantizationLevels*: The number of color levels to represent in the final image. Default is 10.0

- **GPUImageSmoothToonFilter**: This uses a similar process as the GPUImageToonFilter, only it precedes the toon effect with a Gaussian blur to smooth out noise.
  - *texelWidth*:
  - *texelHeight*: These parameters affect the visibility of the detected edges
  - *blurSize*: A multiplier for the prepass blur size, ranging from 0.0 on up, with a default of 0.5
  - *threshold*: The sensitivity of the edge detection, with lower values being more sensitive. Ranges from 0.0 to 1.0, with 0.2 as the default
  - *quantizationLevels*: The number of color levels to represent in the final image. Default is 10.0

- **GPUImageEmbossFilter**: Applies an embossing effect on the image
  - *intensity*: The strength of the embossing, from  0.0 to 4.0, with 1.0 as the normal level

- **GPUImagePosterizeFilter**: This reduces the color dynamic range into the number of steps specified, leading to a cartoon-like simple shading of the image.
  - *colorLevels*: The number of color levels to reduce the image space to. This ranges from 1 to 256, with a default of 10.

- **GPUImageSwirlFilter**: Creates a swirl distortion on the image
  - *radius*: The radius from the center to apply the distortion, with a default of 0.5
  - *center*: The center of the image (in normalized coordinates from 0 - 1.0) about which to twist, with a default of (0.5, 0.5)
  - *angle*: The amount of twist to apply to the image, with a default of 1.0

- **GPUImageBulgeDistortionFilter**: Creates a bulge distortion on the image
  - *radius*: The radius from the center to apply the distortion, with a default of 0.25
  - *center*: The center of the image (in normalized coordinates from 0 - 1.0) about which to distort, with a default of (0.5, 0.5)
  - *scale*: The amount of distortion to apply, from -1.0 to 1.0, with a default of 0.5

- **GPUImagePinchDistortionFilter**: Creates a pinch distortion of the image
  - *radius*: The radius from the center to apply the distortion, with a default of 1.0
  - *center*: The center of the image (in normalized coordinates from 0 - 1.0) about which to distort, with a default of (0.5, 0.5)
  - *scale*: The amount of distortion to apply, from -2.0 to 2.0, with a default of 1.0

- **GPUImageStretchDistortionFilter**: Creates a stretch distortion of the image
  - *center*: The center of the image (in normalized coordinates from 0 - 1.0) about which to distort, with a default of (0.5, 0.5)

- **GPUImageVignetteFilter**: Performs a vignetting effect, fading out the image at the edges
  - *x*:
  - *y*: The directional intensity of the vignetting, with a default of x = 0.75, y = 0.5

- **GPUImageKuwaharaFilter**: Kuwahara image abstraction, drawn from the work of Kyprianidis, et. al. in their publication "Anisotropic Kuwahara Filtering on the GPU" within the GPU Pro collection. This produces an oil-painting-like image, but it is extremely computationally expensive, so it can take seconds to render a frame on an iPad 2. This might be best used for still images.
  - *radius*: In integer specifying the number of pixels out from the center pixel to test when applying the filter, with a default of 4. A higher value creates a more abstracted image, but at the cost of much greater processing time.


You can also easily write your own custom filters using the C-like OpenGL Shading Language, as described below.

## Adding the framework to your iOS project ##

Once you have the latest source code for the framework, it's fairly straightforward to add it to your application. Start by dragging the GPUImage.xcodeproj file into your application's Xcode project to embed the framework in your project. Next, go to your application's target and add GPUImage as a Target Dependency. Finally, you'll want to drag the libGPUImage.a library from the GPUImage framework's Products folder to the Link Binary With Libraries build phase in your application's target.

GPUImage needs a few other frameworks to be linked into your application, so you'll need to add the following as linked libraries in your application target:

- CoreMedia
- CoreVideo
- OpenGLES
- AVFoundation
- QuartzCore

You'll also need to find the framework headers, so within your project's build settings set the Header Search Paths to the relative path from your application to the framework/ subdirectory within the GPUImage source directory. Make this header search path recursive.

To use the GPUImage classes within your application, simply include the core framework header using the following:

    #import "GPUImage.h"

As a note: if you run into the error "Unknown class GPUImageView in Interface Builder" or the like when trying to build an interface with Interface Builder, you may need to add -ObjC to your Other Linker Flags in your project's build settings.

Also, if you need to deploy this to iOS 4.x, it appears that the current version of Xcode (4.3) requires that you weak-link the Core Video framework in your final application or you see crashes with the message "Symbol not found: _CVOpenGLESTextureCacheCreate" when you create an archive for upload to the App Store or for ad hoc distribution. To do this, go to your project's Build Phases tab, expand the Link Binary With Libraries group, and find CoreVideo.framework in the list. Change the setting for it in the far right of the list from Required to Optional.

Additionally, this is an ARC-enabled framework, so if you want to use this within a manual reference counted application targeting iOS 4.x, you'll need to add -fobjc-arc to your Other Linker Flags as well.

## Performing common tasks ##

### Filtering live video ###

To filter live video from an iOS device's camera, you can use code like the following:

	GPUImageVideoCamera *videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset640x480 cameraPosition:AVCaptureDevicePositionBack];
	videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

	GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"CustomShader"];
	GPUImageView *filteredVideoView = [[GPUImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, viewWidth, viewHeight)];

	// Add the view somewhere so it's visible

	[videoCamera addTarget:customFilter];
	[customFilter addTarget:filteredVideoView];

	[videoCamera startCameraCapture];

This sets up a video source coming from the iOS device's back-facing camera, using a preset that tries to capture at 640x480. This video is captured with the interface being in portrait mode, where the landscape-left-mounted camera needs to have its video frames rotated before display. A custom filter, using code from the file CustomShader.fsh, is then set as the target for the video frames from the camera. These filtered video frames are finally displayed onscreen with the help of a UIView subclass that can present the filtered OpenGL ES texture that results from this pipeline.

The fill mode of the GPUImageView can be altered by setting its fillMode property, so that if the aspect ratio of the source video is different from that of the view, the video will either be stretched, centered with black bars, or zoomed to fill.

For blending filters and others that take in more than one image, you can create multiple outputs and add a single filter as a target for both of these outputs. The order with which the outputs are added as targets will affect the order in which the input images are blended or otherwise processed.

Also, if you wish to enable microphone audio capture for recording to a movie, you'll need to set the audioEncodingTarget of the camera to be your movie writer, like for the following:

    videoCamera.audioEncodingTarget = movieWriter;


### Capturing and filtering a still photo ###

To capture and filter still photos, you can use a process similar to the one for filtering video. Instead of a GPUImageVideoCamera, you use a GPUImageStillCamera:

	stillCamera = [[GPUImageStillCamera alloc] init];
	stillCamera.outputImageOrientation = UIInterfaceOrientationPortrait;

	filter = [[GPUImageGammaFilter alloc] init];
	[stillCamera addTarget:filter];
	GPUImageView *filterView = (GPUImageView *)self.view;
	[filter addTarget:filterView];

	[stillCamera startCameraCapture];

This will give you a live, filtered feed of the still camera's preview video. Note that this preview video is only provided on iOS 4.3 and higher, so you may need to set that as your deployment target if you wish to have this functionality.

Once you want to capture a photo, you use a callback block like the following:

	[stillCamera capturePhotoProcessedUpToFilter:filter withCompletionHandler:^(UIImage *processedImage, NSError *error){
	    NSData *dataForPNGFile = UIImageJPEGRepresentation(processedImage, 0.8);

	    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	    NSString *documentsDirectory = [paths objectAtIndex:0];

	    NSError *error2 = nil;
	    if (![dataForPNGFile writeToFile:[documentsDirectory stringByAppendingPathComponent:@"FilteredPhoto.jpg"] options:NSAtomicWrite error:&error2])
	    {
	        return;
	    }
	}];

The above code captures a full-size photo processed by the same filter chain used in the preview view and saves that photo to disk as a JPEG in the application's documents directory.

Note that the framework currently can't handle images larger than 2048 pixels wide or high on older devices (those before the iPhone 4S, iPad 2, or Retina iPad) due to texture size limitations. This means that the iPhone 4, whose camera outputs still photos larger than this, won't be able to capture photos like this. A tiling mechanism is being implemented to work around this. All other devices should be able to capture and filter photos using this method.

### Processing a still image ###

There are a couple of ways to process a still image and create a result. The first way you can do this is by creating a still image source object and manually creating a filter chain:

	UIImage *inputImage = [UIImage imageNamed:@"Lambeau.jpg"];

	GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputImage];
	GPUImageSepiaFilter *stillImageFilter = [[GPUImageSepiaFilter alloc] init];

	[stillImageSource addTarget:stillImageFilter];
	[stillImageSource processImage];

	UIImage *currentFilteredVideoFrame = [stillImageFilter imageFromCurrentlyProcessedOutput];

For single filters that you wish to apply to an image, you can simply do the following:

	GPUImageSepiaFilter *stillImageFilter2 = [[GPUImageSepiaFilter alloc] init];
	UIImage *quickFilteredImage = [stillImageFilter2 imageByFilteringImage:inputImage];


### Writing a custom filter ###

One significant advantage of this framework over Core Image on iOS (as of iOS 5.0) is the ability to write your own custom image and video processing filters. These filters are supplied as OpenGL ES 2.0 fragment shaders, written in the C-like OpenGL Shading Language.

A custom filter is initialized with code like

	GPUImageFilter *customFilter = [[GPUImageFilter alloc] initWithFragmentShaderFromFile:@"CustomShader"];

where the extension used for the fragment shader is .fsh. Additionally, you can use the -initWithFragmentShaderFromString: initializer to provide the fragment shader as a string, if you would not like to ship your fragment shaders in your application bundle.

Fragment shaders perform their calculations for each pixel to be rendered at that filter stage. They do this using the OpenGL Shading Language (GLSL), a C-like language with additions specific to 2-D and 3-D graphics. An example of a fragment shader is the following sepia-tone filter:

	varying highp vec2 textureCoordinate;

	uniform sampler2D inputImageTexture;

	void main()
	{
	    lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
	    lowp vec4 outputColor;
	    outputColor.r = (textureColor.r * 0.393) + (textureColor.g * 0.769) + (textureColor.b * 0.189);
	    outputColor.g = (textureColor.r * 0.349) + (textureColor.g * 0.686) + (textureColor.b * 0.168);
	    outputColor.b = (textureColor.r * 0.272) + (textureColor.g * 0.534) + (textureColor.b * 0.131);
		outputColor.a = 1.0;

		gl_FragColor = outputColor;
	}

For an image filter to be usable within the GPUImage framework, the first two lines that take in the textureCoordinate varying (for the current coordinate within the texture, normalized to 1.0) and the inputImageTexture uniform (for the actual input image frame texture) are required.

The remainder of the shader grabs the color of the pixel at this location in the passed-in texture, manipulates it in such a way as to produce a sepia tone, and writes that pixel color out to be used in the next stage of the processing pipeline.

One thing to note when adding fragment shaders to your Xcode project is that Xcode thinks they are source code files. To work around this, you'll need to manually move your shader from the Compile Sources build phase to the Copy Bundle Resources one in order to get the shader to be included in your application bundle.


### Filtering and re-encoding a movie ###

Movies can be loaded into the framework via the GPUImageMovie class, filtered, and then written out using a GPUImageMovieWriter. GPUImageMovieWriter is also fast enough to record video in realtime from an iPhone 4's camera at 640x480, so a direct filtered video source can be fed into it. Currently, GPUImageMovieWriter is fast enough to record live 720p video at up to 20 FPS on the iPhone 4, and both 720p and 1080p video at 30 FPS on the iPhone 4S (as well as on the new iPad).

The following is an example of how you would load a sample movie, pass it through a pixellation filter, then record the result to disk as a 480 x 640 h.264 movie:

	movieFile = [[GPUImageMovie alloc] initWithURL:sampleURL];
	pixellateFilter = [[GPUImagePixellateFilter alloc] init];

	[movieFile addTarget:pixellateFilter];

	NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
	unlink([pathToMovie UTF8String]);
	NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];

	movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(480.0, 640.0)];
	[pixellateFilter addTarget:movieWriter];

    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];

	[movieWriter startRecording];
	[movieFile startProcessing];

Once recording is finished, you need to remove the movie recorder from the filter chain and close off the recording using code like the following:

	[pixellateFilter removeTarget:movieWriter];
	[movieWriter finishRecording];

A movie won't be usable until it has been finished off, so if this is interrupted before this point, the recording will be lost.

### Interacting with OpenGL ES ###

GPUImage can both export and import textures from OpenGL ES through the use of its GPUImageTextureOutput and GPUImageTextureInput classes, respectively. This lets you record a movie from an OpenGL ES scene that is rendered to a framebuffer object with a bound texture, or filter video or images and then feed them into OpenGL ES as a texture to be displayed in the scene.

The one caution with this approach is that the textures used in these processes must be shared between GPUImage's OpenGL ES context and any other context via a share group or something similar.

## Sample applications ##

Several sample applications are bundled with the framework source. Most are compatible with both iPhone and iPad-class devices. They attempt to show off various aspects of the framework and should be used as the best examples of the API while the framework is under development. These include:

### SimpleImageFilter ###

A bundled JPEG image is loaded into the application at launch, a filter is applied to it, and the result rendered to the screen. Additionally, this sample shows two ways of taking in an image, filtering it, and saving it to disk.

### SimpleVideoFilter ###

A pixellate filter is applied to a live video stream, with a UISlider control that lets you adjust the pixel size on the live video.

### SimpleVideoFileFilter ###

A movie file is loaded from disk, an unsharp mask filter is applied to it, and the filtered result is re-encoded as another movie.

### MultiViewFilterExample ###

From a single camera feed, four views are populated with realtime filters applied to camera. One is just the straight camera video, one is a preprogrammed sepia tone, and two are custom filters based on shader programs.

### FilterShowcase ###

This demonstrates every filter supplied with GPUImage.

### BenchmarkSuite ###

This is used to test the performance of the overall framework by testing it against CPU-bound routines and Core Image. Benchmarks involving still images and video are run against all three, with results displayed in-application.

### CubeExample ###

This demonstrates the ability of GPUImage to interact with OpenGL ES rendering. Frames are captured from the camera, a sepia filter applied to them, and then they are fed into a texture to be applied to the face of a cube you can rotate with your finger. This cube in turn is rendered to a texture-backed framebuffer object, and that texture is fed back into GPUImage to have a pixellation filter applied to it before rendering to screen.

In other words, the path of this application is camera -> sepia tone filter -> cube -> pixellation filter -> display.

### ColorObjectTracking ###

A version of my ColorTracking example from http://www.sunsetlakesoftware.com/2010/10/22/gpu-accelerated-video-processing-mac-and-ios ported across to use GPUImage, this application uses color in a scene to track objects from a live camera feed. The four views you can switch between include the raw camera feed, the camera feed with pixels matching the color threshold in white, the processed video where positions are encoded as colors within the pixels passing the threshold test, and finally the live video feed with a dot that tracks the selected color. Tapping the screen changes the color to track to match the color of the pixels under your finger. Tapping and dragging on the screen makes the color threshold more or less forgiving. This is most obvious on the second, color thresholding view.

Currently, all processing for the color averaging in the last step is done on the CPU, so this is part is extremely slow.
