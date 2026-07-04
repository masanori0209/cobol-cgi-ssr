# cobol-cgi-ssr-demo

GnuCOBOL + CGI で Next.js の機能を分解し、実装行数を測るためのデモです。

- 記事: （公開後に Zenn URL を追記）
- GitHub: https://github.com/masanori0209/cobol-cgi-ssr-demo

## できること

| パス | メソッド | Next.js 相当 | 実装 |
|---|---|---|---|
| `/` | GET | 静的ページ | `home.cbl` |
| `/about` | GET | 静的ページ | `about.cbl` |
| `/posts` | GET | 一覧 SSR | `postslist.cbl`（シード3件 + テーブル HTML） |
| `/posts/:id` | GET | 動的ルート + データ取得 | `postdetail.cbl` + `postserv` LOOKUP |
| `/login` | GET/POST | 認証フォーム | `loginform.cbl` / `loginpost.cbl` |
| `/logout` | GET | ログアウト | `logout.cbl` |
| `/posts/new` | GET/POST | 投稿フォーム | `postnewget.cbl` / `postnewpost.cbl` + `postserv` ADD |

- **POST ボディ**: `CONTENT_LENGTH` + stdin（`cgilib.cbl`）
- **セッション**: Cookie `ssr_sid` + `data/sessions/` ファイルストア
- **永続化**: indexed file `data/posts.dat`（Docker ビルド時に `seedposts.cbl` で3件シード）

ルーティングとテンプレートは [COBOL on Wheelchair](https://github.com/azac/cobol-on-wheelchair) を参考にしています。

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

拡張版 COBOL 合計は **1063 行** 前後（2026-07 時点）。

## スクリーンショット

```bash
docker compose up --build -d
ZENN_IMAGES_DIR=/path/to/m-zenn-dev/images ./scripts/capture-media.sh
```

## ライセンス

MIT（COBOL on Wheelchair 由来部分あり）
