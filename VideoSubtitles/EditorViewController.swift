import UIKit
import AVFoundation

class EditorViewController: UIViewController {
    let slider = SliderControl(frame: .zero)
    
    var getAdditions = Additions.share
    
    var time: Timer?
    var timeObserver: Any?
    var arrayTokens: [Any]?
    var timeObserverToken: Any!
    var mediaDurationOut = Int()
    var currentTimeSeconds = Int()
    var endTimeOutput = Double()
    var urlVideo: URL?
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    var randomColor = UIColor()
    var arrayColor = [UIColor.black, UIColor.orange, UIColor.blue, UIColor.green, UIColor.yellow,UIColor.red, UIColor.systemBlue, UIColor.purple]
    var indexColor = 0
    var sliderFrame = CGRect()
    var arraySubtitles = [String]()
    var values = Double()
    var startTimes = Double()
    var myButtons = UIButton()
    
    @IBOutlet weak var subtitlesOutlet: UILabel!
    @IBOutlet weak var timeLineLabel: UILabel!
    
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseOutletButton: UIButton!
    @IBOutlet weak var playerViewOutlet: UIView!
    @IBOutlet weak var fontSubtitlesOutlet: UILabel!
    @IBAction func playOrPauseAction(_ sender: Any) {
        getAdditions.playOrpayse(player: player, button: playOrPauseOutletButton, timer: timers())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSlider1()
        setupVideoPlayer()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        player.pause()
        timers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sliderInit()
    }
    
    func sliderInit() {
        playerLayer.frame = playerViewOutlet.bounds
        let margin: CGFloat = 20
        let width = view.bounds.width - 2 * margin
        let height: CGFloat = 60
        //        print(width)
        
        slider.frame = CGRect(x: 20, y: playerLayer.frame.width + 65,
                              width: width, height: height)
        sliderFrame = slider.frame
    }
    
    func addNewColor(controller: AddSubViewController) {
        indexColor += 1
        controller.colorSubtitble = arrayColor[indexColor % arrayColor.count]
    }
    
    @IBAction func transferTime(_ sender: Any) {
        getAdditions.onlyPause(player: player, button: playOrPauseOutletButton)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addSubViewController = storyboard.instantiateViewController(identifier: "addSubID") as? AddSubViewController else { return }
        addSubViewController.currentTime = timeLineLabel.text ?? "Ошибка"
        addSubViewController.modalPresentationStyle = .overCurrentContext
        addSubViewController.view.backgroundColor = .clear
        addNewColor(controller: addSubViewController)
        addSubViewController.mediaDuarion = mediaDurationOut
        addSubViewController.currentTimeInSeconds = currentTimeSeconds
        addSubViewController.delegate = self
        
        present(addSubViewController, animated: true, completion: nil)
    }
    
    
    @objc func rangeSliderValueChanged(_ rangeSlider: SliderControl) {
        getAdditions.onlyPause(player: player, button: playOrPauseOutletButton)
        timers()
        guard let duration = player?.currentItem?.duration else { return }
        let value = Float64(slider.lowerValue) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: CMTimeScale(1))
        player?.seek(to: seekTime )
        
