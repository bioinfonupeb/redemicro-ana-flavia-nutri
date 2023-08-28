EXPS=('STD-NCxSTD-NR-trim' 'STD-NCxHSD-NC-trim' 'NRxSTD-NR-trim' 'NCxSTD-NC-trim');
for i in "${EXPS[@]}"
do
	echo "Processing ${i}";
	rm -Rf "experiments/ana-flavia-${i}"
	./pipeline.sh "params/ana-flavia-${i}.yaml" qiime2-2022.2
done

