//
//  ShapeManager.swift
//  BlockCam
//
//  Created by Stuart Rankin on 1/14/20.
//  Copyright © 2020 Stuart Rankin. All rights reserved.
//

import Foundation
import UIKit

/// Class contains central data and attributes about node shapes.
class ShapeManager
{
    /// Initialize the manager.
    public static func Initialize()
    {
        //Right now, nothing to initialize.
    }
    
    /// Returns the minimum allowable pixel size (smaller takes more time and energy) for a given shape.
    /// - Parameter For: The shape whose minimum pixel size will be returned.
    /// - Returns: Minimum pixel size for the passed shape.
    public static func GetMinimumPixelSize(For Shape: NodeShapes) -> Int
    {
        if let Restriction = ShapeSizeRestrictions[Shape]
        {
            return Restriction
        }
        return 16
    }
    
    /// Holds the dictionary of minimum pixel sizes for various shapes. This is to restrict complex
    /// shapes from bogging down or freezing the program.
    private static let ShapeSizeRestrictions =
        [
            NodeShapes.RadiatingLines: 32,
            NodeShapes.Characters: 32,
    ]
    
    /// Table of shape categories and the shapes in them.
    private static let _ShapeCategories: [(CategoryName: String, List: [String])] =
        [
            ("Standard", [NodeShapes.Blocks.rawValue, NodeShapes.Spheres.rawValue, NodeShapes.Toroids.rawValue,
                          NodeShapes.Ellipses.rawValue, NodeShapes.Diamonds.rawValue, NodeShapes.Cylinders.rawValue,
                          NodeShapes.Capsules.rawValue, NodeShapes.Cones.rawValue,
                          NodeShapes.Pyramids.rawValue]),
            ("Polygonal", [NodeShapes.Stars.rawValue, NodeShapes.Polygons.rawValue]),
            ("Regular Solids", [NodeShapes.Tetrahedrons.rawValue, NodeShapes.Icosahedrons.rawValue]),
            ("Combined", [NodeShapes.Lines.rawValue, NodeShapes.CappedLines.rawValue, NodeShapes.StackedShapes.rawValue,
                          NodeShapes.RadiatingLines.rawValue, NodeShapes.PerpendicularSquares.rawValue,
                          NodeShapes.PerpendicularCircles.rawValue,
                          NodeShapes.SpherePlus.rawValue, NodeShapes.BoxPlus.rawValue,
                          NodeShapes.Random.rawValue,
                          NodeShapes.CombinedForRGB.rawValue, NodeShapes.CombinedForHSB.rawValue]),
            ("Complex", [NodeShapes.CharacterSets.rawValue, NodeShapes.Meshes.rawValue]),
            ("Varying", [NodeShapes.HueVarying.rawValue, NodeShapes.SaturationVarying.rawValue,
                         NodeShapes.BrightnessVarying.rawValue, NodeShapes.HueTriangles.rawValue]),
            ("Flat Shapes", [NodeShapes.Polygon2D.rawValue, NodeShapes.Rectangle2D.rawValue,
                             NodeShapes.Circle2D.rawValue, NodeShapes.Oval2D.rawValue,
                             NodeShapes.Oval2D.rawValue, NodeShapes.Diamond2D.rawValue,
                             NodeShapes.Star2D.rawValue]),
    ]
    /// Get the table of shape categories.
    public static var ShapeCategories: [(CategoryName: String, List: [String])]
    {
        get
        {
            return _ShapeCategories
        }
    }
    
    /// Returns a flat list of all shapes.
    /// - Parameter ExceptFor: List of shapes to exclude from the returned list.
    /// - Returns: List of all shapes.
    public static func ShapeFlatList(ExceptFor: [String]) -> [NodeShapes]
    {
        var List = [NodeShapes]()
        for (_, CatList) in _ShapeCategories
        {
            for Name in CatList
            {
                if !ExceptFor.contains(Name)
                {
                List.append(NodeShapes(rawValue: Name)!)
                }
            }
        }
        return List
    }
    
    /// Returns a flat list of all shapes.
    /// - Returns: List of all shapes.
    public static func ShapeFlatList() -> [NodeShapes]
    {
        var List = [NodeShapes]()
        for (_, CatList) in _ShapeCategories
        {
            for Name in CatList
            {
                List.append(NodeShapes(rawValue: Name)!)
            }
        }
        return List
    }
    
