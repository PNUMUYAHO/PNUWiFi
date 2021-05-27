function [txPositions, rxPositions] = hDropNodes(scenario, numRx)
%hDropNodes Returns random node positions based on scenario
%
%   [TXPOSITIONS, RXPOSITIONS] = hDropNodes(SCENARIO) generates and returns
%   random positions to the transmitter and receiver nodes in the network.
%
%   TXPOSITIONS is an N-by-M array where N is the number of APs per room
%   and M is the number of floors. It holds the positions of the
%   transmitters (APs) in the scenario.
%
%   RXPOSITIONS is an N-by-M array where N is the number of STAs per room
%   and M is the number of floors. It holds the positions of the
%   receivers (STAs) in the scenario.
%
%   SCENARIO is a structure specifying the following parameters:
%       BuildingLayout  - Layout in the form of [x,y,z] specifying number 
%                         of rooms in x-direction, number of rooms in 
%                         y-direction, and number of floors
%       RoomSize        - Size of the room in the form [x,y,z] in meters
%       NumRxPerRoom    - Number of stations per room

%   Copyright 2021 The MathWorks, Inc.

    numTx1F = 3; 
    numTx2F = 8;
    numTx3F = 6;
    numTxAll = numTx1F + numTx2F + numTx3F;
    
    numRx1F = sum(numRx.firstFloor,2);
    numRx2F = sum(numRx.secondFloor,2);
    numRx3F = sum(numRx.thirdFloor,2);

    Height = scenario.RoomSize(1,3)/2;
    
    x0 = [14; 27; 38; %1F
          15; 35; 20; 35; 50; 30; 10; 10; %2F
          10; 30; 25; 10; 30; 40]; %3F 
    y0 = [18; 27; 35; %1F
          35; 35; 10; 15; 35; 25; 10; 25; %2F
          25; 35; 10; 10; 25; 15]; %3F           
    z0 = [zeros(numTx1F,1) + Height; zeros(numTx2F,1) + Height*3; zeros(numTx3F,1) + Height*5]; % note we don't adjust z height
    txPositions = [x0, y0, z0];
    
    x1F = zeros(numRx1F,1);
    x2F = zeros(numRx2F,1);
    x3F = zeros(numRx3F,1);
    %x4F = scenario.RoomSize(1) * rand(numRx4F,1);
    
    y1F = [];
    y2F = [];
    y3F = [];
    %y4F = [];
    
    for j = 1:numRx1F
        if(j < numRx.firstFloor(1)+1)
            x1F(j,1) = 22 * rand(1);
            if(x1F(j,1) < 15)
                y1F = [y1F; 33 * rand(1)];
            else
                y1F = [y1F; 22 * rand(1)];
            end
        else
            x1F(j,1) = 44*rand(1) + 8;
            if(x1F(j,1) < 15)
                y1F = [y1F; 5*rand(1) + 33];
            elseif(x1F(j,1) < 22)
                y1F = [y1F; 16*rand(1) + 22];
            elseif(x1F(j,1) < 34)
                y1F = [y1F; 20*rand(1) + 18];
            elseif(x1F(j,1) < 44)
                y1F = [y1F; 12*rand(1) + 26];
            else
                y1F = [y1F; 3*rand(1) + 33];
            end
        end
    end
    
    for j = 1:numRx2F
        if(j < numRx.secondFloor(1)+1)
            x2F(j,1) = 10*rand(1) + 8;
            y2F = [y2F; 5*rand(1) + 33];
        elseif(j < numRx.secondFloor(2)+1)
            x2F(j,1) = 28*rand(1) + 18;
            if(x2F(j,1) < 40)
                y2F = [y2F; 16*rand(1) + 22];
            else
                y2F = [y2F; 5*rand(1) + 33];
            end
        elseif(j < numRx.secondFloor(3)+1)
            x2F(j,1) = 28 * rand(1);
            if(x2F(j,1) < 15)
                y2F = [y2F; 33 * rand(1)];
            else
                y2F = [y2F; 22 * rand(1)];
            end
        elseif(j < numRx.secondFloor(4)+1)
            x2F(j,1) = 12*rand(1) + 28;
            y2F = [y2F; 8*rand(1) + 10];
        elseif(j < numRx.secondFloor(5)+1)
            x2F(j,1) = 14*rand(1) + 46;
            y2F = [y2F; 27*rand(1) + 33];
        elseif(j < numRx.secondFloor(6)+1)
            x2F(j,1) = 28*rand(1) + 18;
            if(x2F(j,1) < 40)
                y2F = [y2F; 16*rand(1) + 22];
            else
                y2F = [y2F; 5*rand(1) + 33];
            end
        else
            x2F(j,1) = 28 * rand(1);
            if(x2F(j,1) < 15)
                y2F = [y2F; 33 * rand(1)];
            else
                y2F = [y2F; 22 * rand(1)];
            end
        end
    end
    
    for j = 1:numRx3F
        if(j < numRx.thirdFloor(1)+1)
            x3F(j,1) = 22 * rand(1);
            if(x3F(j,1) < 15)
                y3F = [y3F; 33 * rand(1)];
            else
                y3F = [y3F; 22 * rand(1)];
            end
        elseif(j < numRx.thirdFloor(2)+1)
            x3F(j,1) = 31*rand(1) + 15;
            if(x3F(j,1) < 34)
                y3F = [y3F; 16*rand(1) + 22];
            else
                y3F = [y3F; 12*rand(1) + 26];
            end
        elseif(j < numRx.thirdFloor(3)+1)
            x3F(j,1) = 6*rand(1) + 22;
            y3F = [y3F; 18 * rand(1)];
        elseif(j < numRx.thirdFloor(4)+1)
            x3F(j,1) = 22 * rand(1);
            if(x3F(j,1) < 15)
                y3F = [y3F; 33 * rand(1)];
            else
                y3F = [y3F; 22 * rand(1)];
            end
        elseif(j < numRx.thirdFloor(5)+1)
            x3F(j,1) = 31*rand(1) + 15;
            if(x3F(j,1) < 34)
                y3F = [y3F; 16*rand(1) + 22];
            else
                y3F = [y3F; 12*rand(1) + 26];
            end
        else
            x3F(j,1) = 16*rand(1) + 28;
            if(x3F(j,1) < 34)
                y3F = [y3F; 13*rand(1) + 5];
            else
                y3F = [y3F; 21*rand(1) + 5];
            end
        end
    end

%     for j = 1:size(x4F,1)
%         if(x4F(j,1) < 8)
%             y4F = [y4F; 33 * rand(1)];
%         elseif(x4F(j,1) < 15)
%             y4F = [y4F; 46 * rand(1)];
%         elseif(x4F(j,1) < 28)
%             y4F = [y4F; 60 * rand(1)];
%         elseif(x4F(j,1) < 44)
%             y4F = [y4F; 55*rand(1) + 5];
%         elseif(x4F(j,1) < 52)
%             y4F = [y4F; 34*rand(1) + 26];
%         else
%             y4F = [y4F; 27*rand(1) + 33];
%         end
%     end
    x1 = [x1F; x2F; x3F];
    y1 = [y1F; y2F; y3F];
    z1 = [zeros(numRx1F,1) + 2; zeros(numRx2F,1) + 6; zeros(numRx3F,1) + 10]; % note we don't adjust z height
    rxPositions = [x1, y1, z1];
end