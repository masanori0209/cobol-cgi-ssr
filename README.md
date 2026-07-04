# cobol-cgi-ssr

GnuCOBOL + CGI で Next.js の機能を分解し、実装行数を測るためのデモです。

- 記事: （公開後に Zenn URL を追記）
- GitHub: https://github.com/masanori0209/cobol-cgi-ssr

## できること

| パス | メソッド | Next.js 相当 | 実装 |
|---|---|---|---|
| `/` | GET | 静的ページ | `home.cbl` |
| `/about` | GET | 静的ページ | `about.cbl` |
| `/posts` | GET | 一覧 SSR | `postslist.cbl` + `views/posts/list.cow`（`{% for %}`） |
| `/posts/:id` | GET | 動的ルート + データ取得 | `postdetail.cbl` + `postserv` LOOKUP |
| `/login` | GET/POST | 認証フォーム | `loginform.cbl` / `loginpost.cbl` |
| `/logout` | GET | ログアウト | `logout.cbl` |
| `/posts/new` | GET/POST | 投稿フォーム | `postnewget.cbl` / `postnewpost.cbl` + `postserv` ADD |

- **POST ボディ**: `CONTENT_LENGTH` + stdin（`cgilib.cbl`）
- **セッション**: Cookie `ssr_sid` + `data/sessions/` ファイルストア
- **永続化**: indexed file `data/posts.dat`（Docker ビルド時に `seedposts.cbl` で3件シード）
- **CSS**: `static/app.css` + ページごとの `{{extra_css}}` 注入
- **JavaScript**: `static/app.js` + `page_script` + `{{extra_js}}` 注入
- **テンプレート**: `{{var}}` に加え `{% include %}`, `{% if %}`, `{% for %}`（Django 風の最小 subset）
- **ページ描画**: `renderpage.cbl` が `page-ctx` を layout に渡す（フレームワーク入口）

ルーティングとテンプレートは [COBOL on Wheelchair](https://github.com/azac/cobol-on-wheelchair) を参考に、タグ処理は `ssrtemplate.cbl`、ページ組み立ては `renderpage.cbl` に拡張しています。

## ページを追加する（最小手順）

1. `src/config.cbl` にルートを1行足す
2. `src/controllers/mypage.cbl` を書き、`renderpage` を呼ぶ
3. 必要なら `views/pages/mypage.cow` と `static/pages/mypage.js` を置く

```cobol
move spaces to page-ctx
move "My page" to page-title
move "pages/mypage.cow" to page-template
move "pages/mypage.js" to page-script
call 'renderpage' using page-ctx cgictx
```

データ取得が要るページ（投稿一覧など）だけ、`postlistfill` のように COBOL 側で `the-vars` を埋めてから `ssrtemplate` を直呼びします。

## 起動

```bash
docker compose up --build
./scripts/run-all.sh
```

`BASE_URL` を変えればホスト側からも実行できます。

```bash
BASE_URL=http://127.0.0.1:8080 ./scripts/run-all.sh
```

`run-all.sh` は GET `/`、GET `/posts`、POST `/login`、GET/POST `/posts/new`、簡易ベンチ（10回 GET `/`）まで通します。

## 行数レポート

```bash
./scripts/count-lines.sh
cat reports/line-count.txt
```

拡張版 COBOL 合計は **1481 行** 前後（2026-07 時点）。`ssrtemplate.cbl` が約 400 行、`renderpage.cbl` が約 35 行。

## スクリーンショット

```bash
docker compose up --build -d
ZENN_IMAGES_DIR=/path/to/m-zenn-dev/images ./scripts/capture-media.sh
```

## ライセンス

MIT（COBOL on Wheelchair 由来部分あり）
