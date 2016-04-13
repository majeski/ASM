#ifndef FLOW__H
#define FLOW__H

extern int mm_flow_width;
extern int mm_flow_height;
extern float *mm_flow_matrix;
extern float *mm_flow_tmp;
extern float mm_flow_weight;

extern void start(int szer, int wys, float *M, float waga);
extern void step(float t[]);

#endif

