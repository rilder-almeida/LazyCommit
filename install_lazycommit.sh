#!/bin/sh

if $(which gum | grep "not found" > /dev/null); then
    echo "gum could not be found"
    echo "Instructions to install:"
    echo "https://github.com/charmbracelet/gum#installation"
fi

if $(which git | grep "not found" > /dev/null); then
    echo "git could not be found"
    echo "Instructions to install:"
    echo "https://git-scm.com/book/en/v2/Getting-Started-Installing-Git"
fi

( wget -O lazycommit https://raw.githubusercontent.com/rilder-almeida/LazyCommit/master/lazycommit.sh && sudo chmod +x lazycommit && sudo mv lazycommit /usr/local/bin/lazycommit ) && echo -e "LazyCommit installed successfully!" || echo -e "LazyCommit could not be installed"

# sudo wget https://raw.githubusercontent.com/rilder-almeida/LazyCommit/master/install_lazycommit.sh && sh install_lazycommit.sh && rm -rf install_lazycommit.sh