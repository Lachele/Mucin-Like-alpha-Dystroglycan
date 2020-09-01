2020-08-31  BLFoley

# Overview

This repo accompanies a publication detailing an experimental and 
computational analysis of some mucin-relevant compounds.  It contains
all the information needed to recreate the simulations, treat the 
simulated data, and analyze the data.  I couldn't include the 
simulation output or the data from all the treatments and analyses 
because the file sizes are too large.  

Before making the repo, I tried to cull out files that are obviously
not relevant.  But, this is a large project spanning many years,
so here there may be cruft.

Currently, this entire repo, in context with the simulation data,
can be accessed at the location below.  It's 110+ GB in total.

http://glycam.org/files/2020/Mucin-Like-alpha-Dystroglycan/

Please open a ticket or contact me otherwise if you are having 
trouble understanding anything in this repo or in the full
dataset at the link above.

# Contents

parms 
: The force field parameters that were used to generate the raw data. 

RAW
: Information relevant to the generation of the raw data.

README.md
: This file

scripts
: The most recent set of scripts.  These are the main scripts used throughout 
  the data generation and analysis.  But, see more about this below.

TREATED 
: Information relevant to any treatments or analyses of the data.
  See more about this below.

# General Notes

## Absolute Paths and Other Names

The information contained in the directory called _RAW_ used to live in a
path that ended with `DLIVE_MD_FINAL_STATE`.  The data contained in the 
directory called _TREATED_ used to live in a path that ended with `DLIVE`.
If you see references to these paths, translate accordingly.

As soon as the script forms began to settle, I moved them to my Dropbox.
You will probably find path references there.  Whenever you see a reference
to Dropbox/something/scripts, translate that into the _scripts_ directory.

In both the _RAW_ and _TREATED_ directories, the following definitions apply:

d4g 
: The short name applied to the GalNAc-modified peptide.

d4m
: The short name applied to the Mannose-modified peptide.

protein
: The short name applied to the unmodified peptide.

Names such as _Eliot_, _Tolkien_, _Rime_, _Nemhain_, _Hoar_, etc., are 
names of specific computers that were used to perform one or more tasks.

## Scripts

The _scripts_ directory at the top level contains the scripts that were used
for the majority of the generation and analyses.  However, early versions of
the scripts might prove to be useful, so they are retained in RAW and TREATED
directories as scripts.early and scripts.legacy, respectively.  

As an example of a change, consider these older scripts:

```
RAW/scripts.early/make_cpptraj_files.bash
RAW/scripts.early/make_cpptraj_files_d4m.bash
```

These two files are nearly identical except that the first is for d4g and
the second does some extra work relevant to d4m.  They are both named 
pretty badly because a 'cpptraj file' could mean nearly anything.  

They are retained because they were, indeed used.  However, in the
newer _scripts_ directory, they became this file:

```
scripts/make_cpptraj_files_for_analysis.bash
```

...which, in turn, came to have a much nicer name and finally contained
code that could be more generally applied:

```
scripts/make_cpptraj_files_for_NMR_structures.bash
```

I suspect it will not be difficult to follow trails such as these if needed.
But, feel free to contact me if you can't figure something out.

### Moved For Safety

Directories called `moved_for_safety` contain scripts that used to exist at the
same level of the directory.  But, as the name implies, they were moved for 
reasons of safety.  Specifically, these are scripts designed to be used to 
start or restart the set of simulations.  As such, if run at any time after
this initial phase, they could be destructive.  They were moved into these
directories to minimize the chance that they might be run accidentally.

Most other scripts can be run at any time.  They might overwrite existing 
files, but the new files would be identical (except time stamps and such) or
would only update to reflect the current state of the data.

_However_, don't trust me on the latter.  Check first.  :-) 


