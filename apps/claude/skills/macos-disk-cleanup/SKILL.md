---
name: macos-disk-cleanup
description: Reclaim disk space on a macOS dev machine with Xcode. Survey first, then remove old simulator runtimes, DeviceSupport, DerivedData and developer caches with the supported tools, never rm inside system asset folders. Use when the disk is full or nearly full, a build fails with "No space left on device", or the user asks to free up space, clean up the disk, or find what is using storage.
---

# macOS disk cleanup playbook

On Xcode machines, disk pressure is almost always simulator runtimes and developer caches, not scattered app caches. Simulator data has been two orders of magnitude bigger than `~/Library/Caches`, so start there.

## 1. Survey first, delete nothing

```sh
df -h /System/Volumes/Data
xcrun simctl runtime list
for p in \
  "Library/Developer/CoreSimulator/Devices" \
  "Library/Developer/Xcode/iOS DeviceSupport" \
  "Library/Developer/Xcode/tvOS DeviceSupport" \
  "Library/Developer/Xcode/DerivedData" \
  "Library/Developer/Xcode/Archives" \
  "Library/Caches/org.swift.swiftpm" \
  "Library/Caches/CocoaPods" \
  "Library/Caches/Yarn" \
  ".npm" \
  "Library/Caches/Homebrew" \
  ".rbenv/versions" \
  "Library/Containers/com.docker.docker" \
  "Library/Application Support/Claude" \
  "Library/Application Support/Notion" \
  "Library/Caches/com.microsoft.VSCode.ShipIt" \
  ".Trash"; do
  [ -e "$HOME/$p" ] && printf '%s\t~/%s\n' "$(du -sh "$HOME/$p" 2>/dev/null | cut -f1)" "$p"
done | sort -h
ls -d /Applications/Xcode*.app
find "${PROJECTS:-$HOME/Documents/Code}" -maxdepth 3 -name node_modules -type d -prune -exec du -sh {} + 2>/dev/null | sort -h | tail
```

`du` prints "Operation not permitted" for privacy-protected folders. That's expected; ignore it unless the folder is a candidate.

`du` on `/Library/Developer/CoreSimulator/Volumes` double-counts, so the survey leaves it out: see the traps below.

## 2. Propose, then wait

Never delete on the strength of the survey alone. Show a table, biggest first:

| Candidate | Size | If deleted | Recommendation |
|---|---|---|---|

"If deleted" is one of: rebuilt automatically, re-downloaded on next use, or the user's data (gone). Wait for the user to approve the list, or a subset of it, before running anything.

Commands that need `sudo` can't run from here: give them to the user to run as `! sudo …`.

## 3. Know the traps

- `/Library/Developer/CoreSimulator/Volumes` holds sealed read-only mounts of runtime images physically stored in `/System/Library/AssetsV2/com_apple_MobileAsset_iOSSimulatorRuntime`.
- Never `rm` inside `/System/Library/AssetsV2` (SIP-protected, and the wrong tool anyway).
- The supported path is `xcrun simctl runtime delete <UUID>`. It removes the AssetsV2 asset and reclaims the per-runtime dyld caches under `/Library/Developer/CoreSimulator/Caches`, which can be as big as the runtimes themselves.
- Runtimes listed as "Unusable - Cryptex Mount Preferred" are duplicate mounts of a Ready image with the same build, not separate disk images. They vanish when the Ready one is deleted (later deletes report "No runtime disk images or bundles found"), and they can't be deleted on their own while you keep the Ready one. They can be half the list.
- `runtime delete` can fail with `SimDiskImageError code=30` ("did not reclaim its MobileAsset") when the asset is still mounted by `cryptexd`. `scan-and-mount` won't re-register it while it's mounted. To find orphans, compare the `.asset` folders in AssetsV2 with the Image Paths shown by `xcrun simctl runtime list -v`; each asset's `Info.plist` shows its build. Reboot, then `scan-and-mount` and delete again.
- `xcrun simctl delete unavailable` only removes devices whose runtime is gone. `CoreSimulator/Devices` can still be large afterwards; `xcrun simctl erase all` resets every simulator, losing the apps and data inside them.
- Xcode Archives hold the dSYMs needed to symbolicate crash reports. Keep the archive of every build that shipped.
- If the disk is completely full, Claude Code can't run any commands. Free space by hand first (empty the Bin, `sudo tmutil deletelocalsnapshots /`). Background writes can use up a few hundred MB within minutes, so free a GB or more.

## 4. Keep policy

- iOS runtimes: newest, plus newest of the previous major version
- tvOS runtimes: newest only (tvOS is actively developed)
- DeviceSupport: only the OS versions current physical devices run; deleted folders regenerate on next device connect
- Xcode Archives: builds that shipped
- rbenv Rubies: any version named in a project's `.ruby-version`
- Docker: images and volumes for projects in active use

## 5. Clean up

Run only what the user approved.

```sh
# Simulators
xcrun simctl runtime delete <UUID>             # per old runtime
xcrun simctl delete unavailable                # devices orphaned by runtime removal
xcrun simctl erase all                         # resets every simulator; apps and data inside are lost

# Xcode
rm -rf ~/Library/Developer/Xcode/'iOS DeviceSupport'/'<old version>'
rm -rf ~/Library/Developer/Xcode/DerivedData   # rebuilt on next build

# Package managers (all re-downloaded on next use)
rm -rf ~/Library/Caches/org.swift.swiftpm
yarn cache clean
npm cache clean --force
pod cache clean --all
rbenv uninstall <version>
brew cleanup --prune=all

# Docker (Docker Desktop must be running)
docker system df                               # see what's reclaimable first
docker system prune                            # stopped containers, unused networks, dangling images, build cache

# Projects not in active use
rm -rf <project>/node_modules                  # restored by yarn/npm install
bin/rails log:clear tmp:clear                  # from a Rails project's root

# Misc
rm -rf ~/Library/Caches/com.microsoft.VSCode.ShipIt
```

## 6. Report and learn

- Re-run `df -h /System/Volumes/Data` and report free space before and after, and which steps freed the most.
- If a new trap turned up (a command that failed, a folder that double-counted, a delete that didn't reclaim space), add it to section 3 of this file (`apps/claude/skills/macos-disk-cleanup/SKILL.md` in the dotfiles repo). Write the lesson, not the occasion: no dates or one-off sizes.

## Leave alone

- `/private/var/folders`: OS-managed temp; a reboot trims it
- `/Library/Developer/PrivateFrameworks`: tiny
- `~/Library/Application Support/Claude/vm_bundles`: the disk image for the virtual machine Claude desktop runs local agent sessions in, about 9 GB and written to whenever those sessions run. Untested whether the app re-provisions it cleanly, so don't offer it. The `Cache` and `Code Cache` folders beside it are rebuilt automatically, but are worth only about 1 GB and need the app quit first
- Notion app data: deleting forces a re-sync; only if desperate