    /// Table of shapes that require more than one `SCNGeometry` node to create.case
    private static let _MultipleGeometryShapes =
    [
        NodeShapes.CappedLines, NodeShapes.StackedShapes, NodeShapes.HueVarying, NodeShapes.SaturationVarying,
        NodeShapes.BrightnessVarying, NodeShapes.PerpendicularCircles, NodeShapes.PerpendicularSquares,
        NodeShapes.CombinedForRGB, NodeShapes.CombinedForHSB, NodeShapes.Meshes, NodeShapes.RadiatingLines,
        NodeShapes.SpherePlus, NodeShapes.BoxPlus, NodeShapes.Random
    ]
    /// Get the table of shapes that are formed from more than one `SCNGeometry` node.
    /// - Returns: Table of shapes that require more than one `SCNGeometry` node.
    public static func MultipleGeometryShapes() -> [NodeShapes]
    {
        return _MultipleGeometryShapes
    }
    
    /// Holds a table of node shapes that take options.
    private static var _OptionsAvailable = [NodeShapes.Letters, NodeShapes.Meshes, NodeShapes.CappedLines, NodeShapes.Stars,
                                            NodeShapes.Blocks, NodeShapes.RadiatingLines, NodeShapes.Cones, NodeShapes.Ellipses,
                                            NodeShapes.HueVarying, NodeShapes.SaturationVarying, NodeShapes.BrightnessVarying,
                                            NodeShapes.Characters, NodeShapes.CharacterSets, NodeShapes.StackedShapes,
                                            NodeShapes.Polygons, NodeShapes.Rectangle2D, NodeShapes.Polygon2D,
                                            NodeShapes.Circle2D, NodeShapes.Oval2D, NodeShapes.Diamond2D, NodeShapes.Star2D,
                                            NodeShapes.Spheres, NodeShapes.SpherePlus, NodeShapes.BoxPlus, NodeShapes.Random,
                                            NodeShapes.Tetrahedrons, NodeShapes.Icosahedrons]
    /// Returns a table of node shapes that take options.
    public static var OptionsAvailable: [NodeShapes]
    {
        get
        {
            return _OptionsAvailable
        }
    }
    
    /// Determines if the passed shape takes options.
    /// - Parameter Shape: The shape to determine if options are available.
    /// - Returns: True if the passed shape takes options, false if not.
    public static func ShapeHasOptions(_ Shape: NodeShapes) -> Bool
    {
        return OptionsAvailable.contains(Shape)
    }
    
    /// Holds valid extruded shapes for sphere + shapes.
    private static var _ValidSpherePlusShapes =
    [
        NodeShapes.Blocks, NodeShapes.Spheres, NodeShapes.Cones, NodeShapes.Lines, NodeShapes.Capsules,
        NodeShapes.Cylinders
    ]
    
    /// Return all valid extruded shapes for sphere +.
    /// - Returns: Array of shapes that can be extruded.
    public static func GetValidSpherePlusShapes() -> [NodeShapes]
    {
        return _ValidStackingShapes
    }
    
    /// Holds valid extruded shapes for box + shapes.
    private static var _ValidBoxPlusShapes =
    [
        NodeShapes.Spheres, NodeShapes.Blocks, NodeShapes.Cones, NodeShapes.Lines, NodeShapes.Capsules,
        NodeShapes.Pyramids, NodeShapes.Cylinders
    ]
    
    /// Return all valid extruded shapes for box +.
    /// - Returns: Array of shapes that can be extruded.
    public static func GetValidBoxPlusShapes() -> [NodeShapes]
    {
        return _ValidBoxPlusShapes
    }
    
    /// Holds valid random shapes.
    private static var _ValidRandomShapes =
    [
        NodeShapes.Spheres, NodeShapes.Blocks, NodeShapes.Circle2D, NodeShapes.Rectangle2D
    ]
    
    /// Return all valid random shapes.
    /// - Returns: Array of shapes that can be used as random shapes.
    public static func GetValidRandomShapes() -> [NodeShapes]
    {
        return _ValidRandomShapes
    }
    
    /// Holds a list of all shapes that are available for the stacked shape set.
    private static var _ValidStackingShapes = [NodeShapes.Blocks, NodeShapes.Spheres, NodeShapes.Capsules,
                                               NodeShapes.Cylinders, NodeShapes.Cones, NodeShapes.Lines,
                                               NodeShapes.Polygons, NodeShapes.Ellipses, NodeShapes.Stars,
                                               NodeShapes.Polygon2D, NodeShapes.Circle2D, NodeShapes.Oval2D,
                                               NodeShapes.Rectangle2D, NodeShapes.Star2D]
    
    /// Get the list of valid shapes for stacked shapes.
    public static func ValidShapesForStacking() -> [NodeShapes]
    {
        return _ValidStackingShapes
    }
    
