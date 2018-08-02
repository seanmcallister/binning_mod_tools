#Use this script to modify bin names for binsanity.
#Usage: binsanity_cleanup.sh outputprefix
#Usage example: binsanity_cleanup.sh S1_qccontigs_simpname-bin_

argumenting=$1
mycount=1
for f in *.fna
	do if echo "$f" | grep -Eq '^.+-bin_[0-9]+-refined_[0-9]+\.fna'
		then echo "$f" >> renaming_convention.txt
		nnaammee=$(echo "$f" | sed -E 's/^.+-bin_[0-9]+-refined_[0-9]+\.fna/'$argumenting'renamed_'$mycount'\.fna/')
		mv $f ${nnaammee}
		echo "$nnaammee" >> renaming_convention.txt
		mycount="$(($mycount+1))"
		fi
	if echo "$f" | grep -Eq 'low_completion-refined_[0-9]+\.fna'
		then echo "$f" >> renaming_convention.txt
		nnaammee=$(echo "$f" | sed -E 's/^low_completion-refined_[0-9]+\.fna/'$argumenting'renamed_'$mycount'\.fna/')
		mv $f ${nnaammee}
		echo "$nnaammee" >> renaming_convention.txt
		mycount="$(($mycount+1))"
		fi
	if echo "$f" | grep -Eq '.+-bin_[0-9]+\.fna'
		then echo "$f" >> renaming_convention.txt
		nnaammee=$(echo "$f" | sed -E 's/^.+-bin_[0-9]+\.fna/'$argumenting'renamed_'$mycount'\.fna/')
		mv $f ${nnaammee}
		echo "$nnaammee" >> renaming_convention.txt
		mycount="$(($mycount+1))"
		fi
done
