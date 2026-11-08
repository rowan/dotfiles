command -v rbenv &>/dev/null || return 0

# bundler-audit checks a project's Gemfile.lock against ruby-advisory-db, the
# same scan Hive and Dunbar run in CI. Gems belong to one Ruby, and projects pin
# their own via .ruby-version, so install it into every installed version.
for version in $(rbenv versions --bare); do
  RBENV_VERSION=$version gem list -i bundler-audit &>/dev/null && continue
  echo "Installing bundler-audit for Ruby $version"
  RBENV_VERSION=$version gem install bundler-audit
done
