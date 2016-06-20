#!/bin/bash
export PATH=/Soft/cuda/7.5.18/bin:$PATH

### Directivas para el gestor de colas
# Asegurar que el job se ejecuta en el directorio actual
#$ -cwd

# Asegurar que el job mantiene las variables de entorno del shell lamador
#$ -V

# Cambiar el nombre del job
#$ -N BLOQUES

# Cambiar el shell
#$ -S /bin/bash




### N, H & W SHOULD BE MULTIPLE OF 32 ###

nvprof ./bloques.exe -n 64 -w 128 -h 128 -o bloques64-128.png
nvprof ./bloques.exe -n 64 -w 256 -h 256 -o bloques64-256.png
nvprof ./bloques.exe -n 64 -w 512 -h 512 -o bloques64-512.png
nvprof ./bloques.exe -n 64 -w 1024 -h 1024 -o bloques64-1024.png
nvprof ./bloques.exe -n 64 -w 2048 -h 2048 -o bloques64-2048.png
nvprof ./bloques.exe -n 64 -w 4096 -h 4096 -o bloques64-4096.png
nvprof ./bloques.exe -n 64 -w 8192 -h 8192 -o bloques64-8192.png

nvprof ./bloques.exe -n 64 -w 1024 -h 1024 -o bloques64-1024.png
nvprof ./bloques.exe -n 128 -w 1024 -h 1024 -o bloques128-1024.png
nvprof ./bloques.exe -n 256 -w 1024 -h 1024 -o bloques256-1024.png
nvprof ./bloques.exe -n 512 -w 1024 -h 1024 -o bloques512-1024.png
nvprof ./bloques.exe -n 1024 -w 1024 -h 1024 -o bloques1024-1024.png
nvprof ./bloques.exe -n 2048 -w 1024 -h 1024 -o bloques2048-1024.png
nvprof ./bloques.exe -n 4096 -w 1024 -h 1024 -o bloques4096-1024.png
nvprof ./bloques.exe -n 8192 -w 1024 -h 1024 -o bloques8192-1024.png