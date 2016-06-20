#!/bin/bash
export PATH=/Soft/cuda/7.5.18/bin:$PATH

### Directivas para el gestor de colas
# Asegurar que el job se ejecuta en el directorio actual
#$ -cwd

# Asegurar que el job mantiene las variables de entorno del shell lamador
#$ -V

# Cambiar el nombre del job
#$ -N MULTIGPU_ROWS

# Cambiar el shell
#$ -S /bin/bash




### N MULTIPLE OF 32 & H & W SHOULD BE MULTIPLE OF 64 ###

nvprof ./multigpu_rows.exe -n 64 -w 128 -h 128 -o multigpu_rows64-128.png
nvprof ./multigpu_rows.exe -n 64 -w 256 -h 256 -o multigpu_rows64-256.png
nvprof ./multigpu_rows.exe -n 64 -w 512 -h 512 -o multigpu_rows64-512.png
nvprof ./multigpu_rows.exe -n 64 -w 1024 -h 1024 -o multigpu_rows64-1024.png
nvprof ./multigpu_rows.exe -n 64 -w 2048 -h 2048 -o multigpu_rows64-2048.png
nvprof ./multigpu_rows.exe -n 64 -w 4096 -h 4096 -o multigpu_rows64-4096.png
nvprof ./multigpu_rows.exe -n 64 -w 8192 -h 8192 -o multigpu_rows64-8192.png

nvprof ./multigpu_rows.exe -n 64 -w 1024 -h 1024 -o multigpu_rows64-1024.png
nvprof ./multigpu_rows.exe -n 128 -w 1024 -h 1024 -o multigpu_rows128-1024.png
nvprof ./multigpu_rows.exe -n 256 -w 1024 -h 1024 -o multigpu_rows256-1024.png
nvprof ./multigpu_rows.exe -n 512 -w 1024 -h 1024 -o multigpu_rows512-1024.png
nvprof ./multigpu_rows.exe -n 1024 -w 1024 -h 1024 -o multigpu_rows1024-1024.png
nvprof ./multigpu_rows.exe -n 2048 -w 1024 -h 1024 -o multigpu_rows2048-1024.png
nvprof ./multigpu_rows.exe -n 4096 -w 1024 -h 1024 -o multigpu_rows4096-1024.png
nvprof ./multigpu_rows.exe -n 8192 -w 1024 -h 1024 -o multigpu_rows8192-1024.png




