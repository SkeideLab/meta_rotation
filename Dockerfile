FROM rocker/binder:4.1.2

ENV HOME=/home/$NB_USER
ENV PROJECT_DIR=$HOME/project
ENV RETICULATE_MINICONDA_ENABLED=FALSE

RUN mkdir $PROJECT_DIR
COPY .Rprofile $PROJECT_DIR/.Rprofile

USER root

RUN \
    # Install system packages
    apt-get update \
    && apt-get install -y --no-install-recommends clang \
    # Install R packages from MRAN
    && install2.r --error --skipinstalled \
    bayestestR \
    brms \
    cowplot \
    git2r \
    ggridges \
    googledrive \
    here \
    Hmisc \
    httpgd \
    huxtable \
    kableExtra \
    languageserver \
    magick \
    metafor \
    MetBrewer \
    psych \
    styler \
    # Install cmdstandr from GitHub
    && installGithub.r stan-dev/cmdstanr@a2a97d9 \
    && mkdir -p "$HOME/.cmdstanr" \
    && Rscript -e "cmdstanr::install_cmdstan(dir = '$HOME/.cmdstanr')" \
    # Install Python packages
    && pip3 install --no-cache-dir \
    radian \
    # Install LaTeX packages
    && tlmgr update --self \
    && tlmgr install \
    amsmath \
    auxhook \
    bigintcalc \
    bitset \
    etexcmds \
    etoolbox \
    euenc \
    fancyvrb \
    fontspec \
    framed \
    geometry \
    gettitlestring \
    hycolor \
    hyperref \
    iftex \
    infwarerr \
    intcalc \
    kvdefinekeys \
    kvoptions \
    kvsetkeys \
    latex-amsmath-dev \
    letltxmacro \
    ltxcmds \
    pdfescape \
    pdftexcmds \
    refcount \
    rerunfilecheck \
    stringenc \
    tipa \
    unicode-math \
    uniquecounter \
    xcolor \
    xunicode \
    zapfding \
    # Add default user permissions
    && chown -R $NB_USER $HOME

USER $NB_USER

WORKDIR $PROJECT_DIR