    /// Holds a table of slow (performant) shapes.
    private static var _SlowList = [NodeShapes.Flowers, NodeShapes.Letters, NodeShapes.CharacterSets,
                                    NodeShapes.Characters]
    /// Get a table of slow shapes.
    /// - Note:
    ///    - Slow shapes may cause over-heating of the device as well as memory crashes.
    ///    - Round shapes are notorious for slowing things down.
    public static var SlowList: [NodeShapes]
    {
        get
        {
            return _SlowList
        }
    }
    
    /// Determines if the passed shape is slow.
    /// - Parameter Shape: The shape to test for slowness (where testing consists of seeing if the shape is in
    ///                    the `SlowList`).
    /// - Returns: True if the shape is slow, false if not.
    public static func ShapeIsSlow(_ Shape: NodeShapes) -> Bool
    {
        return SlowList.contains(Shape)
    }
    
    /// Return a decorated, attributed string for the passed shape name.
    /// - Parameter From: The name of the node shape whose (potentially) decorated name will be returned.
    /// - Returns: Attributed string with potential decorations for the passed shape name.
    public static func DecoratedShapeName(From ShapeName: String) -> NSAttributedString?
    {
        if let Shape = NodeShapes(rawValue: ShapeName)
        {
            return DecoratedShapeName(For: Shape)
        }
        return nil
    }
    
    /// Return a decorated, attributed string for the passed shape.
    /// - Parameter For: The node shape whose (potentially) decorated name will be returned.
    /// - Returns: Attributed string with potential decorations for the passed shape name.
    public static func DecoratedShapeName(For Shape: NodeShapes) -> NSAttributedString
    {
        let Decorated = Shape.rawValue
        var SlowShape: NSAttributedString? = nil
        if ShapeIsSlow(Shape)
        {
            //            let SlowFont = FontManager.CustomFont(.NotoSansSymbols2, Size: 17.0)
            let SlowFont = UIFont.systemFont(ofSize: 17.0)
            let Attributes: [NSAttributedString.Key: Any] =
                [
                    .font: SlowFont as Any,
                    .foregroundColor: UIColor.systemRed as Any
            ]
            SlowShape = NSAttributedString(string: " 􀓑", attributes: Attributes)
        }
        var OptionShape: NSAttributedString? = nil
        if ShapeHasOptions(Shape)
        {
            //let OptionFont = FontManager.CustomFont(.NotoSansSymbols2, Size: 17.0)
            let OptionFont = UIFont.systemFont(ofSize: 17.0)
            let Attributes: [NSAttributedString.Key: Any] =
                [
                    .font: OptionFont as Any,
                    .foregroundColor: UIColor.systemBlue as Any
            ]
            OptionShape = NSAttributedString(string: " 􀍟", attributes: Attributes)
        }
        let Attributes: [NSAttributedString.Key: Any] =
            [
                .font: UIFont.systemFont(ofSize: 17.0) as Any,
                .foregroundColor: UIColor.black as Any
        ]
        let DecoratedString = NSMutableAttributedString(string: Decorated, attributes: Attributes)
        if SlowShape != nil
        {
            DecoratedString.append(SlowShape!)
        }
        if OptionShape != nil
        {
            DecoratedString.append(OptionShape!)
        }
        return DecoratedString
    }
    
    public static let SeriesFontMap =
        [
            ShapeSeriesSet.Flowers: "NotoSansSymbols2-Regular",
            ShapeSeriesSet.Arrows: "NotoSansSymbols2-Regular",
            ShapeSeriesSet.Snowflakes: "NotoSansSymbols2-Regular",
            ShapeSeriesSet.SmallGeometry: "NotoSansSymbols2-Regular",
            ShapeSeriesSet.Stars: "NotoSansSymbols2-Regular",
            ShapeSeriesSet.Ornamental: "NotoSansSymbols2-Regular",
            ShapeSeriesSet.Things: "NotoSansSymbols2-Regular",
            ShapeSeriesSet.Computers: "NotoSansSymbols2-Regular",
            ShapeSeriesSet.Hiragana: "HiraginoSans-W6",
            ShapeSeriesSet.Katakana: "HiraginoSans-W6",
            ShapeSeriesSet.KyoikuKanji: "HiraginoSans-W6",
            ShapeSeriesSet.Hangul: "NotoSansCJKkr-Black",
            ShapeSeriesSet.Bodoni: "BodoniOrnamentsITCTT",
            ShapeSeriesSet.Greek: "Times-Bold",
            ShapeSeriesSet.Cyrillic: "Times-Bold",
            ShapeSeriesSet.Emoji: "NotoEmoji",
            ShapeSeriesSet.Latin: "NotoSans-Bold",
            ShapeSeriesSet.Punctuation: "NotoSans-Bold",
            ShapeSeriesSet.BoxSymbols: "NotoSans-Bold",
            ShapeSeriesSet.MusicalSymbols: "NotoSansSymbols2-Regular"
    ]
    
