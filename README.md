# MATLAB_Porosity_Calculator

Workflow:

1. Obtain the name of image to be processed (excluding a number at the end).  The images received for processing were placed in the same folder as the program for     ease of access and were named the same except for the identifying number at the end.

2. Request the number of images to be processed and the number of the first image to be processed (progresses in an increasing linear fashion to include the number      of images requested)

3. Get the size of the first image and relay this info to the user, and allow the user to choose to crop the image or leave it as it is

4. Indicate which function of the program will be used:
   - Check sensitivity values (Runs through numbers from (first user choice) to (second user choice) (min 1, max 255) to be used to process the images.  Information       will then be relayed from each run to an Excel spreadsheet, where it will be highlighted according to acceptable input values.)
   - Generate images (Creates edited images of the original selection to include highlighted pores.  A sensitivity value is required as an input parameter.)
   - Obtain porosity and pore aspect ratio data (Calculates porosity and pore ratio data from the image(s).)
