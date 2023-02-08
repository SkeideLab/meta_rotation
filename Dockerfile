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
    crsh/papaja@2572124 \
    stan-dev/cmdstanr@a2a97d9 \
    # Build CmdStanR
    && mkdir -p "$HOME/.cmdstanr" \
    && Rscript -e "cmdstanr::install_cmdstan(dir = '$HOME/.cmdstanr')" \
    # Install Python packages
    && pip3 install --no-cache-dir \
    radian \
    # Add default user permissions
    && chown -R $NB_USER $HOME

USER rstudio

WORKDIR $PROJECT_DIR
