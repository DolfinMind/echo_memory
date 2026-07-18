# Play release checklist

## Completed in the repository

- [x] Flutter 3.44.6 and Dart 3.12.2 migration
- [x] Android Gradle Plugin 9.0.1, Gradle 9.1, Kotlin 2.3.20, Java 17
- [x] Package name changed to `com.dolfinmind.echomemory`
- [x] Version set to 2.1.0 (build 7)
- [x] Target SDK 36 and minimum SDK 24
- [x] Release shrinking and resource shrinking enabled
- [x] No production internet, ad ID, storage, location, camera, or microphone permission
- [x] Ads, analytics, backend, and outbound links removed
- [x] Analyzer clean and automated tests passing
- [x] App icon, feature graphic, and six phone screenshots prepared
- [x] Store listing, privacy policy, and Data safety answers prepared
- [x] Privacy policy published as public HTML at `https://dolfinmind.github.io/echo_memory/privacy-policy/`

## Required owner actions in Play Console

- [ ] Confirm `com.dolfinmind.echomemory` is the intended permanent package ID
- [ ] Create and securely back up the upload keystore
- [ ] Build the final AAB with `android/app/key.properties` present
- [ ] Verify the AAB certificate is the intended upload certificate
- [ ] Create the app as **Game**, **Free**, category **Puzzle**
- [ ] Set **Contains ads** to **No**
- [ ] Set app access to **All functionality is available without special access**
- [ ] Complete the Data safety form using `data-safety.md`
- [ ] Replace the rejected privacy URL in Play Console with `https://dolfinmind.github.io/echo_memory/privacy-policy/`
- [ ] Complete the content-rating questionnaire honestly; the expected result is suitable for a general audience
- [ ] Select target ages 13–15, 16–17, and 18+ unless the product strategy changes
- [ ] Declare that the app is not a news, health, financial, government, or social app
- [ ] Upload the icon, feature graphic, and at least the first three phone screenshots
- [ ] Add screenshot alt text from `listing.md`
- [ ] Run internal testing, pre-launch report, and closed testing as required for the developer account
- [ ] Review the automated device report before production rollout

## Release artifact

Run `flutter build appbundle --release`. The uploadable output is:

`build/app/outputs/bundle/release/app-release.aab`

Do not upload a bundle built through the debug-signing fallback.
