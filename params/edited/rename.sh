for file in edited-ana-flavia-*
do
	echo "${file#edited-}"
	mv "$file" "${file#edited-}"
done
