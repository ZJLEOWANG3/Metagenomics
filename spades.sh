#!/bin/bash
mode=$1; shift;

rm -rf ./assemble.txt
mkdir -p ./assemble ./log/assemble ./err/assemble
cat pair.trimmed.txt | while read line
	do
	
	suffix="_R1.fastq.trimmed"
	name=${line%${suffix}*}
	name=${name##*/}
	input1=${line% *}
	input2=$(cut -d " " -f2- <<< $line)
	output="./assemble/${name}.assembled"
	log="./log/assemble/${name}.out"
	err="./err/assemble/${name}.err"
	jn="${name}.spades"
	
	if [[ -d $output ]]; then
		echo "Restart from last"
		cn=". /home/li.gua/.local/env/python-3.10-venv/bin/activate;~/opt/spades/3.15.5/bin/spades.py --restart-from last -o $output "
	elif [[ $mode == "sc" ]]; then
		echo "No Last Checkpoint, begin from start, mode single-cell"
		cn=". /home/li.gua/.local/env/python-3.10-venv/bin/activate;~/opt/spades/3.15.5/bin/spades.py --sc --careful -m 196 -k 21,33,55 -1 $input1 -2 $input2 -o $output "
	elif [[ $mode == "iso" ]]; then
		echo "No Last Checkpoint, begin from start, mode isolate"
		cn=". /home/li.gua/.local/env/python-3.10-venv/bin/activate;~/opt/spades/3.15.5/bin/spades.py --isolate -m 196 -k 21,33,55 -1 $input1 -2 $input2 -o $output "
	fi
	
	echo $output >> assemble.txt
	sbatch --time 24:00:00 --mem 196GB -c 8 -o $log -e $err -J $jn --wrap="$cn"
	
done
