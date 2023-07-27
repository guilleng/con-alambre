#include "minunit.h"
#include "../include/my_module.h"

void test_setup(void)
{
    /* Called before each test case is executed. */
    return;
}

void test_teardown(void)
{
    /* Called after each test case is executed. */
    return;
}

MU_TEST(test_my_module_ret_1)
{
    mu_check(my_module_ret_1() == 1); 
}

MU_TEST_SUITE(test_suite) 
{
	MU_SUITE_CONFIGURE(&test_setup, &test_teardown);
	MU_RUN_TEST(test_my_module_ret_1);
}

int main(int argc, char *argv[]) 
{
	MU_RUN_SUITE(test_suite);
	MU_REPORT();

	return MU_EXIT_CODE;
}
