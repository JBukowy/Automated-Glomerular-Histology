# Automated Glomerular Histology
 This project represents the work done to automate localization and scoring of glomeruli within \Masson's trichrome stained whole kidney slices. This work was performed and validated on rat histology.

The associated localization method:
J Am Soc Nephrol 29: 2081–2088, 2018. doi: https://doi.org/10.1681/ASN.2017111210

The scoring method has yet to be published.

## Running the Localization/Scoring Scripts
The current methods were created and run on MATLAB version 2017b.
Required Toolboxes include:
- distrib_computing_toolbox
- image_toolbox
- neural_network_toolbox
- optimization_toolbox
- phased_array_system_toolbox
- statistics_toolbox

In order to get started you should download the associated code directories to your local machine. Within MATLAB you should then "Set Path" to point toward the code directory and all sub folders.

From the matlab command window, navigate to the folder containing the RGB tif images that you wish to process. The methods, in their current form, can be run using two function calls.

- The first function call required is to "glomlocalizer_deNovo_split1". The only argument that needs to be passed is a string of the file/image you wish to process. Upon successful completion of split1, the "Stain EQ.tif" and "Stain Seperated.tif" files should be created in your working directory.

- The second function call required is to "glomlocalizer_deNovo_split2". Again, the only argument that needs to be passed is a string of the file/image you wish to process. This string should be the same used for split1. This will produce 2 additional files in the current working directory. "Detected Glomeruli.tif" is a grayscale image of the kidney with yellow boxes indicating where glomeruli were detected. The second file, "to be Scored.mat" contains the necessary information for scoring the glomeruli. See split2 documentation for more information.

- Please contact me for the production nets. They are too large to host through github.

## Processing/Scoring Detected Glomeruli
Once you have generated the "to be Scored.mat" files you may wish to manually assign injury scores to the glomeruli. Code included in "Manual Glomeruli Scorer" will display a GUI for manual scoring.

To use the GUI:
- Within MATLAB, navigate to the folder containing the GUI code, right click the .m file (gloMinate_Manual_Scoring.m) and select "Run".
- Select "Load Kidney" and select the desired "to be Scored.mat" file.
- The first glomeruli within the dataset will then be displayed and the program will wait for you to register a score (between 0 and 4) or select N/G (not glomerulus).
- The user may either click the radio button and select "Register" or they may use the number keys on the keyboard. Note: The focus must be in the GUI. If the number buttons are not working, click on the image of the glomerulus. This should only have to be done once.
- All glomeruli from a single sample must be scored within the same session. __Partial completion will not be saved.__
- Upon scoring all glomeruli, the "to be Scored.mat" file will have the scores appended to the next column within the output cell matrix. You will have to extract these for final analysis.
- __The third column in "to be Scored.mat" contains the automated scores. These may be useful for comparison to manual scores, but this method is not yet published.__
