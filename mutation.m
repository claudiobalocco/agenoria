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

function mutation(To_fileID,From)
from_contents = load(From,'-ascii');

%Allocate condensed genome for child 
input = zeros(20,20);

for idx = 1:20
    for idx2 = 1:20
        element = from_contents(idx2*5-4,idx*5-4);
        dec= rand(1); %Decides whether to flip bit
        if dec>=0.95 && element==1 %If larger than 0.95.
            input(idx2,idx) =0;
        elseif dec>=0.95 && element==0
            input(idx2,idx) =1;
        elseif dec<0.95
            input(idx2,idx) = element;
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