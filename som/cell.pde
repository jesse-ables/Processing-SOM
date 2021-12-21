
// basic object for holding and update rgb colors
// color values are [0,1]
class Cell{
 float r;
 float g;
 float b;
 
 Cell(float r, float g, float b){
  this.r = r;
  this.g = g;
  this.b = b;
 }
 
 void update(Cell other_cell, float rate){
   this.r = this.r - (rate * (this.r - other_cell.r));
   this.g = this.g - (rate * (this.g - other_cell.g));
   this.b = this.b - (rate * (this.b - other_cell.b));
 }
 
}
