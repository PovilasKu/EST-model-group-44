% Post-processing script for the EST Simulink model. This script is invoked
% after the Simulink model is finished running (stopFcn callback function).

close all;
figure;

%% Supply and demand
subplot(2,2,1);
plot(tout/unit("day"), PSupply/unit("W"));
hold on;
plot(tout/unit("day"), PDemand/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Supply and demand');
xlabel('Time [day]');
ylabel('Power [W]');
legend("Supply","Demand");

%% Stored energy
subplot(2,2,2);
plot(tout/unit("day"), EStorage/((4*pi/3)*ro*c*(r1^3))+285.15);
xlim([0 tout(end)/unit("day")]);
grid on;
title('Storage temperature');
xlabel('Time [day]');
ylabel('Temperature [K]');

%% Energy losses
subplot(2,2,3);
plot(tout/unit("day"), D/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Losses');
xlabel('Time [day]');
ylabel('Dissipation rate [W]');

%% Load balancing
subplot(2,2,4);
plot(tout/unit("day"), PSell/unit("W"));
hold on;
plot(tout/unit("day"), PBuy/unit("W"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Load balancing');
xlabel('Time [day]');
ylabel('Power [W]');
legend("Sell","Buy");




%% Storage but energy
figure;
hold off;
plot(tout/unit("day"), EStorage/unit("J"));
xlim([0 tout(end)/unit("day")]);
grid on;
title('Storage energy');
xlabel('Time [day]');
ylabel('Energy [J]');
%% Pie charts

% integrate the power signals in time
EfromSupplyTransport = trapz(tout, PfromSupplyTransport);
EtoDemandTransport   = trapz(tout, PtoDemandTransport);
ESell                = trapz(tout, PSell);
EBuy                 = trapz(tout, PBuy);
EtoInjection         = trapz(tout, PtoInjection);
EfromExtraction      = trapz(tout, PfromExtraction);
EStorageDissipation  = trapz(tout, DStorage);
EDirect              = EfromSupplyTransport - ESell - EtoInjection;
ESurplus             = EtoInjection-EfromExtraction-EStorageDissipation;

figure;
tiles = tiledlayout(1,3);

ax = nexttile;
pie(ax, [EDirect, EtoInjection, ESell]/EfromSupplyTransport);
lgd = legend({"Direct to demand", "To storage", "Sold"});
lgd.Layout.Tile = "south";
title(sprintf("Received energy %3.2e [J]", EfromSupplyTransport/unit('J')));

ax = nexttile;
pie(ax, [EDirect, EfromExtraction, EBuy]/EtoDemandTransport);
lgd = legend({"Direct from supply", "From storage", "Bought"});
lgd.Layout.Tile = "south";
title(sprintf("Delivered energy %3.2e [J]", EtoDemandTransport/unit('J')));


%% LOSS CALCULATIONS

% Storage losses
EStorageLoss = trapz(tout, DStorage);

% Injection losses
EInjectionLoss = trapz(tout, aInjection * PtoInjection);

% Extraction losses
EExtractionLoss = trapz(tout, D_extraction);

% Supply transport losses
ESupplyTransportLoss = trapz(tout, ...
    aSupplyTransport * PSupply);

% Demand transport losses
EDemandTransportLoss = trapz(tout, ...
    aDemandTransport * PtoDemandTransport);

% Total losses
ETotalLoss = ...
    EStorageLoss + ...
    EInjectionLoss + ...
    EExtractionLoss + ...
    ESupplyTransportLoss + ...
    EDemandTransportLoss;

%% Maximum allowed losses

allowedLossFraction = 0.05; % 5%

E_loss_max = allowedLossFraction * EStorageMax;

%% Requirement check

if ETotalLoss <= E_loss_max
    fprintf('Requirement satisfied\n');
else
    fprintf('Requirement NOT satisfied\n');
end

%% Print results

fprintf('\n===== LOSS ANALYSIS =====\n');

fprintf('Storage losses:          %.3e J\n', EStorageLoss);
fprintf('Injection losses:        %.3e J\n', EInjectionLoss);
fprintf('Extraction losses:       %.3e J\n', EExtractionLoss);
fprintf('Supply transport losses: %.3e J\n', ESupplyTransportLoss);
fprintf('Demand transport losses: %.3e J\n', EDemandTransportLoss);

fprintf('--------------------------------\n');

fprintf('Total system losses:     %.3e J\n', ETotalLoss);
fprintf('Maximum allowed losses:  %.3e J\n', E_loss_max);


%% Loss pie chart

figure;

Losses = [
    EStorageLoss ...
    EInjectionLoss ...
    EExtractionLoss ...
    ESupplyTransportLoss ...
    EDemandTransportLoss
];

% Avoid issues with exact zeros
LossesPlot = Losses;
LossesPlot(LossesPlot == 0) = eps;

labels = {
    'Storage losses'
    'Injection losses'
    'Extraction losses'
    'Supply transport losses'
    'Demand transport losses'
};

pie(LossesPlot);

legend(labels, 'Location', 'southoutside');

title(sprintf('Total losses = %.3e J', ETotalLoss));