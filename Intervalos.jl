module Intervalos
export Interval

typealias prec BigFloat

type Interval
    lo::Real
    hi::Real   
        function Interval(a, b)
        set_rounding(prec, RoundDown)
        lo = BigFloat("$a")
        set_rounding(prec,RoundUp)
        hi = BigFloat("$b")
        if a>b 
        error("el intervalo está al revés")
        end
        new(lo, hi)
        end
end


function Interval(f)  #Para definir los escalares ya no nos importa que 
    Interval(f,f)              #se definan intervalos de un sólo punto
end

function +(v::Interval, w::Interval)    
    Interval(v.lo+w.lo,v.hi+w.hi)
end

function -(v::Interval, w::Interval) #la resta invierte el orden en los intervalos
    Interval(v.lo-w.hi,v.hi-w.lo)   
end

function *(v::Interval, w::Interval) 
    Interval(min(v.lo*w.lo,v.lo*w.hi,v.hi*w.lo,v.hi*w.hi),max(v.lo*w.lo,v.lo*w.hi,v.hi*w.lo,v.hi*w.hi))    

end
    
function /(v::Interval, w::Interval) 
    Interval(min(v.lo/w.lo,v.lo/w.hi,v.hi/w.lo,v.hi/w.hi),max(v.lo/w.lo,v.lo/w.hi,v.hi/w.lo,v.hi/w.hi))
end 




end

