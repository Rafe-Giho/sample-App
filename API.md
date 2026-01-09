# API 문서

## 애플리케이션 엔드포인트

### 메인 페이지
- **URL**: `/`
- **메서드**: `GET`
- **설명**: 메인 페이지 로드 (강아지 이미지, 로그인 폼, 게시글 목록)

### 데이터베이스 로그인
- **URL**: `/`
- **메서드**: `POST`
- **파라미터**:
  - `action`: `dblogin`
  - `dbuser`: 데이터베이스 사용자명
  - `dbpass`: 데이터베이스 비밀번호
- **응답**: 성공 시 메인 페이지 리다이렉트

### 데이터베이스 로그아웃
- **URL**: `/`
- **메서드**: `POST`
- **파라미터**:
  - `action`: `dblogout`
- **응답**: 세션 무효화 후 메인 페이지 리다이렉트

### 게시글 작성
- **URL**: `/`
- **메서드**: `POST`
- **파라미터**:
  - `action`: `post`
  - `title`: 게시글 제목
  - `content`: 게시글 내용
- **인증**: 데이터베이스 로그인 필요
- **응답**: 성공 시 메인 페이지 리다이렉트 (PRG 패턴)

## 외부 API

### Dog API
- **URL**: `https://dog.ceo/api/breeds/image/random`
- **메서드**: `GET`
- **프록시**: Apache HTTP Server를 통해 호출
- **응답**: JSON 형태의 랜덤 강아지 이미지 URL

## 데이터베이스 스키마

### posts 테이블
```sql
CREATE TABLE posts (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  title   VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 환경 설정

### 필수 환경 변수
- `DB_HOST`: 데이터베이스 호스트
- `DB_PORT`: 데이터베이스 포트
- `DB_NAME`: 데이터베이스명
- `DOG_API_URL`: 외부 API URL
- `HTTP_PROXY_HOST`: 프록시 호스트
- `HTTP_PROXY_PORT`: 프록시 포트