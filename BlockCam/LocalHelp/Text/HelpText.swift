//
//  HelpText.swift
//  BlockCam
//
//  Created by Stuart Rankin on 3/23/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation

/// Holds and manages text for the help viewers.
class HelpText
{
    /// Get the help text for the specified help type.
    /// - Note: This function returns the base English text.
    /// - Parameter For: The type of help text to return.
    /// - Returns: The help text. Empty string if not found.
    public static func GetHelpText(For Type: HelpTextTypes) -> String
    {
        switch Type
        {
            case .BehindTheScenes:
                return Internals_en
            
            case .HUDUI:
            return HUD_en
            
            case .Glossary:
                return Glossary_en
            
            case .FAQs:
                return FAQs_en
            
            case .Rights:
                return Rights_en
            
            case .Overview:
                return Overview_en
            
            case .Constraints:
                return Constraints_en
            
            case .SettingTypes:
                return SettingTypes_en
            
            case .WorkFlow:
                return WorkFlow_en
            
            default:
                return ""
        }
    }
    
    private static let Rights_en = """
   <!DOCTYPE html>
        <html>
<head>
<style>
table
{
font-family: arial, sans-serif;
border-collapse: collapse;
width: 100%;
}
td, th
{
border: 1px solid #dddddddd;
text-align: left;
padding: 8px;
}
</style>
</head>
        <body>
        <font face="Avenir">
        <h1>BlockCam Rights and Privacy</h1>
        </font>
<hr>
<font face="Avenir">
<h1 style="color:DarkSlateGray">Rights</h1>
</font>
<font size="6">
<ol>
<li>You own all images you create with BlockCam.</li>
<li>With respect to images sources you use, you may be required to obtain permission first.</li>
<li>BlockCam is © 2019 – 2020 by Stuart Rankin.</li>
</ol>
</font>
<hr>
<font face="Avenir">
<h1 style="color:DarkSlateGray">Privacy</h1>
</font>
<font size="6">
<p>
BlockCam does not transmit any identifiable information other than when you share
your images. BlockCam can add metadata to your images, including your name and copyright.
You can disable image metadata such that no metadata is added by BlockCam.
</p>
<p>
No other information is shared or sent by BlockCam.
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:DarkSlateGray">Permissions</h1>
</font>
<font size="6">
<p>
In order to function, BlockCam needs your permission to use certain features and assets on your device.
</p>
</font>
<font size="5">
<table>
<tr>
<th>Access to</th>
<th>Why</th>
<tr>
<tr>
<td>Camera</td>
<td>BlockCam needs to access your device's camera in order to take pictures to process them.</td>
</tr>
<tr>
<td>Photo Album</td>
<td>BlockCam needs to access your photo album so you can select previously saved images to process and to be able to save newly processed images.</td>
</tr>
<tr>
<td>Location</td>
<td>If you enable the heading and altitude heads-up display, BlockCam needs to be able to access the device's location.
</tr>
</table>
</font>
</body>
</html>
"""
    
    private static let Overview_en = """
   <!DOCTYPE html>
        <html>
        <body>
        <font face="Avenir">
        <h1>BlockCam Overview</h1>
        </font>
        <font size="6">
        <p>
        BlockCam is a program that takes your pictures and converts them into 3D scenes. This is done by analyzing
        your image and creating 3D shapes based on the colors BlockCam finds. BlockCam lets you move the resulting
        scene around so you can see it in different perspectives.
</p>
        <p>
        This version of BlockCam lets you convert still images into 3D scnes which you can save as images. BlockCam
        also features a camera that lets you take pictures and converts them on the fly.
</p>
        <p>
        Block also allows you to save your 3D scenes for reprocessing later if you wish.
        </p>
        </font>
        </body>
        </html>
"""
    
