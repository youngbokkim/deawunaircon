# Firebase로 견적서 저장하기

이 프로젝트는 견적서 데이터를 **Firebase Firestore**에 저장합니다. (기존 Vercel API 방식에서 변경됨)

## 1. Firebase 프로젝트 만들기

1. [Firebase Console](https://console.firebase.google.com/) 접속 후 로그인
2. **프로젝트 추가** → 프로젝트 이름 입력(예: deawunaircon) → 생성
3. **Firestore Database** 메뉴 → **데이터베이스 만들기** → **테스트 모드**로 시작(나중에 규칙 수정 가능) → 리전 선택 후 사용 설정

## 2. Flutter 앱에 Firebase 연결

1. Firebase Console에서 **프로젝트 설정**(휴지통 옆 톱니바퀴) → **일반** 탭
2. **내 앱**에서 **웹(</>)** 아이콘 클릭 → 앱 닉네임 입력(예: ac_estimate_web) → **앱 등록**
3. **Firebase SDK** 설정 화면은 닫아도 됨(FlutterFire CLI가 처리)

4. 터미널에서 **FlutterFire CLI** 설치 및 설정:
   ```bash
   # 한 번만 실행
   dart pub global activate flutterfire_cli

   # 프로젝트 루트에서 실행 (Firebase 로그인 후)
   cd /경로/deawunaircon
   dart run flutterfire_cli configure
   ```
5. `flutterfire configure` 실행 시:
   - Firebase 로그인 안 되어 있으면 `firebase login` 먼저 실행
   - 생성한 Firebase 프로젝트 선택
   - 플랫폼으로 **Web** 선택
   - 완료되면 `lib/firebase_options.dart`가 자동 생성·덮어쓰기됨

## 3. Firestore 보안 규칙 (선택)

Firebase Console → **Firestore Database** → **규칙** 탭에서 아래처럼 설정할 수 있습니다.

- **테스트/개발용** (모두 허용, 나중에 꼭 제한 권장):
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /estimates/{document=**} {
        allow read, write: if true;
      }
    }
  }
  ```

- **운영용** 예시 (인증된 사용자만):
  ```
  allow read, write: if request.auth != null;
  ```

## 4. 실행

```bash
flutter pub get
flutter run -d chrome
```

브라우저에서 견적서를 저장하면 Firestore **estimates** 컬렉션에 문서가 생성됩니다.

## 참고

- 견적서 저장은 Firestore만 사용합니다.
- `lib/config/api_config.dart`는 더 이상 사용하지 않습니다.
