for i in $( ls *prefinal.bam ); do 
	mv $i ${i%prefinal.bam}final.bam
done

for i in $( ls *prefinal.bam.bai ); do 
	mv $i ${i%prefinal.bam.bai}final.bam.bai
done

