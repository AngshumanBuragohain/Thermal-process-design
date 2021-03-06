%% Batch distillation of Binary mixtures 
% This example takes Benzene (comp.1) and Toluene (comp.2) as the two
% components. The initial mole fraction of the more volatile component,
% benzene is 0.8. The partial pressures of both the components are
% calculated by Antoine's equation. The progression of the distillation
% process based on molar fraction evaporated and the corresponding mole
% fractions of benzene and toluene is traced.
%% The program is adaptable towards different binary mixtures and different initial mole fraction of comp 1.

close all;
clear all;

%% Antoine equation for partial pressue
% Equation of the form ln(p) = A - B/(T+C).............................(1)
Pi = @(a,b,c,x) exp(a-(b./(c+x)));

% Total pressure in mbar
P = 1013.25;

% Number of sample points for plotting partial pressure with Temperature
N = 1000;

% Antoine constants for the 1st component in the binary mixture (User
% enters the component specific data here)
A1 = 16.27 ; B1 = 2817.29 ; C1 = 221.37;
T1_min = 6 ; T1_max = 140;
T1 = T1_min:(T1_max-T1_min)/N:T1_max;

% Antione constants for the 2nd component in the binary mixture (User
% enters the component specific data here)
A2 = 16.4387 ; B2 = 3173.958 ; C2 = 222.88;
T2_min = -18.4 ; T2_max = 177.8;
T2 = T2_min:(T2_max-T2_min)/N:T2_max;

% Partial pressures for component 1 and 2
P1 = zeros(1,N+1);
P2 = zeros(1,N+1);

for i=1:N+1
    P1(i) = Pi(A1,B1,C1,T1(i));
    P2(i) = Pi(A2,B2,C2,T2(i));
end

subplot (2,2,1)
plot(T1,P1, 'Displayname','Component 1')
hold on;
plot(T2,P2, 'Displayname','Component 2')
hold off;
title("Partial pressure based on Antoine's equation")
xlabel("Temperature in degree Celsius");
ylabel("Pressure in mbar");
legend;

%% Separation factor calculation for a given temperature
% Separation factor: W12 = P1*/P2*......................................(2)
T = 100;                                % User enters the operating temperature here
W = Pi(A1,B1,C1,T)/Pi(A2,B2,C2,T);      % Separation factor based on eqn.(2)  

%% Equilibrium lines for the mixture

x1 = 0:0.01:1;
line = 0:0.01:1;
y1 = x1.*W./(x1.*(W-1)+1);
x2 = 1.-x1;
y2 = 1.-y1;

subplot (2,2,2)
plot(x1,y1,'Displayname','Component 1')
hold on;
plot(x1,line,'k--','HandleVisibility','off')
plot(x2,y2,'Displayname','Component 2')
hold off;
title("Equilibrium curves")
xlabel("Mole fraction in liquid phase, xi")
ylabel("Mole fraction in vapor phase, yi")
legend;

%% Bubble point and dew point lines for components

% Bubble point line: x_1 = (P - P2*)/(P1* - P2*)........................(3)

% Setting boundary conditions for temperature
T_max = B2/(A2-log(P))-C2;             % At T_max, x1 = 0
T_min = B1/(A1-log(P))-C1;             % At T_min, x1 = 1

Tstep = 0.1;                           % Temperatures at intervals of 1 degree C
Temp = T_min:Tstep:T_max;

% Bubble point line values
x_1 = (P - Pi(A2,B2,C2,Temp))./(Pi(A1,B1,C1,Temp) - Pi(A2,B2,C2,Temp));

% Dew point line: y1 = x1P1*/P..........................................(4)
y_1 = x_1.*Pi(A1,B1,C1,Temp)./P;

subplot (2,2,3)
plot(x_1,Temp,'r','DisplayName','Bubble Point line')
hold on;
plot(y_1,Temp,'g','DisplayName','Dew Point line')
hold off;
title("Temperature dependence")
xlabel("Molar fractions x1, y1");
ylabel("Temperature in degree C");
legend;

%% Fractional distillation and molar composition at each stage of distillation
% Calculation based on mole fraction of mixture remaining in the vessel,
% NL_NLo
% The equation is: 
% NL/NLo = ((x1/x1o)^(1/(W-1))*((1-x1o)/(1-x1))^(W/(W-1))...............(5)

% Given inital mole fraction of Component 1 = 0.8
xo = 0.8;                     % User can input initial mole fraction here 
% Range of evaporated by initial molar ratio
NL_NLo = 0:0.01:1;

% Initialise solution matrix for x1
xi_1 = zeros(1,length(NL_NLo));

x_sol = 0:1e-3:1;   % Find solution for x1 in the range 0-1 with steps of 0.001

% Simplification of the exponents in the equation
a = 1/(W-1);
b = W/(W-1);

RHS = @(x) (((x/xo)^a)*(((1-xo)/(1-x))^b));   % RHS of eqn (5)

for i=1:(length(NL_NLo))
    for j=1:length(x_sol)
            % Relative error between LHS and RHS of the equation (5)
        err = ( RHS(x_sol(j)) - NL_NLo(i))/NL_NLo(i);
            % If magnitude of relative error is less than 0.01
        if (abs(err)<=1e-02)
                % The assumed solution is the actual solution
            xi_1(i) = x_sol(j);
            break;
        else
            xi_1(i) = 0;
        end
    end
end

yi_1 = xi_1.*W./(xi_1.*(W-1)+1);
xi_2 = 1.-xi_1;
yi_2 = 1.-yi_1;

subplot (2,2,4)
plot(NL_NLo,xi_1,'b','DisplayName','x1')
hold on;
plot(NL_NLo,xi_2,'r','DisplayName','x2')
plot(NL_NLo,yi_1,'b--','DisplayName','y1')
plot(NL_NLo,yi_2,'r--','DisplayName','y2')
title("Trace fractional distillation")
xlabel("NL/NLo");
ylabel("x,y (Mole fractions: x-liq.phase, y-vap.phase");
legend;