# EGS_CBCT simulation 

## Create an example EGS_CBCT input file

#### Rotation 

Define The Rotation of this scan :

#### X-ray light source + Patient phantom

Define The X-ray source :


Define the Patient phantom: 


#### Variance Reduction Technique - Fix splitting

#### Scoring plane

#### Histories

Once we create this example EGS_CBCT input file, we can run it and have a look of the simulation result.

## Generate a batch of egsinp file ( ~895 projections + 1 blank scan)

## Parallel computing (in our computer, we use 30 threads, with 32 maximum )

It would take around a week to do the whole set of simulations. Sometimes, the MATLAB will encounter into some issue after a few days. 
All you need to do is close it, restart the system, and run this code again (make sure you adjusted mode to "continue a scan mode", don't run the "new mode"), it will skip the finished simulations and continue the scan. 

So you just lose the result that haven't finished (may a few hours but not a lot). After the simulation is done, you should get enough \*.egsmap files correponding to the total number of measured projections

## Data process 
