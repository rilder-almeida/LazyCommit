#!/bin/sh

root_path=$(pwd)

( cd "$(mktemp -d)" && wget -O lazycommit https://raw.githubusercontent.com/rilder-almeida/LazyCommit/master/lazycommit && sudo chmod +x lazycommit && sudo mv lazycommit /usr/local/bin/lazycommit; cd "$root_path" ) && echo "LazyCommit installed successfully!" || echo "LazyCommit could not be installed"
