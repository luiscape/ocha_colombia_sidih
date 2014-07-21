OCHA Colombia
=============
Script to transform the OCHA Colombia databae into the HDX format (CPS). It loads a database with 1,276,335 values, transforms the entities and timespans of the observations into those accepted by CPS.

The file `value.csv` is too big for GitHub (400 + mb). You will find that file inside the compressed file `[ocha-colombia-sidih.zip](data/cps/ocha-colombia-sidih.zip)`.



Example
-------

The `COL.B.UNK.0099` is the GDP at constant 1994 prices. That indicator has data for the Departamentos in Colombia (equivalent to States in the United States). Here is a simple visualization of that indicator across all the states:

![]()

The names of the states (and other geographic locations) can be mapped with the data available in this repository: https://github.com/luiscape/colombia_pcode . Unfortunately, the repository uses a newer version of the name mapping and some codes may not exist in the list.