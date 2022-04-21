# icon geisha
This is a script to automatically create icon set for iOS application.

## Usage:
```
icongeisha [original image]
```

- 引数は画像ファイル名となります。一辺が1024ピクセル以上の正方形の画像を用意してください。
- 実行時のフォルダ下に AppIcon.appiconset というフォルダが作成され、必要なファイル一式が作成されます。
- フォルダはそのままプロジェクト内の同名フォルダに置き換えて使うことを意図した構成になっています。(Xcode 9.2 で確認)

## Options:
|      |                           |
| :--- | ------                    |
| -h   | print this.               |
| -v   | print icongeisha version. |

## Watch:

(2022.04.21追加)  
Apple Watch アプリケーション用に同様の機能を持つスクリプトを用意しました。

```
icongeisha_w [original image]
```

使い方は同じです。
