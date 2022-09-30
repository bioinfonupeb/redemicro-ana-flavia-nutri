#! /bin/bash


# sed -i -e 's/\r$//' pipeline.sh # Correcao de command not found

PARAMS=$1; # Parameters file path
ENV=$2; # Virtual Enviroment name or source path

EXPERIMENT="${1##*/}";	# Remove prefix path
EXPERIMENT="${EXPERIMENT%%.*}";	# Remove extension
EXPERIMENTFOLDER="${PWD}/experiments/${EXPERIMENT}";
PARAMS="${EXPERIMENTFOLDER}/${EXPERIMENT}.yaml"

BASEURL="https://raw.githubusercontent.com/bioinfonupeb/redemicro-miliane-nutri/main/steps";

# Define pipeline steps
STEPS=(
	# "step-01-prepare-data"
	# "step-02-dada2"
	"step-metataxonomy"
	"step-rarefaction-analysis"
	"step-diversity-analysis"
	);

STEPSDIR="nb-steps"
if ! [ -d "$STEPSDIR" ]; then
  echo "Creating directory: ${STEPSDIR}";
  mkdir -p ${STEPSDIR};
fi

EXECUTEDDIR="${EXPERIMENTFOLDER}/nb-executed-steps"
if ! [ -d "$EXECUTEDDIR" ]; then
  echo "Creating directory: ${EXECUTEDDIR}";
  mkdir -p ${EXECUTEDDIR};
fi

# Download utils.py file
if ! [ -f "${STEPSDIR}/utils.py" ]; then
	echo "Downloading: ${STEPSDIR}/utils.py";
	wget "${BASEURL}/utils.py" -O "${STEPSDIR}/utils.py";
	cp "${BASEURL}/utils.py" "${EXECUTEDDIR}/utils.py"
	cp "${BASEURL}/utils.py" "."
fi


if ! [ -d "$EXPERIMENTFOLDER" ]; then
  echo "Creating directory: ${EXPERIMENTFOLDER}";
  mkdir -p ${EXPERIMENTFOLDER};
  cp ${1} ${EXPERIMENTFOLDER};
fi

if ! [ -f "${PARAMS}" ]; then
  cp "${1}" "${PARAMS}";
fi



echo "Processing paramenters: ${PARAMS}";

# Activate virtual environment with all dependences
conda activate ${ENV};

# Execute each step
for i in "${!STEPS[@]}"; do
	echo "STEP $((i+1)): ${STEPS[i]}";

	# Define paths
	STEPFILE="${STEPSDIR}/${STEPS[i]}.ipynb";
	EXECUTEDFILE="${EXECUTEDDIR}/${STEPS[i]}-${EXPERIMENT}.ipynb";

	# Download notebook if it not exists
	if ! [ -f "$STEPFILE" ]; then
		echo "Downloading: ${STEPFILE}";
		wget "${BASEURL}/${STEPS[i]}.ipynb" -O "${STEPSDIR}/${STEPS[i]}.ipynb";
	fi

	# Execute notebook
	papermill "${STEPFILE}" "${EXECUTEDFILE}" -f "${PARAMS}";
done

# Deactivate the virtual environment
conda deactivate;
