#!/bin/sh
# Seed any files baked into the image (e.g. newly committed uploads/models)
# into the persistent volume-backed public dir, without clobbering files
# that were already uploaded at runtime (admin uploads live in the volume).
#
# Does this per-file with explicit logging (rather than a single
# `cp -rn seed/. public/ 2>/dev/null || true`) because that batched form
# has been observed to silently do nothing on at least one host, with no
# way to tell why since its errors were discarded.
#
# A small set of paths are curated, git-tracked assets rather than runtime
# uploads (multer always prefixes real uploads with `Date.now()-`, so these
# exact names can never collide with one). Those are force-synced from the
# seed on every start so committed changes actually reach the volume;
# everything else keeps the skip-if-exists behavior above.
FORCE_SYNC_PATHS="uploads/andrew-professional.jpg"

if [ -d /app/public-seed ]; then
  find /app/public-seed -type f | while IFS= read -r src; do
    rel=${src#/app/public-seed/}
    dest="/app/public/$rel"
    force=0
    for p in $FORCE_SYNC_PATHS; do
      if [ "$rel" = "$p" ]; then
        force=1
        break
      fi
    done
    if [ -e "$dest" ] && [ "$force" -ne 1 ]; then
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    if cp "$src" "$dest"; then
      echo "[seed] copied $rel"
    else
      echo "[seed] FAILED to copy $rel" >&2
    fi
  done
fi

exec "$@"
