# Vulnerable Swift/Vapor Application

**⚠️ WARNING: Intentionally vulnerable - NEVER deploy to production!**

Intentionally vulnerable Swift/Vapor application for testing security tools and training.

## 🎯 Purpose

- **200+ dependency vulnerabilities**
- **18 code-level vulnerabilities** (OWASP Top 10)
- Realistic vulnerable patterns in Swift

## 📊 Vulnerabilities

### Dependencies (SCA)
- **30+ vulnerable Swift packages** from 2019
- Vapor 3.3.0, JWT 3.1.0, Alamofire 4.9.0
- Expected **200+ total vulnerabilities**

### Code (SAST) - 18 Vulnerabilities

1. SQL Injection - main.swift:82
2. Command Injection - main.swift:95
3. Path Traversal - main.swift:115
4. XSS - main.swift:137
5. SSRF - main.swift:147
6. Mass Assignment - main.swift:167
7. IDOR - main.swift:185
8. Missing Authentication - main.swift:205
9. Sensitive Data Exposure - main.swift:218
10. Open Redirect - main.swift:234
11. Weak Cryptography - main.swift:246
12. Insecure Randomness - main.swift:258
13. Hardcoded Credentials - main.swift:11-15, 268
14. Information Exposure - main.swift:284
15. Missing Rate Limiting - main.swift:295
16. Global Mutable State - main.swift:34
17. Debug Mode - Enabled
18. Exposed Secrets - .env

## 🚀 Setup

```bash
git clone https://github.com/YOUR_USERNAME/vulnerable-swift-app.git
cd vulnerable-swift-app

swift build
swift run
```

Access: `http://localhost:8080`

## 🔍 Testing

```bash
snyk test
# Expected: 200+ vulnerabilities
```

## 📚 Endpoints

- POST /api/login - SQL Injection
- GET /api/exec?cmd=ls - Command Injection
- GET /api/files?filename=test.txt - Path Traversal
- GET /api/search?query=test - XSS
- GET /api/proxy?url=http://example.com - SSRF
- POST /api/register - Mass Assignment
- GET /api/users/:id - IDOR
- DELETE /api/admin/users/:id - Missing Auth
- GET /api/debug - Sensitive Data Exposure
- And 6 more...

## ⚠️ Security Notice

Educational use only. DO NOT deploy to production.

MIT License - Testing purposes only.
