#!/bin/bash
export PATH=/Soft/cuda/7.5.18/bin:$PATH

### Directivas para el gestor de colas
# Asegurar que el job se ejecuta en el directorio actual
#$ -cwd

# Asegurar que el job mantiene las variables de entorno del shell lamador
#$ -V

# Cambiar el nombre del job
#$ -N SEQ

# Cambiar el shell
#$ -S /bin/bash

#./seq.exe

./seq.exe -n 64 -w 128 -h 128 -o seq64-128.png
./seq.exe -n 64 -w 256 -h 256 -o seq64-256.png
./seq.exe -n 64 -w 512 -h 512 -o seq64-512.png
./seq.exe -n 64 -w 1024 -h 1024 -o seq64-1024.png
./seq.exe -n 64 -w 2048 -h 2048 -o seq64-2048.png
./seq.exe -n 64 -w 4096 -h 4096 -o seq64-4096.png
./seq.exe -n 64 -w 8192 -h 8192 -o seq64-8192.png

./seq.exe -n 64 -w 1024 -h 1024 -o seq64-1024.png
./seq.exe -n 128 -w 1024 -h 1024 -o seq128-1024.png
./seq.exe -n 256 -w 1024 -h 1024 -o seq256-1024.png
./seq.exe -n 512 -w 1024 -h 1024 -o seq512-1024.png
./seq.exe -n 1024 -w 1024 -h 1024 -o seq1024-1024.png
./seq.exe -n 2048 -w 1024 -h 1024 -o seq2048-1024.png
./seq.exe -n 4096 -w 1024 -h 1024 -o seq4096-1024.png
./seq.exe -n 8192 -w 1024 -h 1024 -o seq8192-1024.png