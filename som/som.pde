Cell[][] som; // storing the SOM
float[][] u_matrix_values; // storing the U-matrix
int[][] bmu_locations; // storing the bmu locations
float[][] training_times; // unused


// pallet size (400 = 40 nodes)
int n = 400;
int m = 400;

// other hyper parameters and formulas
int iterations = 5000;
int current_iteration = 1;
int num_training_colors = 30;
float learning_rate = .1;
float learning_radius = (n/10)/2;
float time;

// flag variables
boolean run = false;
boolean scalability_test = false;
boolean draw_bmus = true;

// SOM metrics
float topographical_error;
float quantization_error;

// storing the training colors
color[] training_colors = new color[num_training_colors]; 


// initialize the pallete to be nxm with extra room for stats at the bottom
void settings(){
  size(n+n+10,m+50);
}


void setup(){

  // set backround color to black and create SOM cells
  background(0);
  
  // reset board, draw the new training colors, and draw initial text
  reset();
  draw_training_colors();
  draw_text();
  
}

// Train the model 1 epoch at a time
void train(color c, int t){
  
  // set first bmu to the first SOM cell
  Cell training_cell = new Cell(red(c)/255, green(c)/255, blue(c)/255);
  float bmu = som[0][0].get_euclidean_distance(training_cell);

  
  // calculate SOM metrics every time we have trained on all colors and at the end of trainig
  if (current_iteration % num_training_colors == 0 || current_iteration == iterations){
    calc_som_metrics();
  }
  

  // remember bmu location
  int x = 0;
  int y = 0;
  
  // calculate the learning radius for the current iteration
  float learning_radius_t = (learning_radius/iterations) * (iterations - t);
  float learning_rate_t = (learning_rate/iterations) * (iterations - t);
      
      
  // get distance for each node updating the best matching unit
  for(int i = 0; i < n/10; i++){
   for(int j = 0; j < m/10; j++){
     
     float new_bmu = som[i][j].get_euclidean_distance(training_cell);
      
      // new bmu found
     if(new_bmu < bmu){
      bmu = new_bmu;
      x = i;
      y = j;
    }
   }

  }
  
  // save bmu locations so that we can show the user
  bmu_locations[current_iteration%(num_training_colors)][0] = x;
  bmu_locations[current_iteration%(num_training_colors)][1] = y;
  
  
  // find all of the nodes that are within the learning radius
  for(int i = 0; i < n/10; i++){
   for(int j = 0; j < m/10; j++){
     
     // physical distance between nodes on the grid
     float radius = euclidean_distance(new float[]{i,x,j,y});
     if(radius < learning_radius_t){

       float rate = learning_rate_t * (1/(radius + 1));
       som[i][j].update(training_cell, rate);
       
       
     }
   }
  }
}

void calc_u_matrix_values(){

  // calculate the inner nodes
  for(int i = 10; i < n-10; i = i + 10){
    for(int j = 10; j < m-10; j = j + 10){
      
      float total_distance = 0;
      total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j-10)/10]); // up left
      total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j-10)/10]); // up
      total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j-10)/10]); // up right
      total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j)/10]); // left
      total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j)/10]); // right
      total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j+10)/10]); // down left
      total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j+10)/10]); // down
      total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j+10)/10]); // down right

      u_matrix_values[i/10][j/10] = total_distance/8;

    }
  }

    // calculate the top nodes excluding corners
  for(int i = 10; i < n-10; i = i + 10){
    int j = 0; // som[i][0]

    float total_distance = 0;
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j)/10]); // left
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j)/10]); // right
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j+10)/10]); // down left
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j+10)/10]); // down
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j+10)/10]); // down right

    u_matrix_values[i/10][j/10] = total_distance/5;
  }

    // calculate the bottom nodes excluding corners
  for(int i = 10; i < n-10; i = i + 10){
    int j = m-10; // som[i][39]

    float total_distance = 0;
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j-10)/10]); // up left
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j-10)/10]); // up
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j-10)/10]); // up right
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j)/10]); // left
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j)/10]); // right

    u_matrix_values[i/10][j/10] = total_distance/5;
  }

  // calculate the left nodes excluding corners
  for(int j = 10; j < m-10; j = j + 10){
    int i = 0; // som[i][j]

    float total_distance = 0;
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j-10)/10]); // up
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j-10)/10]); // up right
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j)/10]); // right
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j+10)/10]); // down
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j+10)/10]); // down right
    

    u_matrix_values[i/10][j/10] = total_distance/5;
  }

  // calculate the right nodes excluding corners
  for(int j = 10; j < m-10; j = j + 10){
    int i = n-10; // som[39][j]

    float total_distance = 0;
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j-10)/10]); // up left
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j-10)/10]); // up
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j)/10]); // left
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j+10)/10]); // down left
    total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j+10)/10]); // down
    
    u_matrix_values[i/10][j/10] = total_distance/5;
  }

  // calculate the top left node
  int i = 0;
  int j = 0;

  float total_distance = 0;
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j)/10]); // right
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j+10)/10]); // down
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j+10)/10]); // down right

  u_matrix_values[i/10][j/10] = total_distance/3;

  // calculate the top right node
  i = n-10;
  j = 0;

  total_distance = 0;
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j)/10]); // left
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j+10)/10]); // down left
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j+10)/10]); // down

  u_matrix_values[i/10][j/10] = total_distance/3;

  // calculate the bottom left node
  i = 0;
  j = m-10;

  total_distance = 0;
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j-10)/10]); // up
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j-10)/10]); // up right
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j)/10]); // right

  u_matrix_values[i/10][j/10] = total_distance/3;

  // calculate bottom right node
  i = n-10;
  j = m-10;

  total_distance = 0;
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j-10)/10]); // up left
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j-10)/10]); // up
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j)/10]); // left

  u_matrix_values[i/10][j/10] = total_distance/3;


  // lets normalize the values
  float x_min = u_matrix_values[0][0];
  float x_max = u_matrix_values[0][0];
  for(int i1 = 0; i1 < n; i1 = i1 + 10){
    for(int j1 = 0; j1 < m; j1 = j1 + 10){
     if (u_matrix_values[i1/10][j1/10] < x_min)
     x_min = u_matrix_values[i1/10][j1/10];

     if (u_matrix_values[i1/10][j1/10] > x_max)
     x_max = u_matrix_values[i1/10][j1/10];
    }
  }

  // change the values in the matrix
  for(int i1 = 0; i1 < n; i1 = i1 + 10){
    for(int j1 = 0; j1 < m; j1 = j1 + 10){
     u_matrix_values[i1/10][j1/10] = (u_matrix_values[i1/10][j1/10] - x_min)/(x_max-x_min);
    }
  }
}