    private static let Constraints_en = """
 <!DOCTYPE html>
        <html>
        <body>
        <font face="Avenir">
        <h1>BlockCam Constraints</h1>
        </font>
        <p>
<font size="6">
       BlockCam performs a large number of calculations that may slow down your phone or tablet. Please review
        the information below.
</font>
        <hr>
<font face="Avenir">
        <h1 style="color:Navy">General Performance</h1>
</font>
<font size="6">
        BlockCam performs a large number of calculations when converting 2D images into 3D scenes which involves
        the manipulation of huge amounts of data. For these reasons, it is possible that some scenes may take over
        a minute to create. You can see the progress of your 3D image creation by looking at the status at the bottom
        of the screen.
</font>
        <hr>
<font face="Avenir">
        <h1 style="color:Navy">Power Constraints</h1>
</font>
<font size="6">
        BlockCam makes heavy use of your device's CPU and GPU. This in turn uses a great deal of battery power
        (especially on older devices). Please be aware of this constraint, especially when you are creating
        complex images.
</font>
        <hr>
<font face="Avenir">
        <h1 style="color:Navy">Memory Constraints</h1>
</font>
<font size="6">
        It is possible to create images with BlockCam that will
        strain the available memory and may result in BlockCam
        suddenly stopping to work (eg, crashing). If this happens,
        please try again but reduce the size of the image or
        increase the size of each block or use fewer shapes.
        Everyone’s situation is different so try different settings (especially reducing the image size or increasing the block size) if
        you seem to experience many crashes of this sort.
</font>
        <hr>
<font face="Avenir">
        <h1 style="color:Navy">Thermal Constraints</h1>
</font>
<font size="6">
        BlockCam makes heavy use of your device’s GPU. This has
        the tendency to make your phone or table feel very hot
        after processing several images (especially if complex).
        Your device will automatically shut down if it becomes too
        hot. If you think BlockCam is making your device too hot,
        please stop using BlockCam for a few minutes, and
        provided there are not other reasons why your device may
        be warm, it will cool off by then.
        </font>
</p>
        </body>
        </html>
"""
    
    private static let FAQs_en = """
   <!DOCTYPE html>
        <html>
        <body>
        <font face="Avenir">
        <h1>BlockCam Frequently Asked Questions</h1>
        </font>
<hr>
<font face="Avenir">
<h1 style="color:Maroon">What are the best types of images for BlockCam?</h1>
</font>
<font size="6">
To get the most from BlockCam, images with a wide range of brightness and/or colors tend to result in the
most interesting 3D scenes. You can also increase the vertical/size exaggeration to see more 3D-ness in your
results. Images with dark backgrounds work very well.
</font>
<hr>
<p>
<font face="Avenir">
<h1 style="color:Maroon">Why is BlockCam so slow/hot?</h1>
</font>
<font size="6">
BlockCam performs a huge number of calculations to convert your 2D image into a 3D scene. This is especially
true for larger images and small block sizes. The more work BlockCam has to do, the slower the scene generation
and the hotter your device will become. If this happens a lot, you may want to increase the block size and
decrease the image size.
</font>
<hr>
<font face="Avenir">
<h1 style="color:Maroon">Why does BlockCam freeze?</h1>
</font>
<font size="6">
If BlockCam is working on a very complex scene (say a very large image with small block sizes with multiple
shapes per block), it may appear that BlockCam is frozen. However, BlockCam does its image processing in the
background so you can still use the user interface. For exceptionally complex scenes, it may take up to five minutes
or more (especially on older devices) to create a scene.
</font>
</p>
        </body>
        </html>
"""
    
    private static let Glossary_en = """
   <!DOCTYPE html>
        <html>
        <body>
        <font face="Avenir">
        <h1>Glossary of Terms</h1>
        </font>
<hr>
<font face="Avenir">
<h1 style="color:DarkSlateBlue">Block Size</h1>
</font>
<font size="6">
One of the steps BlockCam uses to create a 3D scene is pixellating the original image. This is nothing more
than getting the average color for a small block of the original image. The <b>Block Size</b> determines how
large that block is. If you use small block sizes, you will get more shapes in the final scene, but processing
will take much longer.
</font>
<hr>
<font face="Avenir">
<h1 style="color:DarkSlateBlue">Image Size</h1>
</font>
<font size="6">
Due to processing limitations on mobile devices, BlockCam works most efficiently with relatively small image sizes.
The default <b>Image Size</b> setting for BlockCam reduces the image to process to about 1000 pixels in the maximum
dimension. (Please note that the original image is untouched by BlockCam.) You can change this setting but increasing
it will slow down BlockCam.
</font>
<hr>
<font face="Avenir">
<h1 style="color:DarkSlateBlue">Scene</h1>
</font>
<font size="6">
A scene is the 3D result of processing your 2D image. The scene may be rotated, zoomed in and out, and skewed as you see fit.
</font>
<hr>
        </body>
        </html>
"""
    
