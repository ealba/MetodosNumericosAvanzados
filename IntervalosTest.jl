using FactCheck
using Intervalos

	facts("Pruebas aritméticas") do
	X1= Interval(5,6);
	Y1= Interval(-2,4); 	
	A = Interval(2,1);
	B = Interval(1,2.0);
	C = Interval(5.0,6.0);
	D = Interval(-1,1); 
    E = Interval(1.10,1.101);
    F = Interval(0.1 , 0.1);  
    G = Interval(1,4)^(1/2);
    H = Interval(1,2);
    I=1000000.1
    J=Interval(I)
    K=(J^2)
    x = 0.1; 
    y = 1.1;  
    
    @fact A => B
    @fact A+B => Interval(2)*A
    @fact X1-Y1 => Interval(1,8)
    @fact A/B => Interval(0.5,2)
    @fact A*B => Interval(1,4)
    @fact A*D => Interval(-2,2)
    @fact H.lo in G  &&  H.hi in G=> true
   
    
    @fact_throws DomainError Interval(-1,2)^(1/4) "No está bien definida la potencia para negativos"
    
    @fact 0 in D=> true
    @fact y in E=> true
    @fact x in F=> true
    @fact 1000000200000.01 in K => true
   

end

