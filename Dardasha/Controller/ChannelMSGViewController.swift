//
//  ChannelMSGViewController.swift
//  Dardasha
//
//  Created by Ahmed on 10/01/2023.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Gallery
import RealmSwift

class ChannelMSGViewController: MessagesViewController {
    
    //custom view for title
    let leftBarButtonView: UIView = {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
    }()
//    let titleLabel: UILabel = {
//        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 100, height: 25))
//        title.textAlignment = .left
//        title.font = UIFont.systemFont(ofSize: 60, weight: .medium)
//        title.adjustsFontSizeToFitWidth = true
//        return title
//    }()
//    let subTitleLabel: UILabel = {
//        let subTitle = UILabel(frame: CGRect(x: 5, y: 22, width: 100, height: 25))
//        subTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
//        subTitle.textColor = .systemGray
//        subTitle.adjustsFontSizeToFitWidth = true
//        subTitle.textAlignment = .left
//        return subTitle
//    }()
    
    var channel: Channel!
    
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    let refreshController = UIRefreshControl()
    let micButton = InputBarButtonItem()
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)

    var mkMessages = [MKMessage]()
    var allLocalMessages: Results<LocalMessage>!
    let realm = try! Realm()
    
    var notificationToken : NotificationToken?
    
    var displayMessagesCount = 0 {
        didSet{
            self.messagesCollectionView.scrollToLastItem()
        }
    }
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
//    var typingCounter = 0
    
    var gallery : GalleryController!
    
    var longPressGesture: UILongPressGestureRecognizer!
    
    var audioFileName = ""
    var audioStartTime = Date()
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    init(channel: Channel){
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        
        self.channel = channel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureGestureRecognizer()
        configureMessageCollectionView()
        configureMessageInputBar()
        configureCustomTitle()
        
        loadMessages()
        listenForNewMessages()
//        listenForReadStatusUpdates()
//        createTypingObserver()
        tabBarController?.tabBar.isHidden = true
        navigationItem.largeTitleDisplayMode = .never
    }
    
    
    // MARK: - UIScroll
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayMessagesCount < allLocalMessages.count {
                self.insertMoreMKMessages()
                messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
        refreshController.endRefreshing()
    }
    
    
    // MARK: - Func
    private func configureMessageCollectionView(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
//        maintainPositionOnInputBarHeightChanged = true
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func configureMessageInputBar(){
        messageInputBar.isHidden = channel.adminId != User.currentId
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "paperclip", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        attachButton.onTouchUpInside { item in
            self.actionAttachMessage()
        }
        
        micButton.image = UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        // add gesture
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        //show mic button
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    func updateMicButtonStatus(show: Bool){
        if show {
            //mic button
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        }else {
            //send button
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    private func loadMessages(){
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: "date", ascending: true)
        
        if allLocalMessages.isEmpty {
            checkForOldMessages()
        }
        
        notificationToken = allLocalMessages.observe({ (change: RealmCollectionChange) in
            
            switch change {
                
            case .initial:
                self.insertMKMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                
            case .update(_, _, let insertions, _):
                for index in insertions {
                    self.insertMKMessage(localMessage: self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(at: .bottom, animated: true)
                }
                
            case .error(let error):
                print(error.localizedDescription)
            }
        })
    }
    
    private func insertMKMessage(localMessage: LocalMessage){
//        markMessageAsRead(localMessage)
        let incoming = Incoming(messageViewController: self)
        let mkMessage = incoming.createMKMessage(localMessage: localMessage)
        self.mkMessages.append(mkMessage)
        displayMessagesCount += 1
    }
    
    private func insertMKMessages(){
        maxMessageNumber = allLocalMessages.count - displayMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in minMessageNumber ..< maxMessageNumber {
            insertMKMessage(localMessage: allLocalMessages[i])
        }
    }
    
    private func insertMoreMKMessage(localMessage: LocalMessage){
        let incoming = Incoming(messageViewController: self)
        let mkMessage = incoming.createMKMessage(localMessage: localMessage)
        self.mkMessages.insert(mkMessage, at: 0)
        displayMessagesCount += 1
    }
    
    private func insertMoreMKMessages(){
        maxMessageNumber = minMessageNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertMoreMKMessage(localMessage: allLocalMessages[i])
        }
    }
    
    private func checkForOldMessages(){
        FMessageListener.shared.checkForOldMessages(documentId: User.currentId, collectionId: chatId)
    }
    
    private func listenForNewMessages(){
        FMessageListener.shared.listenForNewMessages(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    //Configure custom title
    func configureCustomTitle(){
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonPressed))]
        
//        leftBarButtonView.addSubview(titleLabel)
//        leftBarButtonView.addSubview(subTitleLabel)
//
//        let leftBarButtinItem = UIBarButtonItem(customView: leftBarButtonView)
//
//        self.navigationItem.leftBarButtonItems?.append(leftBarButtinItem)
//        titleLabel.text = recipientName
        
        self.title = channel.name
    }
    
    @objc func backButtonPressed(){
        // TODO: remove listener
        removeListeners()
        FChatRoomListener.shared.clearUnreadCounterUsingChatRoomId(chatRoomId: chatId)
        tabBarController?.tabBar.isHidden = false
        navigationController?.popViewController(animated: true)
    }
    
//    func updateTypingIndicator(_ show: Bool){
//        subTitleLabel.text = show ? "Typing..." : ""
//    }
//
//    func startTypingIndicator(){
//        typingCounter += 1
//        FTypingListener.shared.saveTypingCounter(typing: true, chatRoomId: chatId)
//
//        //Stop typing
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//            self.stopTypingIndicator()
//        }
//    }
//
//    func stopTypingIndicator(){
//        typingCounter -= 1
//        if typingCounter == 0 {
//            FTypingListener.shared.saveTypingCounter(typing: false, chatRoomId: chatId)
//        }
//    }
//
//    func createTypingObserver(){
//        FTypingListener.shared.createTypingObserver(chatRoomId: chatId) { isTyping in
//            DispatchQueue.main.async {
//                self.updateTypingIndicator(isTyping)
//            }
//        }
//    }
    
    private func markMessageAsRead(_ localMessage: LocalMessage){
        if localMessage.senderId != User.currentId {
            FMessageListener.shared.updateMessageStatus(message: localMessage, userId: recipientId)
        }
    }
    
//    private func updateReadStatus(_ updatedLocalMessage: LocalMessage){
//        for index in 0 ..< mkMessages.count {
//            let tempMessage = mkMessages[index]
//            if updatedLocalMessage.id == tempMessage.messageId {
//                mkMessages[index].status = updatedLocalMessage.status
//                mkMessages[index].readDate = updatedLocalMessage.readDate
//
//                RealmManager.shared.save(updatedLocalMessage)
//
//                if mkMessages[index].status == kREAD {
//                    self.messagesCollectionView.reloadData()
//                }
//            }
//        }
//    }
//
//    private func listenForReadStatusUpdates(){
//        FMessageListener.shared.listenForReadStatus(User.currentId, collectionId: chatId) { updatedMessage in
//            self.updateReadStatus(updatedMessage)
//        }
//    }
    
    private func configureGestureRecognizer(){
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recoredAndSend))
    }
    
    @objc func recoredAndSend(){
        switch longPressGesture.state {
        case .began:
            micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            // recored and start
            audioFileName = Date().stringDate()
            audioStartTime = Date()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
            
        case .ended:
            micButton.image = UIImage(systemName: "mic", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
            // stop recored
            AudioRecorder.shared.finishRecording()
            // send audio message
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                let audioDuration = audioStartTime.interval(ofComponent: .second, to: Date())
                send(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioDuration)
            }
        case .possible:
            break
        case .changed:
            break
        case .cancelled:
            break
        case .failed:
            break
        @unknown default:
            break
        }
    }
    
    // MARK: - Helper
    private func lastMessageDate() -> Date {
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1 , to: lastMessageDate) ?? lastMessageDate
    }
    
    private func removeListeners(){
//        FTypingListener.shared.removeTypingListener()
        FMessageListener.shared.removeNewMessgaeListener()
    }
    
    // MARK: - Actions
    func send(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String? , audioDuration: Float = 0.0){
        
//        Outgoing.sendMessage(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [User.currentId, recipientId])
        Outgoing.sendChannelMessage(channel: channel, text: text, photo: photo, video: video, audio: audio, location: location)
    }
    
    private func actionAttachMessage(){
        messageInputBar.inputTextView.resignFirstResponder()
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: "Camera", style: .default) { alert in
            //show camera
            self.showImageGallery(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: "Library", style: .default) { alert in
            //show library
            self.showImageGallery(camera: false)
        }
        
        let shareLocation = UIAlertAction(title: "Location", style: .default) { alert in
            //show location
            if let _ = LocationManager.shared.currentLocation {
                self.send(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true)
    }

    // MARK: - Gallery
    private func showImageGallery(camera: Bool){
        gallery = GalleryController()
        gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 100
        
        self.present(gallery, animated: true)
    }
    
}

extension ChannelMSGViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        // TODO: send photo image
        if images.count > 0 {
            images.first!.resolve { image in
                self.send(text: nil, photo: image, video: nil, audio: nil, location: nil)
            }
        }
        
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        self.send(text: nil, photo: nil, video: video, audio: nil, location: nil)
        controller.dismiss(animated: true)
    }
    
    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true)
    }
    
}


