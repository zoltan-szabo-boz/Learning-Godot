extends GutTest

# Test suite for Calculator utility class
# This demonstrates pure unit testing without scene dependencies

# Test: Addition works correctly
func test_add():
	assert_eq(Calculator.add(2, 3), 5, "2 + 3 should equal 5")
	assert_eq(Calculator.add(-1, 1), 0, "-1 + 1 should equal 0")
	assert_eq(Calculator.add(0, 0), 0, "0 + 0 should equal 0")

# Test: Subtraction works correctly
func test_subtract():
	assert_eq(Calculator.subtract(5, 3), 2, "5 - 3 should equal 2")
	assert_eq(Calculator.subtract(0, 5), -5, "0 - 5 should equal -5")
	assert_eq(Calculator.subtract(-2, -3), 1, "-2 - (-3) should equal 1")

# Test: Multiplication works correctly
func test_multiply():
	assert_eq(Calculator.multiply(3, 4), 12, "3 * 4 should equal 12")
	assert_eq(Calculator.multiply(-2, 5), -10, "-2 * 5 should equal -10")
	assert_eq(Calculator.multiply(0, 100), 0, "0 * 100 should equal 0")

# Test: Division works correctly
func test_divide():
	assert_almost_eq(Calculator.divide(10.0, 2.0), 5.0, 0.001, "10 / 2 should equal 5")
	assert_almost_eq(Calculator.divide(7.0, 2.0), 3.5, 0.001, "7 / 2 should equal 3.5")
	assert_almost_eq(Calculator.divide(-10.0, 5.0), -2.0, 0.001, "-10 / 5 should equal -2")

# Test: Division by zero returns 0 and logs error
func test_divide_by_zero():
	var result = Calculator.divide(10.0, 0.0)
	assert_eq(result, 0.0, "Division by zero should return 0")

# Test: Even number detection
func test_is_even():
	assert_true(Calculator.is_even(2), "2 should be even")
	assert_true(Calculator.is_even(0), "0 should be even")
	assert_true(Calculator.is_even(-4), "-4 should be even")
	assert_false(Calculator.is_even(3), "3 should not be even")
	assert_false(Calculator.is_even(-1), "-1 should not be even")

# Test: Positive number detection
func test_is_positive():
	assert_true(Calculator.is_positive(1.0), "1 should be positive")
	assert_true(Calculator.is_positive(0.5), "0.5 should be positive")
	assert_false(Calculator.is_positive(0.0), "0 should not be positive")
	assert_false(Calculator.is_positive(-1.0), "-1 should not be positive")

# Test: Multiple operations combined
func test_complex_calculation():
	var result = Calculator.add(Calculator.multiply(2, 3), Calculator.subtract(10, 5))
	assert_eq(result, 11, "(2 * 3) + (10 - 5) should equal 11")
