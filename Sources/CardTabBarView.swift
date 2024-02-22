//
//  CardTabBar.swift
//  CardTabbar
//
//  Created by Yusa Dogru on 25.11.2021.
//

import UIKit

class CardTabBarView: UITabBar {
    fileprivate enum CardTabBarViewUI {
        static let padding: CGFloat = 8
    }
    
    // MARK: - Properties
    var didSelectItemAt: ((_ index: Int) -> Void)?
    private var barItemColor: UIColor = .clear {
        didSet { stackView.arrangedSubviews.forEach { $0.tintColor = barItemColor } }
    }
    fileprivate var barItemBackgroundColor: UIColor? = .clear {
        didSet { stackView.arrangedSubviews.forEach { $0.backgroundColor = barItemBackgroundColor } }
    }
    
    // MARK: - Views
    private lazy var stackView: UIStackView = .build { stackView in
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
    }
    
    private lazy var backgroundShadowView: UIImageView = .build { imageView in
        imageView.image = UIImage(named: "tabbar_bg")
    }
    
    fileprivate lazy var container: UIView = .build()
    
    // MARK: - Override
    override var backgroundColor: UIColor? {
        set { backgroundShadowView.tintColor = newValue }
        get { return backgroundShadowView.tintColor }
    }
    
    override var tintColor: UIColor! {
        set { barItemColor = newValue }
        get { return barItemColor }
    }
        
    override var barTintColor: UIColor? {
        set { container.backgroundColor = newValue }
        get { return container.backgroundColor }
    }
    
    var isArabicLanguage: Bool? = false
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func layoutSubviews() {
        super.layoutSubviews()
        container.layer.cornerRadius = container.bounds.height / 2
        addShadow()
    }
    
    override func setItems(_ items: [UITabBarItem]?, animated: Bool) {
        super.setItems(items, animated: animated)
        reloadViews()
    }
    
    // MARK: - UI
    private func setupUI() {
        barTintColor = .barTintColor
        backgroundColor = .backgroundColor
        tintColor = .label
        indicatorColor = .tintColor
        
        backgroundImage = UIImage()
        shadowImage = UIImage()
        setupConstraint()
        
        let userdef = UserDefaults.standard
        let langArray = userdef.object(forKey: "AppleLanguages") as! NSArray
        let current = langArray.firstObject as! String
        if current == "ar" {
            isArabicLanguage = true
        }else {
            isArabicLanguage = false
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView?
      {
        guard !clipsToBounds && !isHidden && alpha > 0 else { return nil }
        for member in subviews.reversed()
        {
            let subPoint = member.convert(point, from: self)
            guard let result = member.hitTest(subPoint, with: event)
            else { continue }
            return result
        }
        return nil
      }
    
    private func setupConstraint() {
        addSubview(backgroundShadowView)
        addSubview(container)
        container.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: leadingAnchor, constant: CardTabBarViewUI.padding),
            container.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -CardTabBarViewUI.padding),
            container.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -CardTabBarViewUI.padding),
            container.heightAnchor.constraint(equalToConstant: 60),
            
            stackView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            stackView.topAnchor.constraint(equalTo: container.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: CardTabBarViewUI.padding),
            stackView.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -CardTabBarViewUI.padding),
            
            backgroundShadowView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundShadowView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundShadowView.bottomAnchor.constraint(equalTo: bottomAnchor),
            backgroundShadowView.topAnchor.constraint(equalTo: topAnchor, constant: -40)
        ])
    }
    
    func select(at index: Int) {
        UIView.animate(withDuration: 0.14) {
            for (_index, view) in self.stackView.arrangedSubviews.enumerated() {
                guard let barItemView = view as? BarItemView else { return }
                if index == 1 {
                    barItemView.isCart = true
                }else {
                    barItemView.isCart = false
                }
                barItemView.isSelected = _index == index
                
                if barItemView.isSelected {
                    barItemView.tintColor = self.tintColor
                }else {
                    barItemView.tintColor = self.unselectedItemTintColor
                }
            }
            self.layoutIfNeeded()
        }
    }
    
    private func reloadViews() {
        subviews.filter { String(describing: type(of: $0)) == "UITabBarButton" }.forEach { $0.removeFromSuperview() }
        stackView.removeAllArrangedSubviews()
        
        guard let items = items else { return }
        
        for (index, item) in items.enumerated() {
            addButton(with: item, tag: index)
        }
    }
    
    private func addButton(with item: UITabBarItem, tag: Int) {
        let buttonView = BarItemView(item: item)
        buttonView.tintColor = barItemColor
        buttonView.button.tag = tag

        buttonView.button.addTarget(self, action: #selector(buttonTapped(sender:)), for: .touchUpInside)
        
        let tappy = UITapGestureRecognizer(target: self, action: #selector(CardTabBarView.tapFunction))
        buttonView.labelTitle.isUserInteractionEnabled = true
        buttonView.labelTitle.addGestureRecognizer(tappy)
        buttonView.labelTitle.tag = tag
        buttonView.labelTitle.font = UIFont(name: "NotoSansArabicCondensed-Medium", size: 14)
        buttonView.labelTitle.semanticContentAttribute = (isArabicLanguage ?? false) ? .forceRightToLeft : .forceLeftToRight
        buttonView.labelTitle.textAlignment = (isArabicLanguage ?? false) ? .right : .left
        tappy.view?.largeContentTitle = "\(tag)"
        
        if selectedItem != nil && item === selectedItem {
            buttonView.isSelected = true
        } else {
            buttonView.isSelected = false
        }
        
        stackView.addArrangedSubview(buttonView)
    }
    
    private func addShadow() {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 13
        layer.shadowOpacity = 0.05
    }
    
    // MARK: - Actions
    @objc func buttonTapped(sender: BarButton) {
        let index = sender.tag
        guard let item = items?[index] else { return }
        
        didSelectItemAt?(index)
        delegate?.tabBar?(self, didSelect: item)
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        let index = Int(sender.view?.largeContentTitle ?? "") ?? 0
        guard let item = items?[index] else { return }
        
        didSelectItemAt?(index)
        delegate?.tabBar?(self, didSelect: item)
    }
    
}


public extension UITabBar {
    var indicatorColor: UIColor? {
        set { (self as? CardTabBarView)?.barItemBackgroundColor = newValue }
        get { return (self as? CardTabBarView)?.barItemBackgroundColor }
    }
    
    var bottomInset: CGFloat {
        set { }
        get {
            guard let bar = self as? CardTabBarView else { return 0 }
            
            let containerHeight = bar.container.frame.height
            let tabHeight = frame.height - safeAreaInsets.bottom
            let buff: CGFloat = 8
            
            return buff + containerHeight + CardTabBarView.CardTabBarViewUI.padding - tabHeight
        }
    }
}
