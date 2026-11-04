#!/bin/bash
# Prints the "Upstream changes that can touch this package" section of a bump
# pull request: the Yuvomi diff between two tags for the files this package
# copies or depends on. Usage: upstream-diff.sh <from-tag> <to-tag>
#
# The diffs come from a shallow, blobless fetch of just the two tags, so only
# the blobs of these files are downloaded. A pull request body takes at most
# 65536 characters: each diff is cut at MAX_DIFF bytes, which keeps the whole
# section well below that. Of package.json only the fields npm ci and Node
# read are compared; its test scripts change in nearly every release.

set -euo pipefail
export LC_ALL=C

from=$1
to=$2
repo_url=https://github.com/ulsklyc/yuvomi
max_diff=${MAX_DIFF:-9000}
short_lines=40
# Environment variables and secrets, the files the image ships, Node and
# dependencies, the container start-up the package replaces
files=(
    tools/installer/env-schema.js
    .dockerignore
    package.json
    entrypoint.sh
    server/utils/auto-secrets.js
)

compare="$repo_url/compare/$from...$to"
echo "## Upstream changes that can touch this package"
echo

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
git -C "$work" init -q
if ! git -C "$work" fetch -q --filter=blob:none --depth=1 "$repo_url.git" \
        "refs/tags/$from:refs/tags/$from" "refs/tags/$to:refs/tags/$to"; then
    echo "Could not fetch \`$from\` and \`$to\`; compare by hand: $compare"
    exit 0
fi

echo "Diff of the files the package mirrors or depends on, [\`$from...$to\`]($compare)."
echo

# engines, dependencies and the install scripts of package.json at a tag
package_fields() {
    git -C "$work" show "$1:package.json" 2>/dev/null | jq -S '
        {engines, dependencies, optionalDependencies, overrides,
         installScripts: ((.scripts // {})
             | with_entries(select(.key | test("^(pre|post)?install$|^prepare$"))))}
        | with_entries(select(.value != null and .value != {}))' || echo '{}'
}

unchanged=()
for file in "${files[@]}"; do
    if [ "$file" = package.json ]; then
        diff=$(diff -u --label "a/$file ($from)" --label "b/$file ($to)" \
            <(package_fields "$from") <(package_fields "$to") || true)
        title="<code>$file</code>: engines, dependencies, install scripts"
    else
        diff=$(git -C "$work" diff --no-color "$from" "$to" -- "$file")
        title="<code>$file</code>"
    fi
    if [ -z "$diff" ]; then
        unchanged+=("\`$file\`")
        continue
    fi

    # Minus the one "+++"/"---" header line of the diff
    added=$(( $(printf '%s\n' "$diff" | grep -c '^+') - 1 ))
    removed=$(( $(printf '%s\n' "$diff" | grep -c '^-') - 1 ))
    lines=$(printf '%s\n' "$diff" | wc -l)
    note=""
    if [ "${#diff}" -gt "$max_diff" ]; then
        diff=${diff:0:$max_diff}
        # Cut at a line end, never inside a line or a multi-byte character
        diff=${diff%$'\n'*}
        note="Cut after $max_diff bytes, the full diff is in the [comparison]($compare)."
    fi

    if [ "$lines" -le "$short_lines" ]; then
        echo "<details open>"
    else
        echo "<details>"
    fi
    echo "<summary>$title (+$added -$removed)</summary>"
    echo
    echo "~~~~diff"
    printf '%s\n' "$diff"
    echo "~~~~"
    [ -z "$note" ] || { echo; echo "$note"; }
    echo
    echo "</details>"
    echo
done

if [ "${#unchanged[@]}" -eq "${#files[@]}" ]; then
    echo "None."
elif [ "${#unchanged[@]}" -gt 0 ]; then
    (IFS=,; echo "Unchanged: ${unchanged[*]}." | sed 's/,/, /g')
fi
