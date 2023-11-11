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
float radius_reduction = learning_radius/iterations;
float learning_reduction = ((1 + learning_rate)/iterations) - 1;
float time;

// flag variables
boolean run = false;
boolean scalability_test = false;
boolean draw_bmus = true;

color[] training_colors = new color[num_training_colors]; // storing the training colors


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
  float[] values = {som[0][0].r, red(c)/255, som[0][0].g, green(c)/255, som[0][0].b, blue(c)/255};
  float bmu = euclidean_distance(values);
  Cell training_cell = new Cell(red(c)/255, green(c)/255, blue(c)/255);

  int x = 0;
  int y = 0;
  
  // calculate the learning radius for the current iteration
  float learning_radius_t = (learning_radius/iterations) * (iterations - t);
  float learning_rate_t = (learning_rate/iterations) * (iterations - t);
      
      
  // get distance for each node updating the best matching unit
  for(int i = 0; i < n/10; i++){
   for(int j = 0; j < m/10; j++){
     float new_bmu = euclidean_distance(new float[]{som[i][j].r, red(c)/255, som[i][j].g, green(c)/255, som[i][j].b, blue(c)/255});
      
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
     
     float radius = euclidean_distance(new float[]{i,x,j,y});
     if(radius < learning_radius_t){
       float rate = learning_rate_t * (1/(radius + 1));
       som[i][j].update(training_cell, rate);
       
       fill(som[i][j].r * 255, som[i][j].g * 255, som[i][j].b * 255);
       stroke(0);
       rect(i*10,j*10,10,10);
       
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

      u_matrix_values[i/10][j/10] = total_distance;

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

    u_matrix_values[i/10][j/10] = total_distance;
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

    u_matrix_values[i/10][j/10] = total_distance;
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
    

    u_matrix_values[i/10][j/10] = total_distance;
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
    
    u_matrix_values[i/10][j/10] = total_distance;
  }

  // calculate the top left node
  int i = 0;
  int j = 0;

  float total_distance = 0;
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j)/10]); // right
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j+10)/10]); // down
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j+10)/10]); // down right

  u_matrix_values[i/10][j/10] = total_distance;

  // calculate the top right node
  i = n-10;
  j = 0;

  total_distance = 0;
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j)/10]); // left
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j+10)/10]); // down left
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j+10)/10]); // down

  u_matrix_values[i/10][j/10] = total_distance;

  // calculate the bottom left node
  i = 0;
  j = m-10;

  total_distance = 0;
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j-10)/10]); // up
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j-10)/10]); // up right
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i+10)/10][(j)/10]); // right

  u_matrix_values[i/10][j/10] = total_distance;

  // calculate bottom right node
  i = n-10;
  j = m-10;

  total_distance = 0;
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j-10)/10]); // up left
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i)/10][(j-10)/10]); // up
  total_distance += som[i/10][j/10].get_euclidean_distance(som[(i-10)/10][(j)/10]); // left

  u_matrix_values[i/10][j/10] = total_distance;
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
  
  calc_u_matrix_values();
  draw_u_matrix();
  draw_training_colors();
  draw_text();
  
}





void draw(){
  
  if(keyPressed) {
    switch(key){
      case '1':
        if(!run){
          run = !run;
          time = millis();
        }
        break;
      case 'r':
         reset();
         break;
        
    }
  
   
 }
 
 if(run && current_iteration < iterations){
   train(training_colors[current_iteration%(num_training_colors)], current_iteration);
   calc_u_matrix_values();
   current_iteration += 1;
   
   draw_text();
   draw_squares();
   draw_u_matrix();
   draw_bmu_locations();
 }

}
