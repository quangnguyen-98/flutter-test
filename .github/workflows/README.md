# CI/CD Pipeline for QR App (Flutter)

## 📋 Overview

This CI/CD pipeline automates code quality checks, security scanning, testing, building, and deployment for the QR App Flutter application.

## 🎯 Pipeline Stages

```
Stage 1: Code Quality (flutter analyze, dart format)
    ↓
Stage 2: Security Scanning (OSV Scanner)
    ↓
Stage 3: Testing (flutter test with coverage)
    ↓
Stage 4: Build APK (flutter build apk)
    ↓
Stage 5: Deploy to Staging (Firebase App Distribution)
    ↓
Stage 6: Deploy to Production (Firebase App Distribution + GitHub Release)
```

## 🔧 Tools & Technologies

### Code Quality
- **flutter analyze**: Official static analysis tool
- **dart format**: Official Dart code formatter
- **flutter_lints**: Recommended lints for Flutter apps

### Security
- **OSV Scanner**: Google-maintained vulnerability scanner for pubspec.lock
  - Scans against OSV database (Open Source Vulnerabilities)
  - Free and open source
  - CLI tool installed directly from GitHub releases

### Testing
- **flutter test**: Built-in test runner
- **very_good_coverage**: Coverage threshold checker
  - Min coverage: 0% (increase gradually)
  - Excludes generated files (*.g.dart, *.freezed.dart)

### Build
- **flutter build apk**: Official Android APK builder
- **Java 17**: Required for Android builds
- **Gradle caching**: Speeds up subsequent builds

### Deployment
- **Firebase App Distribution**: APK distribution to testers
- **GitHub Releases**: Production releases with artifacts
- **Slack Notifications**: Success/failure notifications

## 🚀 Workflow Triggers

### Automatic Triggers
- **Push to `main`**: Runs full CI/CD → Production deployment
- **Push to `stg`**: Runs full CI/CD → Staging deployment
- **Push tags `v*`**: Runs CI/CD → Production + GitHub Release
- **Pull Requests**: Runs CI only (no deployment)

### Manual Trigger
- Not configured (can be added via `workflow_dispatch`)

## 📊 Pipeline Flow

### For Pull Requests (PRs)
```yaml
quality + security (parallel) → test → ✅ CI Complete
```

### For Push to `stg` Branch
```yaml
quality + security (parallel) → test → build → deploy-staging → ✅ CD Complete
```

### For Push to `main` Branch
```yaml
quality + security (parallel) → test → build → deploy-production → ✅ CD Complete
```

### For Version Tags (`v*`)
```yaml
quality + security (parallel) → test → build → deploy-production + GitHub Release → ✅ CD Complete
```

## 🔐 Required Secrets

### GitHub Secrets (per environment)

#### Staging Environment
```
FIREBASE_APP_ID       # Firebase App ID for staging
FIREBASE_TOKEN        # Firebase CI token
SLACK_WEBHOOK_URL     # Slack webhook for notifications
```

#### Production Environment
```
FIREBASE_APP_ID       # Firebase App ID for production
FIREBASE_TOKEN        # Firebase CI token
SLACK_WEBHOOK_URL     # Slack webhook for notifications
```

### How to Set Up Secrets

1. **Go to GitHub Repository**
   - Settings → Secrets and variables → Actions

2. **Create Environments**
   - New environment → `staging`
   - New environment → `production`

3. **Add Secrets to Each Environment**
   ```bash
   FIREBASE_APP_ID=1:xxxxx:android:xxxxx
   FIREBASE_TOKEN=xxxxx (from: firebase login:ci)
   SLACK_WEBHOOK_URL=https://hooks.slack.com/services/xxxxx
   ```

## 📦 Artifacts

### Produced Artifacts
- **APK File**: `qr-app-release-{SHA}.apk`
  - Retention: 30 days
  - Available in GitHub Actions UI

- **Coverage Report**: `coverage/lcov.info`
  - Retention: 30 days
  - Can be viewed/downloaded from workflow run

- **Security Report**: `osv-report.json`
  - Retention: 30 days
  - Lists all vulnerabilities found

## 🎯 Coverage Requirements

