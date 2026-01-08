# Requirements: Kaji-Fit (MVP)

## 1. Project Overview

「家事は最高のワークアウトである」というコンセプトのもと、布団干しなどの高負荷家事を検知・数値化し、その消費エネルギーに応じた「冷蔵庫の在庫活用レシピ」を提案するFlutter製iOSアプリ。

## 2. Target Platforms

- iOS (Primary focus for HealthKit integration)
- Flutter 3.x / Dart

## 3. Core Features (MVP Scope)

### 3.1. 家事トレ計測 (Kaji-Workout)

#### 3.1.1 モーション検知

`sensors_plus` を使用し、スマホをポケットに入れた状態での家事動作を加速度センサーから検知する。

**対応する家事タイプ:**

| 家事タイプ | METs | 動作特性 |
|-----------|------|---------|
| 布団干し/上げ下ろし | 4.0 | 大きな上下動 + バサバサ振動 |
| シーツ交換 | 3.3 | 横方向の動き + 細かい作業 |

#### 3.1.2 振動検知アルゴリズム仕様

**センサー設定:**
- サンプリングレート: 50Hz
- 計測モード: ユーザーが明示的に開始/停止

**信号処理パイプライン:**

```
Raw Data (X,Y,Z)
    → 1. Magnitude計算: √(x² + y² + z²)  ※向き非依存化
    → 2. 重力除去: magnitude - 9.8 (ハイパスフィルタ)
    → 3. ノイズ除去: 移動平均 (window=5サンプル)
    → 4. ピーク検出: 閾値 2.0 m/s² 以上
    → 5. パターン認識: 0.5-2秒間隔で連続3回以上のピーク
    → 6. 活動時間累積
```

**検知パラメータ (チューニング対象):**

| パラメータ | 初期値 | 説明 |
|-----------|--------|------|
| `peakThreshold` | 2.0 m/s² | ピークと判定する加速度変化の閾値 |
| `minPeakInterval` | 0.5秒 | ピーク間の最小間隔（ノイズ除去） |
| `maxPeakInterval` | 2.0秒 | ピーク間の最大間隔（パターンリセット） |
| `minConsecutivePeaks` | 3回 | 活動開始と判定する連続ピーク数 |
| `movingAverageWindow` | 5サンプル | 平滑化のウィンドウサイズ |

#### 3.1.3 カロリー計算

```
消費カロリー (kcal) = METs × 体重(kg) × 時間(h) × 1.05
```

#### 3.1.4 HealthKit連携

`health` パッケージを使用。計測した消費エネルギーをiOSの「ヘルスケア」アプリに「ワークアウト」として書き込む。

**書き込むデータ:**
- ワークアウトタイプ: Other (カスタム名: "Kaji-Fit: 布団干し" など)
- 消費カロリー (Active Energy Burned)
- 開始時刻・終了時刻
- 活動時間

### 3.2. 簡易在庫管理 & AIレシピ提案 (Stock & AI Recipe)

#### 3.2.1 レシートスキャン

`google_ml_kit` を使用し、レシートから食材名を抽出・リスト化する。

**処理フロー:**
1. カメラでレシート撮影
2. OCRでテキスト抽出
3. 食材名のパターンマッチング（正規表現 + 除外リスト）
4. 抽出結果をユーザーが確認・編集
5. 在庫DBに保存

#### 3.2.2 AI献立生成

OpenAI API (GPT-4o) を使用。

**入力:**
- 現在の在庫リスト
- 今日の家事消費カロリー
- （オプション）食事の好み・アレルギー

**出力:**
- 在庫を消費しつつ、消費エネルギーを補完する「リカバリーレシピ」を1つ提案
- 必要な追加食材（あれば）
- 栄養バランスの簡易説明

### 3.3. ユーザーインターフェース (UI/UX)

#### 3.3.1 画面構成

| 画面 | 主な機能 |
|------|---------|
| **Home** | 今日の合計消費カロリー、次にやるべき「家事トレ」の推奨表示 |
| **計測** | 「布団干しスタート」ボタン、経過時間、リアルタイム加速度表示（デバッグ用） |
| **在庫** | 食材名と追加日の一覧、手動追加/削除 |
| **レシピ** | AI生成レシピ表示 |
| **設定** | 体重設定、HealthKit連携設定 |

#### 3.3.2 ナビゲーション

- BottomNavigationBar: Home / 計測 / 在庫 / 設定
- レシピはHomeからのモーダル表示

