# cobol-webfw

A minimal **server-side web framework** for [GnuCOBOL](https://gnucobol.sourceforge.io/) using **CGI**.

Each HTTP request runs a COBOL program that renders HTML on the server (SSR). The framework provides routing, HTML templates, form handling, cookie sessions, static assets, and optional page scripts—without a separate runtime or npm toolchain.

## Features

- **Routing** — path table with HTTP method dispatch and dynamic segments (`/posts/%id`)
- **Controllers** — one COBOL program per route handler under `src/controllers/`
- **Templates** — `views/**/*.html` with `{{variables}}`, `{% include %}`, `{% if %}`, `{% for %}`
- **Layout helper** — `renderpage.cbl` wires layout, CSS, JS, and session context
- **Forms & sessions** — `application/x-www-form-urlencoded` POST parsing, cookie `ssr_sid`, file-backed sessions
- **Persistence** — GnuCOBOL indexed file (`data/posts.dat`) with seed data on first build
- **Static files** — CSS/JS served by Apache from `static/`

## Routes (demo app)

| Path | Methods | Handler |
|---|---|---|
| `/` | GET | `home.cbl` |
| `/about` | GET | `about.cbl` |
| `/posts` | GET | `postslist.cbl` |
| `/posts/:id` | GET | `postdetail.cbl` |
| `/login` | GET, POST | `loginform.cbl`, `loginpost.cbl` |
| `/logout` | GET | `logout.cbl` |
| `/posts/new` | GET, POST | `postnewget.cbl`, `postnewpost.cbl` |

Login is username-only (no password)—enough for a demo session gate.

## Architecture

```text
HTTP request
  → Apache (.htaccess → ssr.cgi)
  → ssr.cbl (router)
  → controller (*.cbl)
  → renderpage.cbl or ssrtemplate.cbl
  → views/layout.html + page template
  → HTML response
```

| Piece | Role |
|---|---|
| `src/config.cbl` | Route table (path, method, controller name) |
| `src/controllers/*.cbl` | Request handlers |
| `views/**/*.html` | HTML templates |
| `src/postsdata.cbl` | Indexed-file CRUD |
| `src/renderpage.cbl` | Standard page render entry point |
| `src/ssrtemplate.cbl` | Template engine |

## Quick start

Requirements: Docker (recommended) or GnuCOBOL + Apache with CGI enabled.

```bash
git clone https://github.com/masanori0209/cobol-webfw
cd cobol-webfw
docker compose up --build
```

Open http://127.0.0.1:8080/

Smoke test from the host:

```bash
BASE_URL=http://127.0.0.1:8080 ./scripts/run-all.sh
```

## Add a page

1. Add a route in `src/config.cbl`
2. Create `src/controllers/mypage.cbl` and call `renderpage`
3. Add `views/pages/mypage.html` (and optionally `static/pages/mypage.js`)

```cobol
move spaces to page-ctx
move "My page" to page-title
move "pages/mypage.html" to page-template
move "pages/mypage.js" to page-script
call 'renderpage' using page-ctx cgictx
```

For list/detail pages that read the indexed file, fill template variables in COBOL (see `postlistfill.cbl`) and call `ssrtemplate` directly instead of `renderpage`.

## Project layout

```text
cobol-webfw/
├── src/
│   ├── ssr.cbl              # CGI entry + router
│   ├── config.cbl           # routes (included by ssr.cbl)
│   ├── ssrtemplate.cbl      # template engine
│   ├── renderpage.cbl       # layout render helper
│   ├── cgilib.cbl           # POST, cookies, sessions
│   ├── postsdata.cbl        # indexed-file service
│   └── controllers/         # route handlers
├── views/
│   ├── layout.html
│   ├── partials/
│   └── pages/               # page templates
├── static/                  # CSS, JS (Apache static)
├── data/                    # posts.dat, sessions/ (runtime)
├── scripts/
│   ├── build.sh
│   ├── run-all.sh
│   └── count-lines.sh
└── docker-compose.yml
```

## Build (local)

If GnuCOBOL is installed:

```bash
./scripts/build.sh
# produces ssr.cgi
```

## Scripts

| Script | Purpose |
|---|---|
| `scripts/build.sh` | Compile COBOL to `ssr.cgi` |
| `scripts/run-all.sh` | HTTP smoke test + simple GET benchmark |
| `scripts/count-lines.sh` | Line-count report → `reports/line-count.txt` |
| `scripts/capture-media.sh` | Playwright screenshots (optional; set `ZENN_IMAGES_DIR` or edit output path) |

## Limits

- **CGI only** — spawn-per-request; no FastCGI/process pool in this repo
- **Demo auth** — username cookie session, not production-grade security
- **Template engine** — subset of Django-style tags; no `{% extends %}`, auto-escape, or ORM
- **Not a COBOL production stack** — intended as an open, hackable mini framework on GnuCOBOL + Docker

## License

MIT
