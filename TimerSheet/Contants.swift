struct K{
    static let appName: String  = "ClockIn~ClockOut"
    static let loginSegue: String = "LoginToClokIn_Out"
    static let reportSegue: String  = "ClockIn_OutToReport"
    
    static let cellIdentifier = "DayCell"
    static let cellNibName = "WorkingDayCell"
    
    static let userAccessGroup = "theAvengers.com.theAvengers.dottorStrange.TimerSheet"
    static let appPackageName = "com.theAvengers.dottorStrange.TimerSheet"
    static let url = "https://timerSheet.dottorStrange.theAvengers.com"
    
    struct FSStore{
        static let TimeStampCollectionName = "TimeStamp"
        static let UserID = "UserID"
        static let TimeStamp = "TimeStamp"
        static let Subject = "Subject"
        static let IsValid = "IsValid"
    }
}
