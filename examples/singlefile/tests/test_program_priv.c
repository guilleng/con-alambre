#include "minunit.h"
#include "../src/program.c"

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

MU_TEST(test_ret_31)
{
    mu_check(ret_31() == 31); 
}

MU_TEST(test_greeting)
{
    mu_assert_string_eq(greeting(), "Hello"); 
}

MU_TEST_SUITE(test_suite) 
{
	MU_SUITE_CONFIGURE(&test_setup, &test_teardown);
	MU_RUN_TEST(test_ret_31);
	MU_RUN_TEST(test_greeting);
}

int main(void) 
{
	MU_RUN_SUITE(test_suite);
	MU_REPORT();

	return MU_EXIT_CODE;
}
