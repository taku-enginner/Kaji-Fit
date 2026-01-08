Requirements: Kaji-Fit (MVP)
1. Project Overview
「家事は最高のワークアウトである」というコンセプトのもと、布団干しなどの高負荷家事を検知・数値化し、その消費エネルギーに応じた「冷蔵庫の在庫活用レシピ」を提案するFlutter製iOSアプリ。
2. Target Platforms
iOS (Primary focus for HealthKit integration)
Flutter 3.x / Dart
3. Core Features (MVP Scope)
3.1. 家事トレ計測 (Kaji-Workout)
モーション検知: sensors_plus を使用し、スマホをポケットに入れた状態での「布団干し（上下・拡大運動）」を加速度センサーから検知する。
METs計算ロジック:
布団干し/上げ下ろし = 4.0 METs
シーツ交換 = 3.3 METs
消費カロリー = METs × 体重(kg) × 時間(h) × 1.05
HealthKit連携: health パッケージを使用。計測した消費エネルギーをiOSの「ヘルスケア」アプリに「ワークアウト」として書き込む。
3.2. 簡易在庫管理 & AIレシピ提案 (Stock & AI Recipe)
レシートスキャン: google_ml_kit または google_cloud_vision を使用し、レシートから食材名を抽出・リスト化する。
AI献立生成:
OpenAI API (GPT-4o) を使用。
入力：[現在の在庫リスト] ＋ [今日の家事消費カロリー]。
出力：在庫を消費しつつ、消費エネルギーを補完する「リカバリーレシピ」を1つ提案。
3.3. ユーザーインターフェース (UI/UX)
Home画面: 今日の合計消費カロリーと、次にやるべき「家事トレ」の推奨表示。
計測画面: 「布団干しスタート」ボタン。計測中の心拍数（Apple Watch連携時）や経過時間の表示。
在庫画面: 食材名と追加日の一覧。
4. Technical Requirements
State Management: riverpod (Recommended)
Database: isar または sqflite (ローカルでの在庫保存用)
AI Integration: dart_openai
Health Data: health plugin (Permission handling for HealthKit)
5. Success Metrics for MVP
布団干し動作を開始し、1分間の運動で消費カロリーが正しく算出されること。
算出されたデータがiOSの「ヘルスケア」リングに反映されること。
登録された食材と運動量を元に、AIが妥当なレシピ（例：鶏肉があるなら「高タンパクメニュー」）を提案すること。
6. Future Scalability (Out of Scope for MVP)
サブスクリプション決済 (in_app_purchase)
家事代行サービスへのアフィリエイトリンク
家族間でのスコア共有機能
