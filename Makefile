# User-defined variables
DOCKER_USER := skeidelab
IMAGE_NAME := meta_rotation
IMAGE_VERSION := main
KNIT_CMD := Rscript -e "rmarkdown::render(input = 'manuscript.Rmd')"
LATEX_CMD := xelatex manuscript
SHELL := bash
SLURM_CPUS := 8
SLURM_MEMORY := 32G
SLURM_TIME := 24:00:00
SLURM_SCRIPT := run_slurm.sh

# Automatic workflow variables
PROJECT_DIR	:= $(CURDIR)
PROJECT_NAME := $(notdir $(CURDIR))
IMAGE_TAG := $(DOCKER_USER)/$(IMAGE_NAME)
IMAGE_URL := docker://$(IMAGE_TAG):$(IMAGE_VERSION)
IMAGE_FILE := $(PROJECT_DIR)/$(IMAGE_NAME)_$(IMAGE_VERSION).sif
REMOTE_DIR := /home/rstudio/project

# Knit the manuscript locally
all:
	$(KNIT_CMD)

# Knit the manuscript inside the Docker container
docker:
	docker run -it --rm --volume $(PROJECT_DIR):$(REMOTE_DIR) $(IMAGE_TAG) \
	$(KNIT_CMD)

# Knit the manuscript via SLURM and Singularity on an HPC cluster
sbatch:
	sbatch --chdir $(PROJECT_DIR) --cpus-per-task 40 \
	--mem 180G --nodes 1 --ntasks 1 --time 06:00:00 \
	run_slurm.sh $(PROJECT_DIR) $(REMOTE_DIR) $(IMAGE_FILE)
srun:
	srun --chdir $(PROJECT_DIR) --cpus-per-task 1 \
	--mem 4G --nodes 1 --ntasks 1 --time 01:00:00 \
	run_slurm.sh $(PROJECT_DIR) $(REMOTE_DIR) $(IMAGE_FILE)

# Convert from LaTeX to PDF after postprocessing, locally or in the container
# Required post-processing includes:
# 1. Remove `\&` before the name of the alst author in the `author{}` line
# 2. Place each affiliation into `{}`
# 3. Remove all newlines between `\CSLLeftMargin{XX. }` and `\CSLRightInline`
# 4. Remove empty lines after references for ausubel1968, hedges1985,
#    rosenthal1991, cohen1988, efron1993
# 5. Replace `\caption*{\normalfont{Table \ref{` with
#    `\caption*{\normalfont{Supplementary Table \ref{`
# 6. Detel all instances of `\textit{Note.} `
latex:
	$(LATEX_CMD)
latex-docker:
	docker run -it --rm --volume $(PROJECT_DIR):$(REMOTE_DIR) $(IMAGE_TAG) \
	$(LATEX_CMD)

# Auto-format the manuscript
style:
	Rscript -e "styler::style_file('manuscript.Rmd')"

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
