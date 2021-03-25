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

function[] = Produce_files(max_generation,generation_size,ind_carried_forward)

%Default Inputs
if nargin <3
    ind_carried_forward = 6;
end    
if nargin <2
    generation_size = 60;
end    
if nargin <1
    max_generation = 50;
end    
    
%Error
if ind_carried_forward > max_generation
    fprintf('Number of individuals carried forward larger than generation size')
    return
end

%Make directory for fitness files
mkdir('Fit')

for generation=1:max_generation
    
    %Set up folders
    FolderName = sprintf('Gen%d',generation);
    mkdir(FolderName);
    if generation ==1
        initial_generation(generation_size)
    end    
    cd(FolderName);
    copyfile ../luc_source_ex1.py
    
    
    %For the first generation, test all indiv.
    if generation ==1
        start_point = 1;
    %For subsequent generations, Some individuals are repeated from previous generations.    
    else
        start_point = ind_carried_forward+1;
    end    

    
    %% PRODUCE GEOMETRY
        
    for i=start_point:generation_size
        %%%ITERATE THROUGH OUTPUT FILE
        s = sprintf('geometry%d.py',i);
        fileID = fopen(s,'w');
        fprintf(fileID,'import numpy \nfrom PIL import Image\n\n');

        %Mat Builder
        %Initialise
        fprintf(fileID,'class mat_builder:\n\tdef __init__(self, np_array):\n\t\t');
        fprintf(fileID,'self.m = np_array\n\t\tself.sx = self.m.shape[0]\n\t\t');
        fprintf(fileID,'self.sy = self.m.shape[1]\n\t\tself.sz = self.m.shape[2]\n\t\t');
        fprintf(fileID,'self.m[0:(self.sx-1),0:(self.sy-1),0:(self.sz-1)] = 0\n\n');
        %Box
        fprintf(fileID,'\tdef box(self,(xmin,ymin,zmin),(xmax,ymax,zmax),midx):\n\t\t');
        fprintf(fileID,'self.m[xmin:xmax,ymin:ymax,zmin:zmax] = midx\n\n');
        %Mat2plane
        fprintf(fileID,'\tdef mat2plane(self,fileName,p,t,i_indent,j_indent,midx):\n\t\t');
        fprintf(fileID,'mat = numpy.genfromtxt(fileName,delimiter=",")\n\t\t');
        fprintf(fileID,'mat = numpy.reshape(mat,(100,100))\n\t\t');
        fprintf(fileID,'for i in xrange(100):\n\t\t\tfor j in xrange(100):\n\t\t\t\t');
        fprintf(fileID,'if (mat[i,j] == 1):\n\t\t\t\t\tself.m[i+i_indent,j+j_indent,p:(p+t)]=midx\n\n');

        %Build Geometry
        fprintf(fileID,'def build_geometry(m_buf,Cexe_buf,Cexh_buf,Ceye_buf,');
        fprintf(fileID,'Ceyh_buf,Ceze_buf,Cezh_buf,simp):\n');
        fprintf(fileID,'\tETA0 = simp[''ETA0'']\n\tcourant = simp[''courant'']\n\n');	

        %Domain dimensions
        fprintf(fileID,'\tdt_mat = numpy.dtype(numpy.int16)\n\tdt_mat = dt_mat.newbyteorder(''<'')\n\t');
        fprintf(fileID,'mat = numpy.frombuffer(m_buf,dtype=dt_mat)\n\tmat = mat.reshape((500,500,100))\n\n\t');
        fprintf(fileID,'dt_C = numpy.dtype(numpy.float32)\n\tdt_C = dt_C.newbyteorder(''<'')\n\t');
        fprintf(fileID,'Cexe = numpy.frombuffer(Cexe_buf,dtype=dt_C)\n\t');
        fprintf(fileID,'Cexh = numpy.frombuffer(Cexh_buf,dtype=dt_C)\n\t');
        fprintf(fileID,'Ceye = numpy.frombuffer(Ceye_buf,dtype=dt_C)\n\t');
        fprintf(fileID,'Ceyh = numpy.frombuffer(Ceyh_buf,dtype=dt_C)\n\t');
        fprintf(fileID,'Ceze = numpy.frombuffer(Ceze_buf,dtype=dt_C)\n\t');
        fprintf(fileID,'Cezh = numpy.frombuffer(Cezh_buf,dtype=dt_C)\n\n\t');

        %Material Dictionary	
        fprintf(fileID,'mat_dict = {\n\t\t0:(''vacuum'',1),\n\t\t1:(''silicon'',11.70),');	
        fprintf(fileID,'\n\t\t2:(''metal'',-1000000),\n\t\t3:(''SU8'',3.4225)\n\t}\n\n\t');

        fprintf(fileID,'for mat_idx, v in mat_dict.iteritems():\n\t\t');	
        fprintf(fileID,'print "{} is {}".format(v[0], mat_idx)\n\t\t');
        fprintf(fileID,'Cexe[mat_idx] = 1\n\t\tCexh[mat_idx] = (courant*ETA0)/v[1]\n\t\t');
        fprintf(fileID,'Ceye[mat_idx] = 1\n\t\tCeyh[mat_idx] = (courant*ETA0)/v[1]\n\t\t');
        fprintf(fileID,'Ceze[mat_idx] = 1\n\t\tCezh[mat_idx] = (courant*ETA0)/v[1]\n\n\t');

        %Build
        fprintf(fileID,'mbuild = mat_builder(mat)\n\n\t');
        fprintf(fileID,'mbuild.box((0,0,25),(500,500,31),3)\n\t');
        fprintf(fileID,'mbuild.box((0,0,24),(500,500,25),2)\n\t');
        fprintf(fileID,'mbuild.box((0,249,31),(200,252,32),2)\n\t');

        %%%ITERATE THROUGH INPUT FILE
        fprintf(fileID,'mbuild.mat2plane(''gen%d_ind%d.bin'',31,2,200,200,2)',generation,i);
        fprintf(fileID, '\n\n\treturn 1');
        fclose(fileID);
    end    

        %% PRODUCE CONFIGURATION
    
    for i=start_point:generation_size
        %%%ITERATE THROUGH OUTPUT FILE
        s = sprintf('config%d.py',i);
        fileID = fopen(s,'w');

        fprintf(fileID,'def get_pars():\n\n\tpars = {\n\n\t\t');
        %Simulation Domain
        fprintf(fileID,'''size_x'': 500,\n\t\t''size_y'': 500,\n\t\t''size_z'': 100,\n\n\t\t');
        %Edge dimension. Sim time
        fprintf(fileID,'''cell_size'': 5e-6,\n\t\t''sim_time'': 30e-12,\n\t\t');
        %Courant no, boundaries
        fprintf(fileID,'''courant'': 0.5,\n\n\t\t''front''  : ''pbc'',\n\t\t''back''   : ''pbc'',\n\t\t');
        fprintf(fileID,'''left''   : ''pbc'',\n\t\t''right''  : ''pbc'',\n\t\t');
        fprintf(fileID,'''top''    : ''abc'',\n\t\t''bottom'' : ''abc'',\n\n\t\t');

        %Iterate through geometry files
        fprintf(fileID,'''geom_file'': ''geometry%d'',\n\n\t\t',i);
        %Source files - stays constant
        fprintf(fileID,'''sources'': (''luc_source_ex1'', ),\n\n\t\t');

        %Fields
        fprintf(fileID,'''field_views'': (\n\t\t\t\t\t\t{''field'':''Ex'', ''type'':''xy'', ''pos'':(29,)},');
        %fprintf(fileID,'\n\t\t\t\t\t\t{''field'':''Ex'', ''type'':''xz'', ''pos'':(200,)},');
        fprintf(fileID,'\n\t\t\t\t\t\t),\n\n\t\t');

        %Data file - need to iterate through
        fprintf(fileID,'''data_file'': ''DataFiles/luc_data_ex%d.dat''',i);

        %%%ITERATE THROUGH INPUT FILE
        %fprintf(fileID,'mbuild.mat2plane(''lucifer/sims/nessexample/Gen1/gen1_ind%d.bin'',7,1,200,200,2)',i);
        fprintf(fileID,'\n\n\t}\n\treturn pars');
        fclose(fileID);
    end 
    %%  
    

    mkdir DataFiles;
    cd ../;
    close all
end    
