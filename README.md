<div align="center">
  <img src="https://raw.githubusercontent.com/ulsklyc/yuvomi/main/docs/logo.svg" alt="Yuvomi logo" width="92" />

  <h1>Yuvomi for YunoHost</h1>

  <p><strong>The self-hosted family planner, as a YunoHost app.</strong></p>

  <p>
    Tasks, calendar, budget, meals, health and more for the whole household, on your YunoHost
    server, with its own domain and in every YunoHost backup.
  </p>

  <p>
    <a href="manifest.toml"><img src="https://img.shields.io/badge/dynamic/toml?url=https%3A%2F%2Fraw.githubusercontent.com%2Fulsklyc%2Fyuvomi_ynh%2Fmain%2Fmanifest.toml&query=%24.version&label=package&style=flat-square&color=6C3AED" alt="Package version"></a>
    <a href="#install"><img src="https://img.shields.io/badge/platforms-amd64%20%7C%20arm64-6C3AED?style=flat-square" alt="Runs on amd64 and arm64"></a>
    <a href="https://yunohost.org/"><img src="https://img.shields.io/badge/YunoHost-12.1.17%2B-6C3AED?style=flat-square" alt="YunoHost 12.1.17 or newer"></a>
    <a href="https://github.com/ulsklyc/yuvomi_ynh/actions/workflows/lint.yml"><img src="https://img.shields.io/github/actions/workflow/status/ulsklyc/yuvomi_ynh/lint.yml?branch=main&style=flat-square&color=6C3AED&label=lint" alt="Lint status"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-6C3AED?style=flat-square" alt="MIT license"></a>
  </p>

  <p>
    <a href="#install"><strong>→ Install</strong></a>&nbsp;&nbsp;·&nbsp;
    <a href="doc/ADMIN.md">Admin notes</a>&nbsp;&nbsp;·&nbsp;
    <a href="https://github.com/ulsklyc/yuvomi/releases">Releases</a>&nbsp;&nbsp;·&nbsp;
    <a href="https://github.com/ulsklyc/yuvomi">Yuvomi</a>&nbsp;&nbsp;·&nbsp;
    <a href="https://yuvomi.cloud/">yuvomi.cloud</a>
  </p>
</div>

