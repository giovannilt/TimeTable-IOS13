struct K{
    static let appName: String  = "ClockIn~ClockOut"
    static let registerSegue: String  = "RegisterToClokIn_Out"
    static let loginSegue: String = "LoginToClokIn_Out"
    static let reportSegue: String  = "ClockIn_OutToReport"
    
    static let cellIdentifier = "DayCell"
    static let cellNibName = "WorkingDayCell"
    
    
    struct FSStore{
        static let TimeStampCollectionName = "TimeStamp"
        static let UserID = "UserID"
        static let TimeStamp = "TimeStamp"
        static let Subject = "Subject"
        static let IsValid = "IsValid"
    }
}
