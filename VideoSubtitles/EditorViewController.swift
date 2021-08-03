import UIKit
import AVFoundation

class EditorViewController: UIViewController {
    
    var index = 0
    var time = Timer()
    
    //MARK: таймер исчезновения кнопки плей/пауза
    func timers() {
        time = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            self.playOrPauseOutletButton.isHidden = true
        }
    }
    
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseOutletButton: UIButton!
    @IBOutlet weak var playerViewOutlet: UIView!
    @IBAction func playOrPauseAction(_ sender: Any) {
        timers()
        if index == 0 {
            play()
        } else if index == 1 {
            stop()
        }
    }
    
    var urlVideo: URL? = nil
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    
    func play() {
        playOrPauseOutletButton.setImage(UIImage(named: "pause"), for: .normal)
        player.play()
        index = 1
    }
    
    func stop() {
        playOrPauseOutletButton.setImage(UIImage(named: "play-button"), for: .normal)
        player.pause()
        index = 0
    }
    
    //MARK: нажатие на вью видеоплеера для активации паузы
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        time.invalidate()
        if playOrPauseOutletButton.isHidden == true {
            playOrPauseOutletButton.isHidden = false
            time.invalidate()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        playerViewOutlet.addGestureRecognizer(tap)
        playerViewOutlet.isUserInteractionEnabled = true
        
        //MARK: время видео
        let asset = AVURLAsset(url: urlVideo!)
        let totalSeconds = Int(CMTimeGetSeconds(asset.duration))
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        let mediaDuration = String(format:"%02i:%02i",minutes, seconds)
        endTimeLabel.text = mediaDuration
        
        if let unwrapURL = urlVideo {
            player = AVPlayer(url: unwrapURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer.videoGravity = .resizeAspect
            playerViewOutlet.layer.addSublayer(playerLayer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        player.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = playerViewOutlet.bounds
    }
}