    public static let ShapeMap =
        [
            ShapeSeries.Flowers: ShapeSeriesSet.Flowers,
            ShapeSeries.Arrows: ShapeSeriesSet.Arrows,
            ShapeSeries.Snowflakes: ShapeSeriesSet.Snowflakes,
            ShapeSeries.SmallGeometry: ShapeSeriesSet.SmallGeometry,
            ShapeSeries.Stars: ShapeSeriesSet.Stars,
            ShapeSeries.Ornamental: ShapeSeriesSet.Ornamental,
            ShapeSeries.Things: ShapeSeriesSet.Things,
            ShapeSeries.Computers: ShapeSeriesSet.Computers,
            ShapeSeries.Hiragana: ShapeSeriesSet.Hiragana,
            ShapeSeries.Katakana: ShapeSeriesSet.Katakana,
            ShapeSeries.KyoikuKanji: ShapeSeriesSet.KyoikuKanji,
            ShapeSeries.Hangul: ShapeSeriesSet.Hangul,
            ShapeSeries.Bodoni: ShapeSeriesSet.Bodoni,
            ShapeSeries.Greek: ShapeSeriesSet.Greek,
            ShapeSeries.Cyrillic: ShapeSeriesSet.Cyrillic,
            ShapeSeries.Emoji: ShapeSeriesSet.Emoji,
            ShapeSeries.Latin: ShapeSeriesSet.Latin,
            ShapeSeries.Punctuation: ShapeSeriesSet.Punctuation,
            ShapeSeries.BoxSymbols: ShapeSeriesSet.BoxSymbols,
            ShapeSeries.MusicalNotion: ShapeSeriesSet.MusicalSymbols,
    ]
}

/// Supported node shapes for each node of the image.
/// - Note: The value of each case should be a human-readable, very short description of the shape. These values are used
///         to populate lists and text and the like.
enum NodeShapes: String, CaseIterable
{
    /// Block from SCNBox.
    case Blocks = "Blocks"
    /// Ellipses from custom geometry.
    case Ellipses = "Ovals"
    /// Extruded diamond shapes - custom property (based on `.Ellipses`).
    case Diamonds = "Diamonds"
    /// Regular polygons.
    case Polygons = "Polygons"
    /// Pyramids from SCNPyramid. Each node rotated due to SceneKit's default rotation of the node.
    case Pyramids = "Pyramids"
    /// Toruses from SCNTorus. Each node rotated due to SceneKit's default rotation of the node.
    case Toroids = "Toroids"
    /// Cylinders from SCNCylinder. Each node rotate due to SceneKit's default rotation of the node.
    case Cylinders = "Cylinders"
    /// Spheres from SCNSphere.
    case Spheres = "Spheres"
    /// Capsules from SCNCapsule. Each node rotate due to SceneKit's default rotation of the node.
    case Capsules = "Capsules"
    /// Cones from SCNCone.
    case Cones = "Cones"
    /// Tetrahedrons from SCNTetrahedron.
    case Tetrahedrons = "Tetrahedrons"
    /// Icosahedron from SCNIcosahedron.
    case Icosahedrons = "Icosahedron"
    /// Star shapes from SCNStar.Geometry.
    case Stars = "Stars"
    /// Each node uses three shapes, one for red, one for green, and one for blue.
    case CombinedForRGB = "RGB"
    /// Each node uses three shapes, one for hue, one for saturation, and one for brightness.
    case CombinedForHSB = "HSB"
    /// Not currently implemented
    case Meshes = "Mesh"
    /// Each node is an extruded letter.
    case Letters = "Letters"
    /// Extruded characters.
    case Characters = "Characters"
    /// Each node is a line.
    case Lines = "Lines"
    /// Each node is a line with a sphere on top.
    case CappedLines = "Capped Lines"
    /// Each node consists of radiating lines.
    case RadiatingLines = "Radiating Lines"
    /// Each node's shape depends on the original hue.
    case HueVarying = "Hue Varying"
    /// Each node's shape depends on the original saturation.
    case SaturationVarying = "Saturation Varying"
    /// Each node's shape depends on the original brightness.
    case BrightnessVarying = "Brightness Varying"
    /// Perpendicular square shapes.
    case PerpendicularSquares = "Perpendicular Squares"
    /// Perpendicular circle shapes.
    case PerpendicularCircles = "Perpendicular Circles"
    /// Pointy triangles that point to the hue of the color they represent.
    case HueTriangles = "Hue Triangles"
    /// Stylized flowers.
    case Flowers = "Stylized Flower"
    /// Pre-defined character sets.
    case CharacterSets = "Character Sets"
    /// Stacks of shaped oriented in the prominence dimension.
    case StackedShapes = "Stacked Shapes"
    /// Two-dimensional polygons.
    case Polygon2D = "2D Polygon"
    /// Semi-2D rectangle.
    case Rectangle2D = "2D Rectangle"
    /// Semi-2D circle.
    case Circle2D = "2D Circle"
    /// Semi-2D ellipse.
    case Oval2D = "2D Ellipse"
    /// Semi-2D star.
    case Star2D = "2D Star"
    /// Semi-2D diamond.
    case Diamond2D = "2D Diamond"
    /// Sphere plus an extruded shape.
    case SpherePlus = "Sphere +"
    /// Box plus an extruded shape.
    case BoxPlus = "Box +"
    /// Specified shape with randomness.
    case Random = "Random"
}

