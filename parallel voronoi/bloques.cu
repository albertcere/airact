#include <stdio.h>
#include <stdlib.h>
#include <time.h>


#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

typedef struct _seed
{
    unsigned char color[3];
    int x;
    int y;
} seed;

__global__ void voronoi_cuda(int count, seed* seeds, int width, int height, unsigned char* image)
{ 
    //Index 
    int x = (blockIdx.x*blockDim.x) + threadIdx.x;
    int y = (blockIdx.y*blockDim.y) + threadIdx.y;
    __shared__ seed shared_seeds[32];
    unsigned int distance;
    unsigned char tempColor[3];
    int xdistance, ydistance;
    int index = y*width*3+x*3; //Index on the MAT of RGBs
    unsigned int currentdistance = 0xFFFFFFFF;
    
    for(int i = 0; i < count; i+=32)
    {
        //Share 32 seeds with the block
        if(threadIdx.y == 0) shared_seeds[threadIdx.x] = seeds[i+threadIdx.x];

        __syncthreads();
    	#pragma unroll 32
    	for(int j = 0; j < 32; j++)
        {
    	    xdistance = shared_seeds[j].x -x;
    	    ydistance = shared_seeds[j].y -y;
    	    distance = (xdistance*xdistance)+(ydistance*ydistance);
            //If new distance < current distance, update colour
    	    if(distance < currentdistance)
            {
                currentdistance = distance;
                tempColor[0] = shared_seeds[j].color[0];
                tempColor[1] = shared_seeds[j].color[1];
                tempColor[2] = shared_seeds[j].color[2];
    	    }
            __syncthreads();
    	}
    }
    //Update global colour
    image[index] = tempColor[0];
    image[index+1] = tempColor[1];
    image[index+2] = tempColor[2];
}




static void Usage()
{
    printf("Usage: main [options]\n");
    printf("\t-n <num points>\n");
    printf("\t-i <inputfile>\t\tA list of 2-tuples (float, float) representing 2-d coordinates\n");
    printf("\t-o <outputfile.png>\n");
    printf("\t-w <width>\n");
    printf("\t-h <height>\n");
    printf("\t-p <pinned>\n");
}

