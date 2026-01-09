# 샘플 웹 애플리케이션

Apache HTTP Server, Tomcat, MariaDB를 Docker Compose로 통합한 3계층 컨테이너 웹 애플리케이션입니다.

## 아키텍처

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Apache HTTP   │    │     Tomcat      │    │    MariaDB      │
│   (리버스 프록시)  │───▶│   (JSP 앱)      │───▶│   (데이터베이스)   │
│   포트: 80       │    │   포트: 8080     │    │   포트: 3306     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 주요 기능

- **웹 계층**: Apache HTTP Server 리버스 프록시
- **애플리케이션 계층**: Tomcat 9 JSP 애플리케이션
- **데이터베이스 계층**: UTF-8 지원 MariaDB
- **외부 API**: 랜덤 강아지 이미지 연동
- **세션 관리**: 데이터베이스 로그인/로그아웃
- **CRUD 기능**: 게시글 작성 및 목록 조회

## 빠른 시작

```bash
# 클론 및 실행
git clone <저장소-URL>
cd sample-App
docker-compose up -d

# 애플리케이션 접속
http://localhost
```

## 서비스 구성

### 웹 서버 (Apache HTTP)
- **컨테이너**: `httpd-test`
- **포트**: 80
- **역할**: Tomcat 리버스 프록시, 외부 API 포워드 프록시

### 애플리케이션 서버 (Tomcat)
- **컨테이너**: `tomcat-test`
- **포트**: 8080
- **역할**: 데이터베이스 연동 JSP 애플리케이션

### 데이터베이스 (MariaDB)
- **컨테이너**: `mariadb-board`
- **포트**: 3306
- **데이터베이스**: `board`
- **기본 계정**: `giho` / `giho0723`

## 환경 변수

### 웹 서비스
- `VHOST_SERVER_NAME`: 가상 호스트명
- `TOMCAT_UPSTREAM_HOST`: Tomcat 컨테이너명
- `TOMCAT_UPSTREAM_PORT`: Tomcat 포트
- `ALLOWED_PROXY_IP`: 프록시 접근 제어

### 애플리케이션 서비스
- `DB_HOST`: 데이터베이스 호스트
- `DB_PORT`: 데이터베이스 포트
- `DB_NAME`: 데이터베이스명
- `DOG_API_URL`: 외부 API 엔드포인트
- `HTTP_PROXY_HOST`: 외부 호출용 프록시 호스트
- `HTTP_PROXY_PORT`: 프록시 포트

### 데이터베이스 서비스
- `MYSQL_ROOT_PASSWORD`: 루트 비밀번호
- `MARIADB_DATABASE`: 데이터베이스명
- `MARIADB_USER`: 애플리케이션 사용자
- `MARIADB_PASSWORD`: 애플리케이션 비밀번호

## 사용법

1. **애플리케이션 접속**: `http://localhost` 접속
2. **강아지 이미지 확인**: 랜덤 강아지 이미지 자동 로드
3. **데이터베이스 로그인**: `giho` / `giho0723` 계정 사용
4. **게시글 작성**: 로그인 후 제목과 내용 입력
5. **게시글 조회**: 모든 게시글 시간순 표시

## 개발 정보

### 파일 구조
```
sample-App/
├── httpd/                 # Apache 설정
│   ├── conf/
│   │   └── httpd.conf.template
│   ├── docker-entrypoint.sh
│   └── Dockerfile
├── mariadb/              # 데이터베이스 설정
│   ├── conf/
│   │   └── charset.cnf
│   ├── init/
│   │   └── 01_create_posts_table.sql
│   └── Dockerfile
├── tomcat9/              # 애플리케이션 서버
│   ├── lib/
│   │   └── mariadb-java-client-3.4.1.jar
│   ├── webapps/ROOT/
│   │   ├── assets/css/
│   │   │   └── app.css
│   │   └── index.jsp
│   ├── Dockerfile
│   └── setenv.sh
└── docker-compose.yaml
```

### 데이터베이스 스키마
```sql
CREATE TABLE posts (
  id      INT AUTO_INCREMENT PRIMARY KEY,
  title   VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  regdate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## 문제 해결

### 일반적인 문제
- **연결 거부**: 모든 컨테이너 실행 상태 확인
- **데이터베이스 로그인 실패**: 계정 정보 및 컨테이너 상태 확인
- **프록시 오류**: 네트워크 설정 및 IP 제한 확인

### 로그 확인
```bash
# 전체 로그
docker-compose logs

# 서비스별 로그
docker-compose logs web
docker-compose logs was
docker-compose logs db
```

### 상태 확인
```bash
# 컨테이너 상태
docker-compose ps

# 데이터베이스 상태
docker-compose exec db mariadb-admin ping -uroot -proot1234
```

## 보안 참고사항

- 데이터베이스 계정 정보는 환경 변수로 관리
- 프록시 접근은 IP 범위로 제한
- 외부 API 호출은 프록시를 통해 라우팅
- 데이터베이스 작업은 세션 기반 인증 사용