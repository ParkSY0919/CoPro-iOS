//
//  PhotoViewController.swift
//  CoPro
//
//  Created by 문인호 on 2/5/24.
//

import Alamofire
import UIKit
import Then
import SnapKit
import Photos
import KeychainSwift
import Alamofire

protocol ImageUploaderDelegate: AnyObject {
    func didUploadImages(with urls: [Int])
}

final class PhotoViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    private enum Const {
        static let numberOfColumns = 3.0
        static let cellSpace = 1.0
        static let length = (UIScreen.main.bounds.size.width - cellSpace * (numberOfColumns - 1)) / numberOfColumns
        static let cellSize = CGSize(width: length, height: length)
        static let scale = UIScreen.main.scale
    }
    
    private let keychain = KeychainSwift()
    let imageUploader = ImageUploader()

    // MARK: UI
    private let submitButton = UIButton(type: .system).then {
        $0.setTitle("완료", for: .normal)
        $0.setTitleColor(.P2(), for: .normal)
        $0.addTarget(self, action: #selector(submitButtonTapped), for: .touchUpInside)
    }
    private let dismissButton = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    private let collectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.scrollDirection = .vertical
            $0.minimumLineSpacing = 1
            $0.minimumInteritemSpacing = 0
            $0.itemSize = Const.cellSize
        }
    ).then {
        $0.isScrollEnabled = true
        $0.showsHorizontalScrollIndicator = false
        $0.showsVerticalScrollIndicator = true
        $0.contentInset = .zero
        $0.backgroundColor = .clear
        $0.clipsToBounds = true
        $0.register(PhotoCell.self, forCellWithReuseIdentifier: PhotoCell.id)
        $0.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CameraCell")
    }
    
    // MARK: Property
    private let albumService: AlbumManager = MyAlbumManager()
    private let photoService: PhotoManager = MyPhotoManager()
    private var selectedIndexArray = [Int]() // Index: count
    private var selectedImages: [PHAsset] = []
    weak var delegate: ImageUploaderDelegate?
    
    // album 여러개에 대한 예시는 생략 (UIPickerView와 같은 것을 이용하여 currentAlbumIndex를 바꾸어주면 됨)
    private var albums = [PHFetchResult<PHAsset>]()
    private var dataSource = [PhotoCellInfo]()
    private var currentAlbumIndex = 0 {
        didSet { loadImages() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadAlbums(completion: { [weak self] in
            self?.loadImages()
        })
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        
        view.addSubviews(dismissButton,submitButton)
        dismissButton.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).offset(10)
        }
        submitButton.snp.makeConstraints {
            $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.top.equalTo(submitButton.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func loadAlbums(completion: @escaping () -> Void) {
        albumService.getAlbums(mediaType: .image) { [weak self] albumInfos in
            self?.albums = albumInfos.map(\.album)
            completion()
        }
    }
    
    private func loadImages() {
        guard currentAlbumIndex < albums.count else { return }
        let album = albums[currentAlbumIndex]
        photoService.convertAlbumToPHAssets(album: album) { [weak self] phAssets in
            self?.dataSource = phAssets.map { .init(phAsset: $0, image: nil, selectedOrder: .none) }
            self?.collectionView.reloadData()
        }
    }
    @objc func dismissButtonTapped() {
        self.dismiss(animated: true)
    }
    @objc func submitButtonTapped() {
            // NotificationCenter를 사용하여 선택된 이미지들을 전달
        NotificationCenter.default.post(name: NSNotification.Name("SelectedImages"), object: nil, userInfo: ["images": selectedImages])
        loadImages(from: selectedImages) { images in
                self.uploadImages(images: images) { urls in
                    self.delegate?.didUploadImages(with: urls)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    func loadImages(from assets: [PHAsset], completion: @escaping ([UIImage]) -> ()) {
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isSynchronous = true
        options.deliveryMode = .highQualityFormat

        var images = [UIImage]()
        for asset in assets {
            manager.requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFit, options: options) { (image, _) in
                if let image = image {
                    images.append(image)
                }
            }
        }
        completion(images)
    }
    func uploadImages(images: [UIImage], completion: @escaping ([Int]) -> Void) {
        let url = URL(string: Config.baseURL)!
        if let token = self.keychain.get("accessToken") {
            let headers : HTTPHeaders = [
                        "Content-Type" : "multipart/form-data",
                        "Authorization": "Bearer \(token)" ]
            AF.upload(multipartFormData: { multipartFormData in
                for (index, image) in images.enumerated() {
                    guard let imageData = image.jpegData(compressionQuality: 1.0) else {
                        print("Could not get JPEG representation of UIImage")
                        return
                    }
                    let sizeInMB = Double(imageData.count) / 1024.0 / 1024.0
                                if sizeInMB > 10.0 { // 크기가 10MB를 초과할 경우
                                    let alertController = UIAlertController(title: "업로드 오류", message: "10MB를 초과하는 이미지는 업로드할 수 없습니다.", preferredStyle: .alert)
                                    alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                                    self.present(alertController, animated: true, completion: nil)
                                    return
                                }
                    print("\(imageData)")
                    multipartFormData.append(imageData, withName: "files", fileName: "image\(index).jpeg", mimeType: "image/jpeg")
                }
            }, to: url.appendingPathComponent("/api/v1/images"), headers: headers)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success:
                    if let data = response.data {
                        do {
                            let decoder = JSONDecoder()
                            let imageData = try decoder.decode(ImageUploadResponse.self, from: data)
                            let urls = imageData.data.map { $0.imageId }
                            completion(urls)
                            print(imageData)
                        } catch {
                            print("Error decoding data: \(error.localizedDescription)")
                        }
                    } else {
                        print("Data is not of 'Data' type.")
                    }
                    case .failure(let error):
                        print("Error uploading images: \(error.localizedDescription)")
                    }
            }
        }
    }
}

extension PhotoViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        dataSource.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.id, for: indexPath) as? PhotoCell
        else { return UICollectionViewCell() }
        let imageInfo = dataSource[indexPath.item]
        let phAsset = imageInfo.phAsset
        let imageSize = CGSize(width: Const.cellSize.width * Const.scale, height: Const.cellSize.height * Const.scale)
        
        photoService.fetchImage(
            phAsset: phAsset,
            size: imageSize,
            contentMode: .aspectFit,
            completion: { [weak cell] image in
                cell?.prepare(info: .init(phAsset: phAsset, image: image, selectedOrder: imageInfo.selectedOrder))
            }
        )
        return cell
    }
}

