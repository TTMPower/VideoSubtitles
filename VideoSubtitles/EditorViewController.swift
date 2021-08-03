import UIKit
import AVFoundation

class EditorViewController: UIViewController {
    
    @IBOutlet weak var sliderTimeOutlet: UISlider!
    var time: Timer?
    var timeObserver: Any?
    var minuteTimeOut = Int()
    var secondTimeOut = Int()
    
    @IBAction func transferTime(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addSubViewController = storyboard.instantiateViewController(identifier: "addSubID") as? AddSubViewController else { return }
        addSubViewController.currentTime = timeLineLabel.text ?? "Ошибка"
        addSubViewController.minuteTimeOut = minuteTimeOut
        addSubViewController.secondTimeOut = secondTimeOut
        addSubViewController.modalPresentationStyle = .overCurrentContext
        addSubViewController.view.backgroundColor = .clear
        present(addSubViewController, animated: true, completion: nil)
        print("Попытка передать МИНУТ \(minuteTimeOut) : СЕКУНД \(secondTimeOut) =========")
    }
    //MARK: таймер исчезновения кнопки плей/пауза
    func timers() {
        time?.invalidate()
        time = Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(handleTap),userInfo: nil, repeats: false)
    }
    
    func setupVideoPlayer() {
        let interval = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        sliderTimeOutlet.setValue(sliderTimeOutlet.minimumValue, animated: false)
        timeObserver = player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main, using: { [weak self] elapsedTime in
            self?.updateVideoPlayerSlider()
        })
    }
    func updateVideoPlayerSlider() {
        guard let currentTime = player?.currentTime() else { return }
        let currentTimeInSeconds = CMTimeGetSeconds(currentTime)
        sliderTimeOutlet.value = Float(currentTimeInSeconds)
        if let currentItem = player?.currentItem {
            let duration = currentItem.duration
            if (CMTIME_IS_INVALID(duration)) {
                return;
            }
            let currentTime = currentItem.currentTime()
            sliderTimeOutlet.value = Float(CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(duration))
        }
        let timeLineCurrentTime = formattedTime(minute: Int(currentTimeInSeconds), second: Int(currentTimeInSeconds))
        timeLineLabel.text = String(timeLineCurrentTime)
    }
    
    
    
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
    
    var urlVideo: URL? = nil
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    @IBOutlet weak var timeLineLabel: UILabel!
    
    //    func play() {
    //        playOrPauseOutletButton.setImage(UIImage(named: "pause"), for: .normal)
    //        player.play()
    //        index = 1
    //    }
    //
    //    func stop() {
    //        playOrPauseOutletButton.setImage(UIImage(named: "play-button"), for: .normal)
    //        player.pause()
    //        index = 0
    //    }
    
    //MARK: нажатие на вью видеоплеера для активации паузы
    
    @objc func handleTap() {
        playOrPauseOutletButton.isHidden = true
    }
    
    
    @objc func backAction(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Сбросить?", message: "При возврате на экран библиотеки все данные будут сброшены", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Сбросить", style: .cancel) { [weak self] (result : UIAlertAction) -> Void in
            self?.sliderTimeOutlet.setValue(self?.sliderTimeOutlet.minimumValue ?? 0.0, animated: true)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        playerViewOutlet.addGestureRecognizer(tap)
        playerViewOutlet.isUserInteractionEnabled = true
        
        let newBackButton = UIBarButtonItem(title: "Сбросить", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backAction(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        
        
        //MARK: время видео
        let asset = AVURLAsset(url: urlVideo!)
        let totalSeconds = Int(CMTimeGetSeconds(asset.duration))
        print("Попытка получить тотал секонд \(totalSeconds)")
        let mediaDuration = formattedTime(minute: totalSeconds, second: totalSeconds)
        endTimeLabel.text = mediaDuration
        
        if let unwrapURL = urlVideo {
            player = AVPlayer(url: unwrapURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerViewOutlet.layer.addSublayer(playerLayer)
        }
        initializeSlider1()
        setupVideoPlayer()
    }
    
    @IBAction func sliderValueChange(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let value = Float64(sliderTimeOutlet.value) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: 1)
        player?.seek(to: seekTime )
        let fortmatedTime = formattedTime(minute: Int(value), second: Int(value))
        timeLineLabel.text = String(fortmatedTime)
    }
    func initializeSlider1(){

        let slider1InitialValue:Float = sliderTimeOutlet.value
        let slider1ValueInt:Int = Int(slider1InitialValue)
        timeLineLabel.text = String(slider1ValueInt)
        sliderTimeOutlet.backgroundColor = UIColor.clear
        sliderTimeOutlet.layer.cornerRadius = 1
        sliderTimeOutlet.layer.style = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        player.pause()
        timers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerViewOutlet.bounds
    }
}

extension AVPlayer {
    var isPlaying: Bool {
        return rate != 0 && error == nil
    }
}
