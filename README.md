# tweeeter
게으른 자들을 위한 트위터 감상 어플리케이션



### 기능

* 트위터 자동으로 감상하기
* screen name 으로 사용자 검색
* 트위터의 상세 내용까지는 들어갈 필요가 없을 거 같아 특정 디테일뷰는 만들지 않았고, 대신 UISearchController를 이용한 간단한 사용자 검색기능을 넣었습니다.

#### 사용 라이브러리

* swiflint -> 코드 컨벤션 맞춤
* RxSwift, RxCocoa -> ViewModel과 View의 바인딩에 사용합니다.
* RxText -> Rx 스트림에 대한 테스트 코드 작성을 위해 사용합니다.
* SDWebImage -> 이미지 캐싱을 위해 사용합니다.
* SnapKit -> Autolayout을 편하게 사용하기 위해 사용합니다.
* FlexLayout, PinLayout -> CSS Flex Box 형식을 빌려온 라이브러리로 오토레이아웃보다 빠르고 위의 SnapKit보다 편한 부분이 있습니다.
* FLEX -> 뷰의 디버깅에 편한 여러가지 유틸리티 기능을 가지고 있습니다.