module ContinuedFractionsLentz

export LentzOptions, LentzResult, modified_lentz, cf_coefficients, convergent

"""
    LentzOptions(; atol=zero(T), rtol=sqrt(eps(T)), maxiter=10_000,
                   tiny=sqrt(floatmin(T)), throw_on_nonconvergence=false)

Options for the modified Lentz algorithm. `tiny` is substituted when an
intermediate denominator is too close to zero.
"""
Base.@kwdef struct LentzOptions{T<:AbstractFloat}
    atol::T = zero(T)
    rtol::T = sqrt(eps(T))
    maxiter::Int = 10_000
    tiny::T = sqrt(floatmin(T))
    throw_on_nonconvergence::Bool = false
end

"""
    LentzResult(value, iterations, converged, last_delta)

Result returned by [`modified_lentz`](@ref).
"""
struct LentzResult{T}
    value::T
    iterations::Int
    converged::Bool
    last_delta::T
end

_protect_zero(x, tiny) = iszero(x) || abs(x) < tiny ? copysign(tiny, ifelse(iszero(real(x)), one(real(x)), real(x))) : x

function _promote_options(::Type{T}; atol=nothing, rtol=nothing, maxiter=10_000,
                          tiny=nothing, throw_on_nonconvergence=false) where {T<:AbstractFloat}
    LentzOptions{T}(
        isnothing(atol) ? zero(T) : T(atol),
        isnothing(rtol) ? sqrt(eps(T)) : T(rtol),
        maxiter,
        isnothing(tiny) ? sqrt(floatmin(T)) : T(tiny),
        throw_on_nonconvergence,
    )
end

"""
    modified_lentz(a, b; kwargs...) -> LentzResult

Evaluate the continued fraction

```text
b0 + a1/(b1 + a2/(b2 + a3/(b3 + ...)))
```

with the modified Lentz algorithm.

`a(n)` must return ``a_n`` for `n >= 1`.
`b(n)` must return ``b_n`` for `n >= 0`.

The keyword arguments are `atol`, `rtol`, `maxiter`, `tiny`,
`throw_on_nonconvergence`, and `T`.
"""
function modified_lentz(a, b; T=Float64, atol=nothing, rtol=nothing, maxiter=10_000,
                        tiny=nothing, throw_on_nonconvergence=false)
    opts = _promote_options(T; atol, rtol, maxiter, tiny, throw_on_nonconvergence)
    return modified_lentz(a, b, opts)
end

function modified_lentz(a, b, opts::LentzOptions{T}) where {T<:AbstractFloat}
    f = _protect_zero(T(b(0)), opts.tiny)
    C = f
    D = zero(T)
    delta = one(T)

    for n in 1:opts.maxiter
        an = T(a(n))
        bn = T(b(n))

        D = _protect_zero(bn + an * D, opts.tiny)
        C = _protect_zero(bn + an / C, opts.tiny)
        D = inv(D)
        delta = C * D
        f *= delta

        if abs(delta - one(T)) <= opts.atol + opts.rtol
            return LentzResult(f, n, true, delta)
        end
    end

    if opts.throw_on_nonconvergence
        error("modified Lentz method did not converge within $(opts.maxiter) iterations")
    end
    return LentzResult(f, opts.maxiter, false, delta)
end

"""
    cf_coefficients(; b0, a, b) -> (a, b)

Small helper for naming the continued-fraction parts explicitly.

Example:

```julia
a, b = cf_coefficients(b0=1, a=n -> n == 1 ? 1 : 0, b=n -> 1)
modified_lentz(a, b)
```
"""
function cf_coefficients(; b0, a, b)
    return a, n -> n == 0 ? b0 : b(n)
end

"""
    convergent(a, b, n; T=Float64)

Evaluate the finite `n`th convergent from the bottom up. This is useful for
checking a new coefficient definition before using the infinite algorithm.
"""
function convergent(a, b, n::Integer; T=Float64)
    n < 0 && throw(ArgumentError("n must be non-negative"))
    value = T(b(n))
    for k in (n - 1):-1:0
        value = T(b(k)) + T(a(k + 1)) / value
    end
    return value
end

end
