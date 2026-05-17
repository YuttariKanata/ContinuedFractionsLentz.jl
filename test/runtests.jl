using Test
using ContinuedFractionsLentz

@testset "modified Lentz" begin
    a_phi, b_phi = cf_coefficients(b0=0.0, a=n -> 1.0, b=n -> 1.0)
    r_phi = modified_lentz(a_phi, b_phi; rtol=1e-14)
    @test r_phi.converged
    @test r_phi.value ≈ (sqrt(5) - 1) / 2 rtol=1e-13

    x = 0.7
    a_tan, b_tan = cf_coefficients(
        b0=0.0,
        a=n -> n == 1 ? x : -x^2,
        b=n -> 2n - 1,
    )
    r_tan = modified_lentz(a_tan, b_tan; rtol=1e-14)
    @test r_tan.converged
    @test r_tan.value ≈ tan(x) rtol=1e-13

    a_exp, b_exp = cf_coefficients(
        b0=2.0,
        a=n -> n + 1.0,
        b=n -> n + 1.0,
    )
    r_exp = modified_lentz(a_exp, b_exp; rtol=1e-14)
    @test r_exp.converged
    @test r_exp.value ≈ exp(1) rtol=1e-13

    @test convergent(a_phi, b_phi, 10) ≈ 0.6179775280898876

    setprecision(BigFloat, 256) do
        a_big, b_big = cf_coefficients(
            b0=big(0),
            a=n -> big(1),
            b=n -> big(1),
        )
        r_big = modified_lentz(a_big, b_big; T=BigFloat, rtol=big"1e-70")
        @test r_big.converged
        @test r_big.value ≈ (sqrt(big(5)) - 1) / 2 rtol=big"1e-68"

        a_rat, b_rat = cf_coefficients(
            b0=0//1,
            a=n -> 1//1,
            b=n -> 1//1,
        )
        r_rat = modified_lentz(a_rat, b_rat; T=BigFloat, rtol=big"1e-70")
        @test r_rat.converged
        @test r_rat.value ≈ (sqrt(big(5)) - 1) / 2 rtol=big"1e-68"
    end
end
