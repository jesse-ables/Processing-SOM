
// draws the squares
void draw_squares(){
  fill(0);
  rect(0,0,n,m);
  stroke(0);
  for(int i = 0; i < n; i = i + 10){
    for(int j = 0; j < m; j = j + 10){
     fill(som[i/10][j/10].r * 255, som[i/10][j/10].g * 255, som[i/10][j/10].b * 255);
     stroke(0);
     rect(i,j,10,10);
    }
  }
}

//draws the text
void draw_text(){
  fill(0);
  noStroke();
  rect(n/2, m, n/2, 100);
  fill(230);
  
  textSize(12);
  textLeading(15);
  text("lr: " + nf((learning_rate/iterations) * (iterations - current_iteration), 0,5) + "\n" +
  "Iteration: " + str(current_iteration) + "/" + str(iterations) + "\n" +
  "Radius: " + nf((learning_radius/iterations) * (iterations - current_iteration), 0,5), n - 100, m+15);
  
  if(!run){
    text("Run (1) " + "\n" +
    "Time: 0.00" + "\n" +
    "Reset (r)", n - 200, m+15);
  }else{
    text("Run (1) " + "\n" +
    "Time: " + nf((millis() - time)/1000, 0,2) + "\n" +
    "Reset (r)", n - 200, m+15);
  }

}

// draws the training colors
void draw_training_colors(){
  int xpad = 5;
  int ypad = m+5;
  // create boxes with the training colors at the bottom
  for(int i = 0; i < ceil(num_training_colors/10)+1; i++){
    for(int j = i*10; j < training_colors.length && j < i*10+10;j++){
       fill(training_colors[j]);
       stroke(255);
       rect(xpad, ypad, 10, 10);
       xpad += 15;
    }
    xpad = 5;
    ypad += 15;
  } 
}

// draws the bmu locations with regards to position
void draw_bmu_locations(){
  for(int i = 0; i < bmu_locations.length; i++){
    int x_loc = bmu_locations[i][0] * 10;
    int y_loc = bmu_locations[i][1] * 10;

    int x_loc_u_matrix = bmu_locations[i][0] * 10 + n + 10;
    
    stroke(255);
    fill(training_colors[i]);
    
    // up left
    if(x_loc >= 20 && y_loc >= 20){
      line(x_loc + 5, y_loc + 5, x_loc, y_loc);
      rect(x_loc - 15, y_loc - 15, 15,15);

      line(x_loc_u_matrix + 5, y_loc + 5, x_loc_u_matrix, y_loc);
      rect(x_loc_u_matrix - 15, y_loc - 15, 15,15);
    }
    // up right
    else if(x_loc < 20 && y_loc > 20){
      line(x_loc + 5, y_loc + 5, x_loc + 10, y_loc);
      rect(x_loc + 10, y_loc - 15, 15,15);

      line(x_loc_u_matrix + 5, y_loc + 5, x_loc_u_matrix + 10, y_loc);
      rect(x_loc_u_matrix + 10, y_loc - 15, 15,15);
    }
    // down right
    else if(x_loc < 20 && y_loc < 20){
      line(x_loc + 5, y_loc + 5, x_loc + 10, y_loc+10);
      rect(x_loc + 10, y_loc + 10, 15,15);

      line(x_loc_u_matrix + 5, y_loc + 5, x_loc_u_matrix + 10, y_loc+10);
      rect(x_loc_u_matrix + 10, y_loc + 10, 15,15);
    }
    // down left
    else{
      line(x_loc + 5, y_loc + 5, x_loc, y_loc + 10);
      rect(x_loc - 15, y_loc + 10, 15,15);

      line(x_loc_u_matrix + 5, y_loc + 5, x_loc_u_matrix, y_loc + 10);
      rect(x_loc_u_matrix - 15, y_loc + 10, 15,15);
    }
  }
  
}


void draw_u_matrix(){
  rect(n+10,0,n,m);
  stroke(0);
  for(int i = 0; i < n; i = i + 10){
    for(int j = 0; j < m; j = j + 10){
     fill(u_matrix_values[i/10][j/10] * 255);
     stroke(0);
     rect(i+n+10,j,10,10);
    }
  }

}
