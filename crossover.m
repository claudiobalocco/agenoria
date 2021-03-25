% Agenoria Algorithm: A genetic algorithm for the design of emag components
% Copyright (C) 2021 Vanessa Fenlon
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 3 as
% published by the Free Software Foundation.
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
% GNU General Public License for more details.
% You should have received a copy of the GNU General Public License
% along with this program. If not, see <https://www.gnu.org/licenses/>.



function crossover(To_fileID,x_genome,y_genome)
        
        %Allocate condensed genome for child 
        input = zeros(20,20);
        
        for idx = 1:20
            for idx2 = 1:20
                dec= rand(1);  %Decide between parents genes
                if dec<0.5     %Then choose x genome
                    input(idx2,idx) = x_genome(idx2*5-4,idx*5-4);
                elseif dec>0.5 %Then choose y genome
                    input(idx2,idx) = y_genome(idx2*5-4,idx*5-4);
                end
            end
        end    
        
        %Multiply for full size
        output = repelem(input,5,5);
        %Allocate feedline
        output(1:40,49:52)=1;
        %Write to file
        dlmwrite(To_fileID,output);
end