int main(int argc, const char** argv) 
{
  //CUDA DECLARACIONES  
  unsigned int nBlocks, nThreads;
  
  //para calcular el tiempo en cuda
  float TiempoTotal, TiempoKernel;
  
  cudaEvent_t E0, E1, E2, E3;

  
    cudaEventCreate(&E0);
    cudaEventCreate(&E1);
    cudaEventCreate(&E2);
    cudaEventCreate(&E3);
  

    //Default values
    
    //Number of seeds
    int count = 64;
    
    // Image dimension
    int width = 512;
    int height = 512;
    int pinned = 1;
    
    //Files
    const char* inputfile = 0;
    const char* outputfile = "bloques.png";
    
    /*Change default values
        -i inputfyle
        -o outputfyle
        -n count
        -w width
        -h height
        -p pinned
    */  
    for( int i = 1; i < argc; ++i )
    {
        if(strcmp(argv[i], "-i") == 0)
        {
            if( i+1 < argc ) inputfile = argv[i+1];
            else
            {
                Usage();
                return 1;
            }
        }
        else if(strcmp(argv[i], "-o") == 0)
        {
            if( i+1 < argc ) outputfile = argv[i+1];
            else
            {
                Usage();
                return 1;
            }
        }
        else if(strcmp(argv[i], "-n") == 0)
        {
            if( i+1 < argc ) count = (int)atol(argv[i+1]);
            else
            {
                Usage();
                return 1;
            }
        }
        else if(strcmp(argv[i], "-w") == 0)
        {
            if( i+1 < argc ) width = (int)atol(argv[i+1]);
            else
            {
                Usage();
                return 1;
            }
        }
        else if(strcmp(argv[i], "-h") == 0)
        {
            if( i+1 < argc ) height = (int)atol(argv[i+1]);
            else
            {
                Usage();
                return 1;
            }
        }
        else if(strcmp(argv[i], "-p") == 0)
        {
            if( i+1 < argc ) pinned = (int)atol(argv[i+1]); // si es 1 es pinned, si es 0 no.
            else
            {
                Usage();
                return 1;
            }
        }
    }



    //Open file
    FILE* file = 0;
    if( inputfile )
    {
        if( strcmp(inputfile, "-") == 0 ) file = stdin;
        file = fopen(inputfile, "r");
        if( !file )
        {
            fprintf(stderr, "Failed to open %s for reading\n", inputfile);
            return 1;
        }
        if(fscanf(file, "%d", &count)) printf("Points = %d\n", count);
        else printf("Failed to read number of seeds\n");
    }

    printf("BLOQUES with %d seeds, %d pixels of width and %d pixels of height \n", count, width, height);

    seed* seeds;
    size_t seedssize = (size_t)(sizeof(seed) * (size_t)count);
    if(pinned) cudaMallocHost((seed**)&seeds, seedssize);
    else seeds = (seed*)malloc(seedssize);
  
    
    //Get points from file
    if(inputfile)
    {
        for (int i = 0; i < count; ++i) 
        {
            if(fscanf(file,"%d %d", &seeds[i].x, &seeds[i].y));
        }
    }
    //If no input file, generate points
    else
    {
        int pointoffset = 10; // move the points inwards, for aestetic reasons

        srand(0);

        for( int i = 0; i < count; ++i )
        {
            seeds[i].x = (float)(pointoffset + rand() % (width-2*pointoffset));
            seeds[i].y = (float)(pointoffset + rand() % (height-2*pointoffset));
        }
    }


    //Generate colors for each seed
    for(int i = 0; i < count; ++i)
    {
        unsigned char basecolor = 120;
        seeds[i].color[0] = basecolor + (unsigned char)(rand() % (235 - basecolor));
        seeds[i].color[1] = basecolor + (unsigned char)(rand() % (235 - basecolor));
        seeds[i].color[2] = basecolor + (unsigned char)(rand() % (235 - basecolor));
    }



    //Initialize image
    
    size_t imagesize = (size_t)(width*height*3); //3 is for the RGB color of each pixel
    unsigned char* image;
    if(pinned) cudaMallocHost((unsigned char**)&image,imagesize);
    else image = (unsigned char*)malloc(imagesize);
    memset(image, 0, imagesize);

    cudaEventRecord(E0, 0);
    cudaEventSynchronize(E0);
    
    seed* device_seeds;
    cudaMalloc((seed**)&device_seeds, seedssize); 

    unsigned char* device_image;
    cudaMalloc((char**)&device_image, imagesize); 
  
    cudaMemcpy(device_seeds, seeds, seedssize, cudaMemcpyHostToDevice); //Necesario?
    cudaMemcpy(device_image, image, imagesize, cudaMemcpyHostToDevice);


    nThreads = 32; 
    nBlocks = width/nThreads; 

    dim3 dimGrid(nBlocks, nBlocks, 1);
    dim3 dimBlock(nThreads, nThreads, 1); 


    cudaEventRecord(E1, 0);
    cudaEventSynchronize(E1);

    //Fill the image
    voronoi_cuda<<<dimGrid, dimBlock>>>(count, device_seeds, width, height, device_image);

    cudaEventRecord(E2, 0);
    cudaEventSynchronize(E2);

    cudaMemcpy(image, device_image, imagesize, cudaMemcpyDeviceToHost); 

    cudaFree(device_seeds);
    cudaFree(device_image);
    
    cudaEventRecord(E3, 0);
    cudaEventSynchronize(E3);
    
    cudaEventElapsedTime(&TiempoTotal,  E0, E3);
    cudaEventElapsedTime(&TiempoKernel, E1, E2);
    
    printf("Tiempo Global: %4.6f milseg\n", TiempoTotal);
    printf("Tiempo Kernel: %4.6f milseg\n", TiempoKernel);
    cudaEventDestroy(E0); cudaEventDestroy(E1); cudaEventDestroy(E2); cudaEventDestroy(E3);

    //Paint the seeds
    unsigned char color_seed[] = {255, 255, 255};
    int index;
    for(int i = 0; i < count; i++)
    {
        index = seeds[i].y*width*3+seeds[i].x*3;
        image[index] = color_seed[0];
        image[index+1] = color_seed[1];
        image[index+2] = color_seed[2];
    }


    //Transform tu png
    char path[512];
    sprintf(path, "%s", outputfile);
    stbi_write_png(path, width, height, 3, image, width*3);
    printf("Wrote image in %s\n", path);

    if (pinned) {
        cudaFreeHost(image); cudaFreeHost(seeds);
    }
    else {
        free(image); free(seeds);
    }
        
}
