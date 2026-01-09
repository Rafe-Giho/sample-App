<%@ page language="java"
    contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"
    import="java.sql.*, java.net.*, java.net.http.*, java.io.*" %>

<%
    request.setCharacterEncoding("UTF-8");

    // === 환경변수 읽기 ===
    String dbHost = System.getenv("DB_HOST");
    String dbPort = System.getenv("DB_PORT");
    String dbName = System.getenv("DB_NAME");

    // DB URL 유효성 체크
    boolean dbConfigValid = true;
    String dbConfigError = "";

    if (dbHost == null || dbHost.isBlank()) {
        dbConfigValid = false;
        dbConfigError += "환경변수 DB_HOST 가 설정되지 않았습니다.<br>";
    }
    if (dbPort == null || dbPort.isBlank()) {
        dbConfigValid = false;
        dbConfigError += "환경변수 DB_PORT 가 설정되지 않았습니다.<br>";
    }
    if (dbName == null || dbName.isBlank()) {
        dbConfigValid = false;
        dbConfigError += "환경변수 DB_NAME 가 설정되지 않았습니다.<br>";
    }

    String dbUrl = null;
    if (dbConfigValid) {
        dbUrl = "jdbc:mariadb://" + dbHost + ":" + dbPort + "/" + dbName
            + "?useUnicode=true&characterEncoding=utf8mb4&serverTimezone=Asia/Seoul";
    }

    // DB 드라이버 로딩
    Class.forName("org.mariadb.jdbc.Driver");

    // 세션에서 DB 계정 읽기
    String dbUser  = (String) session.getAttribute("dbUser");
    String dbPass  = (String) session.getAttribute("dbPass");

    String loginError = null;
    boolean isPost = "POST".equalsIgnoreCase(request.getMethod());
    String action  = request.getParameter("action");

    // 로그아웃
    if (isPost && "dblogout".equals(action)) {
        session.invalidate();
        response.sendRedirect(request.getRequestURI());
        return;
    }

    // 로그인
    if (isPost && "dblogin".equals(action)) {
        String inputUser = request.getParameter("dbuser");
        String inputPass = request.getParameter("dbpass");

        if (dbConfigValid == false) {
            loginError = "DB 환경변수(DB_HOST/DB_PORT/DB_NAME) 설정이 올바르지 않아 접속할 수 없습니다.";
        } else if (inputUser != null && inputPass != null
                && !inputUser.isBlank() && !inputPass.isBlank()) {
            try (Connection testConn = DriverManager.getConnection(dbUrl, inputUser, inputPass)) {
                session.setAttribute("dbUser", inputUser);
                session.setAttribute("dbPass", inputPass);
                response.sendRedirect(request.getRequestURI());
                return;
            } catch (Exception e) {
                loginError = "DB 접속 실패: 사용자/비밀번호 또는 권한 오류";
            }
        } else {
            loginError = "DB 사용자와 비밀번호 입력 필요";
        }
    }

    // ===== 게시글 작성/목록 조회용 DB 커넥션 (요청당 1개) =====
    Connection conn = null;
    boolean postInserted = false;

    if (dbUser != null && dbPass != null) {
        try {
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPass);

            // 게시글 등록 (PRG 적용: 성공 시 리다이렉트)
            if (isPost && "post".equals(action)) {
                String title   = request.getParameter("title");
                String content = request.getParameter("content");

                if (title != null && content != null &&
                        !title.isBlank() && !content.isBlank()) {
                    try (PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO posts(title, content) VALUES(?, ?)")) {
                        ps.setString(1, title);
                        ps.setString(2, content);
                        ps.executeUpdate();
                        postInserted = true;
                    }
                }
            }

            if (postInserted) {
                try { conn.close(); } catch (Exception ignore) {}
                conn = null;
                response.sendRedirect(request.getRequestURI());
                return;
            }

        } catch (Exception e) {
            // 아래에서 오류 메시지를 표시할 수 있으므로 로그만 남김
            e.printStackTrace();
        }
    }

    // === Dog API 호출 ===
    String dogApiUrl = System.getenv("DOG_API_URL");
    String dogImg = null;

    if (dogApiUrl != null && !dogApiUrl.isBlank()) {
        try {
            String proxyHost    = System.getenv("HTTP_PROXY_HOST");
            String proxyPortStr = System.getenv("HTTP_PROXY_PORT");

            HttpClient.Builder builder = HttpClient.newBuilder()
                    .connectTimeout(java.time.Duration.ofSeconds(2));

            // 프록시 설정: ConfigMap에서 들어온 값이 있을 때만 적용
            if (proxyHost != null && !proxyHost.isBlank()
                    && proxyPortStr != null && !proxyPortStr.isBlank()) {

                int proxyPort = Integer.parseInt(proxyPortStr);

                java.net.ProxySelector proxySelector =
                        java.net.ProxySelector.of(
                                new java.net.InetSocketAddress(proxyHost, proxyPort)
                        );

                builder.proxy(proxySelector);
            }

            HttpClient client = builder.build();

            HttpRequest req = HttpRequest.newBuilder()
                    .uri(URI.create(dogApiUrl))
                    .GET()
                    .build();

            HttpResponse<String> resp =
                    client.send(req, HttpResponse.BodyHandlers.ofString());

            String body = resp.body();

            int idx = body.indexOf("\"message\":\"");
            if (idx != -1) {
                idx += "\"message\":\"".length();
                int end = body.indexOf("\"", idx);
                if (end != -1) {
                    dogImg = body.substring(idx, end).replace("\\/", "/");
                }
            }
        } catch (Exception e) {
            System.out.println("[Dog API 호출 중 오류] URL=" + dogApiUrl
                               + " / " + e.getClass().getName() + " : " + e.getMessage());
            e.printStackTrace();
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>DB 로그인 + 게시판 + Dog API</title>
    <link rel="stylesheet" href="<%=request.getContextPath()%>/assets/css/app.css">
</head>
<body>
<%
    String webNode = request.getHeader("X-Web-Node");
    if (webNode == null) {
        webNode = "UNKNOWN";
    }
%>
현재 요청을 처리한 WEB 노드: <strong><%= webNode %></strong>
<h2>🐶 랜덤 강아지 이미지</h2>
<img src="<%= dogImg %>" style="width:300px;"><br><br>

<hr>

<!-- ===== DB 로그인 영역 ===== -->
<h2>🔐 DB 로그인</h2>
<%
    if (session.getAttribute("dbUser") == null) {
%>
    <% if (loginError != null) { %>
        <p style="color:red;"><%= loginError %></p>
    <% } %>

    <form method="POST">
        <input type="hidden" name="action" value="dblogin">
        DB 사용자: <input type="text" name="dbuser" required><br>
        DB 비밀번호: <input type="password" name="dbpass" required><br>
        <button type="submit">DB 로그인</button>
    </form>
    <p>예시 계정: 사용자 <b>giho</b>, 비밀번호 <b>giho0723</b></p>

<%
    } else {
%>
    <p>현재 DB 계정: <strong><%= session.getAttribute("dbUser") %></strong> 로 접속 중입니다.</p>
    <form method="POST" style="display:inline;">
        <input type="hidden" name="action" value="dblogout">
        <button type="submit">DB 로그아웃</button>
    </form>
<%
    }
%>

<hr>

<!-- ===== 게시글 작성 영역 ===== -->
<h2>📝 게시글 작성</h2>
<%
    if (dbUser != null && dbPass != null) {
        if (conn != null) {
%>
    <form method="POST">
        <input type="hidden" name="action" value="post">
        제목: <input type="text" name="title" required style="width:300px;"><br>
        내용:<br>
        <textarea name="content" required style="width:300px; height:100px;"></textarea><br>
        <button type="submit">등록</button>
    </form>
<%
        } else {
%>
    <p style="color:red;">DB 연결 중 오류가 발생했습니다. (계정 권한 또는 네트워크 확인 필요)</p>
<%
        }
    } else {
%>
    <p>게시글을 작성하려면 먼저 위에서 <strong>DB 로그인</strong>을 해야 합니다.</p>
<%
    }
%>

<hr>

<h2>📋 게시글 목록</h2>
<table border="1" cellpadding="5">
    <tr>
        <th>ID</th>
        <th>제목</th>
        <th>내용</th>
        <th>등록일</th>
    </tr>
<%
    if (dbUser != null && dbPass != null && conn != null) {
        try (Statement st = conn.createStatement();
             ResultSet rs = st.executeQuery("SELECT * FROM posts ORDER BY id DESC")) {
            while (rs.next()) {
%>
    <tr>
        <td><%= rs.getInt("id") %></td>
        <td><%= rs.getString("title") %></td>
        <td><%= rs.getString("content") %></td>
        <td><%= rs.getString("regdate") %></td>
    </tr>
<%
            }
        } catch (Exception e) {
%>
    <tr><td colspan="4" style="color:red;">게시글 목록 조회 중 오류가 발생했습니다.</td></tr>
<%
            e.printStackTrace();
        }
    } else {
%>
    <tr><td colspan="4">DB 로그인을 해야 게시글 목록을 볼 수 있습니다.</td></tr>
<%
    }
%>
</table>


</body>
</html>
<%
    if (conn != null) {
        try { conn.close(); } catch (Exception ignore) {}
    }
%>
