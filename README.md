# Cone Beam CT (CBCT) Real-time Scatter removal project in CancerCare Manitoba

## project overview
Use a deeplearning network (modified U-net) to perform the Cone Beam CT scatter removal in image-guided radiation therapy.

Project Progress

 - [x]  [Varian planning CT & CBCT measurements (paitent data)](example_data/README.md)
 - [x]  [generate paitent phantom from planning CT (and CBCT)](gen_egsphant/README.md)
 - [x]  [generate X-ray source (IAEA_phsp phase space database)](IAEA_phsp/README.md)
 - [x]  [EGS_CBCT simulation based on measurement geometry](CBCT_simu/README.md) ( ~900 projections each patient)
 - [x]  [Anti-scatter Grid post process on the simulation results](ASG/README.md)
 - [ ]  [Test scatter removal performance with TIGRE reconstruction toolkit](scatter_remove/README.md)
 - [ ]  Generate Training/Validation/Test data set
 - [ ]  [Train & evaluate the U-net work](U-net/README.md)
 - [ ]  Test on mulitiple paitents dataset
 - [ ]  Publication


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


## Clinical data

The data is collected from Varian TrueBeam OBI for Half Fan thorax 125kv scanning in CancerCare Manitoba. Due to privacy, we can not upload the data to this project.
The data is guaranteed access to qualified persons only.

The clinical data contains the planning CT images (reconstruction), CBCT images (reconstruction), and the CBCT projections (Raw data). 
The planning CT and the CBCT is reconstructed by the Varian Reconstructor which is a commerical software.
In this project, we use the TIGRE in MATLAB as our reconstruction method.
The image quanlity of the Varian Reconstructor is a little better, but TIGRE is also giving a fairly good result. 

## Monte-Carlo Simulation

We use the EGSnrc to do the Monte-Carlo simulation to get the scatter distribution on certain measured projection (clinical data). 
For each projection, we perform a EGS_CBCT simulation to evaluate the scatter distribution.
Variance Reduction technique has been adpoted to increase the calculation efficiency.

Once we know the how the scattered photons is contaminating the measured signal, we can substract the scattered signal and produce a cleaned projection. 
Send these cleaned data to the reconstructor will provide us cleaned patient images. 
And the simulation time would be around 2.7 hours each projection. 

## Reconstruction with TIGRE

The open-source code, TIGRE, is used in this project to perform the reconstructions from CBCT projections. 

## Deeplearning 
#### dataset:
* Input: Varian OBI measured raw projections
* Ground truth: scatter level pattern with Anti-Scatter grid

First stage : single patient

Second stage : multiple patients with ground truth

Third stage: test with a unseen patient


#### Architecture(s):
*  [x] U-net 4 layer (modified)
*  [x] U-net 6 layer (modified)
*  [ ] U-net++ 


### Anti-Scatter Grids
* The anti-scatter grids is corrected by using the scatter-kernal-superposition (SKS) method. Please see the reference [1].

## Results



# Conference
  [Improvement on Cone Beam Computed Tomography in radiation treatment using a deep learning network](https://pheedloop.com/compasm2021/site/sessions/?id=SESQ6LQBCRTSB0ZM7).
The COMP Annual Scientific Meeting 2021

# Reference

1. [Improved scatter correction using adaptive scatter kernel superposition](https://pubmed.ncbi.nlm.nih.gov/21030750/)

2. [Developing a tri-hybrid algorithm to predict patient x-ray scatter into planar imaging detectors for therapeutic photon beams](https://mspace.lib.umanitoba.ca/handle/1993/35125)
