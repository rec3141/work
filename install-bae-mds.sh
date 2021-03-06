# This is a recipe for installing the Scalable MDS software of Seung Hee Bee, Judy Qiu, and Geoffrey Fox on BioLinux (Ubuntu)
# I tried but failed to get it working under MacOSX
# http://homes.cs.washington.edu/~shbae/software.html
# http://salsahpc.indiana.edu/smds/
#
# HP-MDS: parallel MDS
# DA-MDS: Deterministic Annealing MDS (incorporate HP-MDS)
# MI-MDS: Majorization Interpolation MDS (incorporates both of)

# with help from http://blog.biophysengr.net/2011/11/compiling-mpinet-under-ubuntu-oneiric.html

INSTALLDIR=~/baemds

# install Mono development tools
# http://www.mono-project.com/docs/getting-started/install/linux/


sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
#for latest version
#echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list

#for mono 3 -- it worked for me using this, not sure if necessary
echo "deb http://download.mono-project.com/repo/debian wheezy/snapshots/3.12.0 main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list

sudo apt-get update

#do NOT install mono-gmcs

sudo apt-get install mono-complete

# compile MPI.NET
# https://github.com/jmp75/MPI.NET

sudo apt-get install git

#COMPILES WITH OPENMPI
sudo apt-get install libopenmpi-dev openmpi-bin openmpi-doc

# DOESN'T COMPILE WITH ATERNATIVE LIBRARY MPICH2
# sudo apt-get install libcr-dev mpich2 mpich2-doc

sudo apt-get install libtool automake autoconf autogen build-essential

# This version from github incorporates the 3 patches that are floating around
# http://www.osl.iu.edu/MailArchives/mpi.net/2011/05/0157.php
# https://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/sys-cluster/mpi-dotnet/files/?hideattic=0

mkdir $INSTALLDIR
cd $INSTALLDIR
git clone https://github.com/jmp75/MPI.NET.git mpi.net
cd mpi.net

# for some reason the default config file looks for ilasm2 which doesn't exist
# and gmcs which has been superceded by mcs

sed -i 's/ilasm2/ilasm/;s/gmcs/mcs/;' configure configure.ac

#to avoid compile warning below
sed -i 's/public void Dispose/new public void Dispose/' MPI/Intercommunicator.cs
#./Intercommunicator.cs(116,21): warning CS0108: `MPI.Intercommunicator.Dispose()' hides inherited member `MPI.Communicator.Dispose()'. Use the new keyword if hiding was intended
#./Communicator.cs(222,21): (Location of the symbol related to previous warning)
#Compilation succeeded - 1 warning(s)

#I don't think this is necessary for OpenMPI but if you try to compile with other libraries you may need to fix this:
sed -i '#/usr/include/mpi.h/#/usr/include/mpi/mpi.h#' MPI/Unsafe.pl

LOCAL_DIR=/usr/local
sh autogen.sh
./configure --prefix=$LOCAL_DIR
make

sudo make install
# MPI.dll MPI.dll.config MPIUtils.dll installed into /usr/local/lib/

sudo ldconfig



### THERE ARE SOME BUGFIXES NEEDED TO COMPILE THESE AND RUN THEM
### CHECK FOR PATCHES AT github.com/rec3141/mds-mountain/damds/

# compile MI-MDS

cd $INSTALLDIR
mkdir mimds
cd mimds

wget http://salsahpc.indiana.edu/smds/src/mimds.zip
unzip mimds.zip

cp /usr/local/lib/MPI.dll ./
cp /usr/local/lib/MPI.dll.config ./
cp /usr/local/lib/MPIUtils.dll ./
cp ./bin/Debug/Ccr.Core.dll ./

mcs /reference:MPI.dll /reference:MPIUtils.dll /reference:Ccr.Core.dll Program.cs FileIO.cs 
mv Program.exe hybrid_MIMDS.exe

# TO USE THE GUI:
# need to change the location of the MPI.dll and MPIUtils.dll in the csproj
# need to cp MPI.dll.config into the dir of the type you are building {bin/Debug/,bin/Release/}
# make sure the build target framework is "Mono / .NET 4.0"

monodevelop hybrid_MIMDS.exe

#[USAGE]: >mpiexec -n [#Proc] hybrid_MIMDS.exe [sampleMappingFile] [sampleDataFile] [outOfSampleDataFile] [labelFile("NoLabelFile")] [outputFile] [threshold] [origDim] [targetDim] [#NN] [numSample] [#thread] [ignore1?] [ignore2?] [stress?]


# compile DA-MDS

cd $INSTALLDIR
mkdir damds
cd damds

wget http://salsahpc.indiana.edu/smds/src/mpi_dasmacof.zip
unzip mpi_dasmacof.zip

cp /usr/local/lib/MPI.dll ./
cp /usr/local/lib/MPI.dll.config ./
cp /usr/local/lib/MPIUtils.dll ./

