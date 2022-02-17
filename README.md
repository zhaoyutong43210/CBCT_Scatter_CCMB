# Cone Beam CT (CBCT) Real-time Scatter removal project in CancerCare Manitoba

## project overview
Use a deeplearning network (modified U-net) to perform the Cone Beam CT scatter removal in image-guided radiation therapy.

Project Progress

 - [x]  [Varian planning CT & CBCT measurements (paitent data)](example_data/README.md)
 - [x]  [generate paitent phantom from planning CT (and CBCT)](gen_egsphant/README.md)
 - [x]  [generate X-ray source (IAEA_phsp phase space database)](IAEA_phsp/README.md)
 - [x]  [EGS_CBCT simulation based on measurement geometry](CBCT_simu/README.md) ( ~900 projections each patient)
 - [x]  Anti-scatter Grid post process on the simulation results 
 - [ ]  Test scatter removal performance with TIGRE reconstruction toolkit
 - [ ]  Generate Training/Validation/Test data set
 - [ ]  [Train & evaluate the U-net work](U-net/README.md)
 - [ ]  Test on mulitiple paitents dataset
 - [ ]  Publication
 
 Last updated on Feb 16, 2022 by Yutong Zhao

### Codes and Software used in this project: 
* [EGS_CBCT](https://nrc-cnrc.github.io/EGSnrc/doc/pirs898/egs_cbct.html) in the [EGSnrc code system](https://nrc-cnrc.github.io/EGSnrc/)

* MATLAB (2020a or later), 

    - **TIGRE [Paper](https://iopscience.iop.org/article/10.1088/2057-1976/2/5/055010) [Github](https://github.com/CERN/TIGRE)**

* Python (3.6 or later), 
    - **[Tensorflow](https://www.tensorflow.org/)**

some useful toolkit: 

* [MicroDicom Viewer](https://www.microdicom.com/downloads.html), a free software to view the clinical data
* [emeditor](https://www.emeditor.com/text-editor-features/history/emeditor-free/), the free version can view the GB scale text file
* [msi afterburner](https://www.msi.com/Landing/afterburner/graphics-cards), a graphics card software that can overclock the GPU and accelerate the network training. 



### Background knowledge / technique you need to know: 
- Monte Carlo Simulation in Medical Physics
- image-guided radiation therapy
- Deeplearning networks (Machine learning)
- Computed tomography and backprojection reconstruction method
- The scatter and attenuation mechanisms of the X-ray in medium (Rayleigh Scattering, Compton Scattering, Beer-Lamberts law, etc.)

### Nice to know
- parallel computing
- binary data structure
- C++ and fortune coding


## Clinical data.
The data is collected from Varian TrueBeam OBI for Half Fan throax 120kv scanning.

##### Planning CT 
The Scaned patient planning images are stored in *.dcm files. Each file gives the information for each slice.

##### Varian CBCT 

### Monte-Carlo Simulation

### Deeplearning dataset
* Input: Varian OBI measured raw projections
* Ground truth: scatter level pattern with Anti-Scatter grid

### Anti-Scatter Grids
* The anti-scatter grids is corrected by using the scatter-kernal-superposition (SKS) method.

# Conference
  [Improvement on Cone Beam Computed Tomography in radiation treatment using a deep learning network](https://pheedloop.com/compasm2021/site/sessions/?id=SESQ6LQBCRTSB0ZM7).
The COMP Annual Scientific Meeting 2021

# Reference

1. [Improved scatter correction using adaptive scatter kernel superposition](https://pubmed.ncbi.nlm.nih.gov/21030750/)

2. [Developing a tri-hybrid algorithm to predict patient x-ray scatter into planar imaging detectors for therapeutic photon beams](https://mspace.lib.umanitoba.ca/handle/1993/35125)
