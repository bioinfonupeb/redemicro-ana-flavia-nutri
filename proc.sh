EXPS=('NCxSTD-NC' 'NRxSTD-NR' 'STD-NCxHSD-NC' 'STD-NCxSTD-NR' 'STD-NRxHSD-NR' 'NCxNR' 'NRxHSD-NR' 'HSD-NCxHSD-NR' 'NCxHSD-NC');
#EXPS=('NCxSTD-NC' 'NRxSTD-NR')
# EXPS=('NCxSTD-NC')

for i in "${EXPS[@]}"
do
	echo "Processing ${i}";
	EXPID="${i}-trim"
	EXPDIR="experiments/ana-flavia-${EXPID}"
#	rm -Rf "experiments/ana-flavia-${i}"

	STEP="abundance-analysis"
	rm "nb-templates/step-${STEP}.ipynb"
    FILEPATH="${EXPDIR}/nb-executed-steps/step-${STEP}-ana-flavia-${EXPID}.ipynb"
    echo "Removing file: ${FILEPATH}"
	rm ${FILEPATH}


	./pipeline.sh "params/ana-flavia-${EXPID}.yaml" qiime2-2022.2
#	./pipeline.sh "params/ana-flavia-${i}.yaml" qiime2-2021.11 # QIIME2 version compatible with picrust2 plugin

	# ls ${EXPDIR}/qiime-artifacts/beta-analysis/*unifrac*
done

