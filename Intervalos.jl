module Intervalos
import Base.in
import Base.==
import Base.log
import Base.exp
import Base.^
import Base.⊆
import Base.∩
import Base.zeros
import Base.sin
import Base.cos
import Base.tan

export Interval, in, == , redonUP , redonDOWN, log , exp, ^, monotona, ∩, ⊆, subset, Cestricto, radio, media, zeros, bisect,multisect, sin ,cos , tan

#------------------------------------------------------------------------------------DEFINICIÓN DE INTERVALO
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

#------------------------------------------------------------------------------------




#------------------------------------------------------------------------------------OPERACIONES de conjuntos entre intervalos

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

function ⊆(A::Interval, B::Interval)
    if ((B.lo<= A.lo) && (A.hi<=B.hi))
    true
        else
        false
    end
end

function subset(A::Interval, B::Interval)
    if ((A ⊆ B) && ((A==B) == false))
    true
        else
        false
    end
end

function Cestricto(A::Interval, B::Interval)
    if ((B.lo<A.lo) && (A.hi<B.hi))
    true
        else
        false
    end
end

function ∩(A::Interval, B::Interval)
    if (A.hi < B.lo || B.hi < A.lo)
    return Interval()
        else
        return Interval(max(A.lo,B.lo),min(A.hi,B.hi))
    end
end


function ==(a::Interval, b::Interval)
	(a.lo == b.lo && a.hi ==b.hi) && return true 
	return false
end


radio(A::Interval) = abs(A.hi - A.lo)

media(A::Interval) = 0.5*(A.hi + A.lo)



function bisect(x::Interval)
    return [Interval(x.lo,(x.hi+x.lo)/2),Interval((x.hi+x.lo)/2,x.hi)]
end



function multisect(x::Interval,ntot::Integer) 
    
    #println("Función que hace una bisección $(ntot) veces")
    if ntot==0
        return x
    

    else
        even=[2*i for i in 1:2^(ntot)];
        odds=even-1;
        A=zeros(Interval(0),2^ntot)

        #-------el paso 1
        A[1:2,1]=bisect(x);
        #----------------

        #---------------------pasos 2 en adelante
        for n in 2:ntot
                #println("n==============================$n")
            for i in 1:2^(n-1)
                #println("i============$i")
                    for j in even[i]
                    for k in odds[i]
                    #println ("j==$j")
                    #println ("k===$k")
                        A[k:j,n]=bisect(A[i,n-1])
                    end
                    end
            end
        end
        #---------------------

        return A[:,ntot]
    end
end


#-----------------------------------------------------------------------------------------------------------------






#----------------------------------------------------------------------------OPERACIONES Aritméticas entre intervalos
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

#----------------------------------------------------------------------------

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



function Smas(A::Interval)
    k1=int(floor((A.lo-π/2)/(2π)))
    k2=int(ceil((A.hi-π/2)/(2π)))
    S1=Float64[]
        for i in k1:k2
        push!(S1,2π*i+π/2)
        end
    return S1
end



function Smenos(A::Interval)
    k1=int(floor((A.lo+π/2)/(2π)))
    k2=int(ceil((A.hi+π/2)/(2π)))
    S1=Float64[]
        for i in k1:k2
        push!(S1,2π*i-π/2)
        end
    return S1
end

function ∩(A::Interval, b::Array{Float64,1})
    k=0
        for i in 1:length(b)
            if (b[i] in A)
            k+=1
            end
        end
    return k
end


function sin(A::Interval)
if ((A ∩ Smenos(A)>0) && (A ∩ Smas(A) >0))
return Interval(-1,1)
end

if ((A ∩ Smenos(A) >0) && (A ∩ Smas(A) ==0))
set_rounding(BigFloat, RoundUp)
A2=max(sin(A.lo),sin(A.hi))
set_rounding(BigFloat, RoundNearest)
return Interval(-1,A2)
end

if ((A ∩ Smenos(A) == 0) && (A ∩ Smas(A)>0))
set_rounding(BigFloat, RoundDown)
A1=min(sin(A.lo),sin(A.hi))
set_rounding(BigFloat, RoundNearest)
return Interval(A1,1)
end

if ((A ∩ Smenos(A) == 0) && (A ∩ Smas(A)==0))
set_rounding(BigFloat, RoundDown)
A1=min(sin(A.lo),sin(A.hi))
set_rounding(BigFloat, RoundUp)
A2=max(sin(A.lo),sin(A.hi))
set_rounding(BigFloat, RoundNearest)
return Interval(A1,A2)
end

end


cos(A::Interval)=sin(A+π/2)

tan(A::Interval)=sin(A)/(cos(A))
















#----------------------------------------------------------En sí, cualquier función monótona la defines como monotona(función, intervalo)



end
