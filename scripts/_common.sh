#!/bin/bash

#=================================================
# COMMON VARIABLES AND CUSTOM HELPERS
#=================================================

# Install the runtime dependencies and drop what the server never reads.
# The list mirrors the upstream .dockerignore, so the package runs the same
# files as the official container image.
_yuvomi_install_dependencies() {
    pushd "$install_dir"
        ynh_hide_warnings ynh_exec_as_app npm ci --omit=dev --no-audit --no-fund
        # Fails loudly when a runtime dependency did not install (upstream #2006)
        ynh_exec_as_app node scripts/check-runtime-deps.mjs
    popd

    ynh_safe_rm "$install_dir/.npm"
    ynh_safe_rm "$install_dir/.cache"
    for path in docs test deploy templates tools coverage backups install.sh \
                docker-compose.yml podman-compose.yml nginx.conf.example ca_profile.xml; do
        ynh_safe_rm "$install_dir/$path"
    done
}

# Folder the backup script fills with a consistent copy of the database
_yuvomi_snapshot_dir() {
    echo "$data_dir/db-snapshot"
}
