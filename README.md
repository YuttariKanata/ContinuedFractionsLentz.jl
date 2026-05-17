# ContinuedFractionsLentz

[![Build Status](https://github.com/YuttariKanata/ContinuedFractionsLentz.jl/actions/workflows/CI.yml/badge.svg?branch=master)](https://github.com/YuttariKanata/ContinuedFractionsLentz.jl/actions/workflows/CI.yml?query=branch%3Amaster)

Juliaで修正Lentz法を毎回思い出さずに使うための、小さな「ガワ」です。

対象の連分数を次の標準形にそろえます。

```text
b0 + a1/(b1 + a2/(b2 + a3/(b3 + ...)))
```

あとは `a(n)` と `b(n)` を書くだけです。

## 使い方

```julia
using ContinuedFractionsLentz

a, b = cf_coefficients(
    b0 = 0.0,
    a = n -> 1.0,
    b = n -> 1.0,
)

result = modified_lentz(a, b; rtol=1e-14)
result.value
```

高精度で評価したい場合は `T=BigFloat` を指定します。`BigInt` や
`Rational` は係数として使えますが、修正Lentz法は収束判定を使う数値法なので、
無限連分数を正確な `Rational` のまま返すのではなく、指定した浮動小数型へ変換して
評価します。

```julia
setprecision(BigFloat, 256) do
    a, b = cf_coefficients(
        b0 = 0//1,
        a = n -> 1//1,
        b = n -> 1//1,
    )

    result = modified_lentz(a, b; T=BigFloat, rtol=big"1e-70")
    result.value
end
```

`modified_lentz` は `LentzResult` を返します。

- `value`: 計算値
- `iterations`: 反復回数
- `converged`: 収束したか
- `last_delta`: 最後の補正倍率

## 新しい連分数に適用する手順

1. 連分数を `b0 + a1/(b1 + a2/(b2 + ...))` に書き換える。
2. `b0`、`a(n)`、`b(n)` を定義する。
3. `convergent(a, b, N)` で有限段の値を確認する。
4. `modified_lentz(a, b; rtol=..., maxiter=...)` を呼ぶ。
5. `result.converged` を必ず確認する。

## 例

```julia
# tan(x) = x / (1 - x^2 / (3 - x^2 / (5 - ...)))
x = 0.7
a_tan, b_tan = cf_coefficients(
    b0 = 0.0,
    a = n -> n == 1 ? x : -x^2,
    b = n -> 2n - 1,
)

result = modified_lentz(a_tan, b_tan; rtol=1e-14)
@show result.value tan(x) result.converged
```

## 実行

```powershell
julia --project=. examples/run_examples.jl
julia --project=. -e "using Pkg; Pkg.test()"
```
