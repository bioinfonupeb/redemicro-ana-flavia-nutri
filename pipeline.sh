#! /bin/bash


# sed -i -e 's/\r$//' pipeline.sh # Correcao de command not found

MYPARAMS=$1; # Parameters file path
ENV=$2; # Virtual Enviroment name or source path

EXPERIMENT="${1##*/}";	# Remove prefix path
EXPERIMENT="${EXPERIMENT%%.*}";	# Remove extension
EXPERIMENTFOLDER="${PWD}/experiments/${EXPERIMENT}";
#MYPARAMS="${EXPERIMENTFOLDER}/${EXPERIMENT}.yaml"

BASEURL="https://raw.githubusercontent.com/lauromoraes/microbiom/main/nb-templates";

# Define pipeline steps
STEPS=(
#	"step-prepare-data"
#	"step-quality-control"
#	"step-rarefaction-analysis"
#	"step-metataxonomy"
#       "step-diversity-analysis"
#        "step-abundance-analysis"
       "step-picrust2-analysis"
	);

STEPSDIR="nb-templates"
if ! [ -d "$STEPSDIR" ]; then
  echo "Creating directory for notebook templates: ${STEPSDIR}";
  mkdir -p ${STEPSDIR};
fi

if ! [ -d "$EXPERIMENTFOLDER" ]; then
  echo "Creating directory for experiment artifacts: ${EXPERIMENTFOLDER}";
  mkdir -p ${EXPERIMENTFOLDER};
  cp ${1} ${EXPERIMENTFOLDER}; # Copy pamameters YAML file to experiment
fi

EXECUTEDDIR="${EXPERIMENTFOLDER}/nb-executed-steps"
if ! [ -d "$EXECUTEDDIR" ]; then
  echo "Creating directory for executed notebooks: ${EXECUTEDDIR}";
  mkdir -p ${EXECUTEDDIR};
fi

# # Download utils.py file
# if ! [ -f "${STEPSDIR}/utils.py" ]; then
# 	echo "Downloading: ${STEPSDIR}/utils.py";
# 	wget "${BASEURL}/utils.py" -O "${STEPSDIR}/utils.py";
# 	cp "${BASEURL}/utils.py" "${EXECUTEDDIR}/utils.py"
# 	cp "${BASEURL}/utils.py" "."
# fi



echo "Processing parameters from: ${MYPARAMS}";

# Activate virtual environment with all dependences
source ~/anaconda3/etc/profile.d/conda.sh;
conda activate ${ENV};

# Execute each step
for i in "${!STEPS[@]}"; do
	echo "====== Executing Pipeline STEP $((i+1)): ${STEPS[i]} ======";

	# Define paths
	STEPFILE="${STEPSDIR}/${STEPS[i]}.ipynb";
	EXECUTEDFILE="${EXECUTEDDIR}/${STEPS[i]}-${EXPERIMENT}.ipynb";

	# Download notebook if it not exists
	if ! [ -f "$STEPFILE" ]; then
		echo "... Downloading file: ${STEPFILE} ...";
		wget "${BASEURL}/${STEPS[i]}.ipynb" -O "${STEPSDIR}/${STEPS[i]}.ipynb";
	fi

	# Execute notebook
	echo ">>> Executing STEP file: ${STEPFILE} <<<";
	papermill "${STEPFILE}" "${EXECUTEDFILE}" -f "${MYPARAMS}";
done

# Deactivate the virtual environment
conda deactivate;
