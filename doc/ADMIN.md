### Database key

The database is encrypted. Its key is generated at installation and stored in the app settings (`db_encryption_key`), from which `__INSTALL_DIR__/.env` is rebuilt on every upgrade. Every YunoHost backup of this app contains the key.

**Without the key the database cannot be read.** If you move Yuvomi to another server by hand instead of a YunoHost backup, take the key with you:

```bash
yunohost app setting __APP__ db_encryption_key
```

### Backups

A YunoHost backup stops Yuvomi for a few seconds to take a consistent copy of the database, then starts it again.

Yuvomi also keeps its own scheduled backups in `__DATA_DIR__/backups` (daily, the last 7). They are included in the YunoHost backup.

### Configuration

`__INSTALL_DIR__/.env` is managed by the package and overwritten on upgrade. The variables Yuvomi understands are listed in [`.env.example`](https://github.com/ulsklyc/yuvomi/blob/main/.env.example).

### Logs

```bash
tail -f /var/log/__APP__/__APP__.log
```
