# Binning mod tools

A collection of tools for working with binning program outputs. When you call the program use ```-h``` to see the help information.

Tools:

1. ```DASTool_converter.pl```
2. ```binsanity_cleanup.sh```
3. ```concoct_pull_contigs.pl```

Tool 1 takes binning outputs and creates a scaffold2bin.tsv file, which is used by the [DAS Tool](https://github.com/cmks/DAS_Tool) program. The DAS Tool folks later made [their own version of this](https://github.com/cmks/DAS_Tool/blob/master/src/Fasta_to_Scaffolds2Bin.sh), which is probably more stable.

Tool 2 quickly renames [Binsanity](https://github.com/edgraham/BinSanity) bins to a simplified naming scheme, and prints an output showing the name changes.

Tool 3 creates bin fasta files from the [CONCOCT](https://github.com/BinPro/CONCOCT) binning program output. 
