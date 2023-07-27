#include "my_module.h"

static int my_module_private_function(int a)
{
    return add(a, 1); /* defined in shared_utils.h */
}

int my_module_ret_1(void)
{
    my_module_private_function(0);
    return 1;
}
