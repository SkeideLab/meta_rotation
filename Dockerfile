FROM rocker/binder:4.1.2

ENV HOME=/home/$NB_USER
ENV PROJECT_DIR=$HOME/project
ENV RETICULATE_MINICONDA_ENABLED=FALSE

COPY data/ $PROJECT_DIR
COPY misc/ $PROJECT_DIR
COPY _quarto.yml $PROJECT_DIR
COPY .gitignore $PROJECT_DIR
COPY LICENSE $PROJECT_DIR
COPY Makefile $PROJECT_DIR
COPY README.md $PROJECT_DIR
COPY index.qmd $PROJECT_DIR
COPY main.qmd $PROJECT_DIR
COPY supplement.qmd $PROJECT_DIR

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
    # Set working directory for R sessions
    && echo "setwd($PROJECT_DIR)" > $HOME/.Rprofile \
    # Add default user permissions
    && chown -R $NB_USER $HOME

USER rstudio

WORKDIR $PROJECT_DIR
