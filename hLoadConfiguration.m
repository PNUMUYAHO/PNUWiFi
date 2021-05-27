function [nodeConfigs, trafficConfigs] = hLoadConfiguration(scenarioParameters, apPositions, staPositions, numRx)
%loadConfiguration Returns the node and traffic configuration
%   [NODECONFIGS, TRAFFICCONFIGS] = hLoadConfiguration(SCENARIO,
%   APPOSITIONS, STAPOSITIONS)
%
%   NODECONFIGS is an array of structures of type wlanNodeConfig. The array
%   size is equal to the number of nodes in the network, specifying MAC and
%   PHY configurations for all the nodes.
%
%   TRAFFICCONFIGS is an array of structures of type wlanTrafficConfig. The
%   array size is equal to the total number of receivers in the building,
%   specifying traffic generation for each destination.
%
%   SCENARIO is a structure specifying the following parameters:
%       BuildingLayout  - Layout in the form of [x,y,z] specifying number 
%                         of rooms in x-direction, number of rooms in 
%                         y-direction, and number of floors
%       RoomSize        - Size of the room in the form [x,y,z] in meters
%       NumRxPerRoom    - Number of stations per room
%
%   APPOSITIONS is an N-by-M array where N is the number of APs per room
%   and M is the number of floors. It holds the positions of the
%   transmitters (APs) in the scenario.
%
%   STAPOSITIONS is an N-by-M array where N is the number of STAs per room
%   and M is the number of floors. It holds the positions of the
%   receivers (STAs) in the scenario.

%   Copyright 2021 The MathWorks, Inc.

numRooms = prod(scenarioParameters.BuildingLayout);
numAPs = numRooms;
numSTAs = scenarioParameters.NumRx;
numNodes = numAPs + numSTAs;

% Get the node IDs and positions for all the nodes
[nodeIDs, positions] = hGetIDsAndPositions(scenarioParameters, apPositions, staPositions);

% Load the application traffic configuration for WLAN nodes
s = load('wlanTrafficConfig.mat', 'wlanTrafficConfig');

% Configure application traffic such that each AP has traffic for all STAs
% present in same room.
trafficConfigs = repmat(s.wlanTrafficConfig, 1, numSTAs);
cfgIdx = 0;

for nodeIdx = 1:length(numRx.firstFloor)
    % Node IDs of AP and STAs present in apartment
    apID = nodeIdx;
    if(numRx.firstFloor(nodeIdx) > 0)
        for staIdx = 1:numRx.firstFloor(nodeIdx)    
            trafficConfigs(cfgIdx + staIdx).SourceNode = apID;
            trafficConfigs(cfgIdx + staIdx).DestinationNode = numAPs + staIdx;
        end
        cfgIdx = cfgIdx + numRx.firstFloor(nodeIdx);
    end
end
for nodeIdx = 1:length(numRx.secondFloor)
    % Node IDs of AP and STAs present in apartment
    apID = length(numRx.firstFloor) + nodeIdx;
    if(numRx.secondFloor(nodeIdx) > 0)
        for staIdx = 1:numRx.secondFloor(nodeIdx)    
            trafficConfigs(cfgIdx + staIdx).SourceNode = apID;
            trafficConfigs(cfgIdx + staIdx).DestinationNode = numAPs + sum(numRx.firstFloor,2) + staIdx;
        end
        cfgIdx = cfgIdx + numRx.secondFloor(nodeIdx);
    end
end
for nodeIdx = 1:length(numRx.thirdFloor)
    % Node IDs of AP and STAs present in apartment
    apID = length(numRx.firstFloor) + length(numRx.secondFloor) + nodeIdx;
    if(numRx.thirdFloor(nodeIdx) > 0)
        for staIdx = 1:numRx.thirdFloor(nodeIdx)    
            trafficConfigs(cfgIdx + staIdx).SourceNode = apID;
            trafficConfigs(cfgIdx + staIdx).DestinationNode = numAPs + sum(numRx.firstFloor,2) + sum(numRx.secondFloor,2) + staIdx;
        end
        cfgIdx = cfgIdx + numRx.thirdFloor(nodeIdx);
    end
end

% Load the node configuration structure and initialize for all the nodes
s = load('wlanNodeConfig.mat', 'wlanNodeConfig');
nodeConfigs = repmat(s.wlanNodeConfig, 1, numNodes);

% Customize configuration for nodes
% Set node positions in each node configuration
for nodeIdx = 1:numNodes
    nodeID = nodeIDs(nodeIdx);
    nodeConfigs(nodeID).NodePosition = positions{nodeIdx};
end

end

function [nodeIDs, positions] = hGetIDsAndPositions(scenarioParameters, apPositions, staPositions)
%hGetIDsAndPositions Returns the IDs and positions of nodes in the network
%
%   [NODEIDS, POSITIONS] = hGetIDsAndPositions(SCENARIO, APPOSITIONS,
%   STAPOSITIONS) returns the IDs and positions of nodes in the network.
%
%   NODEIDS is an array of size N x M where N is the number of rooms and M
%   is the number of nodes in a room. It contains the ID assigned to each
%   node.
%
%   POSITIONS is a cell array of size N x M where N is the number of rooms
%   and M is the number of nodes in each room. It contains the positions of
%   each node.
%
%   SCENARIO is a structure specifying the following parameters:
%       BuildingLayout  - Layout in the form of [x,y,z] specifying number 
%                         of rooms in x-direction, number of rooms in 
%                         y-direction, and number of floors
%       RoomSize        - Size of the room in the form [x,y,z] in meters
%       NumRxPerRoom    - Number of stations per room
%
%   APPOSITIONS is an N-by-M array where N is the number of APs per room
%   and M is the number of floors. It holds the positions of the
%   transmitters (APs) in the scenario.
%
%   STAPOSITIONS is an N-by-M array where N is the number of STAs per room
%   and M is the number of floors. It holds the positions of the
%   receivers (STAs) in the scenario.

%   Copyright 2020 The MathWorks, Inc.

numRooms = prod(scenarioParameters.BuildingLayout);
numAPs = numRooms;
numSTAs = scenarioParameters.NumRx;
numAPPerRoom = numAPs/numRooms; % One AP in each room
numNodes = numAPs + numSTAs;

% Each node in the building is identified by a node ID. Node IDs 1 to N are
% assigned to the APs, where N is the number of APs in building. Node IDs
% (N + 1) to (N + M) are assigned to stations where M is the number of
% stations in the building.
apNodeIDs = (1:numAPs)';
staNodeIDs = (numAPs+1:numNodes);

% Initialize an array of size N x M where N is the number of rooms and M is
% the number of nodes in a room. This array will contain the IDs of nodes
% present in the network. Each row corresponds to a room.
nodeAPIDs = zeros(numAPs, numAPPerRoom);
nodeSTAIDs = zeros(numSTAs, 1);

% Initialize a cell array of size N x M where N is the number of rooms and
% M is the number of nodes in each room. The cells will contain the
% position of nodes present in the network. Each row corresponds to a room.
apPos = cell(numAPs, numAPPerRoom);
staPos = cell(numSTAs, 1);

% Assign IDs and positions to each node
nodeAPIDs(:, 1) = apNodeIDs;
for APIdx = 1:numAPs
    apPos{APIdx, 1} = apPositions(APIdx, :);
end

nodeSTAIDs(:, 1) = staNodeIDs;
for staIdx = 1:numSTAs
    staPos{staIdx, 1} = staPositions(staIdx, :);
end

nodeIDs = [nodeAPIDs; nodeSTAIDs];
positions = [apPos; staPos];
end