enum ShapeSeriesSet: String, CaseIterable
{
    case Flowers = "✻✾✢✥☘❅✽✤🟔✺✿🏵❁🙨🙪🏶❇❀❃❊✼🌻🌺🌹🌸🌷💐⚜✥🌼᪥ꕥꕤꙮ⚘❀❦"
    case Snowflakes = "❄❆⛄🞾❉"
    case Arrows = "❮❯⇧⬀↯⮔☇⇨⮋⏎⬂⮍👎⇩⏪⮈⮎⮰⇪👍⮱⮶⮴⭪⬃🡇☝⭯⏩⇦☜⮊⬁⮇⮌⬄🠣⮏⮉⇳➘☞➙➚⮕⬊⬇⬋⬅☚☛⬉☟⬌⬍➢➳➶➵➴➹➾"
    case SmallGeometry = "●○◐◑⏾◒◓◖⦿⬬◗◔⬒⯋⬢🙾🞆⬠⬡⬟⭖◕◊◍◌🞖⬯◉◎◙🛆◪🞐🞟⛋◆◇❖◬🞜◈⯄▰■□▢▣⬚▤▥▦▧▨▩◧◩◨"
    case Stars = "✦✧✩✪✯⋆✮✹✶🟊❂✴✵☀✺🟑✷🟑🟆☼✸🟏✰✬✫✭"
    case Ornamental = "🎔🙞🙱🙟❛❜🙧❝🙝🙤🙜🙦🙥❢☙🙹🙢🙒🙚❧🙠❡🙘🙐❦❤🙰❟❣❠🙣🙓❞🙛🙡🙑🙙🙵🙖🙔🙗🙕"
    case Things = """
    🖴🎧🌶⏳🏠🕹🖋🌜🎚⛟🖍🏱🎭🕾✂🛰⛔🖊🖉🕰🖫🌢⚾🕷🏆🎭🖩🏍⛏⏱📺🏔🌡🛧🛢👁🛦🙭⌚📹🎮🗑📦🛳📾🏎🔓📬📻🖐🚔📭💿🚇🎖🗝🖳🚘🚍🛱✐✈⛁⛂⛀⛃♨☁🔒☂🐦🐟🌎📽🕮🐈🛎🏭🌏🍽🖪🛲🚲🖁☎🛊🛏👪🐕🏙👽🕯🕬🌍📷☏🕊🎬🕫🐿🏝🕶📪☕⛄🛉✄✏🛩📚👂👓🛠🗺
    """
    case Computers = "🗛🕹🖦🖮🖰␆🖶␡💿🗗⌨🎟␄🎮🗚🔇💻🖫🖲🖨⌧🔉🖬🖵␀🔊🖸⌫⏏🔈⌦🖴🖷␕"
    case Hiragana = """
    あいうえおかがきぎくぐけげこごさざしじすずせぜそぞただちぢつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもやゆよらりるれろわゐゑをん
    """
    case Katakana = """
    アイウエオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモヤユヨラリルレロワヰヱヲンヴ
    """
    case KyoikuKanji = """
    一丁七万三上下不世両並中丸主久乗九乱乳予争事二五亡交京人仁今仏仕他付代令以仮仲件任休会伝似位低住体何余作使例供価便係保信修俳俵倉個倍候借値停健側備傷働像億優元兄兆先光児党入全八公六共兵具典内円冊再写冬冷処出刀分切刊列初判別利制刷券刻則前副割創劇力功加助努労効勇勉動務勝勢勤包化北区医十千午半卒協南単博印危卵厚原厳去参友反収取受口古句可台史右号司各合同名后向君否吸告周味呼命和品員唱商問善喜営器四回因団困囲図固国園土圧在地坂均垂型城域基堂報場塩境墓増士声売変夏夕外多夜夢大天太夫央失奏奮女好妹妻姉始委姿婦子字存孝季学孫宅宇守安完宗官宙定宝実客宣室宮害家容宿寄密富寒察寸寺対専射将尊導小少就尺局居届屋展属層山岩岸島川州巣工左差己巻市布希師席帯帰帳常幕干平年幸幹幼庁広序底店府度座庫庭康延建弁式弓引弟弱張強当形役往径待律後徒従得復徳心必志忘応忠快念思急性恩息悪悲情想意愛感態慣憲成我戦戸所手才打批承技投折担招拝拡拾持指挙捨授採探接推提揮損操支改放政故救敗教散敬数整敵文料断新方旅族旗日旧早明易昔星映春昨昭昼時晩景晴暑暖暗暮暴曜曲書最月有服朗望朝期木未末本札机材村束条来東松板林枚果枝染柱査栄校株根格案桜梅械棒森植検業極楽構様標模権横樹橋機欠次欲歌止正武歩歯歴死残段殺母毎毒比毛氏民気水氷永求池決汽河油治沿泉法波泣注泳洋洗活派流浅浴海消液深混清済減温測港湖湯満源準漁演漢潔潮激火灯灰災炭点無然焼照熟熱燃父片版牛牧物特犬犯状独率玉王班現球理生産用田由申男町画界畑留略番異疑病痛発登白百的皇皮皿益盛盟目直相省看県真眼着矢知短石砂研破確磁示礼社祖祝神票祭禁福私秋科秒秘移程税種穀積穴究空窓立章童競竹笑笛第筆等筋答策算管箱節築簡米粉精糖糸系紀約紅納純紙級素細終組経結給統絵絶絹続綿総緑線編練縦縮績織罪置署羊美群義羽翌習老考者耕耳聖聞職肉肥育肺胃背胸能脈脳腸腹臓臣臨自至興舌舎航船良色花芸芽若苦英茶草荷菜落葉著蒸蔵薬虫蚕血衆行術街衛衣表裁装裏補製複西要見規視覚覧親観角解言計討訓記訪設許訳証評詞試詩話誌認誕語誠誤説読課調談論諸講謝識警議護谷豆豊象貝負財貧貨責貯貴買貸費貿賀賃資賛賞質赤走起足路身車軍転軽輪輸辞農辺近返述迷追退送逆通速造連週進遊運過道達遠適選遺郡部郵郷都配酒酸里重野量金針鉄鉱銀銅銭鋼録鏡長門閉開間関閣防降限陛院除陸険陽隊階際障集雑難雨雪雲電青静非面革音頂順預領頭題額顔願類風飛食飯飲飼養館首馬駅験骨高魚鳥鳴麦黄黒鼻
    """
    case Hangul = """
    ㄱㄴㄷㄹㅁㅂㅅㅇㅈㅊㅋㅌㅍㅎㅏㅑㅓㅕㅗㅛㅜㅠㅡㅣㄲㄸㅃㅆㅉㅐㅒㅚㅔㅖㅙㅟㅞㅢㅝ가나다마버서어저처토포코호꾸뚜삐씨쯔
    """
    case Bodoni = """
    !"#$%&()*+,�./012356789:;<=>?@ABCDEFGHIJKLMNOPQRSTVWXYZ][\
    ^_`abcdefghijklmnopqrstuvwxyz{|}†°¢®©™´¨≠ÆØ∞±≤≥¥�∂∑∏π∫’
    """
    case Greek = """
    ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡΣΤΥΦΧΨΩαβγδεζηθικλμνξορςστυφχψω
    """
    case Cyrillic = """
    АаБбВвГгДдЕеЁёЖжЗзИиЙйКкЛлМмНнОоПпРрСсТтУуФфХхЦцЧчШшЩщЪъЫыЬьЭэЮюЯя
    """
    
