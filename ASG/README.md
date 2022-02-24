# Post process on Anti-Scatter Grid

The Varian Truebeam OBI has an anti-scatter grid during measurement. 

However, the EGS_CBCT program does not have the option to calculate anti-scatter grid.

There are several option we can use.

### 1. Build a series lead strip physical model directly in the EGS_cbct program.

### 2. Edit the egs_cbct.cpp or scoring file

### 3. Use the scatter-kernel-superposition (SKS) method to calculate the anti-scatter grid

# Monte-Carlo simulation with anti-scatter grid
A simple Monte-Carlo simulation is made to test the the grid response function. 
Use  ```grid_response_function_MC.m``` to initialize the Monte-Carlo simulation, this code will randomly generate a uniform distribution of scattered photons towards a certain imager local area (pixels). 
The code will determine if the photon has been interacted with the lead strip of the scatter grid, and assign a transmission to every single photon. 
One the photons reach to a certain number (to decrease the statistical uncertainty), we take the average value of the transmission of the simulated pixel and record its scatter angle. 
Next, we referesh  the target pixel and loop over this process. The results is saved to a \*.m file for further process.

This code assumes that: 
* the scattered photons are isotropic or quasi-isotropic.
* the scatter only ocurred within the scaned area. (ignoring the air, and assume the homogeneous scanned phantom)

```grid_response_function.m``` take the simulated results and plot it. A linear fitting curve can also been displayed.
please see the figure below: 


# Directly modelling the lead strips of the Anti-scatter grids in EGSnrc models
