import UIKit

enum courseStatus {
    case decline
    case waitForTrainer
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
    case other
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
        case .decline:
            return "decline"
        case .waitForTrainer:
            return "waitForTrainer"
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
        case .decline:
            return "学生已拒绝"
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
        case .waitForTrainer:
            return "等待教练同意"
        }
    }
    
    class func toColor(e:courseStatus) -> UIColor{
        switch e {
        case .decline:
            return HexColor.Red
        case .waitForStudent:
            return UIColor.gray
        case .approved:
            return HexColor.Blue
        case .scaned:
            return HexColor.Green
        case .ill:
            return HexColor.Red
        case .noStudent:
            return HexColor.Red
        case .noTrainer:
            return HexColor.Red
        case .noCard:
            return HexColor.Red
        case .other:
            return HexColor.Purple
        case .waitForTrainer:
            return UIColor.gray
        }
    }
    
    class func toDescription(d:[courseStatus]) -> String{
        if d.count == 1{
            return enumService.toDescription(e: d[0])
        } else {
            var allWaitForTrainer = true
            var allWaitForStudent = true
            var existWaitForStudent = false
            var allApproved = true
            var existApproved = true
            var allScaned = true
            var allNoTrainer = true
            var existException = false
            var existScanned = false
            for e in d{
                switch e {
                case .decline:
                    return "有学生拒绝"
                case .waitForTrainer:
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                case .waitForStudent:
                    allWaitForTrainer = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existWaitForStudent = true
                case .approved:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allScaned = false
                    allNoTrainer = false
                    existApproved = true
                case .scaned:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allNoTrainer = false
                    existScanned = true
                case .ill:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existException = true
                case .noStudent:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existException = true
                case .noTrainer:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    existException = true
                case .noCard:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existException = true
                case .other:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existException = true
                }
            }
            if existException{
                return "有特殊情况"
            } else if allWaitForTrainer {
                return "等待教练同意"
            } else if allWaitForStudent {
                return "等待所有学生同意"
            } else if allApproved {
                return "所有学生已同意"
            } else if existWaitForStudent {
                return "有学生尚未同意"
            } else if allScaned {
                return "已全部扫描"
            } else if allNoTrainer {
                return "教练未到"
            } else if ((existScanned || existException) && existWaitForStudent){
                return "有人未同意但有人已扫码"
            } else if ((existScanned || existException) && existApproved){
                return "没有全部扫码"
            } else {
                return "未知情况"
            }
        }
    }
    
    class func toColor(d:[courseStatus]) -> UIColor{
        if d.count == 1{
            return enumService.toColor(e: d[0])
        } else {
            var allWaitForTrainer = true
            var allWaitForStudent = true
            var existWaitForStudent = false
            var allApproved = true
            var existApproved = true
            var allScaned = true
            var allNoTrainer = true
            var existException = false
            var existScanned = false
            for e in d{
                switch e {
                case .decline:
                    return UIColor.red
                case .waitForTrainer:
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                case .waitForStudent:
                    allWaitForTrainer = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existWaitForStudent = true
                case .approved:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allScaned = false
                    allNoTrainer = false
                    existApproved = true
                case .scaned:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allNoTrainer = false
                    existScanned = true
                case .ill:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existException = true
                case .noStudent:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existException = true
                case .noTrainer:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    existException = true
                case .noCard:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existException = true
                case .other:
                    allWaitForTrainer = false
                    allWaitForStudent = false
                    allApproved = false
                    allScaned = false
                    allNoTrainer = false
                    existException = true
                }
            }
            if existException{
                return HexColor.Red
            } else if allWaitForTrainer {
                return UIColor.gray
            } else if allWaitForStudent {
                return UIColor.gray
            } else if allApproved {
                return HexColor.Blue
            } else if existWaitForStudent {
                return UIColor.gray
            } else if allScaned {
                return HexColor.Green
            } else if allNoTrainer {
                return HexColor.Red
            } else if ((existScanned || existException) && existWaitForStudent){
                return HexColor.Yellow
            } else if ((existScanned || existException) && existApproved){
                return HexColor.Yellow
            } else {
                return HexColor.Yellow
            }
        }
    }
    
    class func toDescription(e:userStatus) -> String{
        switch e {
        case .avaliable:
            return "不可用"
        case .canceled:
            return "已注销"
        case .signed:
            return "已注册"
        case .unsigned:
            return "待注册"
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
            return 1
        case .Waterloo:
            return 2
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
        case "all":
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
        case "decline":
            return courseStatus.decline
        case "waitForTrainer":
            return courseStatus.waitForTrainer
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
    
    class func toRequestType(s:String) -> requestType{
        switch s {
        case "studentAddValue":
            return .studentAddValue
        case "studentApproveCourse":
            return .studentApproveCourse
        case "studentRemove":
            return .studentRemove
        case "trainerRemove":
            return .trainerRemove
        case "trainerApproveCourse":
            return .trainerApproveCourse
        default:
            return .other
        }
    }
    
    class func toString(e:requestType) -> String{
        switch e {
        case .studentAddValue:
            return "studentAddValue"
        case .studentApproveCourse:
            return "studentApproveCourse"
        case .studentRemove:
            return "studentRemove"
        case .trainerRemove:
            return "trainerRemove"
        case .trainerApproveCourse:
            return "trainerApproveCourse"
        default:
            return "other"
        }
    }
    
    class func toDescription(e:requestType) -> String{
        switch e {
        case .studentAddValue:
            return "为学生加课的申请"
        case .studentApproveCourse:
            return "添加新课程的申请"
        case .studentRemove:
            return "将学生账户删除的申请"
        case .trainerRemove:
            return "将教练账户删除的申请"
        case .trainerApproveCourse:
            return "为教练添加新课程的申请"
        default:
            return "other"
        }
    }
}