void calc_som_metrics(){

  // initialize sum variables
  int not_close_nodes = 0;
  float sum_euclidean_distance = 0;

  // find BMU and second BMU for all training colors
  for (color c : training_colors){

    Cell training_cell = new Cell(red(c)/255, green(c)/255, blue(c)/255);
    float bmu = som[0][0].get_euclidean_distance(training_cell);
    float second_bmu = 0;
    int bmu_x = 0;
    int bmu_y = 0;
    int second_bmu_x = 0; 
    int second_bmu_y = 0;

    for(int i = 0; i < n/10; i++){
      for(int j = 0; j < m/10; j++){
     
        float new_bmu = som[i][j].get_euclidean_distance(training_cell);
      
        // new bmu found, save old bmu
        if(new_bmu < bmu){
         second_bmu = bmu;

         second_bmu_x = bmu_x;
         second_bmu_y = bmu_y;

         bmu = new_bmu;

         bmu_x = i;
         bmu_y = j;

        }
      }   
    }

    // record bmu distance
    sum_euclidean_distance += bmu;

    // determine if first and second bmu are next to one another
    int x_diff = abs(bmu_x - second_bmu_x);
    int y_diff = abs(bmu_y - second_bmu_y);

    // if not, add one to the tally
    if (!((x_diff <= 1 && y_diff == 0) || (x_diff == 0 && y_diff <= 1) || (x_diff == 1 && y_diff == 1))){
      not_close_nodes += 1;
    }
  }

  // average the sums to finish the equation
  quantization_error = (1/float(num_training_colors)) * sum_euclidean_distance;
  topographical_error = (1/float(num_training_colors)) * not_close_nodes;

}

void reset(){
  
  current_iteration = 1;
  run = false;


  
  // choose new training colors
  for(int i = 0; i < num_training_colors; i++){
    training_colors[i] = color(random(0,255),random(0,255),random(0,255));
  }
  
  bmu_locations = new int[num_training_colors][2];
  
  // allocate new SOM and U-matrix array
  som = new Cell[n/10][m/10];
  u_matrix_values = new float[n/10][m/10];
  
  // create boxes with randomized colors, initialize cells with rgb values
  for(int i = 0; i < n; i = i + 10){
    for(int j = 0; j < m; j = j + 10){
     float r = random(0, 255);
     float g = random(0, 255);
     float b = random(0, 255);
     fill(r,g,b);
     stroke(0);
     rect(i,j,10,10);
     
     som[i/10][j/10] = new Cell(r/255,g/255,b/255);
     u_matrix_values[i/10][j/10] = 1;
    }
  }
  
  // drawing calls
  calc_u_matrix_values();
  draw_u_matrix();
  draw_training_colors();
  draw_text();
  
}





void draw(){
  // user input
  if(keyPressed) {
    switch(key){

      // start training the SOM
      case '1':
        if(!run){
          run = !run;
          time = millis();
        }
        break;

      // reset the SOM
      case 'r':
         reset();
         break;

      // toggle the bmu indicators
      case 'b':
        draw_bmus = !draw_bmus;
        delay(100);
        break;

        
    }
  
   
 }
 
 // during training
 if(run && current_iteration <= iterations){

   // run the iteration
   train(training_colors[current_iteration%(num_training_colors)], current_iteration);

   // update the I-matrix
   calc_u_matrix_values();
   
   // draw the text, SOM, and U-matrix
   draw_text();
   draw_squares();
   draw_u_matrix();

   // draw the bmus if toggled
   if (draw_bmus)
   draw_bmu_locations();

   // update the current iteration
   current_iteration += 1;
 } 
 else // after training we can still modify the gui
 {
   //draw_text(); we dont draw text anymore so that the timer "stops"
   draw_squares();
   draw_u_matrix();

   if (draw_bmus && current_iteration > 1)
   draw_bmu_locations();

 }
 

}
