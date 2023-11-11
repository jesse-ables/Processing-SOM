# Processing-SOM
A visual SOM programmed in processing. This is not a generalized SOM algorithm. This was just a simple project to get back into programming in Processing while also understanding SOMs for research purposes. http://jjguy.com/som/ was used for the initial concept. The goal was to make as much of this from scratch as possible. I believe the above website also links to another SOM website that had some useful insights. The SOM includes visualizations for a RGB dataset and a U-matrix to visualize the distance between nodes.

![RGB SOM with U-Matrix](https://github.com/jesse-ables/Processing-SOM/blob/main/som_screenshot.png)

# Dependencies
Processing 4



# How to Run
- Download Processing 4 from https://processing.org/download
- Download the SOM folder from this github page
- Open Processing
- Open the som.pde file
- Tapping '1' will cause the SOM to run
- Pressing 'r' will reset the SOM and training colors

To modify parameters, open the 'som.pde' file. At the top there are parameters for:
- n x m grid of nodes: These must be divisible by 10. (n = 400, m = 400 equates to a 40x40 SOM)
- iterations: total number of training iterations.
- num_training_colors: total number of training colors (30 is the max that can be seen at the bottom of the GUI. You can do more, but you won't be able to see them.)
- learning_rate: how aggressively we change the SOM node values.

There are a couple of other values that you can change like the initial neighborhood radius and how it reduces with respect to iterations.