extension PhotoViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let info = dataSource[indexPath.item ]
        let updatingIndexPaths: [IndexPath]
        
        if case .selected = info.selectedOrder {
            dataSource[indexPath.item] = .init(phAsset: info.phAsset, image: info.image, selectedOrder: .none)
            if let index = selectedImages.firstIndex(of: info.phAsset) {
                        selectedImages.remove(at: index)
                    }
            selectedIndexArray
                .removeAll(where: { $0 == indexPath.item })
            
            selectedIndexArray
                .enumerated()
                .forEach { order, index in
                    let order = order + 1
                    let prev = dataSource[index]
                    dataSource[index] = .init(phAsset: prev.phAsset, image: prev.image, selectedOrder: .selected(order))
                }
            updatingIndexPaths = [indexPath] + selectedIndexArray
                .map { IndexPath(row: $0, section: 0) }
            print(info)
        } else {
            selectedIndexArray
                .append(indexPath.item)
            
            selectedIndexArray
                .enumerated()
                .forEach { order, selectedIndex in
                    let order = order + 1
                    let prev = dataSource[selectedIndex]
                    dataSource[selectedIndex] = .init(phAsset: prev.phAsset, image: prev.image, selectedOrder: .selected(order))
                }
            
            updatingIndexPaths = selectedIndexArray
                .map { IndexPath(row: $0, section: 0) }
            selectedImages.append(info.phAsset)
            print(info)

        }
//        selectedImages = selectedIndexArray.compactMap { dataSource[$0].phAsset }
        print(selectedImages)
        update(indexPaths: updatingIndexPaths)
    }
    private func update(indexPaths: [IndexPath]) {
        collectionView.performBatchUpdates {
            collectionView.reloadItems(at: indexPaths)
        }
    }
}
