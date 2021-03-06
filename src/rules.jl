const DEFINED_DIFFRULES = Tuple{Symbol,Int}[]

struct DiffRule{F} end

(::Type{DiffRule{F}})(args...) where {F} = error("no derivative rule defined for $F with arguments $args")

macro define_diffrule(def)
    @assert isa(def, Expr) && def.head == :(=)
    rhs = def.args[1]
    lhs = def.args[2]
    @assert isa(rhs, Expr) && rhs.head == :call
    f = rhs.args[1]
    args = rhs.args[2:end]
    rhs.args[1] = :(::Type{DiffRule{$(Expr(:quote, f))}})
    push!(DEFINED_DIFFRULES, (f, length(args)))
    return esc(def)
end

diffrule(f::Symbol, args...) = DiffRule{f}(args...)

hasdiffrule(f::Symbol, arity::Int) = in((f, arity), DEFINED_DIFFRULES)

################
# General Math #
################

# unary #
#-------#

@define_diffrule +(x)       = :(  1                                  )
@define_diffrule -(x)       = :( -1                                  )
@define_diffrule sqrt(x)    = :(  inv(2 * sqrt($x))                  )
@define_diffrule cbrt(x)    = :(  inv(3 * cbrt($x)^2)                )
@define_diffrule abs2(x)    = :(  $x + $x                            )
@define_diffrule inv(x)     = :( -abs2(inv($x))                      )
@define_diffrule log(x)     = :(  inv($x)                            )
@define_diffrule log10(x)   = :(  inv($x) / log(10)                  )
@define_diffrule log2(x)    = :(  inv($x) / log(2)                   )
@define_diffrule log1p(x)   = :(  inv($x + 1)                        )
@define_diffrule exp(x)     = :(  exp($x)                            )
@define_diffrule exp2(x)    = :(  exp2($x) * log(2)                  )
@define_diffrule expm1(x)   = :(  exp($x)                            )
@define_diffrule sin(x)     = :(  cos($x)                            )
@define_diffrule cos(x)     = :( -sin($x)                            )
@define_diffrule tan(x)     = :(  1 + tan($x)^2                      )
@define_diffrule sec(x)     = :(  sec($x) * tan($x)                  )
@define_diffrule csc(x)     = :( -csc($x) * cot($x)                  )
@define_diffrule cot(x)     = :( -(1 + cot($x)^2)                    )
@define_diffrule sind(x)    = :(  (π / 180) * cosd($x)               )
@define_diffrule cosd(x)    = :( -(π / 180) * sind($x)               )
@define_diffrule tand(x)    = :(  (π / 180) * (1 + tand($x)^2)       )
@define_diffrule secd(x)    = :(  (π / 180) * secd($x) * tand($x)    )
@define_diffrule cscd(x)    = :( -(π / 180) * cscd($x) * cotd($x)    )
@define_diffrule cotd(x)    = :( -(π / 180) * (1 + cotd($x)^2)       )
@define_diffrule asin(x)    = :(  inv(sqrt(1 - $x^2))                )
@define_diffrule acos(x)    = :( -inv(sqrt(1 - $x^2))                )
@define_diffrule atan(x)    = :(  inv(1 + $x^2)                      )
@define_diffrule asec(x)    = :(  inv(abs($x) * sqrt($x^2 - 1))      )
@define_diffrule acsc(x)    = :( -inv(abs($x) * sqrt($x^2 - 1))      )
@define_diffrule acot(x)    = :( -inv(1 + $x^2)                      )
@define_diffrule asind(x)   = :(  180 / π / sqrt(1 - $x^2)           )
@define_diffrule acosd(x)   = :( -180 / π / sqrt(1 - $x^2)           )
@define_diffrule atand(x)   = :(  180 / π / (1 + $x^2)               )
@define_diffrule asecd(x)   = :(  180 / π / abs($x) / sqrt($x^2 - 1) )
@define_diffrule acscd(x)   = :( -180 / π / abs($x) / sqrt($x^2 - 1) )
@define_diffrule acotd(x)   = :( -180 / π / (1 + $x^2)               )
@define_diffrule sinh(x)    = :(  cosh($x)                           )
@define_diffrule cosh(x)    = :(  sinh($x)                           )
@define_diffrule tanh(x)    = :(  sech($x)^2                         )
@define_diffrule sech(x)    = :( -tanh($x) * sech($x)                )
@define_diffrule csch(x)    = :( -coth($x) * csch($x)                )
@define_diffrule coth(x)    = :( -(csch($x)^2)                       )
@define_diffrule asinh(x)   = :(  inv(sqrt($x^2 + 1))                )
@define_diffrule acosh(x)   = :(  inv(sqrt($x^2 - 1))                )
@define_diffrule atanh(x)   = :(  inv(1 - $x^2)                      )
@define_diffrule asech(x)   = :( -inv($x * sqrt(1 - $x^2))           )
@define_diffrule acsch(x)   = :( -inv(abs($x) * sqrt(1 + $x^2))      )
@define_diffrule acoth(x)   = :(  inv(1 - $x^2)                      )
@define_diffrule deg2rad(x) = :(  π / 180                            )
@define_diffrule rad2deg(x) = :(  180 / π                            )
@define_diffrule gamma(x)   = :(  digamma($x) * gamma($x)            )
@define_diffrule lgamma(x)  = :(  digamma($x)                        )