## 4. Technical Requirements

### 4.1 技術スタック

| カテゴリ | パッケージ | 用途 |
|---------|-----------|------|
| State Management | `flutter_riverpod` | アプリ全体の状態管理 |
| Local Database | `isar` | 在庫・ワークアウト履歴の永続化 |
| Sensors | `sensors_plus` | 加速度センサーアクセス |
| Health Data | `health` | HealthKit連携 |
| AI Integration | `dart_openai` | GPT-4o API呼び出し |
| OCR | `google_ml_kit` | レシートスキャン |
| Routing | `go_router` | 画面遷移 |

### 4.2 プロジェクト構造

```
lib/
├── main.dart
├── app.dart
│
├── core/
│   ├── constants/
│   │   └── mets_values.dart
│   ├── utils/
│   │   └── signal_processing.dart    # フィルタ、ピーク検出
│   └── extensions/
│
├── features/
│   ├── workout/                       # 家事トレ計測
│   │   ├── data/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   │       ├── motion_detector.dart
│   │   │       ├── calorie_calculator.dart
│   │   │       └── healthkit_service.dart
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── screens/
│   │       ├── widgets/
│   │       └── providers/
│   │
│   ├── inventory/                     # 在庫管理
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   ├── recipe/                        # AIレシピ提案
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   │
│   └── home/                          # ホーム画面
│       └── presentation/
│
├── shared/
│   ├── widgets/
│   └── providers/
│
└── config/
    ├── routes.dart
    └── theme.dart
```

### 4.3 データモデル

```dart
// ワークアウトセッション
class WorkoutSession {
  final String id;
  final KajiActivityType activityType;
  final DateTime startTime;
  final DateTime endTime;
  final double durationMinutes;
  final double caloriesBurned;
  final bool syncedToHealthKit;
}

// 家事タイプ
enum KajiActivityType {
  futonDrying(mets: 4.0, displayName: '布団干し'),
  sheetChanging(mets: 3.3, displayName: 'シーツ交換');

  final double mets;
  final String displayName;
  const KajiActivityType({required this.mets, required this.displayName});
}

// 在庫アイテム
class InventoryItem {
  final String id;
  final String name;
  final DateTime addedAt;
  final DateTime? expiresAt;
  final String? category;
}
```

## 5. 設計上の考慮事項

### 5.1 バッテリー効率

- センサー監視は計測画面でのみ実行（バックグラウンド不可）
- 計測タイムアウト: 5分間無活動で自動停止
- 将来的にバックグラウンド対応する場合はサンプリングレートを10Hzに低減

### 5.2 データ信頼性

- 極端な値（例: 1分で100kcal超）は警告表示
- HealthKit書き込み前に確認ダイアログを表示

### 5.3 プライバシー

- 加速度データはローカルのみに保存（サーバー送信なし）
- HealthKitアクセスは必要最小限の権限のみ要求
- OpenAI APIへの送信データは在庫リストと数値のみ（個人情報なし）

## 6. Success Metrics for MVP

| 指標 | 目標 |
|------|------|
| 布団干し検知精度 | 実際の布団干し動作の80%以上を検知 |
| 誤検知率 | 歩行・その他動作での誤検知10%以下 |
| カロリー計算 | 1分間の運動で正しく算出される |
| HealthKit連携 | 算出データがヘルスケアアプリに反映される |
| レシピ提案 | 在庫と運動量に基づき妥当なレシピが提案される |

## 7. 開発フェーズ

### Phase 1: センサープロトタイプ
1. Flutter プロジェクトセットアップ
2. sensors_plus でリアルタイム加速度表示
3. 信号処理（移動平均、ピーク検出）実装
4. 布団干しパターン認識の閾値チューニング

### Phase 2: コア機能
5. Riverpod セットアップ
6. カロリー計算ロジック
7. isar でローカルDB構築
8. HealthKit連携

### Phase 3: UI実装
9. 共通ウィジェット・テーマ
10. 各画面の実装

### Phase 4: AI連携
11. レシートOCR
12. OpenAI APIレシピ提案

## 8. Future Scalability (Out of Scope for MVP)

- キャリブレーション機能（ユーザー固有の動作パターン学習）
- 機械学習による家事分類精度向上（TensorFlow Lite）
- Apple Watch心拍数連携
- サブスクリプション決済 (`in_app_purchase`)
- 家事代行サービスへのアフィリエイトリンク
- 家族間でのスコア共有機能
- Android対応
