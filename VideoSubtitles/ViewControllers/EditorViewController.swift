import UIKit
import AVFoundation

class EditorViewController: UIViewController {
    
    var getSlider = SliderControl.share
    var getAdditions = Additions.share
    var getPlayer = MyPlayer.share

    var arrayTokens: [Any]?
    var timeObserverToken: Any!
    
    var urlVideo: URL?
    
    var time: Timer?
    
    var startTimes = Double()
    var endTimeOutput = Double()
    
    var arrayColor = [UIColor.black, UIColor.orange, UIColor.blue, UIColor.green, UIColor.yellow,UIColor.red, UIColor.systemBlue, UIColor.purple]
    var indexColor = 0
    var randomColor = UIColor()
    var arrayColorSubtitles = [UIColor]()
    
    var arraySubtitles = [String]()
    
    var myButtons = UIButton()
    
    @IBOutlet weak var subtitlesOutlet: UILabel!
    @IBOutlet weak var timeLineLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseOutletButton: UIButton!
    @IBOutlet weak var playerViewOutlet: UIView!
    @IBOutlet weak var viewSlider: UIView!
    @IBOutlet weak var fontSubtitlesOutlet: UILabel!
    
    @IBAction func playOrPauseAction(_ sender: Any) {
        getAdditions.playOrpayse(player: getPlayer.player, button: playOrPauseOutletButton, timer: timers())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        getPlayer.setupVideoPlayer(label: endTimeLabel, playerOut: playerViewOutlet, urlVideo: urlVideo!)
        getPlayer.initializeSlider1(playerViewOutlet: playerViewOutlet, parentView: viewSlider, timeLineLabel: timeLineLabel)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getPlayer.player.pause()
        timers()
        getPlayer.updateSliderTime(timeLine: timeLineLabel, subOutlet: subtitlesOutlet)
    }
    
    func setupView() {
        subtitlesOutlet.text = ""
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        playerViewOutlet.addGestureRecognizer(tap)
        playerViewOutlet.isUserInteractionEnabled = true
        let newBackButton = UIBarButtonItem(title: "Сбросить", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backAction(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        let fortmatedTime = getAdditions.formattedTime(minute: Int(getPlayer.outputValue), second: Int(getPlayer.outputValue))
        timeLineLabel.text = String(fortmatedTime)
    }
    
    func addNewColor(controller: AddSubViewController) {
        indexColor += 1
        controller.colorSubtitble = arrayColor[indexColor % arrayColor.count]
    }
    
    //MARK: + Button
    @IBAction func transferTime(_ sender: Any) {
        getSlider.updateLayerFrames()
        getAdditions.onlyPause(player: getPlayer.player, button: playOrPauseOutletButton)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let addSubViewController = storyboard.instantiateViewController(identifier: "addSubID") as? AddSubViewController else { return }
        addSubViewController.currentTime = timeLineLabel.text ?? "Ошибка"
        addSubViewController.modalPresentationStyle = .overCurrentContext
        addSubViewController.view.backgroundColor = .clear
        addNewColor(controller: addSubViewController)
        addSubViewController.delegate = self
        present(addSubViewController, animated: true, completion: nil)
    }
    //MARK: Back button
    @objc func backAction(sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Сбросить?", message: "При возврате на экран библиотеки все данные будут сброшены", preferredStyle: .actionSheet)
        let okAction = UIAlertAction(title: "Сбросить", style: .cancel) { [weak self] (result : UIAlertAction) -> Void in
            self?.getSlider.lowerValue = 0.05
            self?.dismiss(animated: true)
            self?.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Отмена", style: .default, handler: nil)
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true)
    }
    
    //MARK: Hide play/pause
    @objc func toggle() {
        playOrPauseOutletButton.isHidden = !playOrPauseOutletButton.isHidden
        timers()
    }
    
    func timers() {
        time?.invalidate()
        time = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleTap),userInfo: nil, repeats: false)
    }
    
    //MARK: Hide play/pause
    @objc func handleTap() {
        playOrPauseOutletButton.isHidden = true
    }
    //MARK: New button at slider position with width like subtitle duration
    func addButtonForView() {
        getSlider.updateLayerFrames()
        getPlayer.slider.currentThumbPoint.x = getPlayer.slider.lowerValue
        let value = CGFloat(endTimeOutput - getPlayer.outputValue)
        print("\(value)value")
        let wPerSec = Double(viewSlider.frame.width) / Double(getPlayer.mediaDurationOut)
        print("\(wPerSec)wPerSec")
        let xPerSec = wPerSec * getPlayer.outputValue
        print("\(xPerSec)xPerSec")
        let startPoint = Double(viewSlider.frame.minX)
        let button = UIButton(frame: CGRect(x: CGFloat(startPoint + xPerSec), y: viewSlider.center.y - 25, width: (value * CGFloat(wPerSec)), height: getPlayer.slider.frame.height - 10))
        button.addTarget(self, action: #selector(tapped), for: .touchUpInside)
        button.layer.cornerRadius = 5
        button.backgroundColor = randomColor
        view.addSubview(button)
    }
    //MARK: Tap on subtitle button
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
    //MARK: Delegate start/end/color of new subtitle, create new token for observer subtitle time
    func dataDelegate(sub: String, startTime: Int, endTime: Int, color: UIColor) {
        fontSubtitlesOutlet.isHidden = false
        endTimeOutput = Double(endTime)
        startTimes = Double(startTime)
        randomColor = color
        addButtonForView()
        let start = Double(startTime)
        let end = Double(endTime) + 1.0
        var times = [NSValue]()
        
        //MARK: Create array of range from start subtitle to end with gap by 0.01
        let doublesArray = Array(stride(from: start, to: end, by: 0.01))
        for el in doublesArray {
            let cm = CMTime(seconds: Double(el), preferredTimescale: 1000)
            times.append(NSValue(time: cm))
        }
        timeObserverToken = getPlayer.player.addBoundaryTimeObserver(forTimes: times, queue: DispatchQueue.main, using: {
            [weak self] in
            self?.subtitlesOutlet.text = sub
        })
        arrayTokens?.append(timeObserverToken!)
        arrayColor.append(color)
        arraySubtitles.append(sub)
        
    }
}
