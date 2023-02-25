FROM rocker/binder:4.1.2

ENV NB_USER=rstudio
ENV PROJECT_NAME=meta_rotation
ENV HOME=/home/$NB_USER
ENV PROJECT_DIR=$HOME/$PROJECT_NAME
ENV CMDSTANR_DIR=$HOME/.cmdstanr

RUN mkdir $PROJECT_DIR
WORKDIR $PROJECT_DIR

COPY data/ data/
COPY misc/ misc/
COPY _quarto.yml .
COPY .gitignore .
COPY LICENSE .
COPY Makefile .
COPY README.md .
COPY index.qmd .
COPY main.qmd .
COPY meta_rotation.Rproj .
COPY supplement.qmd .

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
    && mkdir -p "$CMDSTANR_DIR" \
    && Rscript -e "cmdstanr::install_cmdstan(dir = '$CMDSTANR_DIR')" \
    # Install Python packages
    && pip3 install --no-cache-dir \
    radian \
    # Set working directory for R sessions
    && echo "setwd('$PROJECT_DIR')" > $HOME/.Rprofile \
    # Add default user permissions
    && chown -R $NB_USER $HOME

USER $NB_USER
