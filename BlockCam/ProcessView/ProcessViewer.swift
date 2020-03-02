//
//  ProcessViewer.swift
//  BlockCam
//
//  Created by Stuart Rankin on 11/25/19.
//  Copyright © 2019 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit
import SceneKit
import CoreImage
import CoreMedia
import CoreVideo
import AVFoundation
import Photos

/// Processed image viewer. Also processes the images.
/// - Note: `Initialize` *must* be called immediately after instantiation.
class ProcessViewer: SCNView, SCNSceneRendererDelegate
{
    weak var Delegate: MainProtocol? = nil
    
    // MARK: - Initialization
    
    /// Initializer.
    /// - Parameter frame: Frame for the view.
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter frame: Frame for the view.
    /// - Parameter options: Options to pass to `super.init`.
    override init(frame: CGRect, options: [String: Any]?)
    {
        super.init(frame: frame, options: options)
        Initialize()
    }
    
    /// Initializer.
    /// - Parameter coder: See Apple documentation.
    required init?(coder: NSCoder)
    {
        super.init(coder: coder)
        Initialize()
    }
    
    /// Initialize the scene.
    /// - Note: **If this function is not called, nothing will appear.**
    func Initialize()
    {
        let Scene = SCNScene()
        self.scene = Scene
        delegate = self
        isPlaying = true
        loops = true
        InitializeView()
        ReloadScene()
        AddCameraObserver()
    }
    
    /// Initialize the view.
    private func InitializeView()
    {
        allowsCameraControl = true
        preferredFramesPerSecond = 30
        rendersContinuously = false
        let Mode = UInt(Settings.GetInteger(ForKey: .AntialiasingMode))
        let AntialiasMode = SCNAntialiasingMode(rawValue: Mode)
        antialiasingMode = AntialiasMode!
    }
    
    public func SnapShot() -> UIImage
    {
        let Renderer = UIGraphicsImageRenderer(bounds: self.bounds)
        return Renderer.image
            {
                Context in
                layer.render(in: Context.cgContext)
        }
    }
    
    /// Adds an observer to the point-of-view node's position value. This allows us to track the scene when it is moved
    /// which in turn lets us save a frame for each change, which can then be assembled in to a video. Additionally, if
    /// proper settings are enabled, a histogram is generated for the processed image.
    private func AddCameraObserver()
    {
        CameraObserver = self.observe(\.pointOfView?.position, options: [.new])
        {
            (Node, Change) in
            OperationQueue.current?.addOperation
                {
                    #if false
                    if Settings.GetBoolean(ForKey: .ShowHistogram)
                    {
                        if Settings.GetBoolean(ForKey: .ShowProcessedHistogram)
                        {
                            let MotionFrame = self.snapshot()
                            self.Delegate?.DisplayHistogram(For: MotionFrame)
                        }
                    }
                    #endif
                    if self.RecordScene
                    {
                        let Now = CACurrentMediaTime()
                        let DefaultCamera = Node.defaultCameraController
                        let POVNode = DefaultCamera.pointOfView
                        self.SceneRecords?.append((POVNode!.position, Now))
                        /*
                        let MotionFrame = self.snapshot()
                        let Name = Utilities.MakeSequentialName("Frame", Extension: "jpg", Sequence: &self.SceneFrameCount)
                        //let Name = "Frame\(self.SceneFrameCount).jpg"
                        //self.SceneFrameCount = self.SceneFrameCount + 1
                        FileIO.SaveSceneFrame(MotionFrame, WithName: Name)
 */
                    }
            }
        }
    }
    
    /// Returns the current scene as an image. If no nodes are added, the result will be uninteresting.
    /// - Returns: Image of the current scene.
    public func SceneImage() -> UIImage
    {
        return self.snapshot()
    }
    
    private func InitializeSceneRecording()
    {
        SceneRecords = [(SCNVector3, Double)]()
    }
    
    var SceneRecords: [(SCNVector3, Double)]? = nil
    
