# 견적서 API 서버

Flutter 앱에서 견적서를 서버에 저장/조회할 때 사용하는 간단한 REST API 서버입니다.

## 실행 방법

```bash
cd server
npm install
npm start
```

서버는 기본적으로 `http://localhost:3000`에서 실행됩니다.

## API

- `GET /estimates` - 견적서 목록 조회
- `POST /estimates` - 견적서 저장 (JSON body)
- `DELETE /estimates/:id` - 견적서 삭제

데이터는 `server/estimates.json` 파일에 저장됩니다.
