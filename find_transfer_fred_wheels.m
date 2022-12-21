M = 0.415;%[kg]
R = 0.15/2; %[m]
r = 0.092/2 ;%[m]

%motor30.04758 N.m
torque = 30.04758;%[N.m] 
P = 16.5; %[w]
Km = torque/sqrt(P) ;

kt = Km*R

J = M*(power(r,2)+power(R,2))/2 ;
b = 0.1;
K = kt;
R = 2;
L = 0.0029;
s = tf('s');
P_motor = K/((J*s+b)*(L*s+R)+K^2);