    case Emoji = """
    ♑ℹ⌚⌛⏰⏳Ⓜ☀☁☺♈♉♊♋♌♍♎♏♐♒♓♠♣♥♦♨♻♿⚓⚠⚡⚽⚾⛄⛅⛎⛔⛪⛲⛳⛵⛺⛽✂
    ✈✉✊✋✌✏✒✨✳✴❄❇❤➰➿⭐〰〽㊗㊙🀄🃏🈁🈂🈚🈯🈲🈳🈴🈵🈶🈷🉑
    🌀🌁🌂🌃🌄🌅🌆🌇🌈🌉🌊🌋🌌🌏🌙🌛🌟🌠🌰🌱🌴🌵
    🌷🌸🌹🌺🌻🌼🌽🌾🌿🍀🍁🍂🍃🍄🍅🍆🍇🍈🍉🍊🍌🍍🍎🍏
    🍑🍒🍓🍔🍕🍖🍗🍘🍙🍚🍰🍛🍜🍝🍞🍟🍠🍡🍢🍣🍤🍥🍦🍧🍨
    🎆🎂🎁🎀🍸🍭🍪🍩🍫🍬🍮🍯🍱🍲🍳🍻🍵🍶🍷🍺🎃🎄🎅🎇🎈
    🎧🎉🎊🎋🎌🎎🎐🎏🎍🎑🎒🎓🎠🎥🎨🎩🎬🎫🎮🎯🎰🎱🎲🎳
    🐌🏯🏈🎻🎴🎵🎶🐙🎷🎸🎹🎺🎼🎽🎾🏁🏃🏢🏣🏫🏬🏭🏮🏰🐍🏥🏦
    🐢🐜🐦🐟🐠🐡🐤👓🐣🐥🐹🐚🐎🐔🐛🐝🐞🐑🐒🐗🐘👅👑🐩🐰🐺🐮🐴🐻
    👒👖👕👔🐧🐱🐲🐵👀👂👄🐬🐯🐶🐭🐳🐨🐫🐸🐼🐾🐷👗👘👙👚
    👛👟👢👣👤💇👧👫💠👩💔👪👮👴👵👷👾💄👺👽👿👻💀💅👨👶👹👜👝👡👦
    💖💟💣💤💘💜💞💳💗💙💡💢💚💫👞👠💈💓💛💕💝💋💍💏💑💌
    💥💪💺📆📇📌📏📑📋📎📐💴📍💸💹💵💬💦💨💩💰💲💯💱💧💮
    📜📷🔃🔎📚📞📡📺🔋🔔🔊🔐🔌🌘🔍📰📶🔏🔑📹📼📣📻🔒🔓📠📦📮
    📒📝📟📢📕📖🔲🔳🗼🚒🚓🚅🚇🚏🚕🚙🚧🚩🚤🚥🚚🚢󾓬🚨🚉🚑🚗🔖🔘🔤🔦
    🔴🗻🗽🚌🚃🚄🔨🔩🔱🗾🔮🔰🚀🔧🔪󾓨🔯🔥🌞🔗🔠🔢🔣🔡󾓮🏇🏉🌐
    🚪🚫🚭🚼🈹󾓦🐋󾓩󾓫🚠🐏🍐🚛🌍🌎🌝🌖🐊🔭🚍🚜🚝🌲🌗🌳🌒🚋🚟
    🍼🚊🚎🚞🍋🔬🛃🌜🚦🚰🚿🛁💭💶💷📵🚡🚣🛂🚽🚾🉐󾓥󾓧󾓪󾓭🏤📯
    🈺🚬🛀🈸🚲🐆🐕🐖👳🔀🔅🔆☕🐂🐇🐈🐐👱👲☑☔🚁🚂🐁🐄🐅🐉🐓☎
    🐀🐃
    """
    