    private func FinalizedSceneRecording()
    {
        if SceneRecords != nil
        {
            let End = SceneRecords!.last!.1
            let Start = SceneRecords!.first!.1
            print("Scene frames: \(SceneRecords!.count), duration: \(End - Start)")
            for (POV, _) in SceneRecords!
            {
            self.defaultCameraController.pointOfView?.position = POV
            }
        }
    }
    
    var SceneFrameCount: Int = 0
    var CameraObserver: NSKeyValueObservation? = nil
        private var _RecordScene: Bool = false
        {
            didSet
            {
                if _RecordScene
                {
                    InitializeSceneRecording()
                }
                else
                {
                    FinalizedSceneRecording()
                }
            }
    }
    public var RecordScene: Bool
    {
        get
        {
            return _RecordScene
        }
        set
        {
            _RecordScene = newValue
        }
    }
    
    /// Called when a setting is changed that we care about.
    public func UpdateScene()
    {
        if let BGColorName = Settings.GetString(ForKey: .SceneBackgroundColor)
        {
            if let BGColor = BasicColors(rawValue: BGColorName)
            {
                self.scene?.background.contents = BGColorMap[BGColor]
            }
            else
            {
                self.scene?.background.contents = UIColor.black
                Settings.SetString("Black", ForKey: .SceneBackgroundColor)
            }
        }
        else
        {
            self.scene?.background.contents = UIColor.black
            Settings.SetString("Black", ForKey: .SceneBackgroundColor)
        }
    }
    
    let BGColorMap =
        [
            BasicColors.Black: UIColor.black,
            BasicColors.White: UIColor.white,
            BasicColors.Gray: UIColor.gray,
            BasicColors.Red: UIColor.red,
            BasicColors.Green: UIColor.green,
            BasicColors.Blue: UIColor.blue,
            BasicColors.Cyan: UIColor.cyan,
            BasicColors.Magenta: UIColor.magenta,
            BasicColors.Indigo: UIColor.systemIndigo,
            BasicColors.SysYellow: UIColor.systemYellow,
            BasicColors.SysGreen: UIColor.systemGreen,
            BasicColors.SysBlue: UIColor.systemBlue,
            BasicColors.SysOrange: UIColor.systemOrange
    ]
    
    /// Adds the main light node to the scene. Everytime this function is called, the old node is removed.
    public func UpdateLightNode()
    {
        LightNode?.removeFromParentNode()
        LightNode = SCNNode()
        SceneLight = SCNLight()
        
        var LightIntensity = 1000
        if let LightIntensitySetting = Settings.GetString(ForKey: .LightIntensity)
        {
            switch LightIntensitySetting
            {
                case "Darkest":
                    LightIntensity = 500
                
                case "Dim":
                    LightIntensity = 750
                
                case "Normal":
                    LightIntensity = 1000
                
                case "Bright":
                    LightIntensity = 1500
                
                case "Brightest":
                    LightIntensity = 2000
                
                default:
                    LightIntensity = 1000
            }
        }
        SceneLight.intensity = CGFloat(LightIntensity)
        
        var SavedColorName = Settings.GetString(ForKey: .LightColor)
        if SavedColorName == nil
        {
            SavedColorName = "White"
        }
        var LightColor = ColorMap[SavedColorName!]
        if LightColor == nil
        {
            LightColor = UIColor.white
            Settings.SetString("White", ForKey: .LightColor)
        }
        SceneLight.color = LightColor!
        
        if let SavedLightType = Settings.GetString(ForKey: .LightType)
        {
            switch SavedLightType
            {
                case "Omni":
                    SceneLight.type = .omni
                
                case "Directional":
                    SceneLight.type = .directional
                
                case "Spot":
                    SceneLight.type = .spot
                
                case "Ambient":
                    SceneLight.type = .ambient
                
                default:
                    SceneLight.type = .omni
                    Settings.SetString("Omni", ForKey: .LightType)
            }
        }
        else
        {
            SceneLight.type = .omni
            Settings.SetString("Omni", ForKey: .LightType)
        }
        LightNode?.light = SceneLight!
        LightNode?.position = SCNVector3(-5.0, 5.0, 10.0)
        if Settings.GetBoolean(ForKey: .EnableShadows)
        {
            SceneLight.castsShadow = true
            SceneLight.shadowColor = UIColor.black.withAlphaComponent(0.80)
            SceneLight.shadowMode = .forward
            SceneLight.shadowRadius = 10.0
        }
        self.scene?.rootNode.addChildNode(LightNode!)
    }
    
