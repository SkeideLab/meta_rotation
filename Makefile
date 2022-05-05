# User-defined variables
DOCKER_USER		:= alexenge
IMAGE_VERSION	:= latest

# Automatic workflow variables
PROJECT_DIR		:= $(CURDIR)
PROJECT_NAME	:= $(notdir $(CURDIR))
IMAGE_TAG 		:= $(DOCKER_USER)/$(PROJECT_NAME)
REMOTE_DIR		:= /home/rstudio/project
SHELL			:= bash

# If DOCKER=TRUE, do stuff inside the Docker container
ifeq ($(DOCKER), TRUE)
	run := docker run --rm --volume $(PROJECT_DIR):$(REMOTE_DIR) $(IMAGE_TAG)
endif

# Knit the manuscript
all: manuscript.pdf
manuscript.pdf:
	$(run) Rscript -e "rmarkdown::render(input = 'manuscript.Rmd')"

# Convert from LaTeX to PDF after postprocessing
latex:
	$(run) /bin/bash -c "cd code && xelatex manuscript"

# Auto-format the manuscript
style:
	$(run) Rscript -e "styler::style_file('manuscript.Rmd')"

# Run an interactive RStudio session with Docker
interactive:
	docker run --rm -it --volume $(PROJECT_DIR):$(REMOTE_DIR) \
	-e PASSWORD=1234 -p 8888:8888 $(IMAGE_TAG)

# Build the container with Docker
build: Dockerfile
	docker build --no-cache --progress plain --tag $(IMAGE_TAG) .

# Push the container with Docker
push:
	docker push $(IMAGE_TAG)

# Pull the container with Docker
pull:
	docker pull $(IMAGE_TAG)
