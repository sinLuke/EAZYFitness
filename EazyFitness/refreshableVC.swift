import Firebase

protocol refreshableVC: class {
    func refresh()
    func reload()
    func endLoading()
    func startLoading()
}

protocol credentialReciever: class {
    func callBack(authCredential:AuthCredential)
}