    /// Reload the scene with the settings from the user defaults.
    public func ReloadScene()
    {
        #if false
        OutputView.debugOptions = [.showWireframe]
        #endif
        
        CameraNode?.removeFromParentNode()
        UpdateLightNode()
        
        CameraNode = SCNNode()
        CameraNode!.name = "SceneCamera"
        SceneCamera = SCNCamera()
        SceneCamera.name = "SceneCamera"
        if let FOV = Settings.GetString(ForKey: .FieldOfView)
        {
            switch FOV
            {
                case "Narrowest":
                    SceneCamera.fieldOfView = 60.0
                
                case "Narrow":
                    SceneCamera.fieldOfView = 90.0
                
                case "Normal":
                    SceneCamera.fieldOfView = 120.0
                
                case "Wide":
                    SceneCamera.fieldOfView = 160.0
                
                case "Widest":
                    SceneCamera.fieldOfView = 180.0
                
                default:
                    SceneCamera.fieldOfView = 120.0
                    Settings.SetString("Normal", ForKey: .FieldOfView)
            }
        }
        else
        {
            SceneCamera.fieldOfView = 120.0
            Settings.SetString("Normal", ForKey: .FieldOfView)
        }
        CameraNode?.camera = SceneCamera!
        CameraNode?.position = SCNVector3(0.0, 0.0, 20.0)

        self.scene?.background.contents = UIColor.black
        self.scene?.rootNode.addChildNode(CameraNode!)
    }
    
    var LightNode: SCNNode? = nil
    var SceneLight: SCNLight!
    var CameraNode: SCNNode? = nil
    var SceneCamera: SCNCamera!
    
    let ColorMap =
        [
            "Black": UIColor.black,
            "White": UIColor.white,
            "Red": UIColor.red,
            "Green": UIColor.green,
            "Blue": UIColor.blue,
            "Cyan": UIColor.cyan,
            "Magenta": UIColor.magenta,
            "Yellow": UIColor.yellow,
            "Gray": UIColor.gray
    ]
    
    /// Clear the scene of any existing visible nodes.
    /// - Note: Remove the master node from the parent scene and then set the master node to nil, which has the effect of
    ///         releasing all of the memory (which, depending on the settings, may be prodigious).
    public func Clear()
    {
        Generator.MasterNode?.enumerateChildNodes
            {
                (node, _) in
                node.removeFromParentNode()
        }
        Generator.MasterNode?.removeFromParentNode()
        Generator.MasterNode = nil
        /*
        #if true
        DispatchQueue.main.async
            {
                let OldCount = Utility3D.NodeCount(InScene: self.scene!)
                Generator.MasterNode?.removeFromParentNode()
                Generator.MasterNode?.enumerateChildNodes
                    {
                        (node, _) in
                        node.removeFromParentNode()
                }
                self.PreviousNodeCount = Utility3D.NodeCount(InScene: self.scene!)
                print("Node count delta: \(self.PreviousNodeCount - OldCount)")
        }
        isPlaying = false
        #else
        DispatchQueue.main.async
            {
                Generator.MasterNode?.removeFromParentNode()
                self.PreviousNodeCount = Utility3D.NodeCount(InScene: self.scene!)
        }
        self.isPlaying = false
        #endif
 */
    }
    
    // MARK: - Public processing interfaces.
    
