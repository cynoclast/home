# home

There's no place like ~

## Howto

    mkdir -p ~/src \

    && cd ~/src \
    
    && git clone https://github.com/cynoclast/home.git \
    
    && echo "CLOBBERING YOUR .bash_profile!" \
    
    && ln -sf ~/src/home/.bash_profile ~/.bash_profile \
    
    && echo "CLOBBERED YOUR .bash_profile!" \
    
    && source ~/.bash_profile
