import UIKit
import AVFoundation

class Subtitle {
    var startTime: CMTime = CMTime.zero
    var endTime: CMTime = CMTime.zero
    var text: String = ""
    
    func containsTime(time: CMTime) -> Bool {
        //проверям попадание текущего времени в диапазон субтитра
        fatalError("Нужно реализовать метод containsTime(time: CMTime) ")
    }
}

class EditorViewController: UIViewController {
    
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
    
    var arraySubtitles = [String]()
    
    var myButtons = UIButton()
    
    //текущий отображаемый субтитр
    var currentSubtitle: Subtitle? = nil
    
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
        subtitlesOutlet.text = ""
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggle))
        playerViewOutlet.addGestureRecognizer(tap)
        playerViewOutlet.isUserInteractionEnabled = true
        let newBackButton = UIBarButtonItem(title: "Сбросить", style: UIBarButtonItem.Style.plain, target: self, action: #selector(self.backAction(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        
        let fortmatedTime = getAdditions.formattedTime(minute: Int(getPlayer.outputValue), second: Int(getPlayer.outputValue))
        timeLineLabel.text = String(fortmatedTime)
        getPlayer.initializeSlider1(parentView: viewSlider, timeLineLabel: timeLineLabel)
        getPlayer.setupVideoPlayer(label: endTimeLabel, playerOut: playerViewOutlet, subOutlet: subtitlesOutlet, timeLine: timeLineLabel, urlVideo: urlVideo!)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        getPlayer.player.pause()
        timers()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        getPlayer.sliderInit(playerViewOutlet: playerViewOutlet, parentView: viewSlider)
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
    
    func timers() {
        time?.invalidate()
        time = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(handleTap),userInfo: nil, repeats: false)
    }
    
    @objc func handleTap() {
        playOrPauseOutletButton.isHidden = true
    }
    
    func addButtonForView() {
        getPlayer.slider.currentThumbPoint.x = getPlayer.slider.lowerValue
        let value = CGFloat(Int(endTimeOutput) - (getPlayer.currentTimeSeconds - 1))
        let wPerSec = (Int(viewSlider.bounds.width) - 2 * 30) / getPlayer.mediaDurationOut
        let xPerSec = (wPerSec * getPlayer.outputValue) * 2
        let button = UIButton(frame: CGRect(x: CGFloat(xPerSec), y: viewSlider.center.y - 25, width: (value) * CGFloat(wPerSec), height: getPlayer.slider.frame.height - 10))
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
    
    func addSubtitles(text: String) {
        subtitlesOutlet.text = text
    }
    
    func getSubtitleByTime(time: CMTime) -> [Subtitle] {
        //Необходимо найти субтитры из списка по времени
        //Возвращаем массив на случай если субтитры перекрываются
        fatalError("Нужно реализовать метод getSubtitleByTime(time: CMTime)")
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
        let start = Double(startTime)
        let end = Double(endTime)
//        let arrayRange: [Int] = Array(start...end)
        var times = [NSValue]()
        let doublesArray = Array(stride(from: start, to: end, by: 0.01))
        print(doublesArray)
        for el in doublesArray {
            let cm = CMTime(seconds: Double(el), preferredTimescale: 100)
            times.append(NSValue(time: cm))
        }
        //время здесь нужно только начала и конца
        timeObserverToken = getPlayer.player.addBoundaryTimeObserver(forTimes: times, queue: DispatchQueue.main, using: {
            [weak self] in
            guard let self = self else { return }
            let currentTime = self.getPlayer.player.currentTime()
            //проверяем завершился ли текущий субтитр
            if !(self.currentSubtitle?.containsTime(time: currentTime) ?? false ) {
                self.currentSubtitle = nil
                self.subtitlesOutlet.text = ""
                self.subtitlesOutlet.isHidden = true
            }
            if self.currentSubtitle == nil {
                //далее проверяем нужно ли что отобразить из списка субтитров
                    let subtitlesAvailable = self.getSubtitleByTime(time: currentTime)
                    if subtitlesAvailable.count > 0 {
                        //отображаем субититр
                }
            }
        })
        arrayTokens?.append(timeObserverToken!)
        print(times)
    }
}