- **Current**: 0% minimum (start point)
- **Target**: 80% (increase gradually)
- **Excluded Files**:
  - `**/*.g.dart` (generated code)
  - `**/*.freezed.dart` (generated code)
  - `**/generated/**` (generated code)
  - `**/l10n/**` (localization)

## ⚡ Performance Optimizations

### Caching Strategy
```yaml
Flutter SDK: Cached by subosito/flutter-action
Pub Cache: Cached by subosito/flutter-action
Gradle: Cached by actions/setup-java
```

### Parallel Execution
- **Quality** and **Security** stages run in parallel
- Saves ~2-3 minutes per pipeline run

### Expected Times
- Quality: ~1-2 min
- Security: ~1-2 min
- Test: ~3-5 min
- Build: ~5-10 min
- Deploy: ~2-3 min
- **Total**: ~12-20 min (depending on cache hits)

## 🐛 Troubleshooting

### Build Fails with "Gradle error"
```bash
# Clear Gradle cache
rm -rf ~/.gradle/caches
flutter clean
flutter pub get
flutter build apk
```

### Tests Fail Locally but Pass in CI
```bash
# Ensure same Flutter version
flutter --version  # Should match FLUTTER_VERSION in workflow

# Regenerate build_runner code
flutter pub run build_runner build --delete-conflicting-outputs
```

### Coverage Check Fails
```bash
# Run tests with coverage locally
flutter test --coverage

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### OSV Scanner Reports Vulnerabilities
```bash
# Update dependencies
flutter pub upgrade

# Check for specific package updates
flutter pub outdated
```

### Firebase Distribution Fails
```bash
# Verify Firebase token
firebase login:ci

# Check App ID
firebase apps:list --project your-project

# Test distribution manually
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_APP_ID \
  --groups "staging-testers"
```

## 📝 Configuration Files

### `.github/workflows/ci-cd.yml`
Main CI/CD workflow file

### `analysis_options.yaml`
Flutter analyzer configuration with strict rules

### `pubspec.yaml`
Dependencies and dev dependencies

## 🔄 Workflow Updates

### To Update Flutter Version
```yaml
env:
  FLUTTER_VERSION: '3.24.5'  # Update this
```

### To Update Java Version
```yaml
env:
  JAVA_VERSION: '17'  # Update this
```

### To Add More Test Types
```yaml
- name: Run Integration Tests
  run: flutter test integration_test/ --reporter=expanded
```

### To Add Code Coverage Upload (Codecov)
```yaml
- name: Upload Coverage to Codecov
  uses: codecov/codecov-action@v4
  with:
    files: ./coverage/lcov.info
    token: ${{ secrets.CODECOV_TOKEN }}
```

## 🎓 Best Practices

### 1. Keep Dependencies Up-to-Date
```bash
flutter pub upgrade
flutter pub outdated
```

### 2. Run CI Checks Locally Before Push
```bash
# Quality
flutter analyze
dart format --set-exit-if-changed .

# Security
osv-scanner --lockfile=pubspec.lock

# Tests
flutter test --coverage
```

### 3. Increase Coverage Gradually
- Start at 0%
- Add tests for new code
- Increase threshold by 10% every sprint
- Target 80% eventually

### 4. Use Semantic Versioning for Tags
```bash
git tag v1.0.0
git tag v1.0.1
git tag v1.1.0
git push --tags
```

## 📚 References

- [Flutter CI/CD Docs](https://docs.flutter.dev/deployment/cd)
- [subosito/flutter-action](https://github.com/subosito/flutter-action)
- [OSV Scanner](https://google.github.io/osv-scanner/)
- [Firebase App Distribution](https://firebase.google.com/docs/app-distribution)
- [Very Good Coverage](https://pub.dev/packages/very_good_coverage)

## 💡 Tips

1. **Use GitHub Environments for approval gates**
   - Production deployments can require manual approval
   - Go to Settings → Environments → production → Required reviewers

2. **Monitor pipeline performance**
   - Check Actions → Insights for pipeline duration trends
   - Optimize slow steps with better caching

3. **Set up branch protection rules**
   - Require CI to pass before merging PRs
   - Settings → Branches → Add rule → Require status checks

4. **Use workflow re-runs sparingly**
   - If a flaky test fails, fix the test instead of re-running
   - Document known flaky tests and track them

---

**Last Updated**: 2025-10-16
**Maintained by**: DevOps Team
