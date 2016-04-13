#include <stdlib.h>
#include <stdio.h>

#include "bcd.h"

int main() {
    puts("parsowanie");
    {
        printf("123 = %s\n", unparse(parse("123")));
        printf("-1234 = %s\n", unparse(parse("-1234")));
        printf("00001 = %s\n", unparse(parse("00001")));
        printf("-00001 = %s\n", unparse(parse("-00001")));
        printf("-0 = %s\n", unparse(parse("-0")));
        puts("");
    }

    puts("dodawanie/odejmowanie");
    {
        printf("72 + 133 = %s\n", unparse(suma(parse("72"), parse("133"))));
        printf("-1000 + 1 = %s\n", unparse(suma(parse("-1000"), parse("1"))));
        printf("-100 + 100 = %s\n", unparse(suma(parse("-100"), parse("100"))));
        printf("133 - 2 = %s\n", unparse(roznica(parse("133"), parse("2"))));
        printf("133 - (-2) = %s\n", unparse(roznica(parse("133"), parse("-2"))));
        puts("");
    }

    puts("mnozenie");
    {
        printf("0 * 133 = %s\n", unparse(iloczyn(parse("0"), parse("133"))));
        printf("-1000 * (-2) = %s\n", unparse(iloczyn(parse("-1000"), parse("-2"))));

        bcd *a = parse("11");
        printf("11 * 11 = %s\n", unparse(iloczyn(a, a)));
        puts("");
    }

    puts("dzielenie");
    {
        printf("13 / 42 = %s\n", unparse(iloraz(parse("13"), parse("42"))));
        printf("913 / 104 = %s\n", unparse(iloraz(parse("913"), parse("104"))));
        printf("1525 / 25 = %s\n", unparse(iloraz(parse("1525"), parse("25"))));
        puts("");
    }

    puts("zlozenie");
    {
        bcd *v2 = parse("2");
        bcd *vm3 = parse("-3");
        bcd *v4 = parse("4");
        printf("(2 * (4 + 4)) / 2 = %s\n", unparse(iloraz(iloczyn(v2, suma(v4, v4)), v2)));
        printf("((2 + (-3)) + (-3 + 2)) * 4 = %s\n", unparse(iloczyn(suma(suma(v2, vm3), suma(vm3, v2)), v4)));
        puts("");
    }

    puts("przyklad z tresci");
    {
        bcd *a, *b, *c;
        a = parse("12345678");
        b = parse("234567");
        c = parse("56789");
        a = suma(a, iloczyn(b, c));
        printf("%s\n", unparse(a));
    }
}