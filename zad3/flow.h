#ifndef FLOW__H
#define FLOW__H

typedef int fixed;

extern int mm_flow_width;
extern int mm_flow_height;
extern fixed *mm_flow_matrix;
extern fixed *mm_flow_tmp;
extern fixed mm_flow_weight;

extern void start(int szer, int wys, fixed *M, fixed waga);
extern void step(fixed t[]);

#endif

