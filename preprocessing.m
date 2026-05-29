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

%General parameters
ro = 997*unit("kg/(m^3)"); % density of tank liquid
c = 4184*unit("J/(Kg*K)"); % heat capacity of tank liquid
Tmax = 363.15*unit("K"); 
Tground = 285.15*unit("K");
Twater = 285.15*unit("K");

%Thermal coeficients and thicknesses
ha = 50*unit("W/(m^2*K)"); % convective heat transfer coeficient of air range: 10-500
ks = 15*unit("W/(m*K)"); % conductive heat transfer coeficient of steel 
ki = 0.05*unit("W/(m*K)"); % conductive heat transfer coeficient of insulation range:0.02-0.05
kg = 1*unit("W/(m*K)"); % conductive heat transfer coeficient of ground
x = 0.2*unit("m"); % shell thickness range: 0.1-1
d = 0.1*unit("m"); % insulation thickness range: 0.05-1


%Geometry
V = ((EStorageMax*3.6e9)/(ro*c*(Tmax-Tground)))*unit("m^3"); % volume of the tank 
r1 = ((3*V)/(4*pi))^(1/3)*unit("m"); % inner radius of the tank
r2 = (r1+x)*unit("m"); % radius of the tank + steel layer
r3 = (r2+d)*unit("m"); % radius of the tank + steel + insulation layer
rinf = 20*unit("m"); % radius of the infinite ground

%Resistances
Rs = ((1/(4*pi*ks))*((1/r1)-(1/(r2))))*unit("K/W"); % resistance of the steel layer
Ri = ((1/(4*pi*ki))*((1/(r2))-(1/(r3))))*unit("K/W"); % resistance of the insulation layer
Rc = ((1/(4*pi*kg))*((1/r3)-(1/rinf)))*unit("K/W"); % resistance of the ground
Ra = (0*(1/(4*pi*ha*r3)))*unit("K/W"); % Resistance of the surface when sphere is outside
Rt = (Rs+Ri+Rc+Ra)*unit("K/W"); % total resitance

%Storage dissipation coeficcient
bStorage = (1/(ro*V*c*Rt))/unit("s");  % Storage dissipation coefficient


% extraction system
aExtraction = 0.6; % Dissipation coefficient

% transport to demand
aDemandTransport = 0.01; % Dissipation coefficient