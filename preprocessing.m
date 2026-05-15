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
EStorageMax     = 107.*unit("MWh"); % Maximum energy
EStorageMin     = 0.0*unit("MWh"); % Minimum energy
EStorageInitial = 0.0*unit("MWh"); % Initial energy
ro = 997; % density of tank liquid
c = 4184; % heat capacity of tank liquid
dT = 77; % temperature difference tank and outside
x = 0.2; % shell thickness
d = 0.3; % insulation thickness
hw = 500; % convective heat transfer coeficient of water
ks = 15; % conductive heat transfer coeficient of steel
ki = 0.05; % conductive heat transfer coeficient of insulation
kg = 1; % conductive heat transfer coeficient of ground
V = EStorageMax/(ro*c*dT); % volume of the tank 
ri = ((3*V)/(4*pi))^(1/3); % inner radius of the tank
r2=ri+x+d; % outer radius of the tank
Ai = 4*pi*ri^2; % inner area of the tank
A2 = 4*pi*r2^2; % outer area of the tank
Rb = (1/(hw*Ai)); % resistance of water to steel 
Rs = (1/(4*pi*ks))*((1/ri)-(1/(ri+x))); % resistance of the steel layer
Ri = (1/(4*pi*ki))*((1/(ri+x))-(1/(r2))); % resistance of the insulation layer
Rc = (1/(4*pi*kg*r2)); % resistance of the ground
Rr = 0; % resistance of the radiation loss
Rt = Rb+Rs+Ri+Rc+Rr; % total resitance
bStorage = (1/(ro*V*c*Rt))/unit("s");  % Storage dissipation coefficient

% extraction system
aExtraction = 0.6; % Dissipation coefficient

% transport to demand
aDemandTransport = 0.01; % Dissipation coefficient