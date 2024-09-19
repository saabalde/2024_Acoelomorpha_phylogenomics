## Transcriptomes assembly
A combination of new (29) and already published (18) transcriptomes was used in this study. New transcriptomes were generated from RNA Shield and RNA Later-preserved samples. RNA was extracted using the Zymo Microprep Quick-RNA kit and amplified with the SMARTer Universal Low Input RNA Kit. Due to the variable quality of the sequences, we designed three pipelines that were tested in all samples. Only the most complete assembly (according to BUSCO) was kept.

First, we tried a traditional [Trinity](https://github.com/trinityrnaseq/trinityrnaseq) assembly:

    Trinity --seqType fq --max_memory 110G --CPU 10 --left READ_1 --right READ_2 --trimmomatic

Second, we tried the recently published [TransPi](https://github.com/PalMuc/TransPi) pipeline, which tries several assemblers and merges the resulting contigs with [EvidentialGene](http://arthropods.eugenes.org/EvidentialGene/).

    nextflow run TransPi.nf --all --reads 'READ_[1,2].fastq.gz' --k 21,31,41 --maxReadLen 50 -profile conda --myConda

Third, raw reads were carefully trimmed and quality-trimmed before their assembly with Trinity. Briefly, [Rcorrector](https://github.com/mourisl/Rcorrector) was used to correct sequencing errors in the reads, [Trimmomatic](https://github.com/timflutre/trimmomatic) to remove sequencing adapters, and [Prinseq](https://prinseq.sourceforge.net/) to trim and filter low-quality reads. Potential redundancy in the final assembly was reduced using EvidentialGene.

    perl ~/bin/rcorrector/run_rcorrector.pl -1 READ_1 -2 READ_2 -k 21 -od $outfolder -t 8
    
    java -jar $TRIMMOMATIC_HOME/trimmomatic.jar PE READ_1 READ_2 -baseout $output_name \
          ILLUMINACLIP:/sw/bioinfo/trinity/2.9.1/rackham/trinity-plugins/Trimmomatic/adapters/TruSeq3-PE.fa:2:30:10 \
          SLIDINGWINDOW:4:5 LEADING:5 TRAILING:5 MINLEN:35

    prinseq-lite -fastq READ_1 -fastq2 READ_2 -out_good 19-228_cor_P_good -out_bad 19-228_cor_P_bad -min_qual_mean 20 -ns_max_p 25 \
                 -lc_method entropy -lc_threshold 50 -trim_qual_left 30 -trim_qual_right 30 -min_len 40

    Trinity --seqType fq --max_memory 240G --CPU 20 --left READ_1 --right READ_2

    nextflow run TransPi.nf --onlyEvi -profile conda --myConda

Finally, [BUSCO 3](https://busco.ezlab.org/) and the metazoan database were used to select the best assembly per sample based on its completeness score.

    run_BUSCO.py -i ASSEMBLY -l $BUSCO_LINEAGE_SETS/metazoa_odb9 -o ASSEMBLY_output --long -m tran -c 4

In the end, all the samples from the SRA were assembled following the first approach, while all the new transcriptomes were assembled with one of the other two.




## After any sequencing project, the contamination of samples sequenced in the same lane is a very real posibility. To address this 
## issue, we ran CroCo, which uses Blast searches and mapping of reads to detect transcripts that represent potential instances of 
## contamination:

/home/saabalde/bin/CroCo/src/CroCo_v1.1.sh --mode p --in ASSEMBLIES_directory --tool K --output-level 2 --threads 8 2>&1 | tee directory.log

## Once we have a clean dataset, we can start preparing the data for the phylogenomic analyses. The first step is to identify coding 
## regions in the transcriptome using TransDecoder. In general, the longer the protein the more reliable the inference shuld be. However, 
## if we set a sequence length too long that might imply the recovery of less orthogroups. Since we have data with poor completeness values,
## we need to find the balance between these two parameters. Hence, we identify the coding regions with minimum lengths of 100, 200, 250, 
## 300, 500, 600 and 750 amino acids and see what happens.

TransDecoder.LongOrfs -t ASSEMBLY -m 100 / 200 / 250 / 300 / 500 / 600 / 750
TransDecoder.Predict -t ASSEMBLY

## Only the search of coding regions of 100, 200, 250, 300, and 500 amino acids returned peptides for all the transcriptomes. The sample 
## Neochildia fusca (SRR8617822) failed to return  any protein when the minimum protein size is 700 aa. The sample Solenofilomorpha sp-9 
## (P15761_189) failed at 600 and 700 aa.

## After several attempts cleaning these datasets, counting the number of orthogroups, and inspecting some of the alignments, I decide to 
## continue with a minimum protein size of 300 amino acids because I think it offers the best balance between number of orthogroups and protein 
## size.

## I have seen in the tests that there are duplicated sequences and, I assume, a lot of fragmentation. The program Dedupe, contained in 
## BBMAP, finds duplicates and overlapping fragments

for i in *fasta; do dedupe.sh in=$i out=$i.dedupe.fasta findoverlap=t cluster=t minidentity=95 minoverlap=40 amino=t; done

## Run OrthoFinder over this set of proteins
