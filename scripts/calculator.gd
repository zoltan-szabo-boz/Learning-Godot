extends Node
class_name Calculator

# Simple calculator class for demonstrating unit tests
# This is a pure logic class without any scene dependencies

static func add(a: int, b: int) -> int:
	return a + b

static func subtract(a: int, b: int) -> int:
	return a - b

static func multiply(a: int, b: int) -> int:
	return a * b

static func divide(a: float, b: float) -> float:
	if b == 0:
		push_error("Division by zero")
		return 0.0
	return a / b

static func is_even(n: int) -> bool:
	return n % 2 == 0

static func is_positive(n: float) -> bool:
	return n > 0
