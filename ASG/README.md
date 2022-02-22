# Post process on Anti-Scatter Grid

The Varian Truebeam OBI has an anti-scatter grid during measurement. 

However, the EGS_CBCT program does not have the option to calculate anti-scatter grid.

There are several option we can use.

### 1. Build a series lead strip physical model directly in the EGS_cbct program.

### 2. Edit the egs_cbct.cpp or scoring file

### 3. Use the scatter-kernel-superposition (SKS) method to calculate the anti-scatter grid

# Monte-Carlo simulation with anti-scatter grid

# Directly modelling the lead strips of the Anti-scatter grids in EGSnrc models
