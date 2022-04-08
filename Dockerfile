FROM rocker/binder:4.1.2

ENV HOME="/home/$NB_USER"
ENV PROJDIR="$HOME/proj"
ENV RETICULATE_MINICONDA_ENABLED="FALSE"

USER root

RUN \
    # Install system packages
    apt-get update \
    && apt-get install -y --no-install-recommends clang \
    # Install R packages from MRAN
    && install2.r --error --skipinstalled \
    bayestestR \
    bayesmeta \
    brms \
    cowplot \
    ggridges \
    googledrive \
    here \
    Hmisc \
    httpgd \
    huxtable \
    kableExtra \
    languageserver \
    magick \
    MetBrewer \
    psych \
    styler \
    # Install cmdstandr from GitHub
    && installGithub.r stan-dev/cmdstanr@a2a97d9 \
    && mkdir -p "$HOME/.cmdstanr" \
    && Rscript -e "cmdstanr::install_cmdstan(dir = '$HOME/.cmdstanr')" \
    && echo "options(mc.cores = parallel::detectCores())" >> "$HOME/.Rprofile" \
    && echo "options(brms.backend = 'cmdstanr')" >> "$HOME/.Rprofile" \
    # Install Python packages
    && pip3 install --no-cache-dir \
    radian \
    # Install LaTeX packages
    && tlmgr update --self \
    && tlmgr install \
    amsmath \
    # auxhook \
    # bigintcalc \
    # bitset \
    # etexcmds \
    # etoolbox \
    # euenc \
    # fancyvrb \
    # fontspec \
    # framed \
    # geometry \
    # gettitlestring \
    # hycolor \
    # hyperref \
    # iftex \
    # infwarerr \
    # intcalc \
    # kvdefinekeys \
    # kvoptions \
    # kvsetkeys \
    # latex-amsmath-dev \
    # letltxmacro \
    # ltxcmds \
    # pdfescape \
    # pdftexcmds \
    # refcount \
    # rerunfilecheck \
    # stringenc \
    # tipa \
    # unicode-math \
    # uniquecounter \
    # xcolor \
    # xunicode \
    # zapfding \
    # Make sure R Markdown documents get knitted from the project directory
    && echo "knitr::opts_knit\$set(root.dir = getwd())" >> "$HOME/.Rprofile" \
    # Enable plotting via `httpgd` in VS Code
    && echo "options(vsc.use_httpgd = TRUE)" >> "$HOME/.Rprofile" \
    # Set color theme for radian
    && echo "options(radian.color_scheme = 'vs')" > "$HOME/.radian_profile" \
    # Create working directory
    && mkdir "$PROJDIR" \
    # Add default user permissions
    && chown -R "$NB_USER" "$HOME"

USER "$NB_USER"

WORKDIR "$PROJDIR"
