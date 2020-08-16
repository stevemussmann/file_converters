# file_converters
A collection of file format converters to prepare input for several popular phylogenetic and population genetics software packages.


## stacksStr2immanc.pl
This script converts the structure files output by Stacks to .immanc format for analysis in BA3-SNPs. The '-p' option can be used to select specific populations for inclusion in the .immanc file. This is done by providing a comma-delimited list in quotes on the command line. The '-s' option is used to specify the input Structure file. The '-o' option is used to provide the output file name. Example:

```
 stacksStr2immanc.pl -p "NFV,NTH,WFA" -s populations.structure -o NFV+NTH+WFA.immanc
```