mcs /reference:MPI.dll /reference:MPIUtils.dll Program.cs FileIO.cs BlockMatMult.cs SpecialFunction.cs
mv Program.exe MPI_DA_SMACOF_bMat.exe

# TO USE THE GUI:
# need to change the location of the MPI.dll and MPIUtils.dll in the csproj
# need to cp MPI.dll.config into the dir of the type you are building {bin/Debug/,bin/Release/}
# make sure the build target framework is "Mono / .NET 4.0"

monodevelop MPI_DA_SMACOF_bMat.exe

#[USAGE]: >mpiexec -n [pNum] MPI_DA_SMACOF_bMat.exe [distMatFile] [mappedFile("NoMappedFile")] [labelFile("NoLabelFile")]  [outputFile] [threshold] [finalThresh] [targetDim] [#Points=N] [nRow] [nCol] [blockSize] [alpha] [TminMul] [reduce-flag] [random-flag] [print-flag] [cooling-flag] [coolingStep]

# compile HP-MDS

cd $INSTALLDIR
mkdir hpmds
cd hpmds

wget http://salsahpc.indiana.edu/smds/src/mpi_smacof.zip
unzip mpi_smacof.zip

cp /usr/local/lib/MPI.dll ./
cp /usr/local/lib/MPI.dll.config ./
cp /usr/local/lib/MPIUtils.dll ./

mcs /reference:MPI.dll Program.cs FileIO.cs BlockMatMult.cs SpecialFunction.cs
mv Program.exe MPI_SMACOF_bMat.exe

# TO USE THE GUI:
# need to change the location of the MPI.dll and MPIUtils.dll in the csproj
# need to cp MPI.dll.config into the dir of the type you are building {bin/Debug/,bin/Release/}
# make sure the build target framework is "Mono / .NET 4.0"

monodevelop MPI_SMACOF_bMat.exe

# [USAGE]: >mpiexec -n [pNum] MPI_SMACOF_bMat.exe [distMatFile] [initMappedFile("NoMappedFile")] [labelFile("NoLabelFile")] [outputFile] [threshold] [targetDim] [#Points=N] [nRow] [nCol] [blockSize] [reduce-flag] [random-flag]


exit 0

############### detailed usage info
# MI-MDS

arguments: 
   args[0]: sampleMappingFile - prior MDS mappings of the in-sample data.
   args[1]: sampleDataFile - in-sample data.
   args[2]: outOfSampleDataFile - out-of-sample data to each process.
   args[3]: labelFile - label file (or "NoLabelFile")
   args[4]: outputFile - output file name.
   args[5]: threshold - threshold value for the stop condition.
   args[6]: origDim - the original dimension number
   args[7]: targetDim - the target dimension number 
   args[8]: #NN - the number of nearest neighbors for interpolation.
   args[9]: numSample - the number of points of in-sample data.
   args[10]: numThread - the number of threads in each process.
   args[11]: ignore1? - 1: ignore first line of sampleData, 0: otherwise
   args[12]: ignore2? - 1: ignore first line of outSampleData, 0: otherwise
   args[13]: stress? - 1: skip STRESS calculation, 0: not skip
   

# HP-MDS

arguments:
   args[0]: distMatrixFile - original distance matrix data.
   args[1]: initMappedFile - the initial mapping file (or 'NoMappedFile').
   args[2]: labelFile - label file (or 'NoLabelFile').
   args[3]: outputFile - output file name for the MDS result.
   args[4]: threshold - threshold value for the stop condition.
   args[5]: targetDim - target dimension.
   args[6]: N - the total number of points.
   args[7]: nRow - The number of block-rows.
   args[8]: nCol - The number of block-columns.
   args[9]: blockSize - the block size of block matrix multiplication.
   args[10]: reduce-flag - 1: reduced original distance, 0: no change
   args[11]: random-flag - 1: random seed, 0: fixed seed

# DA-MDS

arguments:
   args[0]: distMatrixFile - original distance matrix data.
   args[1]: mappedFile - initial mapping file (or 'NoMappedFile').
   args[2]: labelFile - label file (or 'NoLabelFile').
   args[3]: outputFile - output file name.
   args[4]: threshold -	threshold value for the stop condition.
   args[5]: finalThresh -	threshold value for SMACOF running with T == 0.
   args[6]: targetDim - target dimension.
   args[7]: N - the total number of points.
   args[8]: nRow - The number of block-rows.
   args[9]: nCol - The number of block-columns.
   args[10]: blockSize - the block size of block matrix multiplication.
   args[11]: alpha - temperature decrease ratio. between 0 and 1.
   args[12]: TminMul - The constant for deciding the Tmin w.r.t. the Tmax.
   args[13]: reduce-flag - 1: reduced original distance, 0: no change
   args[14]: random-flag - 1: random initialization, 0: fixed seed
   args[15]: print-flag - 1: print mapping for each T, 0: no print
   args[16]: coolingFlag - 1: linear, 0: exponential
   args[17]: coolingStep - the step number of the linear cooling scheme.
   
