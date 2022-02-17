# EGS_CBCT simulation 

## Create an example EGS_CBCT input file

#### Rotation 

Define The Rotation of this scan :

```
:start cbct setup:
        orbit = 360.0
        # step = 1;
        y-rotation = 0.005 # in radians
:stop cbct setup:
```

#### X-ray light source + Patient phantom

Define The X-ray source :

```
:start source:
	library 	= iaea_phsp_source
	name 		= iaea_source
	iaea phase space file = D:\IAEA_phsp\Varian_cbct_120kv 
	particle type = all
	# cutout = x1 x2 y1 y2  (optional)
	# weight window = wmin wmax, the min and max particle weights to use. If the particle weight is not in this range, it is rejected. (optional)
	recycle photons = 10  #number of times to recycle each photon (optional)
	#recycle electrons = number of times to recycle each electron (optional)
:stop source:
```


Define the Patient phantom: 

```
:start geometry:
    library = egs_ndgeometry
    type    = EGS_XYZGeometry
    name    = phantom
    egsphant file = C:\EGSnrc-master\egs_home\egs_cbct\throaxCauch_305655.egsphant
	  ct ramp = C:\EGSnrc-master\egs_home\egs_cbct\example_thorax.ramp
:stop geometry:
```
and the blank phantom used in calibration
```
:start geometry:
    library = egs_box
    type    = EGS_box
    name    = blank_phantom
    box size = 40 40 40
    :start media input:
       media = AIR521ICRU
    :stop media input:
:stop geometry:
```

#### Variance Reduction Technique - Fix splitting

```
:start variance reduction:
   scoring type =  forced_detection  # scores photons AIMED at scoring plane  
   delta transport medium = AIR521ICRU # AIR521ICRU LUNG521ICRU ICRUTISSUE521ICRU ICRPBONE521ICRU
   FS splitting = 180 300 # Np Ns
:stop variance reduction:
```


#### Scoring plane
```
:start scoring options:

    calculation type = planar 

      :start planar scoring:
           #minimum Kscat fraction = 0.5
           surrounding medium = AIR521ICRU   # AIR521ICRU or VACUUM 
           screen resolution = 192 256   # 40 cm X 30 cm screen(Yreso)x(Xreso)
           voxel size = 0.1552 0.1552  # This needs to be tested
           :start transformation:        
              translation = 16 0 50
              rotation = 0 0 0
           :stop transformation:
            # Uses file provided in the distribution
            muen file = C:\EGSnrc-master\egs_home\egs_fac\examples\muen_air.data
     :stop planar scoring:

:stop scoring options:
```
#### Histories

Once we create this example EGS_CBCT input file, we can run it and have a look of the simulation result.

## Generate a batch of egsinp file ( ~895 projections + 1 blank scan)

## Parallel computing (in our computer, we use 30 threads, with 32 maximum )

It would take around a week to do the whole set of simulations. Sometimes, the MATLAB will encounter into some issue after a few days. 
All you need to do is close it, restart the system, and run this code again (make sure you adjusted mode to "continue a scan mode", don't run the "new mode"), it will skip the finished simulations and continue the scan. 

So you just lose the result that haven't finished (may a few hours but not a lot). After the simulation is done, you should get enough \*.egsmap files correponding to the total number of measured projections

## Data process 