    case Latin = """
    !"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[]^_`\
    abcdefghijklmnopqrstuvwxya{|}~¡¢£¤¥¦§¨©ª«♪♫♯
    ¬­­®¯°±º¹²³´µØ¶·¸»½¾¼ÃÓÂÇÊËÏÐÑÎÒÄÍ­¿ÁÉÆÈÌÀÅĄÔÜâý×ÚßîñõøÿĀÞàáæçíðôûäêëïòöüă
    ĩĭĮİċęĝĞĪĒĔėğĠīįĲĈďēĜĕĖĚĤħĬćĉčĎĐěĢģĥĦıãåèìó÷þÛÝúāĂČÕÖÙĊĨĘéùąđĆġĸĺļłŅŏ
    ņŇňŌőŖŎŊōŐŉŋŬŒŔŕĳĵĹĽľńœĴΌĶķĿŁŃĻŀŚŗřŞŠťŧŵūůűųŶżǼŜşȚŪŮŰŲŹŽžǽŝŦŴźŻȘśšțŤŨŭŷǺǾǿ
    ⁿ∆−√≠₤№℮∏∞∫◊ﬁ⁸€ℓΩ⅛⅜∑≈≤≥⁷₣₧™⅝⅞∂ΎΊŘŸș℅ΈũſΆ·ƒǻΈ⁴Ήΐ–―ﬂ‗‘’‚‛“”„—‡•‼⁄⁵†‰›…′″‹
    """
    
