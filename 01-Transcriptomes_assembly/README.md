## Transcriptomes assembly
A combination of new (29) and already published (18) transcriptomes was used in this study. New transcriptomes were generated from RNA Shield and RNA Later-preserved samples. RNA was extracted using the Zymo Microprep Quick-RNA kit and amplified with the SMARTer Universal Low Input RNA Kit. Due to the variable quality of the sequences, we designed three pipelines that were tested in all samples. Only the most complete assembly (according to BUSCO) was kept.

First, we tried a traditional [Trinity](https://github.com/trinityrnaseq/trinityrnaseq) assembly:

    Trinity --seqType fq --max_memory 110G --CPU 10 --left READ_1 --right READ_2 --trimmomatic

Second, we tried the recently published [TransPi](https://github.com/PalMuc/TransPi) pipeline, which tries several assemblers and merges the resulting contigs with [EvidentialGene](http://arthropods.eugenes.org/EvidentialGene/).

    nextflow run TransPi.nf --all --reads 'READ_[1,2].fastq.gz' --k 21,31,41 --maxReadLen 50 -profile conda --myConda

Third, raw reads were carefully trimmed and quality-trimmed before their assembly with Trinity. Briefly, [Rcorrector](https://github.com/mourisl/Rcorrector) was used to correct sequencing errors in the reads, [Trimmomatic](https://github.com/timflutre/trimmomatic) to remove sequencing adapters, and [Prinseq](https://prinseq.sourceforge.net/) to trim and filter low-quality reads. Potential redundancy in the final assembly was reduced using EvidentialGene.

    perl ~/bin/rcorrector/run_rcorrector.pl -1 READ_1 -2 READ_2 -k 21 -od $outfolder -t 8
    
    java -jar $TRIMMOMATIC_HOME/trimmomatic.jar PE READ_1 READ_2 -baseout $output_name \
          ILLUMINACLIP:$TRIMMOMATIC_HOME/adapters/TruSeq3-PE.fa:2:30:10 \
          SLIDINGWINDOW:4:5 LEADING:5 TRAILING:5 MINLEN:35

    prinseq-lite -fastq READ_1 -fastq2 READ_2 -out_good 19-228_cor_P_good -out_bad 19-228_cor_P_bad -min_qual_mean 20 -ns_max_p 25 \
                 -lc_method entropy -lc_threshold 50 -trim_qual_left 30 -trim_qual_right 30 -min_len 40

    Trinity --seqType fq --max_memory 240G --CPU 20 --left READ_1 --right READ_2

    nextflow run TransPi.nf --onlyEvi -profile conda --myConda

Finally, [BUSCO 3](https://busco.ezlab.org/) and the metazoan database were used to select the best assembly per sample based on its completeness score.

    run_BUSCO.py -i ASSEMBLY -l $BUSCO_LINEAGE_SETS/metazoa_odb9 -o ASSEMBLY_output --long -m tran -c 4

In the end, all the samples from the SRA were assembled following the first approach, while all the new transcriptomes were assembled with one of the other two.

## Detection of cross-contamination
Cross-contamination can occur when samples are processed at the same time in the lab, by the same people, or are sequenced in the same facility. If not corrected, this can lead to incongruent topologies. We used [CroCo](https://gitlab.mbb.univ-montp2.fr/mbb/CroCo) to identify and separate contigs that might be the result of cross-contamination. In brief, CroCo maps the reads from each sample to all assemblies and measures its expression level (in our case, using [Kallisto](https://github.com/pachterlab/kallisto)). If the expression of a contig is higher in an alien sample than its own, this contig is flagged and removed.
Since our samples were processed in three independent batches (two batches were not extracted or sequenced at the same time), we ran CroCo three times.

    CroCo_v1.1.sh --mode p --in ASSEMBLIES_directory --tool K --output-level 2 --threads 8 2>&1 | tee directory.log

## Annotation of coding regions
Once we have a clean dataset, we can start preparing the data for the phylogenomic analyses. The first step is to identify coding regions in the transcriptome. We used [TransDecoder](https://github.com/TransDecoder/TransDecoder) to extract from the contigs all coding regions with at least 300 amino acids. We chose this length based on preliminary analyses. We tried several minimum sizes (100, 200, 250, 300, 400, 500, 600, and 700 amino acids), but we considered 300 amino acids the best compromise between the number of extracted CDS and the accuracy of the orthology search. Orthology search based on the smallest coding regions returned a lot of orthogroups that did not look good and generally increased the number of gene copies per orthogroup, hampering paralogy pruning.

    TransDecoder.LongOrfs -t ASSEMBLY -m 300
    TransDecoder.Predict -t ASSEMBLY

Finally, we used Dedupe (integrated in [BBMap](https://jgi.doe.gov/data-and-tools/software-tools/bbtools/bb-tools-user-guide/bbmap-guide/)) to find duplicate coding regions and overlapping fragments.

    for i in *fasta
        do
        dedupe.sh in=$i out=$i.dedupe.fasta findoverlap=t cluster=t minidentity=95 minoverlap=40 amino=t
    done

The resulting assemblies have been uploaded to the <a href="https://datadryad.org/stash/share/-j295xDx5ENV04DAmF_IDdEvbUuE24jbi6t_Ug9FmNs">Dryad repository</a>.

---
