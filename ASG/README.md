# Post process on Anti-Scatter Grid

The Varian Truebeam OBI has an anti-scatter grid during measurement. 

However, the EGS_CBCT program does not have the option to calculate anti-scatter grid.

There are several option we can use.

### Build a series lead strip physical model directly in the EGS_cbct program.

### Edit the egs_cbct.cpp or scoring file

### Use the scatter-kernel-superposition (SKS) method to calculate the anti-scatter grid

