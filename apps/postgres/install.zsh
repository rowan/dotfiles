# restart the service
command -v psql &>/dev/null || return 0

brew services restart postgresql@17