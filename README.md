# home

There's no place like ~

## Howto

### Generate key for git via SSH ([enter][enter] for empty passphrase):

    ssh-keygen -t ed25519 -C "email@example.com"

### Copy to clipboard
    
    pbcopy < ~/.ssh/id_ed25519.pub

### Add to git: https://github.com/settings/keys

### Clone and install:
 
    mkdir -p ~/src \
    && cd ~/src \
    && git clone git@github.com:cynoclast/home.git \
    && echo "CLOBBERING your .bash_profile" \
    && ln -sf ~/src/home/.bash_profile ~/.bash_profile \
    && echo "CLOBBERED your .bash_profile" \
    && echo "CLOBBERING your .zprofile" \
    && ln -sf ~/src/home/.bash_profile ~/.zprofile \
    && echo "CLOBBERED your .zprofile" \
    && source ~/.zprofile

### If that didn't work, do it manually:

    git clone git@github.com:cynoclast/home.git
    ln -sf ~/src/home/.bash_profile ~/.bash_profile
    ln -sf ~/src/home/.bash_profile ~/.zprofile
    source ~/.zprofile

