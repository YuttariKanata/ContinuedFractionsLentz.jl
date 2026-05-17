using ContinuedFractionsLentz

function print_result(name, result, expected)
    println(name)
    println("  value      = ", result.value)
    println("  expected   = ", expected)
    println("  abs error  = ", abs(result.value - expected))
    println("  iterations = ", result.iterations)
    println("  converged  = ", result.converged)
end

# 1 / phi = 1 / (1 + 1 / (1 + ...))
a_phi, b_phi = cf_coefficients(b0=0.0, a=n -> 1.0, b=n -> 1.0)
print_result("reciprocal golden ratio", modified_lentz(a_phi, b_phi), (sqrt(5) - 1) / 2)

# tan(x) = x / (1 - x^2 / (3 - x^2 / (5 - ...)))
x = 0.7
a_tan, b_tan = cf_coefficients(
    b0=0.0,
    a=n -> n == 1 ? x : -x^2,
    b=n -> 2n - 1,
)
print_result("tan($x)", modified_lentz(a_tan, b_tan), tan(x))

# exp(1) = 2 + 2 / (2 + 3 / (3 + 4 / (4 + ...)))
a_exp, b_exp = cf_coefficients(
    b0=2.0,
    a=n -> n + 1.0,
    b=n -> n + 1.0,
)
print_result("exp(1)", modified_lentz(a_exp, b_exp), exp(1))