    private static let SettingTypes_en = """
<!DOCTYPE html>
<html>
<body>
<font face="Avenir">
<h1>Setting Types</h1>
</font>
<hr>
<font size="6">
BlockCam has a great many settings for both how the program works in general, and to allow you to fine tune
your 3D scenes.
</font>
<hr>
<font face="Avenir">
<h1 style="color:DarkBlue">General Settings</h1>
</font>
<font size="6">
General settings control the way BlockCam as a whole works. These settings are controlled via the <b>Program settings</b> menu option.
</font>
<hr>
<font face="Avenir">
<h1 style="color:DarkBlue">Image Settings</h1>
</font>
<font size="6">
<p>
Image settings let you control how BlockCam creates your 3D scenes and to fine tune the results. These settings are accessed from the <b>Shapes</b> menu option.
</p>
<p>
You can see what shape options are in effect by selecting the <b>Current settings</b> menu option.
</p>
</font>
<hr>
        </body>
        </html>
"""
    
    private static let WorkFlow_en = """
<!DOCTYPE html>
<html>
<body>
<font face="Avenir">
<h1>BlockCam Workflow</h1>
</font>
<hr>
<font size="6">
This describes the general way to create 3D scenes.
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Using Live View</h1>
</font>
<font size="6">
<p>
BlockCam has two modes of operation: 1) Live View, and 2) Image Album. Using Live View lets you take a picture as you would normally with the camera application. Press the camera button in the bottom tool bar. When you do that, BlockCam will start processing the image and then present it when it is done. When BlockCam is processing the image, you cannot take other images.
</p>
<p>
Once the 3D scene has been shown, you can move it with your finger. After you are satisfied with the results, you can press the folder button on the right-side of the tool bar to save your image. After you save your image, you can move the image again and save it in the new orientation.
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Using Saved Images</h1>
</font>
<font size="6">
<p>
In Image Album mode, you select any still image on your device and process it. The flow is the same as Live View once the 3D scene is complete.
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Changing 3D Scenes</h1>
</font>
<font size="6">
After you have a 3D scene, you can press the settings button (the gear button) to change almost any aspect of the scene, such as shapes, colors, and the like. Be aware that changing the settings usually results in at least a partial reprocessing of the image and may take a long time.
</font>
        </body>
        </html>
"""
    
    private static let Internals_en =
    """
<!DOCTYPE html>
<html>
<body>
<font face="Avenir">
<h1>BlockCam Behind the Scenes</h1>
</font>
<hr>
<font size="6">
<p>
This describes, at a high level, how BlockCam creates 3D images from your 2D images. This section of help is not necessary for you to use and enjoy BlockCam.
</p>
<p>
<b>Note</b>: BlockCam never modifies the original image - all changes are done to in-memory images that are discarded once a 3D scene has been created.
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Pre-Processing</h1>
</font>
<font size="6">
<p>
Once you give BlockCam an image to process (from any source), it will pre-process the image. This involves changing the orientation of the image if necessary and resizing the image as required by settings. This is done to limit the impact to your device in terms of performance.
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Image Processing</h1>
</font>
<font size="6">
<p>
The next step is to pixellate the image. This is done using standard OS functions. The size of each pixellated region is called the <b>Block Size</b>, so the smaller the block size, the more pixellate regions will be generated. This is why smaller block sizes lead to more detailed images but take a lot more time.
</p>
<p>
After the pixellated image is created, BlockCam will parse the image by getting the color of each pixellated region as a color map.
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Scene Creation</h1>
</font>
<font size="6">
<p>
With the color map created in the Image Processing step, BlockCam will do the following for each color:
<ul>
<li>Determine the location of the color. This is so the resultant shape will be placed in the proper location.</li>
<li>Depending on the height determination settings, an aspect of the color will be extracted. For example, the default (and most common) way to determine height is to use the color's brightness value. Other aspects can be:
<ul>
<li>Hue</li>
<li>Color channel value, such as red, or yellow</li>
<li>Others as available in the settings</li>
</ul>
Additionally, the height can be inverted so dark colors are shown over light colors.
</li>
<li>Read the current settings to determine what shape (or shapes) to use for each color.</li>
<li>Based on the shape, its settings, and size or location are retreived from user settings.</li>
<li>A shape is generated for the resultant data set and added to the 3D scene.</li>
</ul>
Once all shapes have been generated and place in to the 3D scene, the scene is presented to the user in the appropriate view.
</p>
<p>
Given the amount of time needed to create a scene, the user interface displays different activity indicators. For those activities whose quantity is known (such as creating shapes) a pie chart is shown indicating the percent complete. For activities whose duration is not available, an indefinite activity indicator is shown.
</p>
</font>
        </body>
        </html>
"""
    
