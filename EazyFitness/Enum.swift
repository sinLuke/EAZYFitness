enum courseStatus {
    case waitForStudent
    case approved
    case scaned
    case ill //就是没来
    case noStudent
    case noTrainer //第一次不管，之后有惩罚
    case noCard //第一次不管，之后有惩罚
    case other
}

enum userRegion{
    case Mississauga
    case Scarborough
    case Waterloo
    case London
    case All
}

enum userStatus {
    case avaliable
    case canceled
    case unsigned
    case signed
}

enum userGroup {
    case student
    case trainer
    case admin
}

enum courseType {
    case general
    case multiple
}

enum messageType {
    case trainer
    case admin
}

enum requestType {
    case studentApproveCourse
    case trainerApproveCourse
    case studentRemove
    case trainerRemove
    case studentAddValue
}

import Foundation

class enumService: NSObject {
    
    static let Region:[userRegion] = [.Mississauga, .Scarborough, .Waterloo, .London]
    static let RegionName:[String] = ["Mississauga", "Scarborough", "Waterloo", "London"]
    static let RegionString:[String] = ["mississauga", "scarborough", "waterloo", "london"]
    
    class func toString(e:messageType) -> String{
        switch e {
        case .admin:
            return "admin"
        case .trainer:
            return "trainer"
        }
    }
    class func toString(e:courseType) -> String{
        switch e {
        case .general:
            return "general"
        case .multiple:
            return "multiple"
        }
    }
    class func toString(e:courseStatus) -> String{
        switch e {
        case .waitForStudent:
            return "waitForStudent"
        case .approved:
            return "approved"
        case .scaned:
            return "scaned"
        case .ill:
            return "ill"
        case .noStudent:
            return "noStudent"
        case .noTrainer:
            return "noTrainer"
        case .noCard:
            return "noCard"
        case .other:
            return "other"
        }
    }
    
    class func toString(e:userRegion) -> String{
        switch e {
        case .Mississauga:
            return "mississauga"
        case .Scarborough:
            return "scarborough"
        case .Waterloo:
            return "waterloo"
        case .London:
            return "london"
        case .All:
            return "all"
        }
    }
    
    class func toString(e:userStatus) -> String{
        switch e {
        case .avaliable:
            return "avaliable"
        case .canceled:
            return "canceled"
        case .signed:
            return "signed"
        case .unsigned:
            return "unsigned"
        }
    }
    
    class func toString(e:userGroup) -> String{
        switch e {
        case .student:
            return "student"
        case .trainer:
            return "trainer"
        case .admin:
            return "admin"
        }
    }
    
    class func toDescription(e:courseStatus) -> String{
        switch e {
        case .waitForStudent:
            return "等待学生同意"
        case .approved:
            return "学生已同意"
        case .scaned:
            return "已扫描"
        case .ill:
            return "学生生病没到"
        case .noStudent:
            return "学生旷课"
        case .noTrainer:
            return "教练未到"
        case .noCard:
            return "没带卡"
        case .other:
            return "其他情况"
        }
    }
    
    class func toDescription(e:userStatus) -> String{
        switch e {
        case .avaliable:
            return "未占用"
        case .canceled:
            return "已注销"
        case .signed:
            return "已注册"
        case .unsigned:
            return "未注册"
        }
    }
    
    
    
    class func toDescription(e:userGroup) -> String{
        switch e {
        case .student:
            return "学生"
        case .trainer:
            return "教练"
        case .admin:
            return "管理员"
        }
    }
    
    class func toDescription(e:userRegion) -> String{
        switch e {
        case .Mississauga:
            return "Mississauga"
        case .Scarborough:
            return "Scarborough"
        case .Waterloo:
            return "Waterloo"
        case .London:
            return "London"
        case .All:
            return "All"
        }
    }
    
    class func toInt(e:userRegion) -> Int{
        switch e {
        case .Mississauga:
            return 0
        case .Scarborough:
            return 2
        case .Waterloo:
            return 1
        case .London:
            return 3
        case .All:
            return 0
        }
    }
    
    class func toInt(i:userStatus) -> Int{
        switch i {
        case .avaliable:
            return 0
        case userStatus.canceled:
            return 3
        case userStatus.signed:
            return 2
        case userStatus.unsigned:
            return 1
        }
    }
    
    class func toUsergroup(s:String) -> userGroup{
        switch s {
        case "student":
            return userGroup.student
        case "trainer":
            return userGroup.trainer
        case "admin":
            return userGroup.admin
        default:
            return userGroup.student
        }
    }
    class func toUserStatus(s:String) -> userStatus{
        switch s {
        case "avaliable":
            return userStatus.avaliable
        case "canceled":
            return userStatus.canceled
        case "signed":
            return userStatus.signed
        case "unsigned":
            return userStatus.unsigned
        default:
            return userStatus.canceled
        }
    }
    class func toUserStatus(i:Int) -> userStatus{
        switch i {
        case 0:
            return userStatus.avaliable
        case 3:
            return userStatus.canceled
        case 2:
            return userStatus.signed
        case 1:
            return userStatus.unsigned
        default:
            return userStatus.canceled
        }
    }
    
    class func toRegion(s:String) -> userRegion{
        switch s {
        case "Mississauga":
            return userRegion.Mississauga
        case "Scarborough":
            return userRegion.Scarborough
        case "Waterloo":
            return userRegion.Waterloo
        case "London":
            return userRegion.London
        case "All":
            return userRegion.All
        case "mississauga":
            return userRegion.Mississauga
        case "scarborough":
            return userRegion.Scarborough
        case "waterloo":
            return userRegion.Waterloo
        case "london":
            return userRegion.London
        case "super":
            return userRegion.All
        default:
            return userRegion.Mississauga
        }
    }
    
    class func toMessageType(s:String) -> messageType{
        switch s {
        case "admin":
            return messageType.admin
        case "trainer":
            return messageType.trainer
        default:
            return messageType.trainer
        }
    }
    
    class func toCourseType(s: String) -> courseType{
        switch s {
        case "multiple":
            return courseType.multiple
        case "general":
            return courseType.general
        default:
            return courseType.general
        }
    }
    
    class func toCourseStatus(s:String) -> courseStatus{
        switch s {
        case "waitForStudent":
            return courseStatus.waitForStudent
        case "approved":
            return courseStatus.approved
        case "scaned":
            return courseStatus.scaned
        case "ill":
            return courseStatus.ill
        case "noStudent":
            return courseStatus.noStudent
        case "noTrainer":
            return courseStatus.noTrainer
        case "noCard":
            return courseStatus.noCard
        case "other":
            return courseStatus.other
        default:
            return courseStatus.other
        }
    }
}
