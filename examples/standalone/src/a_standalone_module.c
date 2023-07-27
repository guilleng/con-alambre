#include "a_standalone_module.h"

static int private_function(void)
{
    return 0;
}

int function(void)
{
    return private_function();
}