    private static let HUD_en =
"""
<!DOCTYPE html>
<html>
<body>
<font face="Avenir">
<h1>BlockCam Overlays</h1>
</font>
<hr>
<font size="6">
BlockCam has live view overlays available for you to use. They are designed to help you frame images, see the overall image color quality, and the like. You control the display in the <b>Program settings</b> menu.
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Grid</h1>
</font>
<font size="6">
<p>
Several types of grids are available for live view for leveling your images and using the rule of thirds. Additionally, you can see the current orientation of your device if you desire.
</p>
<p>
Grids are shown only in live view.
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Histogram</h1>
</font>
<font size="6">
<p>
A histogram display is available for the live view. It is updated on a frequency determined by you but is fast enough that real-time histograms are available.
</p>
<p>
In addition, you can change the order of channels being display, or combine them all into a synthetic color histogram.
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Image data</h1>
</font>
<font size="6">
<p>
You can view overall image data based on the average color of the current live view frame. You can view any one (or combination) of:
<ul>
<li><b>Brightness</b>: This is similar to a light meter. The value shown is a percent from 0.0 (fully black) to 1.0 (fully white).</li>
<li><b>Saturation</b>: This is the overall saturation of the average color of the live view frame, from 0.0 (no saturation) to 1.0 (fully saturated).</li>
<li><b>Hue</b>: This is the hue of the average color (and tends to be rather dark). The value ranges from 0.0 (or 0°) to 1.0 (or 359°).
<li><b>Mean color</b>: This is a display of the mean color of the current live view frame.
</ul>
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Location</h1>
</font>
<font size="6">
<p>
This allows you to see the heading of the device (true, not magnetic) and the altitude of the device. Both values are approximate and should not be used for navigation purposes.
</p>
<p>
The first time you enable these settings, you will be asked to grant permission for BlockCam to access the location. If you do not grant access, these settings will not be available.
</p>
<p>
The location settings that can be viewed are:
<ul>
<li><b>Heading</b>: This is the heading of the back of your device. The value shown is in degrees and represents true heading, not magnetic.</li>
<li><b>Altitude</b>: This is the altitude of your device. This value tends to fluctuate and is probably accurate to within 5 meters or so.</li>
</ul>
</p>
</font>
<hr>
<font face="Avenir">
<h1 style="color:SteelBlue">Other</h1>
</font>
<font size="6">
You can display BlockCam's version and build information on the screen as well.
</font>
<hr>
</body>
</html>
"""
}

enum HelpTextTypes: String, CaseIterable
{
    case Overview = "Overview"
    case BehindTheScenes = "Internals"
    case SettingTypes = "SettingTypes"
    case SettingsDictionary = "SettingsDictionary"
    case Constraints = "Constraints"
    case Miscellaneous = "Miscellaneous"
    case Rights = "Rights"
    case FAQs = "FAQs"
    case Glossary = "Glossary"
    case WorkFlow = "WorkFlow"
    case OverallUI = "OverallUI"
    case ToolbarUI = "ToolbarUI"
    case HUDUI = "HUDUI"
}
