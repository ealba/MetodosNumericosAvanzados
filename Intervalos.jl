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

export Interval, in, == , redonUP , redonDOWN, log , exp, ^, monotona, ∩, ⊆, subset, Cestricto, radio, media, zeros, bisect,trisect, multisect, sin ,cos , tan , segment , IntervalMD 

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

Interval() = println("Intervalo vacío")


#------------------------------------------------------------------------------------

#Para desplegar menos a la hora de sacar un intervalo

function Base.show(io::IO, t::Interval)
    repr="($(t.lo), $(t.hi))"
    print(io,repr)
end


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
return("putamadre")
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

function trisect(x::Interval)
    return [Interval(x.lo,x.lo+radio(x)/3),Interval(x.lo+radio(x)/3,x.lo+2*radio(x)/3),Interval(x.lo+2*radio(x)/3,x.hi)]
end

function zeros(T::Interval,dim::Integer)
a=[];

    for i in 1:dim
    a=cat(1,a,Interval(0))
end

    b=a
    for j in 1:dim-1
    a=cat(2,a,b)
end

    return a
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


function segment(A::Interval,n::Int)
    Iseg=Interval[]
    b = (A.hi-A.lo)/(n)
    
    for i in 1:n-1
        set_rounding(BigFloat,RoundDown)
        A1=A.lo + b*(i-1)
        set_rounding(BigFloat,RoundUp)
        A2=A.lo+b*i
        set_rounding(BigFloat,RoundNearest)
        push!(Iseg,Interval(A1,A2))
    end
            set_rounding(BigFloat,RoundDown)
            A1=A.lo+b*(n-1)
            set_rounding(BigFloat,RoundUp)
            A2=A.hi
            set_rounding(BigFloat,RoundNearest)
            push!(Iseg,Interval(A1,A2))
        return Iseg
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









function /(A::Interval, B::Interval)
    if 0 in B == false
        return A*Interval(redonDOWN(/,1,B.hi),redonUP(/,1,B.lo))
    end
    
    if (0 in A && 0 in B)
        return Interval(-Inf, Inf)
    end
    
    if (A.hi < 0 && B.lo < B.hi == 0)
        return Interval(redonDOWN(/,A.hi,B.lo), Inf)
    end
    
    if (A.hi < 0 && B.lo < 0 < B.hi)
        return Interval(redonDOWN(/,A.hi,B.lo), redonUP(/,A.hi,B.hi))
    end
    
    if (A.hi < 0 && 0 == B.lo < B.hi)
        return Interval(-Inf, redonUP(/,A.hi,B.hi))
    end
    
    if (0< A.lo && B.lo < B.hi==0)
        return Interval(-Inf, redonUP(/,A.lo,B.lo))
    end
    
    if (0 < A.lo && B.lo < 0 < B.hi)
        return Interval(redonDOWN(/,A.lo,B.hi), redonUP(/,A.lo,B.lo))
    end
    
    if (0 < A.lo && 0 == B.lo < B.hi)
        return Interval(redonDOWN(/,A.lo,B.hi), Inf)
    end
    
    if ( 0 in A == false && B == Interval(0,0))
        return Interval()
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





#----------------------------------------------------------
#Cosas para Intervalos de varias dimensiones:

typealias IntervalMD{} Vector{Interval}


Base.promote_type{T<:Number}(::Type{T}, ::Type{Interval}) = Interval

Base.convert(::Type{Interval}, x::Real) = Interval(x)
Base.convert(::Type{Interval}, x::Interval) = x

Base.convert(::Type{IntervalMD}, x::Real) = [Interval(x), Interval(x)]
Base.convert(::Type{IntervalMD}, x::IntervalMD) = x



Base.zero(::Type{Interval}) = Interval(0)
promote_type(Int, Interval)

Base.zeros(::Type{IntervalMD}) = [Interval(0), Interval(0)]
promote_type(Int, Interval)


Base.zero(x::Interval) = Interval(0)
Base.zero(x::Any) = 0















end
