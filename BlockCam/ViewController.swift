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

/// Main view controller for the BlockCam program.
/// - Note: See [Create a Custom Camera View](https://guides.codepath.com/ios/Creating-a-Custom-Camera-View)
class ViewController: UIViewController,
    AVCapturePhotoCaptureDelegate,
    AVCaptureVideoDataOutputSampleBufferDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate,
    SettingChangedProtocol,
    MenuButtonProtocol
{
    func GetButtonMenu() -> UIMenu
    {
        return MakeLiveViewMenu()
    }
    
    // MARK: - Initialization
    
    var CaptureSession: AVCaptureSession!
    var StillImageOutput: AVCapturePhotoOutput!
    var VideoPreviewLayer: AVCaptureVideoPreviewLayer!
    var IsOnCatalyst: Bool = false
    // Thread for running the processing of images in the background.
    let BackgroundThread = DispatchQueue(label: "ProcessingThread", qos: .background)
    
    /// Initialize the UI and program.
    /// - Note: Assumes several other classes have been initialized by the time control reaches here. These are initialized
    ///         in the app delegate.
    override func viewDidLoad()
    {
        super.viewDidLoad()
        Settings.AddSubscriber(self, "MainView")
        InitializeStatusLayer()
        Generator.Delegate = self
        definesPresentationContext = true
        InitializeModeUIs()
        SetupNotifications()
        Sounds.Initialize()
        
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
        /*
        let SceneContextMenu = UIContextMenuInteraction(delegate: self)
        OutputView.addInteraction(SceneContextMenu)
        let LiveContextMenu = UIContextMenuInteraction(delegate: self)
        LiveView.addInteraction(LiveContextMenu)
        */
        
        OutputView.alpha = 0.0
        
        //UnicodeHelper.Initialize()
        //Emoji.Initialize()
        
        FileIO.ClearScratchDirectory()
        
        ShowStatusLayer()
        ShowSplashScreen()
        GetPermissions()
        
        let Gradient = Colors.GetGradientFor(CurrentViewMode, Container: MainBottomBar.bounds)
        MainBottomBar.layer.addSublayer(Gradient)
        ImageBottomBar.layer.addSublayer(Colors.GetProcessingGradient(Container: ImageBottomBar.bounds))
        
        FileIO.ClearScratchDirectory()
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
                    self.ShowMainTitle("BlockCam", Version: VersionString, VersionBackground: VBG, AnimateTime: 3.0,
                                       ShowDuration: 5.0)
                }
        }
    }
    
    /// Ask for the necessary permissions from the user.
    /// - Note:
    ///   - There are two sets of permissions required to use BlockCam:
    ///         1 Camera access.
    ///         2 Photo roll access.
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
            case .ShowHistogram:
                if Settings.GetBoolean(ForKey: .ShowHistogram)
                {
                    self.ShowHistogramView()
                }
                else
                {
                    self.HideHistogramView()
            }
            
            case .AntialiasingMode:
                let Mode = UInt(Settings.GetInteger(ForKey: .AntialiasingMode))
                let AntialiasMode = SCNAntialiasingMode(rawValue: Mode)!
                OutputView.antialiasingMode = AntialiasMode
            
            default:
                break
        }
    }
    
    var ChangedSettings = [SettingKeys]()
    
    /// Initialize the output view.
    func InitializeOutput()
    {
        var ViewOptions: [String: Any]!
        #if targetEnvironment(macCatalyst)
        ViewOptions = [SCNView.Option.preferredDevice.rawValue: NSNumber(value: SCNRenderingAPI.metal.rawValue) as Any]
        #else
        if Settings.GetBoolean(ForKey: .UseMetal)
        {
            ViewOptions = [SCNView.Option.preferredDevice.rawValue: NSNumber(value: SCNRenderingAPI.metal.rawValue) as Any]
        }
        else
        {
            ViewOptions = [SCNView.Option.preferredDevice.rawValue: NSNumber(value: SCNRenderingAPI.openGLES2.rawValue) as Any]
        }
        #endif
        let NewFrame = CGRect(x: self.view.frame.minX,
                              y: self.view.frame.minY,
                              width: self.view.frame.width,
                              height: self.view.frame.height - 70)
        OutputView = ProcessViewer(frame: NewFrame, options: ViewOptions) 
        if OutputView == nil
        {
            fatalError("Output view was deallocated!")
        }
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
    ///   - If we are running via Catalyst on a Mac, set the appropriate flag. Unfortunately, right now, Catalyst does not support
    ///     AVFoundation to the extent we need and official Apple guidance (for now) is to use the UIImagePickercontroller with
    ///     the camera source.
    ///   - If we are on an iOS/iPadOS device, initialize the live view.
    ///   - If we are running on a simulator, report an error to the debug console and return.
    /// - Parameter animated: Passed to super class.
    override func viewDidAppear(_ animated: Bool)
    {
        super.viewDidAppear(animated)
        #if targetEnvironment(simulator)
        Log.Message("Simulator does not support camera input.")
        return
        #endif
        #if targetEnvironment(macCatalyst)
        IsOnCatalyst = true
        #endif
        if IsOnCatalyst
        {
            if UIImagePickerController.isSourceTypeAvailable(.camera)
            {
                let ImagePicker = UIImagePickerController()
                ImagePicker.sourceType = .camera
                ImagePicker.delegate = self
                ImagePicker.cameraDevice = .front
                self.present(ImagePicker, animated: true, completion: nil)
            }
        }
        else
        {
            InitializeLiveView()
        }
        #if true
        InitializeHistogramView()
        HideHistogramView()
        #else
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
        #if !targetEnvironment(macCatalyst) && !targetEnvironment(simulator)
        self.CaptureSession.stopRunning()
        #endif
    }
    
    /// Handle instantiation of the settings dialog.
    /// - Parameter coder: Used to create the settings controller.
    /// - Returns: Settings controller to run the UI.
    @IBSegueAction func InstantiateSettingsDialogs(_ coder: NSCoder) -> SettingsNavigationController?
    {
        HideTitle(After: 0.0, HideDuration: 0.5, HideHow: .FadeOut)
        //        HideTitle()
        let Controller = SettingsNavigationController(coder: coder)
        return Controller
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
            
            case .PhotoLibrary, .ProcessedView:
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
                CameraButton.setImage(UIImage(systemName: "camera"), for: UIControl.State.normal)
                CameraButton.setTitle(NSLocalizedString("UIPhotoButton", comment: ""), for: .normal)
                SwitchCameraButton.isHidden = false
                SwitchCameraButton.isUserInteractionEnabled = true
                ImageFromLibrary = false
//                MainBottomBar.backgroundColor = UIColor.systemYellow
                SwitchToLiveViewMode()
            
            case .MakeVideo:
                CameraButton.setImage(UIImage(systemName: "tv.fill"), for: UIControl.State.normal)
                CameraButton.setTitle(NSLocalizedString("UIVideoButton", comment: ""), for: .normal)
                SwitchCameraButton.isHidden = false
                SwitchCameraButton.isUserInteractionEnabled = true
                ImageFromLibrary = false
//                MainBottomBar.backgroundColor = UIColor.systemGreen
                SwitchToLiveViewMode()
            
            case .PhotoLibrary:
                CameraButton.setImage(UIImage(systemName: "photo.on.rectangle"), for: UIControl.State.normal)
                CameraButton.setTitle(NSLocalizedString("UIAlbumButton", comment: ""), for: .normal)
                SwitchCameraButton.isHidden = true
                SwitchCameraButton.isUserInteractionEnabled = false
                ImageFromLibrary = true
//                MainBottomBar.backgroundColor = UIColor.systemOrange
                SwitchToPhotoPickerMode()
            
            default:
                break
        }
    }
    
    /// Handle the switch camera button pressed. Reinitializes the live view with the appropriate camera.
    /// - Parameter sender: Not used.
    @IBAction func HandleSwitchCameras(_ sender: Any)
    {
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        HideTitle(After: 0.0, HideDuration: 0.5, HideHow: .FadeOut)
        UsingBackCamera = !UsingBackCamera
        InitializeLiveView(UseBackCamera: UsingBackCamera)
    }
    
    var UsingBackCamera: Bool = true
    
    /// Show the quick help text for the record scene toolbar.
    @IBAction func HandleVideoInfoButtonPressed(_ sender: Any)
    {
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
    
    @IBAction func HandleLiveViewInfoButtonPressed(_ sender: Any)
    {
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        switch CurrentViewMode
        {
            case .LiveView:
            ShowLiveViewMenu()
            
            case .PhotoLibrary:
                ShowProcessedViewMenu(From: SettingsButton)
            
            case .MakeVideo:
            ShowLiveViewMenu()
            
            default:
            return
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
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        FileIO.DeletePixellatedData(WithName: "Pixels.dat")
        SwitchToLiveViewMode()
        CanSaveOriginal = true
        InProcessView = false
        OutputView.Clear()
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
    /// - Parameter sender: Not used.
    @IBAction func HandleSaveProcessedImageButton(_ sender: Any)
    {
        if Settings.GetBoolean(ForKey: .EnableButtonPressSounds)
        {
            Sounds.PlaySound(.Tock)
        }
        let Image = OutputView.snapshot()
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
            SceneRecorderButton.setTitle("Record", for: .normal)
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
            #if true
            SceneRecorderButton.setTitle(NSLocalizedString("UIStopButton", comment: ""), for: .normal)
            #else
            SceneRecorderButton.setTitle("Stop", for: .normal)
            #endif
            OutputView.RecordScene = true
        }
    }
    
    func ChangeSettingsFromMenu()
    {
        performSegue(withIdentifier: "ToSettingsController", sender: self)
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
            
            let FullRedrawOptions = [SettingKeys.BlockSize]
            let SemiRedrawOptions = [SettingKeys.ShapeType, SettingKeys.HeightSource, SettingKeys.VerticalExaggeration,
                                     SettingKeys.FullyExtrudeLetters, SettingKeys.LetterLocation, SettingKeys.LetterSmoothness,
                                     SettingKeys.LetterFont, SettingKeys.RandomCharacterSource, SettingKeys.StarApexCount,
                                     SettingKeys.IncreaseStarApexesWithProminence, SettingKeys.CappedLineBallLocation,
                                     SettingKeys.FontSize, SettingKeys.MeshDotSize, SettingKeys.MeshLineThickness,
                                     SettingKeys.BlockChamferSize, SettingKeys.RadiatingLineCount, SettingKeys.InvertHeight,
                                     SettingKeys.HeightSource, SettingKeys.InvertDynamicColorProcess, SettingKeys.FlowerPetalCount,
                                     SettingKeys.DynamicColorAction, SettingKeys.DynamicColorType, SettingKeys.CappedLineCapShape,
                                     SettingKeys.DynamicColorCondition, SettingKeys.SourceAsBackground, SettingKeys.EllipseShape,
                                     SettingKeys.IncreasePetalCountWithProminence, SettingKeys.CharacterUsesRandomFont,
                                     SettingKeys.CharacterRandomRange, SettingKeys.CharacterFontName, SettingKeys.CharacterRandomFontSize,
                                     SettingKeys.CharacterSeries, SettingKeys.StackedShapesSet]
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
            if Utilities.ArrayContains(AnyOf: SemiRedrawOptions, In: Working)
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
                    OutputView.ProcessImage(PrePixellated!, CalledFrom: "Redraw3D")
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
    
    // MARK: - Extension-required variables.
    
    var HistogramIsVisible: Bool = false
    
    // MARK: - Activity viewer required variables.
    
    var ImageToExport: UIImage? = nil
    
    // MARK: - Title related variables.
    
    var TitleClosure: ((Bool) -> ())? = nil
    
    // MARK: - Asynchronous event handling variables.
    
    let ThermalMap =
        [
            ProcessInfo.ThermalState.critical: "Critical",
            ProcessInfo.ThermalState.fair: "Fair",
            ProcessInfo.ThermalState.nominal: "Nominal",
            ProcessInfo.ThermalState.serious: "Serious"
    ]
    
    // MARK: - Status layer required variables.
    
    var HideTitleDuration: Double = 1.0
    var TitleTimer: Timer!
    var TitleIsVisible = false
    var TitleNode: SCNNode? = nil
    var TitleBox: SCNView!
    var ParentWidth: CGFloat = 0.0
    var ParentHeight: CGFloat = 0.0
    var TitleCenter: CGPoint = .zero
    var Wrapper: UIView!
    var ShowingTitle = true
    
    // MARK: - Process view variables.
    var InProcessView = false
    
    // MARK: - Interface builder variables.
    
    @IBOutlet weak var StatusLayer: UIView!
    @IBOutlet weak var StatusMainLabel: UILabel!
    
    @IBOutlet weak var SettingsButton: UIButton!
    @IBOutlet weak var SceneRecordInfoButton: UIButton!
    @IBOutlet weak var SceneRecorderButton: UIButton!
    @IBOutlet weak var CloseSceneRecorderViewButton: UIButton!
    @IBOutlet weak var SceneMotionRecorderView: UIView!
    @IBOutlet weak var MainBottomBar: UIView!
    @IBOutlet weak var ImageBottomBar: UIView!
    @IBOutlet weak var SwitchCameraButton: UIButton!
    @IBOutlet weak var SwitchModeButton: UIButton!
    @IBOutlet weak var LiveView: UIView!
    @IBOutlet weak var CameraButton: UIButton!
    // "weak" is removed from OutputView because we recreate the class in code and weak leads to strange compiler warnings...
    @IBOutlet var OutputView: ProcessViewer!
    
    // MARK: - Interface builder variables for image processing.
    
    @IBOutlet weak var CompositeStatus: SmallStatusDisplay!
    @IBOutlet weak var SaveButton: UIButton!
    @IBOutlet weak var DoneButton: UIButton!
    
    // MARK: - Histogram view.
    
    @IBOutlet weak var HistogramView: UIView!
}
