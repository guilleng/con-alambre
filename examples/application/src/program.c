#include <stdio.h>
#include "my_module.h"
#include "my_other_module.h"
#include "shared_utils.h"

char *program_function(void)
{
    multiply(1,2);            /*shared_utils*/
    my_module_ret_1();        /*my_module*/
    return "Hello";
}

char *other_program_function(void)
{
    return my_other_module_function(); /*my_other_module*/
}

#ifndef MINUNIT_MINUNIT_H
int main(void)
{
    printf("%s", program_function());
    printf("%s", other_program_function());
    return 0;
}
#endif
