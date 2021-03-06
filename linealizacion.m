%% Linealización
clear all;clc;close all;

%Variables symbólicas
syms x1 x2 u1 u2 v2 v3 UA Co tv lamb alf V

dx1 = -((UA)/(Co)) *x1 - ((1)/(tv))*x1*u1 - ((lamb)/(Co)) * u2  + ((UA)/(Co))* v2 + ((1)/(tv))*u1*v2;
dx2 = -((1)/(tv)) * x2*u1 + ((1)/(V)) *u2 + ((1)/(tv))*u1*v3 ;

% Creación de los vectores para linealizar

dx = [dx1;dx2];
x = [x1;x2];
u = [u1,u2];
Pert = [v2;v3];

% Jacobianos

A = jacobian(dx,x);
B = jacobian(dx,u);
Bd = jacobian(dx,Pert);

% Parámetros

Co = -324.67;
UA = 29.81;
tv = 3.41;
lamb = 465;
alf = 0.0033;
V = 13.3;

% x1_p = 28; % °C 
% x2_p = 16; % gH2O/kg
u1_p = 16;
u2_p = 20;
v1_p = 250;% W/m^2
v2_p = 13; % °C
v3_p = 12; % gH2O/kg

% Puntos de equilibrio

% A = [(1/tv)*(x1_p + v2_p) -(lamb/Co); (1/tv)*(x2_p + v3_p) (1/V)];
% B = [(UA/Co)*x1_p + (UA/Co)*v2_p; -alf*v1_p];
% C = inv(A)*B;
% u1 = C(1)
% u2 = C(2)

%x1_p = (  ( (-1*UA/Co) - ((1/tv)*u1_p) )            )   /   (  (lamb/Co)*u2_p - (UA/Co)*v2_p - (1/tv)*u1_p*v2_p  )                 )
x1_p = ( ((lamb/Co)*u2_p) - ((UA/Co)*v2_p) - ((1/tv)*u1_p*v2_p) - (1/(Co))*v1_p )  /   ( (-UA/Co)- ((1/tv)*u1_p) )
x2_p = (tv/u1_p)* ( ((1/V)*u2_p) + ((1/tv)*u1_p*v3_p) + (alf*v1_p) )


% x1_p = ( ((lamb/Co)*u2_p) - ((UA/Co)*v2_p) - ((1/tv)*u1_p*v2_p) )  /   ( (-UA/Co)- ((1/tv)*u1_p) )
% x2_p = (tv/u1_p)* ( ((1/V)*u2_p) + ((1/tv)*u1_p*v3_p)  )
% Evaluando...

x1 = x1_p;
x2 = x2_p;
u1 = u1_p;
u2 = u2_p;
v1 = v1_p;
v2 = v2_p;
v3 = v3_p;


A_1 = eval(A)
B_1 = eval(B);
Bd_1 = eval(Bd); 


%% Ecuación característica.
% Polinomio carácteristico de A

syms p

A_p = A_1 - p*eye(2);
deter_A = det(A_p);
%% Grafica UNICAMENTE para mostrar estabilidad del sistema.
% Respuesta al escalón

C = eye(2);
D = zeros(2);

% sys=ss(A_1,B_1,C,D);
% figure(1)
% step(sys)

%% Controlador por realimentación de estados

% K = place(A_1,B_1,[-2 -3])

zeta= 0.7;
ts= 1000;
wn=-log(0.02)/(zeta*ts);

pol=[1 2*zeta*wn wn^2];
r = roots(pol);

p1 = r(1);
p2 = r(2);

%K = place(A_1,B_1,[p1 p2])  %NO FUNCIONA CON POLOS REPETIDOS

K = place(A_1,B_1,[-5 -60])  %NO FUNCIONA CON POLOS REPETIDOS
% 
% Alc=Ad-Bd*k;
% P1=1/(Cd*(inv(eye(2)-(Alc)))*Bd)

NumeDeno = ss(A_1,B_1,C,D);
FuncionTransferencia = tf(NumeDeno);


Anew=(A_1-B_1*K);
eig(Anew)
sys_K=ss(Anew,B_1,C,D);
figure(2)
step(sys_K)

Ref = [16;12];

GK = K
