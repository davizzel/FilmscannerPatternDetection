# FilmscannerPatternDetection
Pattern-Detection for recognizing test-chart pattern for evaluating MTF.
Converts Raw-Image-Data to tiffs and debayeres them in the first step. 
In the second step the user can select the pattern to be found in various scales in the image.
The program then will search for the pattern (and a 90° rotation of it) in different smaller scales using normxcorr2.
The resulting matches are saved in an array (coordinates and size of the boxes surrounding the pattern).
