// euclidean distance calculator. what more do you want from me?
float euclidean_distance(float[] values){
 
  float distance = 0;
  for(int i = 0; i < values.length; i += 2){
    distance += pow(values[i] - values[i+1], 2);
  }

  return sqrt(distance);
}
