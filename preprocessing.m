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

% storage system
EStorageMax     = 107.*unit("MWh"); % Maximum energy
EStorageMin     = 0.0*unit("MWh"); % Minimum energy
EStorageInitial = 0.0*unit("MWh"); % Initial energy

%General parameters
ro = 2900; % density of basalt (kg/m^3)
c = 1000; % heat capacity of tank liquid (J/(kg*K)
Tmax = 1073.15; % maximum temperature of the basalt (K)
Tground = 285.15; % ground temperature (K)
Twater = 285.15; % water temperature (K)

%Thermal coeficients and thicknesses
ha = 50; % convective heat transfer coeficient of air (W/(m^2*K) range: 10-500
ks = 15; % conductive heat transfer coeficient of steel (W/(m*K)
ki = 0.032; % conductive heat transfer coeficient of insulation (W/(m*K) range:0.02-0.05
kg = 1; % conductive heat transfer coeficient of ground (W/(m*K)
x = 0.2; % shell thickness (m) range: 0.1-1
d = 0.1; % insulation thickness (m) range: 0.05-1


%Geometry
V = ((EStorageMax)/(ro*c*(Tmax-Tground))); % volume of the tank (m^3) 
r1 = ((3*V)/(4*pi))^(1/3); % inner radius of the tank (m)
r2 = (r1+x); % radius of the tank + steel layer (m)
r3 = (r2+d); % radius of the tank + steel + insulation layer (m)
rinf = 5; % radius of the infinite ground (m)

%Resistances
Rs = ((1/(4*pi*ks))*((1/r1)-(1/(r2)))); % resistance of the steel layer (K/W)
Ri = ((1/(4*pi*ki))*((1/(r2))-(1/(r3)))); % resistance of the insulation layer (K/W)
Rc = ((1/(4*pi*kg))*((1/r3)-(1/rinf))); % resistance of the ground (K/W)
Ra = ((1/(4*pi*ha*r3))); % Resistance of the surface when sphere is outside (K/W)
Rtb = (Rs+Ri+Rc); % total resitance for burried tank (K/W)
Rto = (Rs+Ri+Ra); % total resistance for outside tank (K/W)


%% Dissipation coefficients

% extraction system
aExtraction = 0.4; % Dissipation coefficient from the storage (converter efficiency)


% injection system
aInjection = 0.2; % Dissipation coefficient (1-efficiency of heater)


% Power line dissipation coefficients
aDemandTransport = 0.6;

aSupplyTransport = 0.6;

%Storage dissipation coeficcient
bStorage = (1/(ro*V*c*Rtb))/unit("s");  % Storage dissipation coefficient

