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

function Fitness_Test(generation,generation_size,ind_carried_forward)

close all

%Default inputs
if nargin <3
    ind_carried_forward = 0;
end    
if nargin <2
    generation_size = 60;
end    

%Error
if nargin <1
    fprintf('No generation selected')
    return
end    
    
%File to write
fname = sprintf('Fit/fitness%d.txt',generation);
fitfid = fopen(fname,'w+');

if generation == 1
    start_point =1;
else
    start_point = ind_carried_forward+1;
    prev_fname   = sprintf('Fit/fitness%d.txt',generation-1);
    prev         = load(prev_fname);
    score= sort(prev,'descend');
    best_of_prev     = score(1:6);
    for k =1:6
        fprintf(fitfid,'%d\n',best_of_prev(k));
    end
end

%Iterate through each individual in a generation
for i=start_point:generation_size
    
    %File to read
    DataFile = sprintf('Gen%d/DataFiles/luc_data_ex%d.dat',generation,i);
    datafid=fopen(DataFile);

    cell_size = 5; %in um

    %Read data file. Read unused data as well, as fread reads next
    %characters in order.
    ht = fread(datafid, 128, 'uint8=>char');
    sx = fread(datafid, 1,'int16=>int32');
    sy = fread(datafid, 1,'int16=>int32');
    sz = fread(datafid, 1,'int16=>int32');
    maxt = fread(datafid, 1,'int16=>int32');
    cn = fread(datafid, 1, 'float');
    nslices = fread(datafid, 1,'int16=>int32');
    for j=1:nslices
        field = fread(datafid, 2, 'uint8=>char');
        ax = fread(datafid, 1, 'uint8=>char');
        pos = fread(datafid, 1,'int16=>int32');
    end

    %Simulation Details
    c0=3e8;
    dt = double(cn)*cell_size*1e-6/c0;
    Fs = 1/ dt; L = double(maxt); f = Fs*(0:(L/2))/L;

    %Allocate Matrix
    Electric_Field = zeros(L,1);
    %Get Electric Field data through feed
    for j=1:maxt
        s = fread(datafid, sx*sy, '*float');
        s = reshape(s,[sy sx]);
        Electric_Field(j,1) = s(250,100);
    end

    %Input pulse
    pulse= zeros(L-1,1);
    for k=1:L
        pulse(k,1) = -(k-500)*exp(-((k-500)*dt/0.125e-12)^2);
    end

    %No need to convert to voltage, as is scalar multiplication and will
    %not change relative fitness score.
    two_sided_output = abs(fft(Electric_Field).^2);
    one_sided_output = two_sided_output(1:length(f));
    two_sided_input  = abs(fft(pulse).^2);
    one_sided_input  = two_sided_input(1:length(f));
    norm_spec = one_sided_output ./ one_sided_input;

    %Chose frequency range to analyse
    %For 30ps run time: 100 GHz to 5 THz == 24 to 33 data points
    %Look into output frequency file to decide this.
    fit = sum(norm_spec(24:33,1));
    dB = 10*log10(fit);
    fprintf(fitfid,'%d\n',dB);
end


