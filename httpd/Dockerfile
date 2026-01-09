FROM httpd:2.4-alpine

# envsubst 설치 (gettext 패키지에 포함)
RUN apk add --no-cache gettext

# 템플릿 conf 복사
COPY conf/httpd.conf.template /usr/local/apache2/conf/httpd.conf.template

# entrypoint 스크립트 복사
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# 실행 권한
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# 컨테이너 시작 시 템플릿 → 실제 conf 생성 후 httpd 실행
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

EXPOSE 80