    /// Process the passed image using settings the user defaults.
    /// - Parameter SomeImage: The image to process.
    public func ProcessImage(_ SomeImage: UIImage, CalledFrom: String)
    {
        print("ProcessImage called from \(CalledFrom)")
        Clear()
        SaveVideoFrames = false
        Generator.MakeImage(self, SomeImage)
    }
    
    /// Process the passed set of pixels using user settings.
    /// - Parameter Colors: Pre-processed image as pixel data.
    public func ProcessImage(_ Colors: [[UIColor]], CalledFrom: String)
    {
        print("ProcessImage (with colors) called from \(CalledFrom)")
        Clear()
        SaveVideoFrames = false
        Generator.MakeImage(self, With: Colors)
    }
    
    /// Convert a video (or at least the first portion of it) to 3D scene with the current settings. The API we use to get stored
    /// videos only returns the first 30 seconds.
    /// - Notes:
    ///   - See: [Get all frames from a video](https://stackoverflow.com/questions/42665271/swift-get-all-frames-from-video)
    ///   - See: [Export UIImage array as video](https://stackoverflow.com/questions/3741323/how-do-i-export-uiimage-array-as-a-movie)
    ///   - See: [How to capture frames from a video using generateCGImagesAsynchronously()](https://forums.developer.apple.com/thread/66332)
    /// - Parameter SomeVideo: URL of the video to convert.
    /// - Parameter Status: Called once a frame with the percent complete value.
    /// - Parameter Completed: Called after completion.
    public func ProcessVideo(_ SomeVideo: URL)
    {
        SaveVideoFrames = true
        Generator.MakeVideo(self, SomeVideo)
    }
    
    // MARK: - Scene renderer delegate functions.
    
    private var RenderCount: Int = 0
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval)
    {
        RenderCount = RenderCount + 1
        RenderStart = CACurrentMediaTime()
    }
    
    var RenderStart: Double = 0.0
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval)
    {
        if SaveVideoFrames
        {
            //If we are here (and processing videos), the rendered scene is ready to view (and create a snapshot).
            let Image = self.snapshot()
            RenderedFrames = RenderedFrames + 1
            FileIO.SaveImageEx(Image, WithName: "PI\(RenderedFrames).jpg", InDirectory: FileIO.ScratchDirectory, AsJPG: true)
            Frames.append(Image)
            Log.Message("Frames.count=\(Frames.count), ExpectedFrameCount=\(ExpectedFrameCount)")
            if Frames.count == ExpectedFrameCount
            {
                Log.Message("Staring final video assembly.")
                let ScratchFile = FileIO.MakeTemporaryFileNameInScratch(WithExtension: ".mp4")
                VideoAssembly.AssembleAndSave(Frames, Size: CGSize(width: VideoFrameSize.width, height: VideoFrameSize.height),
                                              TargetURL: ScratchFile, FrameDuration: VideoIncrement,
                                              Parent: self.ParentViewController!, SaveFrames: true,
                                              StatusHandler: VideoStatusHandler, Completed: VideoCompletionHandler)
            }
        }
        else
        {
            let NodeCount = Utility3D.NodeCount(InScene: self.scene!)
            if NodeCount > 3
            {
                if PreviousNodeCount != NodeCount
                {
                    PreviousNodeCount = NodeCount
                    print("Scene node count: \(NodeCount)")
                }
            }
        }
    }
    
    var PreviousNodeCount = -1
    var RenderedFrames = 0
    
    var Frames: [UIImage] = []
    
    var SaveVideoFrames = false
    {
        didSet
        {
            Log.Message("SaveVideoFrames=\(SaveVideoFrames)")
        }
    }
    
    var ExpectedFrameCount = -1
    
    var VideoIncrement: Double = 0
    var VideoStatusHandler: ((Double, UIColor) -> ())?
    var VideoCompletionHandler: ((Bool) -> ())?
    var VideoFrameSize: CGSize = .zero
}

