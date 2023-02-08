# User-defined variables
DOCKER_USER := skeidelab
IMAGE_NAME := meta_rotation
IMAGE_VERSION := main
RENDER_CMD := quarto render
PUBLISH_CMD := quarto publish gh-pages --no-promt --no-render --no-browser
SHELL := bash
SLURM_CPUS := 8
SLURM_MEMORY := 32G
SLURM_TIME := 24:00:00
SLURM_SCRIPT := misc/run_slurm.sh

# Automatic workflow variables
PROJECT_DIR	:= $(CURDIR)
PROJECT_NAME := $(notdir $(CURDIR))
IMAGE_TAG := $(DOCKER_USER)/$(IMAGE_NAME)
IMAGE_URL := docker://$(IMAGE_TAG):$(IMAGE_VERSION)
IMAGE_FILE := $(PROJECT_DIR)/$(IMAGE_NAME)_$(IMAGE_VERSION).sif
REMOTE_DIR := /home/rstudio/project

# Render locally
all:
	$(RENDER_CMD)

# Render inside the Docker container
docker:
	docker run -it --rm --volume $(PROJECT_DIR):$(REMOTE_DIR) $(IMAGE_TAG) \
	$(RENDER_CMD)

# Render via SLURM and Singularity on an HPC cluster
sbatch:
	sbatch --chdir $(PROJECT_DIR) --cpus-per-task 40 \
	--mem 180G --nodes 1 --ntasks 1 --time 06:00:00 \
	run_slurm.sh $(PROJECT_DIR) $(REMOTE_DIR) $(IMAGE_FILE)
srun:
	srun --chdir $(PROJECT_DIR) --cpus-per-task 1 \
	--mem 4G --nodes 1 --ntasks 1 --time 01:00:00 \
	run_slurm.sh $(PROJECT_DIR) $(REMOTE_DIR) $(IMAGE_FILE)

# Publish to GitHub pages
publish:
	$(PUBLISH_CMD)

# Auto-format
style:
	Rscript -e "styler::style_file('main.qmd')"
	Rscript -e "styler::style_file('supplement.qmd')"

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

# Pull the container with Docker
pull-singularity:
	singularity pull --disable-cache --force $(IMAGE_URL)
