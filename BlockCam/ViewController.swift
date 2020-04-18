//
//  ViewController.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/9/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import AVFoundation
import CoreImage
import CoreServices
import AVKit
import Photos
import MobileCoreServices
import CoreMotion

/// Main view controller for the BlockCam program.
/// - Note: See [Create a Custom Camera View](https://guides.codepath.com/ios/Creating-a-Custom-Camera-View)
class ViewController: UIViewController,
    AVCapturePhotoCaptureDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    SettingChangedProtocol
{
    // MARK: - Initialization
    
    var CaptureSession: AVCaptureSession!
    var StillImageOutput: AVCapturePhotoOutput!
    var VideoPreviewLayer: AVCaptureVideoPreviewLayer!
    var CaptureDevice: AVCaptureDevice? = nil
    // Thread for running the processing of images in the background.
    let BackgroundThread = DispatchQueue(label: "ProcessingThread", qos: .background)
    var CameraHasDepth = false
    
    /// Initialize the UI and program.
    /// - Note: Assumes several other classes have been initialized by the time control reaches here. These are initialized
    ///         in the app delegate.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Settings.AddSubscriber(self, "MainView")
        Generator.Delegate = self
        definesPresentationContext = true
        SetupNotifications()
        Sounds.Initialize()
        
        #if false
        let BI = BoxIndicator()
        BI.TextLocation = .Left
        BI.BoxSize = CGSize(width: 50, height: 20)
        BI.Text = "Test 5"
        BI.Percent = 0.39
        BI.DrawBox()
        let CI0 = ColorIndicator(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 50, height: 50)))
        CI0.Draw(UIColor.yellow)
        let CI1 = ColorIndicator(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)))
        CI1.Draw(UIColor.purple)
        let CI2 = ColorIndicator(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)))
        CI2.Draw(UIColor(hue: 0.01, saturation: 0.4, brightness: 0.8, alpha: 1.0))
        let CI3 = ColorIndicator(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 100, height: 100)))
        CI3.Draw(UIColor(hue: 0.5, saturation: 0.61, brightness: 0.83, alpha: 1.0))
        #endif
        
        #if false
        //Used to dump the fonts on the system, including those embedded with this application. The names are used to ensure
        //the font name is correct in the program. This code is needed only to ensure proper font name and should be commented
        //out after name verification.
        for Family in UIFont.familyNames
        {
            print(Family)
            for Names in UIFont.fontNames(forFamilyName: Family)
            {
                print("  \(Names)")
            }
        }
        #endif
        
        InitializeOutput()
        
        OutputView.alpha = 0.0
        InitializeTextLayer()
        ShowSplashScreen()
        GetPermissions()
        
        FileIO.ClearScratchDirectory()
        
        if !DeviceHasCamera
        {
            SwitchToPhotoPickerMode()
        }
        
        StartOrientationUpdates()
        
        AddLiveViewTaps()
        if Settings.GetBoolean(ForKey: .ShowCompass) || Settings.GetBoolean(ForKey: .ShowAltitude)
        {
            InitializeLocation()
        }
    }
    
    func AddLiveViewTaps()
    {
        let Tap = UITapGestureRecognizer(target: self, action: #selector(LiveViewTapHandler))
        Tap.numberOfTapsRequired = 1
        LiveView.addGestureRecognizer(Tap)
    }
    
    /// Handle taps on the live view to focus and set exposure.
    /// - Note: See [Set Camera Focus on Tap Point with Swift](https://stackoverflow.com/questions/26682450/set-camera-focus-on-tap-point-with-swift)
    /// - Parameter Recognizer: The gesture recognizer.
    @objc func LiveViewTapHandler(Recognizer: UIGestureRecognizer)
    {
        HideTitle(After: 0.0, HideDuration: 0.5, HideHow: .FadeOut)
        let Location = Recognizer.location(in: LiveView)
        DispatchQueue.main.async
            {
                let Converted = self.VideoPreviewLayer.captureDevicePointConverted(fromLayerPoint: Location)
                if let Device = self.CaptureDevice
                {
                    do
                    {
                        try Device.lockForConfiguration()
                        Device.focusMode = .autoFocus
                        Device.focusPointOfInterest = Converted
                        Device.exposureMode = .continuousAutoExposure
                        Device.exposurePointOfInterest = Converted
                        Device.unlockForConfiguration()
                    }
                    catch
                    {
                        print("Error locking device.")
                    }
                }
                self.ShowLiveViewTapFeedback(At: Location)
                if Settings.GetBoolean(ForKey: .ShowTapFeedback)
                {
                    self.ShowLiveViewTapFeedback(At: Location)
                }
        }
    }
    
    /// This even occurs when the safe area insets changed. Unfortunately, iOS doesn't set the insets
    /// immediately after the view loaded, so we have to wait until they are available, and then we
    /// can change views taking into account safe area insets.
    override func viewSafeAreaInsetsDidChange()
    {
        InitializeModeUIs(With: self.view.safeAreaInsets)
        let Gradient = Colors.GetGradientFor(CurrentViewMode, Container: MainBottomBar.bounds)
        MainBottomBar.layer.addSublayer(Gradient)
        ImageBottomBar.layer.addSublayer(Colors.GetProcessingGradient(Container: ImageBottomBar.bounds))
        if Settings.GetEnum(ForKey: .LiveViewGridType, EnumType: GridTypes.self, Default: GridTypes.None) == .None
        {
            GridView.HideGrid()
        }
        else
        {
            GridView.ShowGrid()
        }
    }
    
    /// Show the splash screen (if settings allow).
    func ShowSplashScreen()
    {
        DispatchQueue.main.async
            {
                if Settings.GetBoolean(ForKey: .ShowSplashScreen)
                {
                    //Use the DEBUG flag to determine the background color of the verion text.
                    #if DEBUG
                    let VBG = UIColor(red: 128.0 / 255.0, green: 0.0, blue: 32.0 / 255.0, alpha: 1.0)
                    #else
                    let VBG = UIColor.systemGreen
                    #endif
                    let VersionString = Versioning.MakeVersionString() + " Build \(Versioning.Build)"
                    self.ShowMainTitle(Version: VersionString, VersionBackground: VBG, ShowDuration: 3.0)
                    //                    self.ShowMainTitle("BlockCam", Version: VersionString, VersionBackground: VBG, AnimateTime: 3.0,
                    //                                       ShowDuration: 5.0)
                }
        }
    }
    
    /// Ask for the necessary permissions from the user.
    /// - Note:
    ///   - There are two sets of permissions required to use BlockCam:
    ///        - Camera access.
    ///        - Photo roll access.
    func GetPermissions()
    {
        if Settings.GetBoolean(ForKey: .AllPermissionsGranted)
        {
            return
        }
        switch AVCaptureDevice.authorizationStatus(for: .video)
        {
            case .authorized:
                break
            
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler:
                    {
                        granted in
                        if granted
                        {
                            Settings.SetBoolean(true, ForKey: .CameraAccessGranted)
                            if Settings.GetBoolean(ForKey: .PhotoRollAccessGranted)
                            {
                                Settings.SetBoolean(true, ForKey: .AllPermissionsGranted)
                            }
                        }
                })
            
            case .denied:
                break
            
            case .restricted:
                return
            
            @unknown default:
                Crash.ShowCrashAlert(WithController: self, "Error", "Unexpected camera authorization status.")
                Log.AbortMessage("Unexpected camera authorization status.", FileName: #file, FunctionName: #function)
                {
                    Message in
                    fatalError(Message)
            }
        }
        
        switch PHPhotoLibrary.authorizationStatus()
        {
            case .authorized:
                break
            
            case .denied:
                //User denied access.
                break
            
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization
                    {
                        Status in
                        switch Status
                        {
                            case .authorized:
                                Settings.SetBoolean(true, ForKey: .AllPermissionsGranted)
                                if Settings.GetBoolean(ForKey: .CameraAccessGranted)
                                {
                                    Settings.SetBoolean(true, ForKey: .AllPermissionsGranted)
                            }
                            
                            case .denied:
                                break
                            
                            case .restricted:
                                break
                            
                            case .notDetermined:
                                break
                            
                            @unknown default:
                                break
                        }
            }
            
            case .restricted:
                //Cannot access and the user cannot grant access.
                break
            
            @unknown default:
                Log.AbortMessage("Unknown photo library authorization status.", FileName: #file, FunctionName: #function)
                {
                    Message in
                    fatalError(Message)
            }
        }
    }
    
    /// Handle notifications of proposed setting changes.
    /// - Parameter ChangedSetting: The setting that will be changed.
    /// - Parameter NewValue: The new value for the setting.
    /// - Parameter CancelChange: If set to true, the change will be canceled. If set to false, the change will be made.
    func WillChangeSetting(_ ChangedSetting: SettingKeys, NewValue: Any, CancelChange: inout Bool)
    {
        CancelChange = false
    }
    
    /// Handle individual setting changes.
    /// - Parameter ChangedSetting: The setting that was changed.
    func DidChangeSetting(_ ChangedSetting: SettingKeys)
    {
        if !ProcessedViewInitialized
        {
            InitializeProcessedLiveView()
        }
        ChangedSettings.append(ChangedSetting)
        switch ChangedSetting
        {
            case .EnableHUD, .ShowHue, .ShowSaturation, .ShowLightMeter, .ShowVersionOnHUD,
                 .ShowMeanColor, .ShowHUDHistogram:
                UpdateHUDViews()
                if Settings.GetBoolean(ForKey: .EnableHUD)
                {
                    if Settings.GetBoolean(ForKey: .ShowCompass) || Settings.GetBoolean(ForKey: .ShowAltitude)
                    {
                        LocationManager?.startUpdatingHeading()
                        LocationManager?.startUpdatingLocation()
                    }
                }
                else
                {
                    LocationManager?.stopUpdatingHeading()
                    LocationManager?.stopUpdatingLocation()
            }
            
            case .ShowCompass, .ShowAltitude:
                if LocationManager == nil
                {
                    InitializeLocation()
                    UpdateHUDViews()
                }
                if Settings.GetBoolean(ForKey: .ShowCompass) || Settings.GetBoolean(ForKey: .ShowAltitude)
                {
                    LocationManager?.startUpdatingHeading()
                    LocationManager?.startUpdatingLocation()
                }
                else
                {
                    LocationManager?.stopUpdatingHeading()
                    LocationManager?.stopUpdatingLocation()
            }
            
            case .AntialiasingMode:
                let Mode = UInt(Settings.GetInteger(ForKey: .AntialiasingMode))
                let AntialiasMode = SCNAntialiasingMode(rawValue: Mode)!
                OutputView.antialiasingMode = AntialiasMode
            
            case .LiveViewGridType:
                GridView.GridType = Settings.GetEnum(ForKey: .LiveViewGridType, EnumType: GridTypes.self, Default: GridTypes.None)
            
            case .ShowActualOrientation:
                GridView.ShowActualOrientation = Settings.GetBoolean(ForKey: .ShowActualOrientation)
            
            default:
                break
        }
    }
    
    /// Holds a list of changed settings.
    var ChangedSettings = [SettingKeys]()
    
    /// Initialize the output view.
    func InitializeOutput()
    {
        var ViewOptions: [String: Any]!
        if Settings.GetBoolean(ForKey: .UseMetal)
        {
            ViewOptions = [SCNView.Option.preferredDevice.rawValue: NSNumber(value: SCNRenderingAPI.metal.rawValue) as Any]
        }
        else
        {
            ViewOptions = [SCNView.Option.preferredDevice.rawValue: NSNumber(value: SCNRenderingAPI.openGLES2.rawValue) as Any]
        }
        let NewFrame = CGRect(x: self.view.frame.minX,
                              y: self.view.frame.minY,
                              width: self.view.frame.width,
                              height: self.view.frame.height - 70)
        OutputView = ProcessViewer(frame: NewFrame, options: ViewOptions) 
        if OutputView == nil
        {
            Log.AbortMessage("Outputview was deallocated.")
            {
                Message in
                fatalError(Message)
            }
        }
        OutputView.Delegate = self
        self.view.addSubview(OutputView)
        #if DEBUG
        OutputView.showsStatistics = true
        #endif
    }
    
    /// Returns the value needed to set a dark style status bar (in other words, we want the status bar to be light).
    override var preferredStatusBarStyle: UIStatusBarStyle
    {
        return .lightContent
    }
    
    var ProcessedViewInitialized = false
    let VOQueue = DispatchQueue(label: "VideoOutputQueue")
    var VideoConnection: AVCaptureConnection? = nil
    
    var FrameCount = 0
    
    /// Handle view did appear events.
    /// - Note:
    ///   - If we are running on a simulator, report an error to the debug console and return.
    /// - Parameter animated: Passed to super class.
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        UpdateHUDViews()
        #if targetEnvironment(simulator)
        DeviceHasCamera = false
        Log.Message("Simulator does not support camera input.")
        #else
        InitializeLiveView()
        InitializeProcessedLiveView()
        
        if DeviceHasCamera
        {
            SwitchModeButton.isHidden = false
        }
        else
        {
            SwitchModeButton.isHidden = true
        }
        #if false
        InitializeHistogramView()
        if Settings.GetBoolean(ForKey: .ShowHistogram)
        {
            if !ProcessedViewInitialized
            {
                InitializeProcessedLiveView()
            }
            ShowHistogramView()
        }
        #endif
        #endif
    }
    
    /// Set of discovered camera devices.
    var VideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInTrueDepthCamera],
                                                                       mediaType: .video, position: .unspecified)
    
    /// Handle the view will disappear event.
    /// - Note: The capture session is stopped. If the user is merely moving us to the background, the session will have to be
    ///         restarted.
    /// - Parameter animated: Passed to the super class.
    override func viewWillDisappear(_ animated: Bool)
    {
        super.viewWillDisappear(animated)
        #if !targetEnvironment(simulator)
        self.CaptureSession.stopRunning()
        #endif
    }
    
    /// Handle instantiation of the settings dialog.
    /// - Parameter coder: Used to create the settings controller.
    /// - Returns: Settings controller to run the UI.
    @IBSegueAction func InstantiateSettingsDialogs(_ coder: NSCoder) -> SettingsNavigationController?
    {
        HideTitle(After: 0.0, HideDuration: 0.5, HideHow: .FadeOut)
        let Controller = SettingsNavigationController(coder: coder)
        return Controller
    }
    
    /// Highlight a button bar. Intended to be called when the user presses a button.
    /// - Note: Highlighting consists of changing the color of the button's tint to `HighlightColor`
    ///         then changing the color back to UIColor.black over a period of time.
    /// - Parameter Button: The button the user pressed.
    /// - Parameter HighlightColor: The color to use for the highlight.
    func HighlightButtonPress(_ Button: UIButton, HighlightColor: UIColor = UIColor.white)
    {
        let OriginalColor: UIColor = Button.tintColor
        Button.tintColor = HighlightColor
        let AnimationDuration = Settings.GetDouble(ForKey: .UIButtonHighlightFadeDuration, IfZero: 0.35)
        UIView.animate(withDuration: AnimationDuration, animations:
            {
                Button.tintColor = OriginalColor//UIColor.black
        })
    }
    
    /// Handle the camera button pressed event.
    /// - Note:
    ///    - Depending on the current mode, either a snapshot of the current live view will be processed or the image
    ///      picker will be called to let the user select an image to process.
    ///    - The actual camera button icon will change depending on what mode we are in.
    /// - Parameter sender: Not used.
    @IBAction func HandleCameraButtonPressed(_ sender: Any)
    {
        HideTitle(After: 0.0, HideDuration: 0.5, HideHow: .FadeOut)
        switch CurrentViewMode
        {
            case .LiveView:
                HighlightButtonPress(sender as! UIButton)
                if Settings.GetBoolean(ForKey: .EnableShutterSound)
                {
                    Sounds.PlaySound(.Shutter)
                }
                else
                {
                    if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
                    {
                        Sounds.PlaySound(.Tock)
                    }
                }
                let Settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                StillImageOutput.capturePhoto(with: Settings, delegate: self)
                SwitchToImageMode()
            
            case .MakeVideo:
                HighlightButtonPress(sender as! UIButton)
                if MakingVideo
                {
                    if Settings.GetBoolean(ForKey: .EnableVideoRecordingSound)
                    {
                        Sounds.PlaySound(.BeginRecording)
                    }
                }
                else
                {
                    if Settings.GetBoolean(ForKey: .EnableVideoRecordingSound)
                    {
                        Sounds.PlaySound(.EndRecording)
                    }
                }
                MakingVideo = !MakingVideo
                CameraButton.tintColor = MakingVideo ? UIColor.systemRed : UIColor.black
                if !MakingVideo
                {
                    //All done - save the video then process it.
                    SwitchToImageMode()
                }
                else
                {
                    let MediaBrowser = UIImagePickerController()
                    MediaBrowser.sourceType = .camera
                    MediaBrowser.mediaTypes = [kUTTypeMovie as String]
                    MediaBrowser.allowsEditing = true
                    MediaBrowser.delegate = self
                    self.present(MediaBrowser, animated: true, completion:
                        {
                            self.SwitchToImageMode()
                    }
                    )
            }
            
            case .PhotoLibrary,
                 .ProcessedView:
                HighlightButtonPress(sender as! UIButton, HighlightColor: UIColor.yellow)
                if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
                {
                    Sounds.PlaySound(.Tock)
                }
                InitialProcessedImage = true
                let ImagePicker = UIImagePickerController()
                ImagePicker.sourceType = .photoLibrary
                ImagePicker.mediaTypes = UIImagePickerController.availableMediaTypes(for: UIImagePickerController.SourceType.photoLibrary)!
                ImagePicker.delegate = self
                self.present(ImagePicker, animated: true, completion: nil)
        }
    }
    
    var InitialProcessedImage = false
    var MakingVideo = false
    var LastImageName: String = ""
    
    var ImageToProcess: UIImage? = nil
    
    var ViewOrder = [ProgramModes.LiveView, ProgramModes.PhotoLibrary, ProgramModes.MakeVideo]
    
    var CurrentView = 0
    var CurrentViewMode = ProgramModes.LiveView
    
    /// Handle the switch mode button press. This switches input modes between the various supported modes.
    /// - Parameter sender: Not used.
    @IBAction func HandleSwitchModeButtonPressed(_ sender: Any)
    {
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        HideTitle(After: 0.0, HideDuration: 0.5, HideHow: .FadeOut)
        CurrentView = CurrentView + 1
        if CurrentView > ViewOrder.count - 1
        {
            CurrentView = 0
        }
        CurrentViewMode = ViewOrder[CurrentView]
        MainBottomBar.layer.sublayers?.forEach
            {
                if $0.name == "GradientBackground"
                {
                    $0.removeFromSuperlayer()
                }
        }
        let Gradient = Colors.GetGradientFor(CurrentViewMode, Container: MainBottomBar.bounds)
        MainBottomBar.layer.addSublayer(Gradient)
        switch CurrentViewMode
        {
            case .LiveView:
                HighlightButtonPress(sender as! UIButton)
                CameraButton.setImage(UIImage(systemName: "camera"), for: UIControl.State.normal)
                SwitchCameraButton.isHidden = false
                SwitchCameraButton.isUserInteractionEnabled = true
                ImageFromLibrary = false
                SwitchToLiveViewMode()
            
            case .MakeVideo:
                HighlightButtonPress(sender as! UIButton)
                CameraButton.setImage(UIImage(systemName: "tv.fill"), for: UIControl.State.normal)
                SwitchCameraButton.isHidden = false
                SwitchCameraButton.isUserInteractionEnabled = true
                ImageFromLibrary = false
                SwitchToLiveViewMode()
            
            case .PhotoLibrary:
                HighlightButtonPress(sender as! UIButton, HighlightColor: UIColor.yellow)
                CameraButton.setImage(UIImage(systemName: "photo.on.rectangle"), for: UIControl.State.normal)
                SwitchCameraButton.isHidden = true
                SwitchCameraButton.isUserInteractionEnabled = false
                ImageFromLibrary = true
                SwitchToPhotoPickerMode()
            
            default:
                break
        }
    }
    
    /// Handle the switch camera button pressed. Reinitializes the live view with the appropriate camera.
    /// - Parameter sender: Not used.
    @IBAction func HandleSwitchCameras(_ sender: Any)
    {
        HighlightButtonPress(sender as! UIButton)
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        HideTitle(After: 0.0, HideDuration: 0.5, HideHow: .FadeOut)
        UsingBackCamera = !UsingBackCamera
        InitializeLiveView(UseBackCamera: UsingBackCamera)
        InitializeProcessedLiveView()
    }
    
    var UsingBackCamera: Bool = true
    
    /// Show the quick help text for the record scene toolbar.
    @IBAction func HandleVideoInfoButtonPressed(_ sender: Any)
    {
        HighlightButtonPress(sender as! UIButton)
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        let Alert = UIAlertController(title: "Quick Help",
                                      message: "Press the Record button to start. Move the scene with your finger. Press the Stop button to stop.",
                                      preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(Alert, animated: true, completion: nil)
    }
    
    /// Handle the main settings button pressed. Depending on the current mode, different context
    /// menus are shown.
    /// - Parameter sender: Not used.
    @IBAction func HandleMainSettingsButtonPressed(_ sender: Any)
    {
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        switch CurrentViewMode
        {
            case .LiveView:
                HighlightButtonPress(sender as! UIButton)
                ShowLiveViewMenu()
            
            case .PhotoLibrary,
                 .ProcessedView:
                HighlightButtonPress(sender as! UIButton, HighlightColor: UIColor.yellow)
                ShowProcessedViewMenu(From: SettingsButton)
            
            case .MakeVideo:
                HighlightButtonPress(sender as! UIButton)
                ShowLiveViewMenu()
        }
    }
    
    // MARK: - Image processing save functions.
    
    /// The user closed the image processing view/mode. Switch back to live view. If came from the image picker view, move back
    /// to that mode.
    /// - Note: When the user pressed the Done button, all nodes in the 3D scene are removed. This is done to save energy as
    ///         the 3D scene is still running in the background even though it is not visible. By removing all (except for camera
    ///         and light) nodes, the amount of GPU processing is reduced significantly.
    @IBAction func HandleDoneWithImageProcessingButton(_ sender: Any)
    {
        HighlightButtonPress(sender as! UIButton, HighlightColor: UIColor.systemYellow)
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        FileIO.DeletePixellatedData(WithName: "Pixels.dat")
        SwitchToLiveViewMode()
        CanSaveOriginal = true
        InProcessView = false
        //OutputView.Clear()
    }
    
    /// That that controls how often to save the original image - this flag is set to false once the save button is pressed,
    /// thereby stopping further saves (with presumably different parameters) from saving the same image multiple times. Once
    /// the user closes the image (3D) mode, this flag is set to true again so the next time a different image is processed, its
    /// original will be saved.
    var CanSaveOriginal = true
    
    /// If the processed image's source is an image from the photo library, don't save the original if the user saves the
    /// processed image. This flag is set and reset in the mode switching code.
    var ImageFromLibrary = false
    
    /// Handle the save image button from the image processing view/mode. The current state of the processed image is saved
    /// along with the original image, if the user selected that option.
    /// - Note:
    ///    - There is a sub-second delay from when the user presses the save image button and the image
    ///      actually being saved. This is because if the SCNView is showing statistics, we want to
    ///      give the view time to turn off the sub-view before saving the image. After the image
    ///      is saved, the statistics are returned to its original state at the time of this function call.
    ///    - Due to the sub-second delay, it is possible for the user to move the rendered scene before
    ///      the image is actually taken. It may end up being desirable to disable camera motion when
    ///      this image executes and restore it afterwards.
    ///    - If output view is *not* showing statistics, there is no delay.
    ///    - Rather than using `SCNView.snapshot`, this function uses an extension method defined on
    ///      `UIView`: `ToImage`. This is because `SCNView.snapshot` does not render shadows correctly
    ///      while `ToImage` does.
    /// - See:
    ///    - `DoSaveImage`
    ///    - `UIView.ToImage`
    /// - Parameter sender: Not used.
    @IBAction func HandleSaveProcessedImageButton(_ sender: Any)
    {
        HighlightButtonPress(sender as! UIButton, HighlightColor: UIColor.systemPurple)
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        let IsShowing = OutputView.showsStatistics
        if IsShowing
        {
            OutputView.showsStatistics = false
            var Image: UIImage = UIImage()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5)
            {
                Image = self.OutputView.ToImage()
                self.DoSaveImage(Image)
                self.OutputView.showsStatistics = IsShowing
            }
        }
        else
        {
            let Image = self.OutputView.ToImage()
            self.DoSaveImage(Image)
        }
    }
    
    /// Do the actual image save here. Intended to be called by `HandleSaveProcessedImageButton`.
    /// - Note: If the image is *not* from the photo library, the original image will be saved along
    ///         with the processed image.
    /// - Parameter Image: The image to save.
    /// - See: `HandleSaveProcessedImageButton`
    func DoSaveImage(_ Image: UIImage)
    {
        let SourceSize = "\(Generator.OriginalImageSize)"
        let ReducedSize = "\(Generator.ReducedImageSize)"
        let UserData = CurrentSettings.KVPs(AppendWith: [("Original size", SourceSize), ("Reduced size", ReducedSize)])
        FileIO.SaveImageWithMetaData(Image, KeyValueString: UserData)
        {
            Successful in
            if Successful
            {
                #if true
                self.CompositeStatus.AddText(NSLocalizedString("StatusImageSaved", comment: ""), HideAfter: 3.0)
                #else
                self.CompositeStatus.AddText("Image saved OK.", HideAfter: 3.0)
                #endif
            }
        }
        if !ImageFromLibrary
        {
            /// Save the original image if required...
            if Settings.GetString(ForKey: .SaveOriginalImageAction) == SaveOriginalImageActions.WhenProcessedSaved.rawValue && CanSaveOriginal
            {
                CanSaveOriginal = false
                if let SaveMe = ImageToProcess
                {
                    UIImageWriteToSavedPhotosAlbum(SaveMe, self, #selector(image(_:didFinishSavingWithError:contextInfo:)),nil)
                }
            }
        }
    }
    
    /// Handle the record scene button pressed. Functions as a toggle button.
    /// - Parameter sender: Not used.
    @IBAction func HandleSceneRecordButtonPressed(_ sender: Any)
    {
        if OutputView.RecordScene
        {
            SceneRecorderButton.setImage(UIImage(systemName: "circle"), for: .normal)
            SceneRecorderButton.tintColor = UIColor.black
            OutputView.RecordScene = false
            let Alert = UIAlertController(title: "Save Recorded Scene?",
                                          message: "Do you want to save your scene motion as a video? Selecting \"No\" removes recorded frames.",
                                          preferredStyle: .alert)
            #if true
            Alert.addAction(UIAlertAction(title: NSLocalizedString("GenericYes", comment: ""), style: .default, handler:
                {
                    _ in
                    self.SaveRecordedScene()
            }))
            Alert.addAction(UIAlertAction(title: NSLocalizedString("GenericNo", comment: ""), style: .destructive, handler: nil))
            #else
            Alert.addAction(UIAlertAction(title: "Yes", style: .default, handler:
                {
                    _ in
                    self.SaveRecordedScene()
            }))
            Alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            #endif
            self.present(Alert, animated: true)
        }
        else
        {
            SceneRecorderButton.setImage(UIImage(systemName: "circle.fill"), for: .normal)
            SceneRecorderButton.tintColor = UIColor.red
            OutputView.RecordScene = true
        }
    }
    
    func ChangeSettingsFromMenu()
    {
        let Storyboard = UIStoryboard(name: "ProgramSettings", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "SettingsRootUI") as? SettingsNavigationController
        {
            self.present(Controller, animated: true)
        }
    }
    
    func ShowAboutFromMenu()
    {
        let Storyboard = UIStoryboard(name: "AboutStoryboard", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "AboutBlockCam") as? AboutBlockCam
        {
            self.present(Controller, animated: true)
        }
    }
    
    /// Save the recorded scene. Delete scene frames once completed.
    func SaveRecordedScene()
    {
        OutputView.SceneFrameCount = 0
        #if true
        let Files = FileIO.ContentsOfSpecialDirectory(FileIO.SceneFrames)!
        VideoGenerator.CombineIntoVideo(Files)
        #else
        VideoAssembly.AssembleAndSave(FilesInDirectory: FileIO.SceneFrames, TargetURL: FileIO.GetSceneFramesDirectory()!,
                                      SaveToPhotoRoll: true, Parent: self,
                                      StatusHandler: nil, Completed: nil)
        #endif
    }
    
    /// Show the current settings that will be used to generate images.
    func ShowCurrentSettings()
    {
        let ParagraphStyle = NSMutableParagraphStyle()
        ParagraphStyle.alignment = .left
        let MessageText = NSAttributedString(string: CurrentSettings.Description,
                                             attributes:
            [
                NSAttributedString.Key.paragraphStyle: ParagraphStyle,
                NSAttributedString.Key.foregroundColor: UIColor.black,
                NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)
        ])
        let SettingsView = UIAlertController(title: "Current Settings",
                                             message: "", preferredStyle: .alert)
        SettingsView.setValue(MessageText, forKey: "attributedMessage")
        SettingsView.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(SettingsView, animated: true)
    }
    
    /// Run the shape settings menu command.
    func RunShapeSettingsFromMenu()
    {
        performSegue(withIdentifier: "ToContextShapeSettings", sender: self)
    }
    
    /// Run the height setting menu command.
    func RunHeightSettingsFromMenu()
    {
        performSegue(withIdentifier: "ToContextHeightSettings", sender: self)
    }
    
    /// Run the lighting dialog.
    func RunLightingSettingsFromMenu()
    {
        performSegue(withIdentifier: "ToContextLightingSettings", sender: self)
    }
    
    /// Run the performance settings dialog.
    func RunPerformanceSettingsFromMenu()
    {
        performSegue(withIdentifier: "ToPerformanceSettings", sender: self)
    }
    
    /// Change settings to values to help with performance.
    func SetForBestPerformance()
    {
        Settings.SetInteger(32, ForKey: .BlockSize)
        Settings.SetInteger(1024, ForKey: .MaxImageDimension)
        Settings.SetString(NodeShapes.Blocks.rawValue, ForKey: .ShapeType)
        Settings.SetString(BlockEdgeSmoothings.None.rawValue, ForKey: .BlockChamferSize)
        Log.Message("Changed settings for \"best\" performance.")
    }
    
    /// Export/share processed images.
    func RunExportProcessedImageFromMenu()
    {
        let Image = OutputView.snapshot()
        DoExportImage(Image)
    }
    
    /// Run the help viewer.
    func RunHelpViewer()
    {
        let Storyboard = UIStoryboard(name: "Help", bundle: nil)
        if let Controller = Storyboard.instantiateViewController(identifier: "HelpRoot") as? UINavigationController
        {
            self.present(Controller, animated: true)
        }
    }
    
    /// Handle some segues to assign the the appropriate delegate property. This is needed for context menu-created dialogs.
    /// - Note: Specifically, the following classes will have their `Delegate` property set:
    ///    - `Menu_ShapeSettings`
    ///    - `Menu_HeightSettings`
    ///    - `Menu_LightSettings`
    ///    - `Menu_PerformanceSettings`
    /// - Parameter for: The segue that will be executed.
    /// - Parameter sender: Not used.
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if let NavVC = segue.destination as? UINavigationController
        {
            if let Dest = NavVC.viewControllers.first as? Menu_ShapeSettings
            {
                Dest.Delegate = self
            }
            if let Dest = NavVC.viewControllers.first as? Menu_HeightSettings
            {
                Dest.Delegate = self
            }
            if let Dest = NavVC.viewControllers.first as? Menu_LightSettings
            {
                Dest.Delegate = self
            }
            if let Dest = NavVC.viewControllers.first as? Menu_PerformanceSettings
            {
                Dest.Delegate = self
            }
        }
        super.prepare(for: segue, sender: self)
    }
    
    func LoadSavedScene()
    {
        
    }
    
    func SaveScene()
    {
        let SceneFileName = Utilities.MakeSequentialName("Scene", Extension: "scn")
        let SceneDir = FileIO.GetSavedScenesDirectory()
        let FinalURL = SceneDir?.appendingPathComponent(SceneFileName)
        OutputView.scene!.write(to: FinalURL!,
                                options: [:],
                                delegate: nil,
                                progressHandler: nil)
    }
    
    /// Handle the close scene recorder button bar. Restores the original image bottom tool bar.
    /// - Parameter sender: Not used.
    @IBAction func HandleCloseSceneRecordButtonPressed(_ sender: Any)
    {
        OutputView.SceneFrameCount = 0
        FileIO.ClearSceneFrameDirectory()
        HideRecordSceneBar()
    }
    
    // MARK: - High-level drawing and redrawing functions.
    
    /// Called by context menus when settings change that do not need a redraw of the 3D image.
    /// - Parameter Updated: Changed settings.
    func ContextMenuSettingsChanged(_ Updated: [SettingKeys])
    {
        
    }
    
    /// Called when a setting changes that requires redrawing the 3D view. Ignored when not in 3D mode. Called by setting dialogs
    /// when they are closed (to prevent too many redraws).
    /// - Note:
    ///     - If the program is not in processed image mode (eg, looking at a processed 3D image), no action is taken as
    ///       there is no image to modify.
    ///     - If the image to process (`ImageToProcess`) is not defined, no action is taken.
    ///     - Care is taken to try to optimize performance by not re-running the entire process if it does not need to be.
    /// - Parameter With: The array of changed settings (represented by their respective keys). If no
    ///                   changes were made, this array will be empty. If nothing is passed, control
    ///                   is returned immediately and no redrawing is done.
    func Redraw3D(_ With: [SettingKeys])
    {
        if ImageToProcess == nil
        {
            return
        }
        if !InProcessView
        {
            return
        }
        print("Redraw3D: \(With)")
        var Working = With
        if Working.count > 0
        {
            if Working.count == 1
            {
                switch With[0]
                {
                    case .SceneBackgroundColor:
                        self.OutputView.UpdateScene()
                        return
                    
                    case .StarApexCount:
                        Generator.UpdateImage(OutputView)
                        return
                    
                    case .BlockChamferSize:
                        Generator.UpdateImage(OutputView)
                        return
                    
                    case .LightingModel:
                        Generator.UpdateNodeLightingModel()
                        return
                    
                    default:
                        break
                }
            }
            
            let LightingSettings = [SettingKeys.LightType, SettingKeys.LightColor, SettingKeys.LightIntensity]
            if Utilities.ArrayContains(AnyOf: LightingSettings, In: Working)
            {
                OutputView.UpdateLightNode()
                Working = Utilities.RemoveAllOf(LightingSettings, From: Working)
            }
            
            let FullRedrawAndNewLightOptions = [SettingKeys.EnableShadows]
            let FullRedrawOptions = [SettingKeys.BlockSize]
            
            let SceneOptions = [SettingKeys.SceneBackgroundColor]
            
            if Utilities.ArrayContains(AnyOf: SceneOptions, In: Working)
            {
                self.OutputView.UpdateScene()
            }
            if Utilities.ArrayContains(AnyOf: FullRedrawOptions, In: Working)
            {
                ProcessImageInBackground(ImageToProcess!)
                return
            }
            if Utilities.ArrayContains(AnyOf: FullRedrawAndNewLightOptions, In: Working)
            {
                self.OutputView.UpdateLightNode()
                ProcessImageInBackground(ImageToProcess!)
                return
            }
            //            if Utilities.ArrayContains(AnyOf: ShapeManager.GetSemiRedrawOptions(), In: Working)
            if ShapeManager.InSemiRedraw(Working)
            {
                let PrePixellated = FileIO.GetPixelData(From: "Pixels.dat")
                var CanReusePixels = true
                if PrePixellated == nil
                {
                    Log.Message("No pre-pixellated data found - cannot change shape.")
                    CanReusePixels = false
                }
                if CanReusePixels
                {
                    #if true
                    ProcessImageWrapper(PrePixellated!)
                    #else
                    OutputView.ProcessImage(PrePixellated!, CalledFrom: "Redraw3D")
                    #endif
                }
            }
        }
    }
    
    // MARK: - Alert functions used by the app delegate
    
    public func ShowAlert(Title: String, Message: String, CloseButtonLabel: String)
    {
        let Alert = UIAlertController(title: Title, message: Message, preferredStyle: .alert)
        Alert.addAction(UIAlertAction(title: CloseButtonLabel, style: .cancel, handler: nil))
        self.present(Alert, animated: true, completion: nil)
    }
    
    // MARK: - PhotoKit delegate-required variables.
    public var SavingOriginalImage = false
    public var DeviceHasCamera: Bool = true
    public var PreviewSize: CGSize = CGSize.zero
    
    // MARK: - Histogram variables.
    let HistogramSpeedTable =
        [
            HistogramCreationSpeeds.Fastest: 1,
            HistogramCreationSpeeds.Fast: 5,
            HistogramCreationSpeeds.Medium: 15,
            HistogramCreationSpeeds.Slow: 20,
            HistogramCreationSpeeds.Slowest: 30
    ]
    //var HistogramIsVisible: Bool = false
    
    // MARK: - Activity viewer required variables.
    var ImageToExport: UIImage? = nil
    
    // MARK: - Title related variables.
    var TitleClosure: ((Bool) -> ())? = nil
    var MainTitleView: UIView!
    var TitleImage: UIImageView!
    var TitleVersionBox: UIView!
    var TitleVersionLabel: UILabel!
    
    // MARK: - Asynchronous event handling variables.
    let ThermalMap =
        [
            ProcessInfo.ThermalState.critical: "Critical",
            ProcessInfo.ThermalState.fair: "Fair",
            ProcessInfo.ThermalState.nominal: "Nominal",
            ProcessInfo.ThermalState.serious: "Serious"
    ]
    
    // MARK: - Text layer required variables.
    var ShowingTitle = true
    @IBOutlet weak var TextPleaseWait: UILabel!
    @IBOutlet weak var TextLayerView: UIView!
    @IBOutlet weak var TextTooLong: UILabel!
    var PleaseWaitFrame: CGRect = CGRect.zero
    
    // MARK: - Process view variables.
    var InProcessView = false
    
    // MARK: - Gyroscope variables.
    var MotionManager: CMMotionManager? = nil
    var PreviousRotation: Double = -1000.0
    
    // MARK: - Interface builder variables.
    @IBOutlet weak var SettingsButton: UIButton!
    @IBOutlet weak var SceneRecordInfoButton: UIButton!
    @IBOutlet weak var SceneRecorderButton: UIButton!
    @IBOutlet weak var CloseSceneRecorderViewButton: UIButton!
    @IBOutlet weak var SceneMotionRecorderView: UIView!
    @IBOutlet weak var MainBottomBar: UIView!
    @IBOutlet weak var PhotoEditorBar: UIView!
    @IBOutlet weak var ImageBottomBar: UIView!
    @IBOutlet weak var SwitchCameraButton: UIButton!
    @IBOutlet weak var SwitchModeButton: UIButton!
    @IBOutlet weak var LiveView: UIView!
    @IBOutlet weak var GridView: GridLayer!
    @IBOutlet weak var CameraButton: UIButton!
    @IBOutlet weak var SkipEditingButton: UIButton!
    @IBOutlet weak var BackToCameraButton: UIButton!
    @IBOutlet weak var CropRotateButton: UIButton!
    @IBOutlet weak var AdjustContrastButton: UIButton!
    @IBOutlet weak var AcceptEditsButton: UIButton!
    // "weak" is removed from OutputView because we recreate the class in code and weak leads to strange compiler warnings...
    @IBOutlet var OutputView: ProcessViewer!
    @IBOutlet weak var HUDView: UIView!
    @IBOutlet weak var EditView: UIView!
    @IBOutlet weak var EditImageView: UIImageView!
    
    // MARK: - Interface builder variables for image processing.
    @IBOutlet weak var CompositeStatus: SmallStatusDisplay!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var DoneButton: UIButton!
    
    // MARK: - Histogram view.
    @IBOutlet weak var HistogramView: HistogramDisplay!
    
    // MARK: - HUD variables and interface builder outlets
    @IBOutlet weak var HUDVersionLabel: UILabel!
    @IBOutlet weak var HUDCompassLabel: UILabel!
    @IBOutlet weak var HUDAltitudeLabel: UILabel!
    @IBOutlet weak var HUDHSBIndicator1: BoxIndicator!
    @IBOutlet weak var HUDHSBIndicator2: BoxIndicator!
    @IBOutlet weak var HUDHSBIndicator3: BoxIndicator!
    @IBOutlet weak var HUDHSBStack: UIStackView!
    @IBOutlet weak var MeanColorIndicator: SimpleColorIndicator!
    @IBOutlet weak var HistogramWidthConstraint: NSLayoutConstraint!
    
    // MARK: - Location management variables.
    var LocationManager: CLLocationManager? = nil
    var PreviousAltitude: Double = -10000.0
    var LocationTimer: Timer!
    
    // MARK: - Processing image wrapper variables.
    var TooLongTimer: Timer!
}
