#include "minunit.h"
#include "FILE_TO_TEST"

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

/* CHEATSHEET ******************************************************************

mu_check(condition): passes if condition is true, 
                     otherwise shows the condition as the error message

mu_assert(condition, message): passes if condition is true, 
                               otherwise shows the failed condition and message

mu_assert_int_eq(expected, result): 
       passes if the two numbers are equal 
       otherwise shows their values as error message

mu_assert_double_eq(expected, result): 
       passes if the two values are almost equal 
       otherwise shows their values as the error message. 
       MINUNIT_EPSILON sets the threshold to determine equality

mu_assert_string_eq(expected, result): 
       it will pass if the two strings are equal.  

mu_fail(message): fails and show the message

*******************************************************************************/

MU_TEST(test_test)
{
    /* A test that passes */
    mu_check(1); 
}

MU_TEST_SUITE(test_suite) 
{
	MU_SUITE_CONFIGURE(&test_setup, &test_teardown);
	MU_RUN_TEST(test_test);
}

int main(int argc, char *argv[]) 
{
	MU_RUN_SUITE(test_suite);
	MU_REPORT();

	return MU_EXIT_CODE;
}
