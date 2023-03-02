import UIKit
import PlaygroundSupport

let catImagesUrl = [
    "http://swiftdeveloperblog.com/wp-content/uploads/2015/07/1.jpeg",
    "https://cf.shopee.com.br/file/ba982c26c0910c0de5be09e34163a370",
    "https://m.media-amazon.com/images/I/619n7dVxFqL._AC_SX466_.jpg",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRhWSuoV5RUZiv4vizlSTEFOJCuA6Db5nwvtA&usqp=CAU",
    "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTzr2nEnzvdK4OxHaU2au8MNxyNqU4TOmy0Jg&usqp=CAU",
    "https://notAImage.com",
    "not a URL"
]

class MyView: UIView {

    var stack: UIStackView
    var imagesUrl: [String]
    var images: [UIImage?]

    convenience init(frame: CGRect, cats: Int) {
        print("\(Date()): Start")
        self.init(frame: frame)
        stack = UIStackView()
        backgroundColor = .black
        
        imagesUrl = []
        for _ in 0..<cats {
            imagesUrl.append(catImagesUrl.randomElement() ?? "")
        }
        images = Array(repeating: nil, count: imagesUrl.count)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        imagesUrl = []
        images = Array(repeating: nil, count: imagesUrl.count)
        stack = UIStackView()
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        layoutStackView()
        addViewsOnStack()
    }
    
    func layoutStackView() {
        addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            stack.topAnchor.constraint(equalTo: self.topAnchor),
            stack.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])

        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fillEqually
    }
    
    func addViewsOnStack() {
        let group = DispatchGroup()
        
        imagesUrl.enumerated().forEach { (index, imageUrlString) in
            group.enter()
            guard let imageUrl:URL = URL(string: imageUrlString) else {
                self.images[index] = UIImage(systemName: "heart.fill")
                group.leave()
                return
            }
            loadImge(withUrl: imageUrl){ [weak self] img in
                guard let self = self else {
                    group.leave()
                    return
                }
                self.images[index] = img
                group.leave()
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let self = self else { return }
            
            for image in self.images {
                var imageView = UIImageView(image: image)
                imageView.contentMode = .scaleAspectFit
                self.stack.addArrangedSubview(imageView)
            }
            print("\(Date()): End")
        }
    }

    func loadImge(withUrl url: URL, completion: @escaping (UIImage) -> Void) {
        DispatchQueue.global().async {
            if let imageData = try? Data(contentsOf: url), let image = UIImage(data: imageData) {
                completion(image)
            } else {
                if let image = UIImage(systemName: "heart") {
                    completion(image)
                }
            }
            
        }
    }

}

// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyView(frame: CGRect(origin: .zero, size: CGSize(width: 400.0, height: 600.0)), cats: 10)
