import UIKit
import AVFoundation

class EditorViewController: UIViewController {
    let slider = SliderControl(frame: .zero)
    var time: Timer?
    var timeObserver: Any?
    var minuteTimeOut = Int()
    var secondTimeOut = Int()
    var timeObserverToken: Any?
    var mediaDurationOut = Int()
    var currentTimeSeconds = Int()
    
    var urlVideo: URL?
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    @IBOutlet weak var timeLineLabel: UILabel!
    
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseOutletButton: UIButton!
    @IBOutlet weak var playerViewOutlet: UIView!
    @IBAction func playOrPauseAction(_ sender: Any) {
        guard let player = player else { return }
        if !player.isPlaying {
            playOrPauseOutletButton.setImage(UIImage(named: "pause"), for: .normal)
            player.play()
            timers()
            
        } else {
            playOrPauseOutletButton.setImage(UIImage(named: "play-button"), for: .normal)
            player.pause()
            timers()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slider.addTarget(self, action: #selector(rangeSliderValueChanged(_:)), for: .valueChanged)
        slider.backgroundColor = .lightGray
        view.addSubview(slider)
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        playerViewOutlet.addGestureRecognizer(tap)
        playerViewOutlet.isUserInteractionEnabled = true
        let newBackButton = UIBarButtonItem(title: "Сбросить", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backAction(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        
        //MARK: время видео
        let asset = AVURLAsset(url: urlVideo!)
        let totalSeconds = Int(CMTimeGetSeconds(asset.duration))
        let mediaDuration = formattedTime(minute: totalSeconds, second: totalSeconds)
        endTimeLabel.text = mediaDuration
        mediaDurationOut = totalSeconds
        
        if let unwrapURL = urlVideo {
            player = AVPlayer(url: unwrapURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerViewOutlet.layer.addSublayer(playerLayer)
        }
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
        playerLayer.frame = playerViewOutlet.bounds
        
        
        let margin: CGFloat = 20
        let width = view.bounds.width - 2 * margin
        let height: CGFloat = 60
        
        slider.frame = CGRect(x: 20, y: playerLayer.frame.width + 65,
                              width: width, height: height)
        //        slider.center = view.center
        
        
    }
   
    @IBAction func transferTime(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addSubViewController = storyboard.instantiateViewController(identifier: "addSubID") as? AddSubViewController else { return }
        addSubViewController.currentTime = timeLineLabel.text ?? "Ошибка"
        addSubViewController.modalPresentationStyle = .overCurrentContext
        addSubViewController.view.backgroundColor = .clear
        addSubViewController.mediaDuarion = mediaDurationOut
        addSubViewController.currentTimeInSeconds = currentTimeSeconds
        present(addSubViewController, animated: true, completion: nil)
    }
    
    
    @objc func rangeSliderValueChanged(_ rangeSlider: SliderControl) {
        player?.pause()
        playOrPauseOutletButton.setImage(UIImage(named: "play-button"), for: .normal)
        timers()
        guard let duration = player?.currentItem?.duration else { return }
        let value = Float64(slider.lowerValue) * CMTimeGetSeconds(duration)
//        actuallySeekToTime()
        let seekTime = CMTime(value: CMTimeValue(value), timescale: CMTimeScale(1))
        player?.seek(to: seekTime )

        let fortmatedTime = formattedTime(minute: Int(value), second: Int(value))
        timeLineLabel.text = String(fortmatedTime)
    }


    func timers() {
        time?.invalidate()
        time = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(handleTap),userInfo: nil, repeats: false)
    }
    
    func setupVideoPlayer() {
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
            }
        let timeLineCurrentTime = formattedTime(minute: Int(currentTimeInSeconds), second: Int(currentTimeInSeconds))
        currentTimeSeconds = Int(currentTimeInSeconds)
        timeLineLabel.text = String(timeLineCurrentTime)
    }
    
    //MARK: нажатие на вью видеоплеера для активации паузы
    
    @objc func handleTap() {
        playOrPauseOutletButton.isHidden = true
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
    
    func formattedTime(minute: Int, second: Int) -> String {
        let formattedMinute = minute / 60
        let formattedSecond = second % 60
        
        secondTimeOut = formattedSecond
        minuteTimeOut = formattedMinute
        
        return String(format: "%02i:%02i", formattedMinute, formattedSecond)
    }
    
    @objc func toggle() {
        playOrPauseOutletButton.isHidden = !playOrPauseOutletButton.isHidden
        timers()
    }
    
    
    func initializeSlider1(){
        
        let slider1InitialValue:Float = Float(slider.lowerValue)
        let slider1ValueInt:Int = Int(slider1InitialValue)
        timeLineLabel.text = String(slider1ValueInt)
        
    }
}
    

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
