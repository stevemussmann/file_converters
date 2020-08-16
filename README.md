# file_converters
A collection of file format converters to prepare input for several popular phylogenetic and population genetics software packages.


## stacksStr2immanc.pl
This script converts the structure files output by Stacks to .immanc format for analysis in BA3-SNPs. The '-p' option can be used to select specific populations for inclusion in the .immanc file. This is done by providing a comma-delimited list in quotes on the command line. The '-s' option is used to specify the input Structure file. The '-o' option is used to provide the output file name. Example:

```
 stacksStr2immanc.pl -p "NFV,NTH,WFA" -s populations.structure -o NFV+NTH+WFA.immanc
```

## pyradStr2immanc.pl
This script converts the structure files output by pyRAD to .immanc format for analysis in BA3-SNPs. Since the structure file output by pyRAD does not contain any population information, you must provide a tab-delimited population map that contains all the individuals in your structure file as well as their assigned population. Each line in this file should contain population information in the format of "sample<tab>population". The name of the population map is provided with the '-m' option. The '-p' option can be used to select specific populations for inclusion in the .immanc file. This is done by providing a comma-delimited list in quotes on the command line. The '-s' option is used to specify the input Structure file. The '-o' option is used to provide the output file name. Example:

```
 pyradStr2immanc.pl -m map.txt -p "NFV,NTH,WFA" -s pyrad_output.str -o NFV+NTH+WFA.immanc
 ```
