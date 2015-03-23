module Intervalos
	export Interval
	typealias prec BigFloat
	type Interval
	lo
	hi
		function Interval(a, b)
		set_rounding(prec, RoundDown)
		lo = BigFloat("$a")
		set_rounding(prec, RoundUp)
		hi = BigFloat("$b")
		new(lo, hi)
		end
	end
end