    case Punctuation = """
    ¦'.@◊#(:;=<?_[`~,¢£¡{§}%½&*/$+>]^")-!|⁄\
    ¯´¶¨«®°·¬¥©±¼¤»¾‰∞∫¿―‗‚„•≠…″‹№—′›ℓΩ–‘’“”†‡‼€™−≈
    ‛₤₧℅⅛⅜∂₵℮⅝⅞∑≥∆∏≤ȷ₮₯√₡₲₹₢₥₠₭₰₱₳⅓₦₩₨₴⅔℗⅍ⅎ≡⌂ↄ
    """
    
    case BoxSymbols = """
    ○◦◘─│┌┐└┘├┤┴┬╒┼║╖╗╘╚╞╦╕╙╟╛╜╠◙═╓╔╝╡╢╣╤╪╬╥╩╫╨╧▀▄█░▐▌▒▓■□◌●
    """
    
    case MusicalSymbols = """
    𝄀𝄁𝄂𝄃𝄄𝄅𝄆𝄇𝄈𝄉𝄊𝄋𝄌𝄍𝄎𝄏𝄐𝄑𝄒𝄓𝄔𝄕𝄖𝄗𝄘𝄙𝄚𝄛𝅜𝅝𝅗𝅥𝅘𝅥𝅘𝅥𝅮𝅘𝅥𝅯𝅘𝅥𝅰𝅘𝅥𝅱𝅘𝅥𝅲♭♮♯𝄜𝄝𝄞𝄟𝄠𝄡𝄢𝄣𝄤𝄥𝄦𝄩𝄪𝄫𝄬𝄭𝄮𝄯𝄰𝄱𝄲𝄳𝄴𝄵𝄶𝄷𝄸𝄹𝄺𝄻𝄼𝄽𝄾𝄿𝅀𝅁𝅂𝅃𝅄𝅅𝅆𝅇𝆃𝆄𝆌𝆍𝆎𝆏𝆐𝆑𝆒𝆓
    𝆔𝆕𝆖𝆗𝆘𝆙𝆚𝆛𝆜𝆝𝆞𝆟𝆡𝆢𝆮𝆯𝆰𝆱𝆲𝆳𝆴𝆵𝆶𝆷𝆸𝆹𝆺𝆹𝅥𝆺𝅥𝆹𝅥𝅮𝆺𝅥𝅮𝆹𝅥𝅯𝆺𝅥𝅯𝇏𝇐𝇑𝇒𝇓𝇔𝇕𝇖𝇗𝇘𝇙𝇚𝇛𝇜𝇝
"""
}

/// Pre-defined sets of characters.
enum ShapeSeries: String, CaseIterable
{
    /// Flower shapes.
    case Flowers = "Flowers"
    /// Snowflake (or snow-related) shapes.
    case Snowflakes = "Snowflakes"
    /// Arrow shapes.
    case Arrows = "Arrows"
    /// Small geometric figures.
    case SmallGeometry = "Small Geometric Shapes"
    /// Star and sun shapes.
    case Stars = "Stars"
    /// Ornamental characters.
    case Ornamental = "Ornamental"
    /// Miscellaneous things.
    case Things = "Things"
    /// Comptuer-related shapes.
    case Computers = "Computer-Related"
    /// Hiragana characters.
    case Hiragana = "Hiragana"
    /// Katakana characters.
    case Katakana = "Katakana"
    /// Grade school kanji.
    case KyoikuKanji = "Grade School Kanji"//"Kyōiku Kanji"
    /// Hangul characters.
    case Hangul = "Hangul"
    /// Bodoni ornaments.
    case Bodoni = "Bodoni Ornaments"
    /// Latin characters.
    case Latin = "Latin Letters"
    /// Greek characters.
    case Greek = "Greek Letters"
    /// Cyrillic characters.
    case Cyrillic = "Cyrillic Letters"
    /// Emoji charactes.
    case Emoji = "Emoji"
    /// Punctuation marks.
    case Punctuation = "Punctuation"
    /// Symbols used to draw boxes.
    case BoxSymbols = "Box Symbols"
    /// Symbols used for musical notation.
    case MusicalNotion = "Musical Noation"
}


