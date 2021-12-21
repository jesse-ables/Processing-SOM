Cell[][] som;
int[][] bmu_locations;
float[][] training_times;

int n = 400;
int m = 400;

int iterations = 5000;
int current_iteration = 1;
int num_training_colors = 30;
float learning_rate = .1;
float learning_radius = (n/10)/2;
float radius_reduction = learning_radius/iterations;
float learning_reduction = ((1 + learning_rate)/iterations) - 1;
float time;

boolean run = false;
boolean scalability_test = false;
boolean draw_bmus = true;

// old booleans for now hidden, useless features
boolean show_squares = true;
boolean show_grid = false;


//******************** Perceptual ColorPicker colors ********************
color[] pcpColors = new color[num_training_colors];

void settings(){
  size(n,m+50);
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
       som[i][j].r = som[i][j].r - (rate * (som[i][j].r - red(c)/255));
       som[i][j].g = som[i][j].g - (rate * (som[i][j].g - green(c)/255));
       som[i][j].b = som[i][j].b - (rate * (som[i][j].b - blue(c)/255));
       som[i][j].x = som[i][j].x - (rate * (som[i][j].x - som[x][y].x));
       som[i][j].y = som[i][j].y - (rate * (som[i][j].y - som[x][y].y));
       
       fill(som[i][j].r * 255, som[i][j].g * 255, som[i][j].b * 255);
       stroke(0);
       rect(i*10,j*10,10,10);
       
     }
   }
  }
}

void reset(){
  
  current_iteration = 1;
  run = false;
  
  // choose new training colors
  for(int i = 0; i < num_training_colors; i++){
    pcpColors[i] = color(random(0,255),random(0,255),random(0,255));
  }
  
  bmu_locations = new int[num_training_colors][2];
  
  // allocate new SOM array
  som = new Cell[n/10][m/10];
  
  // create boxes with randomized colors, initialize cells with rgb values
  for(int i = 0; i < n; i = i + 10){
    for(int j = 0; j < m; j = j + 10){
     float r = random(0, 255);
     float g = random(0, 255);
     float b = random(0, 255);
     fill(r,g,b);
     stroke(0);
     rect(i,j,10,10);
     
     som[i/10][j/10] = new Cell(r/255,g/255,b/255, i+5, j+5);
    }
  }
  
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
         
      case 'g':
        show_grid = !show_grid;
        delay(500);
        break;
        
      case 's':
        if(show_squares){
          show_squares = false;
        }
        else{
          show_squares = true;
        }
          delay(1000);
          break;
    }
  
   
 }
 
 if(run && current_iteration < iterations){
   train(pcpColors[current_iteration%(num_training_colors)], current_iteration);
   current_iteration += 1;
   
   draw_text();
   draw_squares();
   draw_bmu_locations();
 }

}
