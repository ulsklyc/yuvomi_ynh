# Contributing to Yuvomi for YunoHost

Thanks for helping! This repository packages [Yuvomi](https://github.com/ulsklyc/yuvomi) as a
YunoHost app. Changes go in through pull requests; questions about Yuvomi itself belong in the
[Yuvomi discussions](https://github.com/ulsklyc/yuvomi/discussions).

---

## Hard Constraints

- **No Yuvomi code, no patches.** The package installs the official release asset (`yuvomi-<version>-dist.tar.gz`, attested) named in
  `manifest.toml` and only adds YunoHost's scripts and config templates. A change Yuvomi needs
  goes upstream.
- **The package version is the Yuvomi version plus a revision**, e.g. `2.85.0~ynh1`. A new Yuvomi
  release starts at `~ynh1`; a change to the package alone raises the revision.
- **The database key is never lost or replaced.** It is generated once at install and kept in the
  app settings (`db_encryption_key`); upgrades stop rather than generate a new one.
- **The removed-files list in `scripts/_common.sh` mirrors Yuvomi's `.dockerignore`**, so the
  package runs the same files as the official container image.

## Layout

```
manifest.toml                Package metadata, install questions, resources, source + sha256
scripts/install              Secrets, source, .env, npm, nginx, systemd, the admin account
scripts/upgrade              Same, keeping the secrets from the app settings
scripts/backup, restore      Consistent database copy while the service is stopped
scripts/remove, change_url   YunoHost lifecycle
scripts/_common.sh           Dependency install and the removed-files list
conf/.env                    Environment for Yuvomi, rebuilt from the settings
conf/nginx.conf              Reverse proxy
conf/systemd.service         Hardened service
doc/                         DESCRIPTION, PRE_INSTALL and ADMIN texts shown by YunoHost
tests.toml                   package_check scenarios
.github/workflows/bump.yml   Daily: opens a pull request for a new Yuvomi release
.github/scripts/             The upstream diff the bump pull request carries
.github/workflows/lint.yml   YunoHost's package_linter on every pull request and on main
.github/dependabot.yml       Weekly updates of the GitHub Actions
```

## Decisions

- **A separate repository**, named `yuvomi_ynh` as YunoHost expects.
- **A domain of its own**: Yuvomi does not run under a sub path yet
  ([ulsklyc/yuvomi#2231](https://github.com/ulsklyc/yuvomi/discussions/2231)).
- **No SSO or LDAP**: Yuvomi keeps its own accounts and offers OpenID Connect. The app stays public
  ("visitors"), so the installable app, calendar feeds and API tokens work outside the portal.
- **Encryption always on**, with the key in the app settings, so every YunoHost backup carries it.
  Yuvomi 2.85+ would generate a key of its own when none is set; the package always sets one, so
  that never happens.
- **The administrator is created during the install**, so the first-run setup page never faces
  the internet.
- **amd64 and arm64 only**: `better-sqlite3-multiple-ciphers` ships prebuilt binaries for those.
- **The README is written by hand** while the package is outside the YunoHost catalog. Once it is
  in, YunoHost's bot generates the README from `manifest.toml` and `doc/`, and the bump moves to
  YunoHost's autoupdate bot (`autoupdate.strategy`); `bump.yml` goes then.

## Testing

- **package_linter** - [YunoHost's linter](https://github.com/YunoHost/package_linter) runs as the
  `package-linter` check. It fails on errors, not on warnings; the catalog checks are not counted
  while the package is outside the YunoHost catalog.
- **On YunoHost** - install, upgrade from the previous version, backup and restore on a YunoHost
  12.1.17+ server before merging a bump.
- **package_check** - [YunoHost's test suite](https://github.com/YunoHost/package_check) runs the
  scenarios in `tests.toml`.

## Commits and pull requests

Same rules as [Yuvomi](https://github.com/ulsklyc/yuvomi/blob/main/CONTRIBUTING.md#4-commit):

- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/), e.g.
  `chore: bump Yuvomi to 2.85.0`. The subject says what is true after the change, lowercase, no
  period, max 72 characters.
- One logical change per pull request; pull requests are squash-merged.
- **New Yuvomi release** - the Bump workflow opens the pull request with version, asset URL and
  sha256 (only after `gh attestation verify` passed), the upstream diff of the files the package
  depends on (`env-schema.js`, `.dockerignore`,
  `package.json`, `entrypoint.sh`, `auto-secrets.js`), and starts the linter on it. Read that diff
  and the release notes since the last bump for changes to environment variables, secrets, Node or
  the files the server needs, and test it on YunoHost before merging.

## AI Assistance

The full policy is in Yuvomi's
[AI Assistance](https://github.com/ulsklyc/yuvomi/blob/main/CONTRIBUTING.md#ai-assistance)
section, and it applies here unchanged.

- **If you contribute, say so if an agent wrote it**, with one line in the pull request
  description ("drafted with Claude Code"). It is not a mark against the contribution. The
  maintainer's own pull requests carry no such line: how this project uses agents is stated once,
  in the section linked above.
- **No tool attribution in commits** - no `Co-Authored-By:` trailer for a tool and no
  "Generated with" footer.
- Agent instruction files (`CLAUDE.md`, `AGENTS.md`, `.claude/` and the like) stay local; they
  are ignored in `.gitignore`.

## License

By contributing, you agree that your contributions are licensed under the [MIT License](LICENSE).
