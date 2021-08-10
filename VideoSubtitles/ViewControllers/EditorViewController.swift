import UIKit
import AVFoundation

class EditorViewController: UIViewController {
    let slider = SliderControl(frame: .zero)
    
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
    
    var sliderFrame = CGRect()
    
    var arraySubtitles = [String]()
   
    var myButtons = UIButton()
    
    @IBOutlet weak var subtitlesOutlet: UILabel!
    @IBOutlet weak var timeLineLabel: UILabel!
    @IBOutlet weak var endTimeLabel: UILabel!
    @IBOutlet weak var playOrPauseOutletButton: UIButton!
    @IBOutlet weak var playerViewOutlet: UIView!
    @IBOutlet weak var fontSubtitlesOutlet: UILabel!
    
    @IBAction func playOrPauseAction(_ sender: Any) {
        getAdditions.playOrpayse(player: getPlayer.player, button: playOrPauseOutletButton, timer: timers())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeSlider1()
        getPlayer.setupVideoPlayer(label: endTimeLabel, playerOut: playerViewOutlet, slider: slider, subOutlet: subtitlesOutlet, timeLine: timeLineLabel, urlVideo: urlVideo!)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getPlayer.player.pause()
        timers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sliderInit()
    }
    
    func sliderInit() {
        getPlayer.playerLayer.frame = playerViewOutlet.bounds
        let margin: CGFloat = 20
        let width = view.bounds.width - 2 * margin
        let height: CGFloat = 60
        slider.frame = CGRect(x: 20, y: getPlayer.playerLayer.frame.width + 65,
                              width: width, height: height)
        sliderFrame = slider.frame
    }
    
    func addNewColor(controller: AddSubViewController) {
        indexColor += 1
        controller.colorSubtitble = arrayColor[indexColor % arrayColor.count]
    }
    
    @IBAction func transferTime(_ sender: Any) {
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
    
    
    @objc func rangeSliderValueChanged(_ rangeSlider: SliderControl) {
        getAdditions.onlyPause(player: getPlayer.player, button: playOrPauseOutletButton)
        timers()
        guard let duration = getPlayer.player?.currentItem?.duration else { return }
        let value = Float64(slider.lowerValue) * CMTimeGetSeconds(duration)
        let seekTime = CMTime(value: CMTimeValue(value), timescale: CMTimeScale(1))
        getPlayer.player?.seek(to: seekTime )
        
        let fortmatedTime = getAdditions.formattedTime(minute: Int(value), second: Int(value))
        timeLineLabel.text = String(fortmatedTime)
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
    
    func addButtonForView() {
        slider.currentThumbPoint.x = slider.lowerValue
        let value = CGFloat(Int(endTimeOutput) - (getPlayer.currentTimeSeconds - 1))
        let wPerSec = (Int(view.bounds.width) - 2 * 30) / getPlayer.mediaDurationOut
        let currentPoint = (Double(wPerSec) * getPlayer.values) + 25
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
        let newTimeObserverToken = getPlayer.player.addBoundaryTimeObserver(forTimes: times, queue: DispatchQueue.main, using: {
                    [weak self] in
                    self?.subtitlesOutlet.text = sub
            })
        arrayTokens?.append(newTimeObserverToken)
    }
    }
