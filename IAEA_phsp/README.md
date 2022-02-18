# Generate IAEA_phsp data files for CBCT KV scanning simulations 

### Why do we need the IAEA source instead of the EGS base source? 

The EGSnrc code system got several source option to use in the simulation. The simple collimated source (isotropic) was used in the EGS_CBCT example file, however, this source is not identical to the real world measurement. 

[EGS base source](https://nrc-cnrc.github.io/EGSnrc/doc/pirs898/classEGS__BaseSource.html) gives all available source in the EGSnrc simulations. Since the CBCT measurement source is an anisotropic source modified by a bow-tie filter (Full Fan or Half Fan), we need to define the simulation source accordingly.

!(Bowtie Filters)[./bowtiefilters.png]

To achieve this, the only options we have are the following: 
   - make a source simulation from BEAMnrc and use the output file as an [EGS beam source](https://nrc-cnrc.github.io/EGSnrc/doc/pirs898/classEGS__BeamSource.html), taking the X-ray tube, collimator, beam hardening foil and bow-tie fileter into consideration. and this could be complicated but it would be very accurate if we did everything correct.
   
   or
   
   - use the measured blank scan (empty scan during calibration) generate a phase space file, using the  [IAEA phsp source](https://nrc-cnrc.github.io/EGSnrc/doc/pirs898/classIAEA__PhspSource.html) or [EGS phsp source](https://nrc-cnrc.github.io/EGSnrc/doc/pirs898/classEGS__PhspSource.html). This may not be accurate but it would be relatively easy to achieve.

### IAEA_PHSP Phase-space database for external beam radiotherapy

There are a lot of [MV sources](https://www-nds.iaea.org/phsp/photon1/) ready to use on the [international atomic energy institute (IAEA) website](https://www-nds.iaea.org/phsp/phsp.htmlx). 

### The IAEA database for EGSnrc simulation 

However, the KV source is not on that and the KV blank scan could differs from paitent to paitent. Therefore, I decided to make a code to generate the customized database for this project.

   1. Import the blank scan image file and the scanning geometry (get the X-ray source space location). 
   2. Generate the X-ray source energy spectrum by using [SpekPy v2.0](https://bitbucket.org/spekpy/spekpy_release/wiki/Home). 
   3. Generate the  data and transfer it to binary format.
   4. Write the data into IAEA database files (binary data into \*.IAEAphsp file and ascii header into \*.IAEAheader file)
   
   Then, the generated IAEA database should be ready to use for EGSnrc simulations

During this time, the example files provided by the IAEA database helped me alot to learn the data structure.

#### Convert IAEA binary file to ASCII file

A generic converter from IAEA to ASCII is given by IAEA. To use it, open the IAEA2ascii.exe file, type the IAEA_phsp filename without extension.

#### Generate the source data



#### Write the source data


## Results

