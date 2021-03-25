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

function GA(Generation)

name_conv=1;

%Open fitness file
fitness_file = sprintf('Fit/fitness%d.txt',Generation);
ID=fopen(fitness_file,'r');
fit=fscanf(ID,'%f');
Gen_size = length(fit);

%Mutation likelihood should increase when fitness score converges
%First generation should have very low mutation rate.
ID_gen1 = fopen('Fit/fitness1.txt','r');
fit1 = fscanf(ID_gen1,'%f');
spread1 = range(fit1);
%mutation probability of gen1 0.1%
likelihood_multiplier = 0.999./spread1;

%Find range of fitness for this generation
spread = range(fit);
mutation_likelihood = spread*likelihood_multiplier;

%Prioritise by fitness score
[~,Indx]= sort(fit,'descend');
top = round(Gen_size*0.1); %Top 10%
for i=1:top
    %From
    top_name=sprintf('Gen%d/gen%d_ind%d.bin',Generation,Generation,Indx(i));
    from_contents = load(top_name,'-ascii');
    
    %To
    fileID=sprintf('Gen%d/gen%d_ind%d.bin',Generation+1,Generation+1,name_conv);
    dlmwrite(fileID,from_contents);
    name_conv=name_conv+1; %use for next naming convention
end

%Combination and mutation to top 50%
keep= floor(Gen_size*0.5); %round down
while name_conv <Gen_size-4
    
    %Combination
    x=randi(keep); y=randi(keep); %2 parents %make it more prob to choose better pp
    x_name   = sprintf('Gen%d/gen%d_ind%d.bin',Generation,Generation,Indx(x));
    x_genome=load(x_name,'-ascii');
    y_name   = sprintf('Gen%d/gen%d_ind%d.bin',Generation,Generation,Indx(y));
    y_genome=load(y_name,'-ascii');

    To_fileID = sprintf('Gen%d/gen%d_ind%d.bin',Generation+1,Generation+1,(name_conv));
    crossover(To_fileID,x_genome,y_genome);
    name_conv = name_conv+1;
    
    %Mutation
    replace = rand(1);
    if replace>mutation_likelihood
        To_fileID = sprintf('Gen%d/gen%d_ind%d.bin',Generation+1,Generation+1,(name_conv));
        From=sprintf('Gen%d/gen%d_ind%d.bin',Generation,Generation,randi(keep)); 
        mutation(To_fileID,From);
        name_conv = name_conv+1;
    end    
      
end 

%Last 5 spaces of new generation filled by combining pairs that have any
%fitness score
while name_conv<Gen_size+1
    x=randi(Gen_size); y=randi(Gen_size);
    x_name   = sprintf('Gen%d/gen%d_ind%d.bin',Generation,Generation,Indx(x));
    x_genome=load(x_name,'-ascii');
    y_name   = sprintf('Gen%d/gen%d_ind%d.bin',Generation,Generation,Indx(y));
    y_genome=load(y_name,'-ascii');
    To_fileID = sprintf('Gen%d/gen%d_ind%d.bin',Generation+1,Generation+1,(name_conv));
    crossover(To_fileID,x_genome,y_genome);        
    name_conv = name_conv+1;
end    
end
