# RefreshCollectionProject
Global Bottom Indicator을 지원하기 위한 Custom UICollectionView

현재 버전으로 Scroll Direction - Vertical만 지원

<br>

## RefreshCollectionView 구조
![RefreshCollectionView1](https://user-images.githubusercontent.com/79794944/204951389-76773f84-44cc-48fe-a660-2ffaabaa9898.jpg)
![RefreshCollectionView2](https://user-images.githubusercontent.com/79794944/204951403-a660184a-0a71-49b4-a8f7-69ded8208bb0.jpg)

## 예시화면
> 스크린 화면보다 CollectionView의 ContentSize가 큰 경우!

![ezgif com-gif-maker-7](https://user-images.githubusercontent.com/79794944/204951093-47153c9c-6b36-48ee-9955-6cb9a89cf361.gif)


> 스크린 화면보다 CollectionView의 ContentSize가 작은 경우!

![ezgif com-gif-maker-6](https://user-images.githubusercontent.com/79794944/204951101-3ac74070-0926-4eb5-a043-3fd937f903c8.gif)

## 구현방법
1. RefreshCollectionView 프로젝트에 추가

![image](https://user-images.githubusercontent.com/79794944/204951998-974b1e85-a0b8-425e-954f-9d08e60effb0.png)


2. Storyboard(or xib) 기준 > UICollectionView 추가 후 Custom Class 설정

![image](https://user-images.githubusercontent.com/79794944/204951771-ed666aa9-023c-43a5-b3f9-715b61f2f031.png)


2-1. IBOutlet 설정 및 UICollectionViewDelegate 설정

(UICollectionViewDataSource 생략) 

```
@IBOutlet weak var collectionView: RefreshCollectionView!

override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    self.collectionView.delegate = self
}
```

3. UICollectionViewDelegate 스크롤 진행시 

```
// MARK: UICollectionViewDelegate
extension RefreshViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.collectionView.isAnimating {
            // request api - pre page
            // 응답 받고 collectionView.hideRefreshControl()
        } else {
            self.collectionView.hideRefreshControl()
        }

        if self.collectionView.isBottomAnimating {
            // request api - next page
            // 응답 받고 collectionView.hideBottomView()
        } else {
            self.collectionView.hideBottomView()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // scroll offset 변경 사항을 전달
        self.collectionView.changedContentOffset()
    }
}
```

🙌
