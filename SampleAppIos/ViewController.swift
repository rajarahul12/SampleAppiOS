import UIKit
import IBMMobileFirstPlatformFoundation
import IBMMobileFirstPlatformFoundationPush
import IBMMobileFirstPlatformFoundationLiveUpdate

class ViewController: UIViewController {
    @IBOutlet private var statusText: UILabel!
    private var wlClient: WLClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        wlClient = WLClient.sharedInstance()
        mfConnect()
        mfPushInit()
        mfLiveUpdateInit()
        mfAnalyticsInit();
    }
    func mfAnalyticsInit() {
        let mfAnalytics = WLAnalytics.sharedInstance()
        mfAnalytics?.addDeviceEventListener(LIFECYCLE)
        mfAnalytics?.addDeviceEventListener(NETWORK)
        mfAnalytics?.log("App started successfully...", withMetadata: ["customDataKey": "customDataValue"])
        mfAnalytics?.send()
        OCLogger.setLevel(OCLogger_DEBUG)
        let logger = OCLogger.getInstanceWithPackage("SampleAppIos")
        logger!.logDebugWithMessages(message:"App started successfully...")
        OCLogger.send()   
    }

    func mfLiveUpdateInit() {
        LiveUpdateManager.sharedInstance.obtainConfiguration(useCache:false, completionHandler: liveUpdateHandler)
    }
    func mfPushInit() {
        let mfpPush = MFPPush.sharedInstance()
        mfpPush?.initialize()
        NotificationCenter.default.addObserver(self, selector: #selector(handlePush), name: Notification.Name("PushNotificationKey"), object: nil)
        mfpPush?.registerDevice(nil, completionHandler: pushHandler)
    }

    @objc func handlePush(_ notification: Notification) {
        if let msg = notification.userInfo?["message"] {
            changeStatusText("Received notification: \(msg)")
        } else {
            changeStatusText(notification.userInfo?["errorMsg"] as! String)
        }   
    }

    func mfConnect() {
        WLAuthorizationManager.sharedInstance()?.obtainAccessToken(forScope: "", withCompletionHandler: accessTokenHandler)
    }

    func changeStatusText(_ message: String) {
        self.statusText.text = message
    }
    
    func accessTokenHandler(token : AccessToken?, error: Error?) {
        if error == nil {
            changeStatusText("Connected to MobileFirst Server")
        } else {
            changeStatusText("Failed to connect to MobileFirst Server")
        }
    }

  
    func pushHandler(response: WLResponse?, error: Error?) {
        if error == nil {
            changeStatusText("Device successfully registered for push")
        } else {
            changeStatusText("Failed to register the device for push")
        }    
    }
    
    func liveUpdateHandler(configuration: Configuration?, error: NSError?) {
        if error == nil {
          var luArray: [String : Any] = [String : Any]()
          if let enableButton = configuration?.isFeatureEnabled("enableButton") {
              luArray["enableButton"] = enableButton
          }
          if let titleColour = configuration?.getProperty("titleColour") {
              luArray["titleColour"] = titleColour
          }
          let data = try? JSONSerialization.data(withJSONObject: luArray, options: [.prettyPrinted])
          changeStatusText("Live update schema:" + String(data: data!,  encoding: .utf8)!)
        } else {
          changeStatusText("Failed to obtain live update configuration")
        }
    }
}
extension OCLogger {
    func logTraceWithMessages(message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_TRACE, message: message, args:getVaList(args), userInfo:Dictionary<String, String>())
    }
    func logDebugWithMessages(message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_DEBUG, message: message, args:getVaList(args), userInfo:Dictionary<String, String>())
    }
    func logInfoWithMessages(message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_INFO, message: message, args:getVaList(args), userInfo:Dictionary<String, String>())
    }
    func logWarnWithMessages(message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_WARN, message: message, args:getVaList(args), userInfo:Dictionary<String, String>())
    }
    func logErrorWithMessages(message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_ERROR, message: message, args:getVaList(args), userInfo:Dictionary<String, String>())
    }
    func logFatalWithMessages(message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_FATAL, message: message, args:getVaList(args), userInfo:Dictionary<String, String>())
    }
    func logAnalyticsWithMessages(message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_ANALYTICS, message: message, args:getVaList(args), userInfo:Dictionary<String, String>())
    }        
    func logTraceWithUserInfo(userInfo:Dictionary<String, String>, message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_TRACE, message: message, args:getVaList(args), userInfo:userInfo)
    }
    func logDebugWithUserInfo(userInfo:Dictionary<String, String>, message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_DEBUG, message: message, args:getVaList(args), userInfo:userInfo)
    }
    func logInfoWithUserInfo(userInfo:Dictionary<String, String>, message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_INFO, message: message, args:getVaList(args), userInfo:userInfo)
    }
    func logWarnWithUserInfo(userInfo:Dictionary<String, String>, message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_WARN, message: message, args:getVaList(args), userInfo:userInfo)
    }
    func logErrorWithUserInfo(userInfo:Dictionary<String, String>, message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_ERROR, message: message, args:getVaList(args), userInfo:userInfo)
    }
    func logFatalWithUserInfo(userInfo:Dictionary<String, String>, message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_FATAL, message: message, args:getVaList(args), userInfo:userInfo)
    }
    func logAnalyticsWithUserInfo(userInfo:Dictionary<String, String>, message:String, _ args: CVarArg...) {
        log(withLevel: OCLogger_ANALYTICS, message: message, args:getVaList(args), userInfo:userInfo)
    }
}

