struct K{
    static let appName: String  = "ClockIn~ClockOut"
    static let registerSegue: String  = "RegisterToClokIn_Out"
    static let loginSegue: String = "LoginToClokIn_Out"
    static let reportSegue: String  = "ClockIn_OutToReport"
    
    struct FSStore{
        static let TimeStampCollectionName = "TimeStamp"
        static let UserID = "UserID"
        static let TimeStamp = "TimeStamp"
        static let Subject = "Subject"
        static let IsValid = "IsValid"
    }
}
