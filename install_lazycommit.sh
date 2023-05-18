#!/bin/sh

(wget -O lazycommit https://raw.githubusercontent.com/rilder-almeida/LazyCommit/master/lazycommit && sudo chmod +x lazycommit && sudo mv lazycommit /usr/local/bin/lazycommit) && echo -e "LazyCommit installed successfully!" || echo -e "LazyCommit could not be installed"
