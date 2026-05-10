% Pre-processing script for the EST Simulink model. This script is invoked
% before the Simulink model starts running (initFcn callback function).

%% Load the supply and demand data

timeUnit   = 's';

supplyFile = "Team44_supply.csv";
supplyUnit = "MW";

% load the supply data
Supply = loadSupplyData(supplyFile, timeUnit, supplyUnit);

demandFile = "Team44_demand.csv";
demandUnit = "MW";

% load the demand data
Demand = loadDemandData(demandFile, timeUnit, demandUnit);

%% Simulation settings

deltat = 15*unit("min");
stopt  = min([Supply.Timeinfo.End, Demand.Timeinfo.End]);

%% System parameters

% transport from supply
aSupplyTransport = 0.01; % Dissipation coefficient

% injection system
aInjection = 0.0; % Dissipation coefficient

% storage system
EStorageMax     = 10.*unit("MWh"); % Maximum energy
EStorageMin     = 0.0*unit("MWh"); % Minimum energy
EStorageInitial = 0.0*unit("MWh"); % Initial energy
ro = 1000;
c = 4184;
dT = 60;
x = 0.2;
d = 0.3; 
hw = 500;
ks = 15;
ki = 0.5;
kg = 1;
V = EStorageMax/(ro*c*dT);
ri = ((3*V)/(4*pi))^(1/3);
r2=ri+x+d;
Ai = 4*pi*ri^2;
A2 = 4*pi*r2^2;
Rb = (1/(hw*Ai));
Rs = (1/(4*pi*ks))*((1/ri)-(1/(ri+x)));
Ri = (1/(4*pi*ki))*((1/(ri+x))-(1/(r2)));
Rc = (1/(4*pi*kg*r2));
Rr = 0; 
Rt = Rb+Rs+Ri+Rc+Rr;
bStorage = (1/(ro*V*c*Rt))/unit("s");  % Storage dissipation coefficient

% extraction system
aExtraction = 0.6; % Dissipation coefficient

% transport to demand
aDemandTransport = 0.01; % Dissipation coefficient