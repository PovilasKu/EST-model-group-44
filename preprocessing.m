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

%Tank parameters
ro = 997; % density of tank liquid
c = 4184; % heat capacity of tank liquid
dT = 77; % temperature difference tank and outside range: 67-77
sig = 5.67e-8; % stephan boltzman constant 

%Thermal coeficients and thicknesses
hw = 500; % convective heat transfer coeficient of water range:50-3000
ha = 50; % convective heat transfer coeficient of air range: 10-500
ks = 15; % conductive heat transfer coeficient of steel 
ki = 0.05; % conductive heat transfer coeficient of insulation range:0.02-0.05
kg = 1; % conductive heat transfer coeficient of ground
x = 0.2; % shell thickness range: 0.1-1
d = 0.3; % insulation thickness range: 0-1
eps = 0.1; % emissivity of outside material 0.05-0.95
Ta = 15; % Temperature of air
Ts = 90; % surface temperature of tank 
hr = (sig*eps*(Ts+Ta)*(Ts^2+Ta^2)); % coeficient of the radiation loss

%Geometry
V = EStorageMax/(ro*c*dT); % volume of the tank 
ri = ((3*V)/(4*pi))^(1/3); % inner radius of the tank
r2=ri+x+d; % outer radius of the tank
Ai = 4*pi*ri^2; % inner area of the tank
A2 = 4*pi*r2^2; % outer area of the tank

%Resistances
Rb = (1/(hw*Ai)); % resistance of water to steel 
Rs = (1/(4*pi*ks))*((1/ri)-(1/(ri+x))); % resistance of the steel layer
Ri = (1/(4*pi*ki))*((1/(ri+x))-(1/(r2))); % resistance of the insulation layer
Rc = (1/(kg*A2)); % resistance of the ground
Rsur = 0*(1/((hr+ha)*A2)); % Resistance of the surface when sphere is outside
Rt = Rb+Rs+Ri+Rc+Rsur; % total resitance

%Storage dissipation coeficcient
bStorage = (1/(ro*V*c*Rt))/unit("s");  % Storage dissipation coefficient


% extraction system
aExtraction = 0.6; % Dissipation coefficient

% transport to demand
aDemandTransport = 0.01; % Dissipation coefficient