        let fortmatedTime = getAdditions.formattedTime(minute: Int(value), second: Int(value))
        timeLineLabel.text = String(fortmatedTime)
    }
    
    
    
    func setupVideoPlayer() {
        //MARK: время видео
        let asset = AVURLAsset(url: urlVideo!)
        let totalSeconds = Int(CMTimeGetSeconds(asset.duration))
        let mediaDuration = getAdditions.formattedTime(minute: totalSeconds, second: totalSeconds)
        endTimeLabel.text = mediaDuration
        mediaDurationOut = totalSeconds
        
        if let unwrapURL = urlVideo {
            player = AVPlayer(url: unwrapURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerViewOutlet.layer.addSublayer(playerLayer)
        }
        let interval = CMTime(seconds: 1, preferredTimescale: 2)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] time in
            
            self?.updateVideoPlayerSlider(time: time)
        })
        
    }
    func updateVideoPlayerSlider(time: CMTime) {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        slider.lowerValue = CGFloat(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            slider.lowerValue =
                CGFloat(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
            values = currentTimeInSeconds
        }
        subtitlesOutlet.text = ""
        let timeLineCurrentTime = getAdditions.formattedTime(minute: Int(currentTimeInSeconds), second: Int(currentTimeInSeconds))
        currentTimeSeconds = Int(currentTimeInSeconds) + 1
        timeLineLabel.text = String(timeLineCurrentTime)
    }
    
    @objc func backAction(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Сбросить?", message: "При возврате на экран библиотеки все данные будут сброшены", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Сбросить", style: .cancel) { [weak self] (result : UIAlertAction) -> Void in
            self?.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    
    @objc func toggle() {
        playOrPauseOutletButton.isHidden = !playOrPauseOutletButton.isHidden
        timers()
    }
    
    
    func initializeSlider1(){
        slider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        slider.backgroundColor = .lightGray
        view.addSubview(slider)
        subtitlesOutlet.text = ""
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        playerViewOutlet.addGestureRecognizer(tap)
        playerViewOutlet.isUserInteractionEnabled = true
        let newBackButton = UIBarButtonItem(title: "Сбросить", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backAction(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        let slider1InitialValue:Float = Float(slider.lowerValue)
        let slider1ValueInt:Int = Int(slider1InitialValue)
        timeLineLabel.text = String(slider1ValueInt)
        
    }
    
    func timers() {
        time?.invalidate()
        time = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleTap),userInfo: nil, repeats: false)
    }
    
    @objc func handleTap() {
        playOrPauseOutletButton.isHidden = true
    }
    
    func makeRangeArray() -> CMTimeRange {
        let cmTimeStarts = CMTime(seconds: startTimes, preferredTimescale: 100)
        let cmTimeEnds = CMTime(seconds: endTimeOutput, preferredTimescale: 100)
        print(cmTimeStarts)
        print(cmTimeEnds)
        let cmTimeRanges = CMTimeRange(start: cmTimeStarts, end: cmTimeEnds)
        return cmTimeRanges
    }
    
    func addButtonForView() {
        slider.currentThumbPoint.x = slider.lowerValue
        let value = CGFloat(Int(endTimeOutput) - (currentTimeSeconds - 1))
        let wPerSec = (Int(view.bounds.width) - 2 * 30) / mediaDurationOut
        let currentPoint = (Double(wPerSec) * values) + 25
        let button = UIButton(frame: CGRect(x: CGFloat(currentPoint), y: slider.center.y - 25, width: (value) * CGFloat(wPerSec), height: slider.frame.height - 10))
        button.tag += 1
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.backgroundColor = randomColor
        view.addSubview(button)
        }
    
    @objc private func tapped() {
        guard let popVC = storyboard?.instantiateViewController(withIdentifier: "popVC") else { return }
        popVC.modalPresentationStyle = .overCurrentContext
        popVC.view.backgroundColor = .clear
                let popOverVC = popVC.popoverPresentationController
                popOverVC?.delegate = self
                popOverVC?.sourceView = self.myButtons
                self.present(popVC, animated: true)
            }
        }
    

extension EditorViewController: UIPopoverPresentationControllerDelegate {

       func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
           return .none
       }
   }

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}

extension EditorViewController: AddSubDelegate {
    func dataDelegate(sub: String, startTime: Int, endTime: Int, color: UIColor) {
        fontSubtitlesOutlet.isHidden = false
        arraySubtitles.append(sub)
        endTimeOutput = Double(endTime)
        startTimes = Double(startTime)
        randomColor = color
        addButtonForView()
        let start = Int(startTime)
        let end = Int(endTime)
        let arrayRange: [Int] = Array(start...end)
        var times = [NSValue]()
        for el in arrayRange {
            let cm = CMTime(seconds: Double(el), preferredTimescale: 1)
            times.append(NSValue(time: cm))
            print(cm)
        }
            let newTimeObserverToken = player.addBoundaryTimeObserver(forTimes: times, queue: DispatchQueue.main, using: {
                    [weak self] in
                    self?.subtitlesOutlet.text = sub
            })
        arrayTokens?.append(newTimeObserverToken)
    }
    }
