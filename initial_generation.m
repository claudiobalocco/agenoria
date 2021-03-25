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

function initial_generation(generation_size)
for i=1:generation_size
    %Produce randomised 100 x 100 binary array with 5 x 5 unit size
    antenna = randi([0 1],20,20);
    Antenna_design = repelem(antenna,5,5);
    
    %Assign Feed
    Antenna_design(1:40,49:52)=1;
    
    %Write to file
    s=sprintf('Gen1/gen1_ind%d.bin',i);   
    dlmwrite(s,Antenna_design);
end


