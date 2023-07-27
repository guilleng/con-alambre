#include "minunit.h"
#include "../include/another_standalone_module.h"

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

MU_TEST(test_string_returning_function)
{
    mu_assert_string_eq("Hello", string_retuning_function()); 
}

MU_TEST_SUITE(test_suite) 
{
	MU_SUITE_CONFIGURE(&test_setup, &test_teardown);
	MU_RUN_TEST(test_string_returning_function);
}

int main(int argc, char *argv[]) 
{
	MU_RUN_SUITE(test_suite);
	MU_REPORT();

	return MU_EXIT_CODE;
}
