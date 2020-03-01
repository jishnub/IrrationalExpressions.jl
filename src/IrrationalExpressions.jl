"""
A module that makes expressions like `-π` behave like Irrational, rather
than Float64.

Generates IrrationalExpr objects when arithmetic operations are applied to
objects of type Irrational, and these operations are carried out in the
destination type when type conversion occurs.

For example, `BigFloat(π) + BigFloat(-π)` will evaluate to BigFloat(0),
rather than to approximately 1.2e-16.
"""

module IrrationalExpressions

import Base: +, -, *, /, convert, promote_rule, show

struct IrrationalExpr{op, N} <: Real
  args::NTuple{N,Union{IrrationalExpr, Irrational, Rational, Integer}}
end

@generated convert(::Type{T}, x::IrrationalExpr{op,N}) where {T<:AbstractFloat,op,N} =
  Expr(:call, op, [Expr(:call, :convert, T, :( x.args[$i] )) for i=1:N]...)

promote_rule(::Type{T1}, ::Type{T2}) where {T1<:AbstractFloat, T2<:IrrationalExpr}= T1
promote_rule(::Type{BigFloat}, ::Type{T2}) where {T2<:IrrationalExpr} = BigFloat

## Unary operators
(+)(x::IrrationalExpr) = x
(-)(x::IrrationalExpr) = IrrationalExpr{:(-),1}((x,))
(-)(x::Irrational) = IrrationalExpr{:(-),1}((x,))

## Binary operators
ops = (:(+), :(-), :(*), :(/))
types = (IrrationalExpr, Irrational, Rational, Integer)
for op in ops, i in eachindex(types), j in eachindex(types)
  if i<=2 || j<=2
    @eval $op(x::$(types[i]), y::$(types[j])) = IrrationalExpr{Symbol($op),2}((x,y))
  end
end

# We define expr() as a conveninent middle step to get to strings,
# but this also allows eval(expr(x)) as a roundabout way to get x.
expr(x) = x
expr(::Irrational{sym}) where {sym} = sym
expr(x::IrrationalExpr{op,N}) where {op,N} = Expr(:call, op, map(expr,x.args)...)

show(io::IO, x::IrrationalExpr) = print(io, string(expr(x)), " = ", string(convert(Float64,x))[1:end-2], "...")

for T in (:AbstractFloat,:BigFloat,:Float64,:Float32,:Float16)
	eval(quote
		Base.$T(x::IrrationalExpr) = convert($T,x)
	end)
end

end # module
