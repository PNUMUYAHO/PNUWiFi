rng(1,'twister');                       % Seed for random number generator
simulationTime = 0.1*1e6;               % Simulation time in microseconds
showLiveStateTransitionPlot = true;     % Show live state transition plot for all nodes
displayStatsInUITable = true;           % Display table of statistics

% Add the folder to the path for access to all helper files
addpath(genpath(fullfile(pwd, 'mlWLANSystemSimulation')));

% 2019-06-01 ~ 2019-12-31 data
data = readtable('aps_2019_lib-2.csv');
dataStruct = table2struct(data);

Date = struct;
Date.month = input("Enter the month: ");
Date.day = input("Enter the day: ");
Date.hour = input("Enter the hour: ");

apNames = struct;
apNames.firstFloor = ["11S-420-1-1" "11S-420-1-2" "16AP-420-1-3"];
apNames.secondFloor = ["16AP-420-2-1" "11S-420-2-2" "11S-420-2-3" "11S-420-2-4" "16K-420-2-5" "16AP-420-2-6" "16AP-420-2-7" "18AP-420-2-8"];
apNames.thirdFloor = ["16AP-420-3-1" "11S-420-3-2" "11S-420-3-3" "16AP-420-3-4" "16K-420-3-5" "16AP-420-3-6"];
    
numRx = struct;
numRx.firstFloor = zeros(1,length(apNames.firstFloor));
numRx.secondFloor = zeros(1,length(apNames.secondFloor));
numRx.thirdFloor = zeros(1,length(apNames.thirdFloor));
    
for n = 1:size(dataStruct,1)
    if(dataStruct(n).month == Date.month && dataStruct(n).day == Date.day && dataStruct(n).hour == Date.hour)
        for m = 1:length(apNames.firstFloor)
            if(strcmp(dataStruct(n).APName, apNames.firstFloor(m)))
                numRx.firstFloor(m) = dataStruct(n).TotalNumberOfUsers_1;
            end
        end
            
        for m = 1:length(apNames.secondFloor)
            if(strcmp(dataStruct(n).APName, apNames.secondFloor(m)))
                numRx.secondFloor(m) = dataStruct(n).TotalNumberOfUsers_1;
            end
        end
            
        for m = 1:length(apNames.thirdFloor)
            if(strcmp(dataStruct(n).APName, apNames.thirdFloor(m)))
                numRx.thirdFloor(m) = dataStruct(n).TotalNumberOfUsers_1;
            end
        end
    end
end
numRx.firstFloor
numRx.secondFloor
numRx.thirdFloor
    
numRxAll = sum(numRx.firstFloor,2) + sum(numRx.secondFloor,2) + sum(numRx.thirdFloor,2);

ScenarioParameters = struct;
% Number of rooms in [x,y,z] directions
ScenarioParameters.BuildingLayout = [1 1 17];
% Size of each room in meters [x,y,z]
ScenarioParameters.RoomSize = [60 60 4];
% Number of STAs
ScenarioParameters.NumRx = numRxAll;

% Obtain random positions for placing nodes
[apPositions, staPositions] = hDropNodes(ScenarioParameters, numRx);

% Get the IDs and positions of each node
[nodeConfigs, trafficConfigs] = hLoadConfiguration(ScenarioParameters, apPositions, staPositions, numRx);

nodeConfigs(1).TxMCS = 6;
trafficConfigs(1).PacketSize = 1000;

% Create transmitter and receiver sites
[txs,rxs] = hCreateSitesFromNodes(nodeConfigs);

% Create triangulation object and visualize the scenario
tri = hTGaxResidentialTriangulation(ScenarioParameters);
hVisualizeLibraryScenario(tri,txs,rxs,apPositions);



% Generate propagation model and lookup table
propModel = hTGaxResidentialPathLoss('Triangulation',tri,'ShadowSigma',0,'FacesPerWall',1);
[pl,tgaxIndoorPLFn] = hCreatePathlossTable(txs,rxs,propModel);

% Create WLAN nodes
wlanNodes = hCreateWLANNodes(nodeConfigs, trafficConfigs, simulationTime, tgaxIndoorPLFn);

% Initialize visualization parameters and create an object for
% hStatsLogger which is a helper for retrieving, and displaying
% the statistics.
visualizationInfo = struct;
visualizationInfo.DisablePlot = ~showLiveStateTransitionPlot;
visualizationInfo.Nodes = wlanNodes;
statsLogger = hStatsLogger(visualizationInfo);  % Object that handles retrieving and visualizing statistics
networkSimulator = hWirelessNetworkSimulator;   % Object that handles network simulation

% Run the simulation
run(networkSimulator, wlanNodes, simulationTime, statsLogger);

% Cleanup the persistent variables used in functions
clear edcaPlotStats;

% Retrieve the statistics and store them in a mat file
statistics = getStatistics(statsLogger, ~displayStatsInUITable);

% Save the statistics to a mat file
save('statistics.mat', 'statistics');

% Plot the throughput, packet loss ratio, and average packet latency at each node
hPlotNetworkStats(statistics, wlanNodes);

% Remove the folder from the path
rmpath(genpath(fullfile(pwd, 'mlWLANSystemSimulation')));