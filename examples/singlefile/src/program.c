#include <stdio.h>

int ret_31(void)
{
    return 31;
}

char *greeting(void)
{
    return "Hello";
}

#ifndef MINUNIT_MINUNIT_H
int main(void)
{
    printf("%s\n", greeting());
    return 0;
}
#endif
