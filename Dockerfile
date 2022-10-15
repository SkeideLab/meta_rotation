FROM rocker/binder:4.1.2

ENV HOME=/home/$NB_USER
ENV PROJECT_DIR=$HOME/project
ENV RETICULATE_MINICONDA_ENABLED=FALSE

COPY .Rprofile $PROJECT_DIR/.Rprofile

USER root

RUN \
    # Install system packages
    apt-get update \
    && apt-get install -y --no-install-recommends clang \
    # Install R packages from MRAN
    && install2.r --error --skipinstalled \
    bayestestR \
    bootstrap \
    brms \
    cowplot \
    furrr \
    ggnewscale \
    ggridges \
    here \
    Hmisc \
    httpgd \
    languageserver \
    logspline \
    magick \
    metafor \
    metaviz \
    psych \
    styler \
    tidybayes \
    # Install R packages from GitHub
    && installGithub.r \
    claudiozandonella/trackdown@844a0ec \
    crsh/papaja@2572124 \
    stan-dev/cmdstanr@a2a97d9 \
    # Build CmdStanR
    && mkdir -p "$HOME/.cmdstanr" \
    && Rscript -e "cmdstanr::install_cmdstan(dir = '$HOME/.cmdstanr')" \
    # Install Python packages
    && pip3 install --no-cache-dir \
    radian \
    # Install LaTeX packages
    && tlmgr update --self \
    && tlmgr install \
    amsmath \
    apa7 \
    auxhook \
    bigintcalc \
    bitset \
    booktabs \
    caption \
    csquotes \
    endfloat \
    environ \
    epstopdf-pkg \
    etexcmds \
    etoolbox \
    euenc \
    fancyhdr \
    fancyvrb \
    float \
    fontspec \
    fp \
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
    lineno \
    ltxcmds \
    makecell \
    mdwtools \
    ms \
    multirow \
    nowidow \
    pgf \
    pdfescape \
    pdftexcmds \
    refcount \
    rerunfilecheck \
    scalerel \
    setspace \
    stringenc \
    threeparttable \
    threeparttablex \
    tipa \
    trimspaces \
    unicode-math \
    uniquecounter \
    was \
    xcolor \
    xpatch \
    xunicode \
    zapfding \
    # Add default user permissions
    && chown -R $NB_USER $HOME

USER rstudio

WORKDIR $PROJECT_DIR
