#include "shared_utils.h"

static int private_util(void)
{
    return 0;
}

int add(int a, int b)
{
    private_util();
    return a + b;
}

int multiply(int a, int b)
{
    return a * b;
}
