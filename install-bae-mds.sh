# this is the recipe for installing the MDS software of Seung Hee Bee 
# (http://homes.cs.washington.edu/~shbae/software.html) on BioLinux (Ubuntu)
#
# HP-MDS: parallel MDS
# DA-MDS: Deterministic Annealing MDS
# MI-MDS: Majorization Interpolation MDS

# with help from http://blog.biophysengr.net/2011/11/compiling-mpinet-under-ubuntu-oneiric.html

INSTALLDIR=~/baemds

# install Mono development tools
# http://www.mono-project.com/docs/getting-started/install/linux/

sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF
echo "deb http://download.mono-project.com/repo/debian wheezy main" | sudo tee /etc/apt/sources.list.d/mono-xamarin.list
sudo apt-get update

sudo apt-get install mono-complete


# compile MPI.NET
# https://github.com/jmp75/MPI.NET

sudo apt-get install libopenmpi-dev openmpi-bin openmpi-doc
sudo apt-get install libtool automake autoconf autogen build-essential

mkdir $INSTALLDIR
cd $INSTALLDIR
git clone https://github.com/jmp75/MPI.NET.git mpi.net
cd mpi.net

# for some reason the default config file looks for ilasm2 which doesn't exist
# and gmcs which has been superceded by mcs

sed -i 's/ilasm2/ilasm/;s/gmcs/mcs/;' configure configure.ac

LOCAL_DIR=/usr/local
sh autogen.sh
./configure --prefix=$LOCAL_DIR
make

sudo make install

sudo ldconfig 

# compile MI-MDS

cd $INSTALLDIR
mkdir mimds
cd mimds

wget http://salsahpc.indiana.edu/smds/src/mimds.zip
unzip mimds.zip

cp $INSTALLDIR/mpi.net/MPI/MPI.dll ./
cp $INSTALLDIR/mpi.net/MPI/MPI.dll.config ./
cp bin/Debug/Ccr.Core.dll ./

mcs /reference:MPI.dll /reference:Ccr.Core.dll Program.cs FileIO.cs

#[USAGE]: >mpiexec -n [#Proc] hybrid_MIMDS.exe [sampleMappingFile] [sampleDataFile] [outOfSampleDataFile] [labelFile("NoLabelFile")] [outputFile] [threshold] [origDim] [targetDim] [#NN] [numSample] [#thread] [ignore1?] [ignore2?] [stress?]


# compile DA-MDS

cd $INSTALLDIR
mkdir damds
cd damds

wget http://salsahpc.indiana.edu/smds/src/mpi_dasmacof.zip
unzip mpi_dasmacof.zip

cp $INSTALLDIR/mpi.net/MPI/MPI.dll ./
cp $INSTALLDIR/mpi.net/MPI/MPI.dll.config ./

mcs /reference:MPI.dll Program.cs FileIO.cs BlockMatMult.cs SpecialFunction.cs

mv Program.exe damds

#[USAGE]: >mpiexec -n [pNum] MPI_DA_SMACOF_bMat.exe [distMatFile] [mappedFile("NoMappedFile")] [labelFile("NoLabelFile")]  [outputFile] [threshold] [finalThresh] [targetDim] [#Points=N] [nRow] [nCol] [blockSize] [alpha] [TminMul] [reduce-flag] [random-flag] [print-flag] [cooling-flag] [coolingStep]

# compile HP-MDS

cd $INSTALLDIR
mkdir hpmds
cd hpmds

wget http://salsahpc.indiana.edu/smds/src/mpi_smacof.zip
unzip mpi_smacof.zip

cp $INSTALLDIR/mpi.net/MPI/MPI.dll ./
cp $INSTALLDIR/mpi.net/MPI/MPI.dll.config ./

mcs /reference:MPI.dll Program.cs FileIO.cs BlockMatMult.cs SpecialFunction.cs
mv Program.exe hpmds

# [USAGE]: >mpiexec -n [pNum] MPI_SMACOF_bMat.exe [distMatFile] [initMappedFile("NoMappedFile")] [labelFile("NoLabelFile")] [outputFile] [threshold] [targetDim] [#Points=N] [nRow] [nCol] [blockSize] [reduce-flag] [random-flag]



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
   
