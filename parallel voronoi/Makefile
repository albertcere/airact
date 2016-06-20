CUDA_HOME   = /Soft/cuda/7.5.18

NVCC        = $(CUDA_HOME)/bin/nvcc
NVCC_FLAGS  = -O3 -I$(CUDA_HOME)/include -arch=sm_20 --ptxas-options=-v -I$(CUDA_HOME)/sdk/CUDALibraries/common/inc
LD_FLAGS    = -lcudart -Xlinker -rpath,$(CUDA_HOME)/lib64 -I$(CUDA_HOME)/sdk/CUDALibraries/common/lib
SEQ              = seq.exe
BLOQUES	         = bloques.exe
OBJBLOQUES       = bloques.o
MULTIGPU_ROWS    = multigpu_rows.exe
OBJMULTIGPU_ROWS = multigpu_rows.o



bloques.o: bloques.cu
	$(NVCC) -c -o $@ bloques.cu $(NVCC_FLAGS)

$(BLOQUES): $(OBJBLOQUES)
	$(NVCC) $(OBJBLOQUES) -o $(BLOQUES) $(LD_FLAGS)

multigpu_rows.o: multigpu_rows.cu
	$(NVCC) -c -o $@ multigpu_rows.cu $(NVCC_FLAGS)

$(MULTIGPU_ROWS): $(OBJMULTIGPU_ROWS)
	$(NVCC) $(OBJMULTIGPU_ROWS) -o $(MULTIGPU_ROWS) $(LD_FLAGS)

$(SEQ): seq.c
	gcc -o $(SEQ) -g -O0 -m64 -std=c99 -Wall -Wno-float-equal -pedantic seq.c -lm

qsubseq:
	qsub -l execution job/job_seq.sh

qsubbloques:
	qsub -l cuda job/job_bloques.sh

qsubmultigpu_rows:
	qsub -l cuda job/job_multigpu_rows.sh

all:	$(SEQ) $(BLOQUES) $(MULTIGPU_ROWS) 

clean:
	rm -rf *.o seq.exe bloques.exe multigpu_rows.exe 

clean_out:
	rm -rf *.o* *.e*

clean_img:
	rm -rf *.png

