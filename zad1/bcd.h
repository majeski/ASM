#ifndef BCD__H
#define BCD__H

typedef char bcd;

extern bcd *parse(char *);
extern char *unparse(bcd *);
extern bcd *suma(bcd *, bcd *);
extern bcd *roznica(bcd *, bcd *);
extern bcd *iloczyn(bcd *, bcd *);
extern bcd *iloraz(bcd *, bcd *);

#endif