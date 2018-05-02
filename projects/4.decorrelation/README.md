# De-correlation Analysis in Tracking Algorithm

Radiofrequency(RF) data is used to derived the B-Mode ultrasound image in clinical and research application. Due to the system noise (actually interferences of acoustic reflection waves), the B-Mode ultrasound image of bone and tissue has speckle pattern. People believed these pattern are determined by the local microstructures and thus can be used to represent their features. Under the assumption of unchanged speckle pattern during tissue deformation, one can perform speckle tracking to find the displacements in region of interest (ROI).

The common steps of speckle tracking include
1. outline ROI (ex. 100 x 100)
2. The ROI is divided into smaller patches with dimensions (ex. 20x20). Each patch groups a few signal data. People call it kernel in computer vision. If we don't allow overlap between patch, then it has 25 (5x5) patches in the ROI, but for speckle tracking, we usually allow overlap of 50%. So approximately we will have 400 patches in ROI.
3. The movement of each patch is tracked between frames by correlation method. For example, if the patch moves a few pixels from frame 1 to frame 2, we can find this displacement by searching the patch pattern in frame 2, under the assumption that it remained unchanged. The searching method terminates when the most likely pattern is found, which could be the maximum correlation ratio (NCC/SSD-based), or the optimal solution for some function(optical flow).
4. Repeat step 3 for every patch for 400 times.
5. Interpret the 400 displacements related to the location of patch, and form a displacement map.

The goal of the current project is to test if the de-correlation is the cause of decreased accuracy in ultrasound movement measurement. The assumption of unchanged pattern isn't true, due to all kind of noise sources. In our previous experiment, we identified two factors, velocity and tissue layer, could possibly change the tracking measurement accuracy. We hope to further investigate whether velocity and the tissue layer would increment signal de-correlation, which is believed to be the direct cause of tracking failure.  

Phase I:
Use tracking result to find the degree of de-correlation
Result: de-correlation ratio decreases over the velocity. Range of values: 0.951 (1mm,4Hz) to .9334(4mm, 10Hz)
Observation: 1/x dependence
Possible Improvements:
a. rewrite the code, take "xlsread" out of loops because of speed
b. trim the data better in each time segments
c. correlate the actual speed, rather than absolute average velocity, to the correlation correlation


Phase II:
Use original raw images and results to find the degree of de-correlation
