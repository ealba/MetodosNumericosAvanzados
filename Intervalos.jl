module Intervalos
import Base.in
import Base.==
import Base.log
import Base.exp
import Base.^

export Interval, in, == , redonUP , redonDOWN, log , exp, ^,monotona
#NO ME PREOCUPÉ POR DIVIDIR ENTRE CEROS


typealias prec BigFloat

type Interval
    lo::Real
    hi::Real   
    
        function Interval(a, b)
        a, b = a > b ? (b,a) : (a,b)      #invierte el intervalo si está al revés  
        set_rounding(prec, RoundDown)
        lo = BigFloat("$a")
        set_rounding(prec,RoundUp)
        hi = BigFloat("$b")
        new(lo, hi)
        end
end

function Interval(f)  #Para definir los escalares  
    Interval(f,f)             
end

function redonUP(f::Function,x,y)
    with_rounding(BigFloat,RoundUp) do 
        f(BigFloat(x),BigFloat(y))
    end
end
function redonUP(f::Function,x)
    with_rounding(BigFloat,RoundUp) do 
        f(BigFloat(x))
    end
end



function redonDOWN(f::Function,x,y)
    with_rounding(BigFloat,RoundDown) do 
        f(BigFloat(x),BigFloat(y))
    end
end


function redonDOWN(f::Function,x)
    with_rounding(BigFloat,RoundDown) do 
        f(BigFloat(x))
    end
end


function in(x::Real,l::Interval)
	#manera fácil:
	#(Interval(x).hi <= l.hi && Interval(x).lo >= l.lo)
	#return true
    	#else
	#return false
    	#end

	(Interval(x).hi <= l.hi && Interval(x).lo >= l.lo) && return true #manera cortocircuito
	return false
end


function +(v::Interval, w::Interval)    
    Interval(redonDOWN(+,v.lo,w.lo),redonUP(+,v.hi,w.hi))
end

function +(v::Number, w::Interval)    
    Interval(v)+w
end

function +(v::Interval, w::Number)    
    v+Interval(w)
end


function -(v::Interval, w::Interval)    
    Interval(redonDOWN(-,v.lo,w.hi),redonUP(-,v.hi,w.lo))
end

function -(v::Number, w::Interval)    
    Interval(v)-w
end

function -(v::Interval, w::Number)    
    v-Interval(w)
end


function *(v::Interval, w::Interval) 
    Interval(min(redonDOWN(*,v.lo,w.lo),redonDOWN(*,v.lo,w.hi),redonDOWN(*,v.hi,w.lo),redonDOWN(*,v.hi,w.hi)),max(redonUP(*,v.lo,w.lo),redonUP(*,v.lo,w.hi),redonUP(*,v.hi,w.lo),redonUP(*,v.hi,w.hi)))    
end

function *(v::Number, w::Interval) 
    Interval(v)*w
end

function *(v::Interval, w::Number) 
    v*Interval(w)
end




function /(v::Interval, w::Interval)
    if (0 in w)
        return error("El intervalo denominador contiene al cero")
    else
        return Interval(min(redonDOWN(/,v.lo,w.lo),redonDOWN(/,v.lo,w.hi),redonDOWN(/,v.hi,w.lo),redonDOWN(/,v.hi,w.hi)),max(redonUP(/,v.lo,w.lo),redonUP(/,v.lo,w.hi),redonUP(/,v.hi,w.lo),redonUP(/,v.hi,w.hi)))
    end
end 

function /(v::Number, w::Interval)
    Interval(v)/w
end 

function /(v::Interval, w::Number)
    v/Interval(w)
end 



function monotona(f::Function,v::Interval) #para cualquier función monótona, si es decreciente, se invierte el intervalo
        Interval(redonDOWN(f,v.lo),redonUP(f,v.hi))
end 


function log(v::Interval)   # logaritmo del valor absoluto de una función
    if (v.lo < 0 || v.hi < 0)
        return throw(DomainError()) #("el logaritmo no admite números negativos")
        elseif (v.lo == 0)
            return Interval(-Inf,-Inf) 
        else
            return monotona(log,v)
        end
end 


function exp(v::Interval)
    monotona(exp,v)
end 


function ^(v::Interval, w::Integer)
    
    if (v.hi > 0 && v.lo > 0)
        return Interval(v.lo^w,v.hi^w)
        elseif (v.hi < 0 && v.lo < 0)
        return Interval(v.hi^w,v.lo^w)
        else        
        return Interval(0,max(v.lo^2,v.hi^2))
    
    end
end 


function ^(v::Interval, q::Real) #Definido sólo para intervalos positivos
    exp(Interval(q)*log(v))
end 


#en sí, cualquier función monótona la defines como monotona(función, intervalo)


function ==(a::Interval, b::Interval)
	(a.lo == b.lo && a.hi ==b.hi) && return true 
	return false
end
end
