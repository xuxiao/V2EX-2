import UIKit
import Marklight
import RxSwift
import RxCocoa
import MobileCoreServices
import SnapKit

class CreateTopicViewController: BaseViewController, TopicService {
    
    // MARK: Constants
    fileprivate struct Limit {
        static let titleMaxCharacter = 120
        static let bodyMaxCharacter = 20000
    }

    private lazy var titleLabel: UILabel = {
        let view = UIInsetLabel()
        view.text = "主题标题"
        view.contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.textAlignment = .left
        view.backgroundColor = .white
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()
    
    private lazy var titleFieldView: UITextField = {
        let view = UITextField()
        view.placeholder = "请输入主题标题(0~120)"
        view.addLeftTextPadding(15)
        view.font = UIFont.systemFont(ofSize: 15)
        view.backgroundColor = .white
        return view
    }()
    
    private lazy var bodyLabel: UIInsetLabel = {
        let view = UIInsetLabel()
        view.text = "正文"
        view.contentInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        view.textAlignment = .left
        view.backgroundColor = .white
        view.font = UIFont.systemFont(ofSize: 14)
        return view
    }()

    private lazy var markdownToolbar: MarkdownInputAccessoryView = {
        let view = MarkdownInputAccessoryView()
        return view
    }()

    private lazy var bodyTextView: UIPlaceholderTextView = {
        let textContainer = NSTextContainer()
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        let view = UIPlaceholderTextView(frame: .zero, textContainer: textContainer)
        view.placeholder = "请输入正文，如果标题能够表达完整内容，则正文可以为空(0~20000)"
        view.textContainerInset = UIEdgeInsets(top: 10, left: 10, bottom: 15, right: 5)
        view.returnKeyType = .done
        view.translatesAutoresizingMaskIntoConstraints = false
        view.font = UIFont.systemFont(ofSize: 15)
        view.keyboardDismissMode = .onDrag
        view.delegate = self
        view.isEditable = true
        view.inputAccessoryView = markdownToolbar
        return view
    }()

    //    private var bodyText: String = ""

    private lazy var textStorage: MarklightTextStorage = {
        let textStorage = MarklightTextStorage()
        textStorage.marklightTextProcessor.codeColor = .orange
        textStorage.marklightTextProcessor.quoteColor = .darkGray
        textStorage.marklightTextProcessor.syntaxColor = .blue
        textStorage.marklightTextProcessor.codeFontName = "Courier"
        textStorage.marklightTextProcessor.fontTextStyle = UIFontTextStyle.subheadline.rawValue
        //        textStorage.marklightTextProcessor.hideSyntax = true
        return textStorage
    }()
    
    private lazy var postTopicBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "发布")
        return view
    }()

    private lazy var previewBarButton: UIBarButtonItem = {
        let view = UIBarButtonItem(title: "预览")
        return view
    }()

    private lazy var imagePicker: UIImagePickerController = {
        let view = UIImagePickerController()
        view.allowsEditing = true
        view.mediaTypes = [kUTTypeImage as String]
        view.sourceType = .photoLibrary
        view.delegate = self
        return view
    }()

    private lazy var selectNodeBtn: UIButton = {
        let view = UIButton()
        view.setImage(#imageLiteral(resourceName: "selectNode"), for: .normal)
        view.setImage(#imageLiteral(resourceName: "selectNode"), for: .selected)
        view.setTitle("选择节点", for: .normal)
        view.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        view.setTitleColor(.black, for: .normal)
        view.sizeToFit()
        view.backgroundColor = .white
        view.contentEdgeInsets = UIEdgeInsetsMake(5, 10, 5, 10)
        view.setCornerRadius = 15
        view.layer.borderColor = Theme.Color.globalColor.cgColor
        view.layer.borderWidth = 0.5
        return view
    }()

    public var nodename: String?

    private var selectNodeBtnBottomConstranit: Constraint?

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "创建新主题"
        edgesForExtendedLayout = []
        titleFieldView.becomeFirstResponder()

        /// 恢复草稿
        if let title = UserDefaults.get(forKey: Constants.Keys.createTopicTitleDraft) as? String {
            titleFieldView.text = title
            titleFieldView.rx.value.onNext(title)
        }

        if let body = UserDefaults.get(forKey: Constants.Keys.createTopicBodyDraft) as? String {
            bodyTextView.text = body
            bodyTextView.rx.value.onNext(body)
        }

        if let nodename = UserDefaults.get(forKey: Constants.Keys.createTopicNodenameDraft) as? String {
            selectNodeBtn.setTitle("  " + nodename, for: .normal)
        }

        markdownToolbar.didSelectedItemHandle = { [weak self] type in
            self?.toolbarClickHandle(type)
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        view.endEditing(true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        UserDefaults.save(at: titleFieldView.text, forKey: Constants.Keys.createTopicTitleDraft)
        UserDefaults.save(at: bodyTextView.text, forKey: Constants.Keys.createTopicBodyDraft)
        if let `nodename` = nodename {
            UserDefaults.save(at: nodename, forKey: Constants.Keys.createTopicNodenameDraft)
        }
    }

    override func setupSubviews() {
        NotificationCenter.default.addObserver(forName: .UITextViewTextDidChange, object: textView, queue: .main) { notification in
            if self.bodyTextView.textStorage.string.hasSuffix("\n") {
                CATransaction.setCompletionBlock({ () -> Void in
                    self.scrollToCaret(self.bodyTextView, animated: false)
                })
            } else {
                self.scrollToCaret(self.bodyTextView, animated: false)
            }
        }

        view.addSubviews(
            titleLabel,
            titleFieldView,
            bodyLabel,
            bodyTextView,
            selectNodeBtn
        )
        navigationItem.rightBarButtonItems = [postTopicBarButton, previewBarButton]

        if let `nodename` = self.nodename {
            selectNodeBtn.setTitle(nodename, for: .normal)
            return
        }
    }

    override func setupConstraints() {
        titleLabel.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        titleFieldView.snp.makeConstraints {
            $0.left.right.equalTo(titleLabel)
            $0.top.equalTo(titleLabel.snp.bottom).offset(1)
            $0.height.equalTo(50)
        }
        
        bodyLabel.snp.makeConstraints {
            $0.left.right.height.equalTo(titleLabel)
            $0.top.equalTo(titleFieldView.snp.bottom).offset(1)
        }
        
        bodyTextView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.top.equalTo(bodyLabel.snp.bottom).offset(1)
        }

        selectNodeBtn.snp.makeConstraints {
            $0.left.equalToSuperview().inset(20)
            selectNodeBtnBottomConstranit = $0.bottom.equalToSuperview().inset(20).constraint
        }
    }

    override func setupRx() {
        
        // 验证输入状态
        titleFieldView.rx
            .text
            .orEmpty
            .flatMapLatest {
                return Observable.just( $0.trimmed.isNotEmpty && $0.trimmed.count <= Limit.titleMaxCharacter )
            }.bind(to: postTopicBarButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)

        bodyTextView.rx
            .text
            .orEmpty
            .map { $0.trimmed.isNotEmpty }
            .bind(to: previewBarButton.rx.isEnabled)
            .disposed(by: rx.disposeBag)
        
        postTopicBarButton.rx
            .tap
            .subscribeNext { [weak self] in
                self?.postTopicHandle()
            }.disposed(by: rx.disposeBag)

        selectNodeBtn.rx
            .tap
            .subscribeNext { [weak self] in
                self?.selectNodeHandle()
        }.disposed(by: rx.disposeBag)


        previewBarButton.rx
            .tap
            .subscribeNext { [weak self] in
                guard let markdownString = self?.bodyTextView.text else {
                    HUD.showText("预览失败，无法读取到正文内容")
                    return
                }
                let previewVC = MarkdownPreviewViewController(markdownString: markdownString)
                let nav = NavigationViewController(rootViewController: previewVC)
                self?.present(nav, animated: true, completion: nil)
            }.disposed(by: rx.disposeBag)

        Observable.of(NotificationCenter.default.rx.notification(.UIKeyboardWillShow),
                      NotificationCenter.default.rx.notification(.UIKeyboardWillHide),
                      NotificationCenter.default.rx.notification(.UIKeyboardDidHide)).merge()
            .subscribeNext { [weak self] notification in
                guard let `self` = self else { return }
                guard var userInfo = notification.userInfo,
                    let keyboardRect = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
                let convertedFrame = self.view.convert(keyboardRect, from: nil)
                let heightOffset = self.view.bounds.size.height - convertedFrame.origin.y
                let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as? Double
                self.selectNodeBtnBottomConstranit?.update(offset: -(heightOffset + 20))

                UIView.animate(withDuration: duration!) {
                    self.view.layoutIfNeeded()
                }
            }.disposed(by: rx.disposeBag)
    }
    
    func postTopicHandle() {

        guard bodyTextView.text.count <= Limit.bodyMaxCharacter else {
            HUD.showText("正文内容不能超过 \(Limit.bodyMaxCharacter) 个字符")
            return
        }
        guard let title = titleFieldView.text else {
            HUD.showText("标题不能为空")
            return
        }

        guard let selectedNodename = nodename else {
            selectNodeHandle()
            return
        }
        
        createTopic(nodename: selectedNodename, title: title, body: bodyTextView.text, success: { [weak self] in
            HUD.showText("发布成功")
            self?.titleFieldView.text = nil
            self?.bodyTextView.text = nil
            UserDefaults.remove(forKey: Constants.Keys.createTopicTitleDraft)
            UserDefaults.remove(forKey: Constants.Keys.createTopicBodyDraft)
            UserDefaults.remove(forKey: Constants.Keys.createTopicNodenameDraft)
        }) { error in
            HUD.showText(error)
        }
    }

    private func toolbarClickHandle(_ type: MarkdownItemType) {

        if let mark = type.mark {
            bodyTextView.insertText(mark)
        }

        var range = bodyTextView.selectedRange
        if let location = type.location {
            range.location -= location
        }

        switch type {
        case .closeKeyboard:
            bodyTextView.resignFirstResponder()
        case .undo:
            bodyTextView.undoManager?.undo()
        case .redo:
            bodyTextView.undoManager?.redo()
        case .leftMove:
            range.location -= 1
        case .rightMove:
            range.location += 1
        case .image:
            present(imagePicker, animated: true, completion: nil)
        case .clear:
            bodyTextView.text = nil
        default:
            break
        }
        bodyTextView.selectedRange = range
    }

    // 上传配图请求
    private func uploadPictureHandle(_ fileURL: String) {
        HUD.show()
        uploadPicture(localURL: fileURL, success: { [weak self] url in
            self?.bodyTextView.insertText("![V2EX](\(url))")
            self?.bodyTextView.becomeFirstResponder()
            HUD.dismiss()
        }) { error in
            HUD.dismiss()
            HUD.showText(error)
        }
    }

    private func selectNodeHandle() {

        let allNodeVC = AllNodesViewController()
        allNodeVC.title = "请选择主题节点"
        let nav = NavigationViewController(rootViewController: allNodeVC)
        present(nav, animated: true, completion: nil)

        allNodeVC.didSelectedNodeHandle = { [weak self] node in
            self?.selectNodeBtn.setTitle("  " + node.name, for: .normal)
            self?.nodename = node.name
            self?.view.becomeFirstResponder()
        }
    }
}


// MARK: - Character limit
extension CreateTopicViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        print("Should interact with: \(URL)")
        return true
    }

    func scrollToCaret(_ textView: UITextView, animated: Bool) {
        var rect = textView.caretRect(for: textView.selectedTextRange!.end)
        rect.size.height = rect.size.height + textView.textContainerInset.bottom
        textView.scrollRectToVisible(rect, animated: animated)
    }
}

extension CreateTopicViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        dismiss(animated: true, completion: nil)
        guard var image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        image = image.resized(by: 0.7)
        guard let data = UIImageJPEGRepresentation(image, 0.5) else { return }

        let path = FileManager.document.appendingPathComponent("smfile.png")
        _ = FileManager.save(data, savePath: path)
        uploadPictureHandle(path)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
            self.bodyTextView.becomeFirstResponder()
        }
    }
}
