# Automated Glomerular Histology
This project represents the work done to automate localization and scoring of glomeruli within \Masson's trichrome stained whole kidney slices. While the method was trained in-part using Gomori's Trichrome, the results were not validated and I do not endorse its use for Gomori's. This work was performed and validated on rat histology.

The associated localization method:
J Am Soc Nephrol 29: 2081–2088, 2018. doi: https://doi.org/10.1681/ASN.2017111210

The scoring method has yet to be published.

Please contact me for the production nets. They are too large to host through github.

## Benchmarks
Estimated runtime on a single kidney image.

__System__
- Threadripper 1920X 12-score
- 48 GB Ram
- x3 NVIDIA GeForce GTX 1080 Ti

__Image__
- Image size - 16k x 12k pixels

__Section__
- Split1: ~3.5 minutes
- Split2: ~6 minutes
- Damage Map: ~30 minutes

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

GUI example:

![alt text][GUIExample]




## Generating Damage Maps
With scores assigned to each found glomerulus, you can generate full resolution damage maps using the associated Damage Map scripts. A word of caution, this is not well optimized and it generates full resolution damage maps. The full resolution has the advantage of visually exploring the kidney sample, but you may have issues with image size and resource requirement. Future improvements may want to downsample these output images for publications.

In order to get started you should download the associated code directories to your local machine. Within MATLAB you should then "Set Path" to point toward the code directory and all sub folders.

To use the Damage Map Scripts:
- Using the same format for split1 and split2, pass the original image name as an argument to InterpMapFunc.
- This function first looks for manually scored glomeruli and will use the most recent scores added to the "to be Scored.mat" file (highest column number >= 7). If the manual scores are not available and you have run the automated scoring methods, the automated scores will be used.
- This method relies on having access to the original RGB image and the associated "to be Scored.mat" file.

Damage map example:

![alt text][DamageMapExample]



[GUIExample]: https://github.com/JBukowy/Automated-Glomerular-Histology/icon48.png "Preview of graphical user interface."

[DamageMapExample]: https://github.com/JBukowy/Automated-Glomerular-Histology/blob/master/DamageMapExample.png "Example of a damage map generated using automated scoring."