# binary #
#--------#

@define_diffrule +(x, y) = :(1),                  :(1)
@define_diffrule -(x, y) = :(1),                  :(-1)
@define_diffrule *(x, y) = :($y),                 :($x)
@define_diffrule /(x, y) = :(inv($y)),            :(-$x / ($y^2))
@define_diffrule ^(x, y) = :($y * ($x^($y - 1))), :(($x^$y) * log($x))

# TODO:
#
# mod
# hypot
# atan2

####################
# SpecialFunctions #
####################

# unary #
#-------#

@define_diffrule erf(x)         = :(  (2 / sqrt(π)) * exp(-$x * $x)       )
@define_diffrule erfinv(x)      = :(  (sqrt(π) / 2) * exp(erfinv($x)^2)   )
@define_diffrule erfc(x)        = :( -(2 / sqrt(π)) * exp(-$x * $x)       )
@define_diffrule erfcinv(x)     = :( -(sqrt(π) / 2) * exp(erfinv($x)^2)   )
@define_diffrule erfi(x)        = :(  (2 / sqrt(π)) * exp($x * $x)        )
@define_diffrule erfcx(x)       = :(  (2 * x * erfcx($x)) - (2 / sqrt(π)) )
@define_diffrule dawson(x)      = :(  1 - (2 * x * dawson($x))            )
@define_diffrule digamma(x)     = :(  trigamma($x)                        )
@define_diffrule invdigamma(x)  = :(  inv(trigamma(invdigamma($x)))       )
@define_diffrule trigamma(x)    = :(  polygamma(2, $x)                    )
@define_diffrule airyai(x)      = :(  airyaiprime($x)                     )
@define_diffrule airyaiprime(x) = :(  $x * airyai($x)                     )
@define_diffrule airybi(x)      = :(  airybiprime($x)                     )
@define_diffrule airybiprime(x) = :(  $x * airybi($x)                     )
@define_diffrule besselj0(x)    = :( -besselj1($x)                        )
@define_diffrule besselj1(x)    = :(  (besselj0($x) - besselj(2, $x)) / 2 )
@define_diffrule bessely0(x)    = :( -bessely1($x)                        )
@define_diffrule bessely1(x)    = :(  (bessely0($x) - bessely(2, $x)) / 2 )

# TODO:
#
# eta
# zeta
# airyaix
# airyaiprimex
# airybix
# airybiprimex

# binary #
#--------#

@define_diffrule besselj(ν, x)   = :NaN, :(  (besselj($ν - 1, $x) - besselj($ν + 1, $x)) / 2   )
@define_diffrule besseli(ν, x)   = :NaN, :(  (besseli($ν - 1, $x) + besseli($ν + 1, $x)) / 2   )
@define_diffrule bessely(ν, x)   = :NaN, :(  (bessely($ν - 1, $x) - bessely($ν + 1, $x)) / 2   )
@define_diffrule besselk(ν, x)   = :NaN, :( -(besselk($ν - 1, $x) + besselk($ν + 1, $x)) / 2   )
@define_diffrule hankelh1(ν, x)  = :NaN, :(  (hankelh1($ν - 1, $x) - hankelh1($ν + 1, $x)) / 2 )
@define_diffrule hankelh2(ν, x)  = :NaN, :(  (hankelh2($ν - 1, $x) - hankelh2($ν + 1, $x)) / 2 )
@define_diffrule polygamma(m, x) = :NaN, :(  polygamma($m + 1, $x)                             )

# TODO:
#
# zeta
# besseljx
# besselyx
# besselix
# besselkx
# besselh
# besselhx
# hankelh1x
# hankelh2
# hankelh2x

# ternary #
#---------#

# TODO:
#
# besselh
# besselhx
