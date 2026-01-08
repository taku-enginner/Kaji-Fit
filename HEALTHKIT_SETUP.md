# HealthKit設定ガイド

HealthKitの同期が失敗する場合、以下の手順でXcodeプロジェクトを設定してください。

## 問題の原因

`Runner.entitlements`ファイルが作成されましたが、Xcodeプロジェクトに正しく登録されていません。

## 修正手順（Mac上のXcodeで実行）

### 1. Xcodeでプロジェクトを開く

```bash
cd /path/to/Kaji-Fit
open ios/Runner.xcworkspace
```

### 2. Signing & Capabilities の設定

1. **左サイドバーで「Runner」プロジェクトを選択**
2. **「Signing & Capabilities」タブを選択**
3. **「+ Capability」ボタンをクリック**
4. **「HealthKit」を検索して追加**

これにより、Xcodeが自動的に：
- `Runner.entitlements`ファイルをプロジェクトに追加
- HealthKit frameworkをリンク
- 必要な設定を`project.pbxproj`に追加

### 3. Entitlementsファイルの確認

追加後、以下の内容が`Runner.entitlements`に含まれていることを確認：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>com.apple.developer.healthkit</key>
	<true/>
	<key>com.apple.developer.healthkit.access</key>
	<array/>
</dict>
</plist>
```

### 4. Info.plistの確認

`ios/Runner/Info.plist`に以下が含まれていることを確認（既に設定済み）：

```xml
<key>NSHealthShareUsageDescription</key>
<string>ワークアウトデータをヘルスケアアプリに同期するために使用します</string>
<key>NSHealthUpdateUsageDescription</key>
<string>家事トレーニングの消費カロリーをヘルスケアアプリに記録するために使用します</string>
<key>NSMotionUsageDescription</key>
<string>家事動作を検知するために加速度センサーを使用します</string>
```

### 5. Bundle Identifierの設定

1. **「Signing & Capabilities」タブで「Team」を選択**
2. **Apple IDでサインイン**
3. **Bundle Identifierがユニークであることを確認**
   - 例: `com.yourname.kajifit`

### 6. クリーンビルド

```bash
# Xcodeを閉じてから実行
cd ios
rm -rf Pods
rm Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### 7. 再ビルド＆実行

```bash
flutter run
```

## デバッグ方法

### エラーメッセージの確認

アプリを実行すると、HealthKit同期時に詳細なエラーメッセージが表示されるようになりました：

- **「HealthKitの権限が拒否されました」**: 権限ダイアログで「許可しない」を選択した
- **「HealthKitへの書き込みに失敗しました」**: データの書き込みに失敗
- **「エラー: [詳細]」**: 具体的なエラー内容が表示される

### コンソールログの確認

Xcodeのコンソールで以下のログを確認：

```
Writing workout to HealthKit:
  Activity: 布団干し
  Start: 2024-01-08 12:00:00
  End: 2024-01-08 12:05:00
  Calories (raw): 2.1
  Calories (rounded): 2
  Calories (to write): 2
HealthKit write result: true
  Writing energy data: 2.1 kcal
  Energy data write result: true
```

### ヘルスケアアプリでのデータ確認

同期が成功した後、iPhoneのヘルスケアアプリで確認：

**1. ワークアウトデータの確認：**
1. ヘルスケアアプリを開く
2. 「ブラウズ」タブ → 「アクティビティ」
3. 「ワークアウト」を選択
4. 最新の「Kaji-Fit: 布団干し」をタップ
5. 詳細で以下を確認：
   - 開始時刻・終了時刻
   - アクティブエネルギー（カロリー）
   - 継続時間

**2. アクティブエネルギーの確認：**
1. ヘルスケアアプリを開く
2. 「ブラウズ」タブ → 「アクティビティ」
3. 「アクティブエネルギー」を選択
4. グラフで該当時間帯のデータを確認

**注意：**
- ワークアウトとアクティブエネルギーは別々に記録されます
- ワークアウトの詳細画面にカロリーが表示されます
- 「今日」タブの合計カロリーにも反映されます

### 権限のリセット

HealthKitの権限をリセットする場合：

1. iPhoneで**設定 > プライバシーとセキュリティ > ヘルスケア**を開く
2. 「Kaji Fit」を選択
3. すべての権限をオフにして、再度オンにする

または、アプリを削除して再インストール。

## よくある問題と解決策

### 1. 「HealthKit is not available on this device」

- **原因**: シミュレータで実行している
- **解決**: 実機でテストする

### 2. 権限ダイアログが表示されない

- **原因**: Info.plistの設定が不足
- **解決**: 上記の手順3を確認

### 3. 「No suitable application records were found」

- **原因**: Bundle Identifierが正しく設定されていない
- **解決**: Signing & Capabilitiesで確認

### 4. ビルドエラー「Provisioning profile doesn't include the HealthKit entitlement」

- **原因**: プロビジョニングプロファイルにHealthKitが含まれていない
- **解決**:
  1. Xcode > Preferences > Accounts でApple IDを確認
  2. 「Download Manual Profiles」をクリック
  3. プロジェクトのTeam設定を一旦外して、再度設定

### 5. ヘルスケアアプリでカロリーが0kcalと表示される

- **原因**: 以前のバージョンでは`totalEnergyBurned`が正しく書き込まれていなかった
- **解決**:
  1. 最新版にアップデート（エネルギーデータを個別に書き込むように改善）
  2. アプリを完全に削除して再インストール
  3. 古いワークアウトデータはヘルスケアアプリで手動削除
  4. 新しく計測を実行

- **確認方法**:
  - Xcodeのコンソールで「Writing energy data: X.X kcal」と「Energy data write result: true」を確認
  - ヘルスケアアプリの「アクティブエネルギー」でもデータを確認
  - ワークアウトの詳細画面で「アクティブエネルギー」の値を確認

### 6. 短時間の活動でカロリーが表示されない

- **原因**: 活動時間が短すぎてカロリーが1kcal未満になる
- **仕様**: 最小値として1kcalが保証されます
- **計算例**:
  - 10秒の活動（布団干し、体重60kg）
  - 理論値: 4.0 × 60 × (10/3600) × 1.05 = 0.7 kcal
  - 実際に書き込まれる値: 1 kcal（最小値保証）

## 確認事項チェックリスト

- [ ] Xcodeで「HealthKit」Capabilityを追加した
- [ ] `Runner.entitlements`がプロジェクトに含まれている
- [ ] `Info.plist`に3つの説明文が含まれている
- [ ] Bundle Identifierがユニークである
- [ ] Teamが設定されている
- [ ] 実機で実行している（シミュレータではない）
- [ ] iPhoneでアプリを信頼している
- [ ] HealthKitの権限ダイアログで「許可」を選択した

## 参考情報

- [Apple Developer: HealthKit](https://developer.apple.com/documentation/healthkit)
- [Flutter health package](https://pub.dev/packages/health)
- [HealthKit Capabilities](https://developer.apple.com/documentation/healthkit/setting_up_healthkit)
