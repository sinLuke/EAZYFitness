import Firebase

protocol refreshableVC: class {
    func refresh()
    func reload()
}

protocol credentialReciever: class {
    func callBack(authCredential:AuthCredential)
}
