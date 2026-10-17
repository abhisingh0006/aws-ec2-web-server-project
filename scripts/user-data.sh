#!/bin/bash
set -euxo pipefail

# Bootstrap Apache on Amazon Linux 2023 and publish the demo page.
dnf update -y
dnf install -y httpd
systemctl enable --now httpd

cat > /var/www/html/index.html <<'HTML'
<!doctype html>
<html lang="en">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>My AWS Web Server</title>
  <style>
    body{margin:0;min-height:100vh;display:grid;place-items:center;background:#07152e;color:#f4f7ff;font-family:system-ui,Arial,sans-serif;text-align:center}
    main{max-width:720px;padding:32px}
    h1{font-size:clamp(36px,6vw,60px)}
    span{color:#7dd3fc}
    p{color:#cbd5e1;line-height:1.8}
    .badge{display:inline-block;border:1px solid #38bdf855;border-radius:24px;padding:9px 15px;color:#7dd3fc}
  </style>
</head>
<body>
  <main>
    <div class="badge">AWS EC2 · Apache</div>
    <h1>Welcome to My <span>AWS Web Server!</span></h1>
    <p>Hosted on Amazon EC2 using Apache HTTP Server on Amazon Linux 2023.</p>
  </main>
</body>
</html>
HTML
