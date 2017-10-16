import UIKit

class TopicCell: BaseTableViewCell {

    private lazy var avatarView: UIImageView = {
        return UIImageView()
    }()
    
    private lazy var usernameLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 16)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 17)
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var nodeLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.hex(0x999999)
        return view
    }()
    
    private lazy var lastReplyLabel: UILabel = {
        let view = UILabel()
        view.font = UIFont.systemFont(ofSize: 14)
        view.textColor = UIColor.hex(0x999999)
        return view
    }()
    
    override func initialize() {
        selectionStyle = .none

        contentView.addSubviews(
            avatarView,
            usernameLabel,
            nodeLabel,
            titleLabel,
            lastReplyLabel
        )
    }
    
    override func setupConstraints() {
        
        avatarView.snp.makeConstraints {
            $0.left.top.equalToSuperview().inset(15)
            $0.size.equalTo(48)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.left.equalTo(avatarView.snp.right).offset(10)
            $0.centerY.equalTo(avatarView)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(15)
            $0.top.equalTo(avatarView.snp.bottom).offset(15)
        }
        
        nodeLabel.snp.makeConstraints {
            $0.left.bottom.equalToSuperview().inset(15)
            $0.top.equalTo(titleLabel.snp.bottom).offset(15)
        }
        
        lastReplyLabel.snp.makeConstraints {
            $0.left.equalTo(nodeLabel.snp.right)
            $0.centerY.equalTo(nodeLabel)
        }
    }
    
    var topic: TopicModel? {
        didSet {
            guard let `topic` = topic else { return }
            avatarView.setRoundImage(urlString: topic.user.avatarNormalSrc)
            usernameLabel.text = topic.user.username
            titleLabel.text = topic.title
            let lastReplyTime = (topic.lastReplyTime != nil) ? "  •  " + topic.lastReplyTime! : ""
            lastReplyLabel.text = lastReplyTime + "  •  \(topic.replyCount) 回复"
            
            guard let node = topic.node else { return }
            nodeLabel.text = node.name
        }
    }

    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.size.height -= 10
            newFrame.origin.y += 10
            super.frame = newFrame
        }
    }
}
