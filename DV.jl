module diff

import Base.+
import Base.-
import Base.*
import Base./
import Base.exp
import Base.log
import Base.^

export DV, +, -, * , / ,exp , log , ^

type DV
    f
    d
end
            function DV(f::Float64)
                DV(f,0) 
            end

            function +(v::DV, w::DV)
            nuevof=v.f+w.f;
            nuevod=v.d+w.d;
            DV(nuevof,nuevod)
            end

            function -(v::DV, w::DV)
            nuevof=v.f-w.f;
            nuevod=v.d-w.d;
            DV(nuevof,nuevod)
            end


            function *(v::DV, w::DV)
            nuevof=v.f*w.f;
            nuevod=v.f*w.d+v.d*w.f;
            DV(nuevof,nuevod)
            end
#Para multiplicar por escalares es más fácil usar la definición de constante, es decir usar DV(3)*DV(x) en vez de definir 3*DV(v)

            function /(v::DV, w::DV)
            nuevof=v.f/w.f;
            nuevod=(v.d*w.f-v.f*w.d)/(w.f^2);
            DV(nuevof,nuevod)
            end

            function ^(v::DV, a::Float64) #Decidí dejarla así para no causar problema con las potencias ya definidas
            nuevof=(v.f^a);
            nuevod=a*(v.f^(a-1))*v.d
            DV(nuevof,nuevod)
            end
            
            function exp(v::DV) #Decidí dejarla así para no causar problema con las potencias ya definidas
            nuevof=exp(v.f);
            nuevod=exp(v.f)*v.d
            DV(nuevof,nuevod)
            end

            function log(v::DV) #Decidí dejarla así para no causar problema con las potencias ya definidas
            nuevof=exp(v.f);
            nuevod=(1/v.f)*v.d
            DV(nuevof,nuevod)
            end

            function variableindep(v::DV)
            nuevof=v.f;
            nuevod=1.0;
            DV(nuevof,nuevod)
            end
end