This repository packages [Yuvomi](https://github.com/ulsklyc/yuvomi) for
[YunoHost](https://yunohost.org/). The package installs the official Yuvomi release unchanged,
runs it as a systemd service behind YunoHost's nginx and keeps its secrets in the app settings.
What Yuvomi itself does, module by module, is on [yuvomi.cloud](https://yuvomi.cloud/) and in the
[main repository](https://github.com/ulsklyc/yuvomi).

---

## Install

The package is not in the YunoHost catalog yet. Install it from this repository:

```bash
sudo yunohost app install https://github.com/ulsklyc/yuvomi_ynh
```

1. Pick a domain or subdomain of its own (for example `family.example.com`); Yuvomi cannot run
   under a sub path yet.
2. Pick the YunoHost user who becomes the Yuvomi administrator and enter a password for that
   account. It is separate from the YunoHost password.
3. Open the domain, sign in and invite the rest of the family from **Settings > Family**. They need
   no YunoHost account. On phones, add the page to the home screen, no app store needed.

**Requirements** - YunoHost 12.1.17 or newer on amd64 or arm64, about 200 MB RAM while running
(600 MB during install and upgrade) and 600 MB of disk.

## What the package takes care of

- **The administrator account** - created during the install, so the first-run setup page never
  faces the internet.
- **Database encryption** - always on. The key is generated at install, kept in the app settings
  and carried by every YunoHost backup; an upgrade without it stops instead of opening the database
  with a new one.
- **YunoHost backups** - a backup stops Yuvomi for a few seconds and copies the database while it
  is closed, so the copy is consistent. Yuvomi's own daily backups, documents and modules are in it
  too.
- **Upgrades** - `.env` is rebuilt from the app settings on every upgrade, the database migrations
  run on the next start.
- **System integration** - nginx in front, a hardened systemd service, log rotation, and the
  service in the YunoHost admin.

Admin notes (key, backups, configuration, logs) are in [doc/ADMIN.md](doc/ADMIN.md).

<details>
<summary><b>Not yet: the YunoHost catalog, sub paths and the YunoHost login</b></summary>

<br>

- **YunoHost catalog** - the package is installed from this repository until it is accepted into
  the catalog. From then on YunoHost's bot generates this README from `manifest.toml` and `doc/`.
- **Sub path** - Yuvomi does not run under a sub path such as `example.com/yuvomi` yet. Sub-path
  support is discussed in
  [ulsklyc/yuvomi#2231](https://github.com/ulsklyc/yuvomi/discussions/2231).
- **YunoHost login (SSO, LDAP)** - Yuvomi keeps its own accounts and supports OpenID Connect. Keep
  the app public ("visitors"), so the installable app, calendar feeds and API tokens work outside
  the YunoHost portal.

</details>

---

## How it works

The package downloads the Yuvomi release tarball named in `manifest.toml` (checked by sha256),
installs the runtime dependencies with npm and removes what the server never reads, the same list
the official container image leaves out. Yuvomi itself runs unchanged, and this repository contains
no Yuvomi code.

| Yuvomi path   | On the YunoHost server (app id `yuvomi`)             |
| ------------- | ---------------------------------------------------- |
| database      | `/home/yunohost.app/yuvomi/db/yuvomi.db` (encrypted) |
| backups       | `/home/yunohost.app/yuvomi/backups`                  |
| documents     | `/home/yunohost.app/yuvomi/documents`                |
| modules       | `/home/yunohost.app/yuvomi/modules`                  |
| configuration | `/var/www/yuvomi/.env` (managed, see above)          |
| log           | `/var/log/yuvomi/yuvomi.log`                         |

A second instance gets its own id (`yuvomi__2`) and paths.

The package version is the Yuvomi version plus a package revision, e.g. `2.85.0~ynh1`.

<details>
<summary><b>Maintaining this repository</b></summary>

<br>

- **New Yuvomi release** - the [Bump workflow](.github/workflows/bump.yml) checks for a new release
  every day and opens one pull request with the new version, tarball URL, sha256 and the upstream
  diff of the files the package depends on. Before merging, read that diff and the Yuvomi release
  notes for changes to environment variables, secrets, Node or the
  files the server needs, and install or upgrade once on a YunoHost server.
- **Package changes** - raise the `~ynhN` revision in `manifest.toml`.
- **Contributing** - constraints, decisions, commit and AI assistance rules are in
  [CONTRIBUTING.md](CONTRIBUTING.md).

</details>

---

## Support

- **The package** (install, upgrade, backups) - [issues in this repository](https://github.com/ulsklyc/yuvomi_ynh/issues/new/choose)
- **A bug in Yuvomi itself** - [Yuvomi issues](https://github.com/ulsklyc/yuvomi/issues/new/choose)
- **Questions and ideas** - [Yuvomi discussions](https://github.com/ulsklyc/yuvomi/discussions)
- **Security** - privately, see [SECURITY.md](SECURITY.md)

---

<div align="center">
  <br>
  <img src="https://raw.githubusercontent.com/ulsklyc/yuvomi/main/docs/logo.svg" alt="Yuvomi logo" width="48" />
  <p><strong>One home for your household. On the server you already run.</strong></p>
  <p>
    <a href="#install"><strong>→ Install it</strong></a>&nbsp;&nbsp;·&nbsp;
    <a href="https://yuvomi.cloud/"><strong>Take the tour</strong></a>&nbsp;&nbsp;·&nbsp;
    <a href="https://github.com/ulsklyc/yuvomi/discussions"><strong>Ask a question</strong></a>
  </p>
  <br>
  <sub>MIT licensed, see <a href="LICENSE">LICENSE</a>. Yuvomi itself is MIT-licensed by ulsklyc.</sub>
</div>
