# Example data 

## The Varian TrueBeam OBI gives the following data:

### CBCT scanning geometry is  given by the following files:

#### Scan.xml file 

- the distance between the source and detector (origin).
- number of pixels
- pixel size 
- total size of the detector
- Offset of Detector
- Offset of image from origin

#### Reconstruction.xml

- total size of the image 
- number of voxels  
- size of each voxel


#### Acquisitions folder

This folder stores the raw projection data, the data was store in \*.xim files. Each paitent have around 895 projections. 

ReadXim function will read the data out according to the xim file names and returns to uint16 data. Also, the angle of each projection can also be acquired by 

#### Calibrations folder

This folder contains the blank scan.

#### Reconstructions folder

This folder contains the reconstructed image by using the Varian Reconstructor.
