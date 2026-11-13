# 2023 クライアント互換ランチャー

ゲーム DLL を更新せず、2023-11-28 ビルドの既存クライアントを起動するための標準ビルドです。
ベースは `23ad8c5c8c70edc15759d3ec2dd9b58b5e3e9b5c`。
リポジトリのルートを、実際に動作確認した版に統一しています。

## 修正

- `-login` に加えて `-username` を受け付け、IP・ポート・認証情報のコピー長を制限。
- ZIP バッファの初期化とファイルクローズ、CSV の `fromFile` 判定を修正。
- 実際の DLL に合わせて UMsg / Alarm / PE compilation time の検索シグネチャを調整。
- 長いログを切り詰め、整形済み文字列を `%s` として転送し、CRT エラーを防止。
- 接続時のビルド日時を元のランチャーと同じ `0x6588118B` に維持（wire version `24.12.23`）。

## ビルドとテスト

Visual Studio 2022 の x86 開発環境と Windows 10 SDK を使用します。
検証時は MSVC 14.44.35207 / SDK 10.0.26100.0、Win32、静的 CRT を使用しました。
リポジトリのルートから実行します。

```powershell
.\Build.ps1 -OutputDirectory D:\Build\launcher-2023
.\Build.ps1 -OutputDirectory D:\Build\launcher-tests -LogFormattingTest
& D:\Build\launcher-tests\CSOLauncher.exe
```

通常ビルドの `CSOLauncher.exe` をゲームの `Bin` に配置します。ゲーム DLL はそのまま使用します。
接続先は `-ip 127.0.0.1 -port 30002`。省略時もこの値です。
既存の `-loadzbskillfromfile` 等の引数も使用できます。

## 検証範囲

実 DLL の 27 箇所の静的シグネチャ照合と、長文・パーセント文字・wire build date の回帰テストを通過。
互換サーバーと接続し、大灾变「破碎海岸」で入場・移動できることを利用者が確認しました。
全マップ・全モードの検証ではありません。
