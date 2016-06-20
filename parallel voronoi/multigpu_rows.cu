#include <stdio.h>
#include <stdlib.h>
#include <time.h>


//#include <resource.h> // hay qe poner el include

#define STB_IMAGE_WRITE_IMPLEMENTATION
#include "stb_image_write.h"

typedef struct _seed
{
    unsigned char color[3];
    int x;
    int y;
} seed;

__global__ void voronoi_cuda(int count, seed* seeds, int width, int height, unsigned char* image, int d)
{ 
    //Index
    int x = (blockIdx.x*blockDim.x) + threadIdx.x;
    int y = (blockIdx.y*blockDim.y) + threadIdx.y;

    //Global index
    int xglobal = x;
    int yglobal = y;
    if(d == 1) yglobal = y + height;
    if(d == 2) yglobal = y + 2*height;
    if(d == 3) yglobal = y + 3*height;

    __shared__ seed shared_seeds[32];
    unsigned int distance;
    unsigned char tempColor[3];
    int xdistance, ydistance;
    int index = y*width*3+x*3; //Index on the MAT of RGBs
    unsigned int currentdistance = 0xFFFFFFFF;
    
    for(int i = 0; i < count; i+=32)
    {
        //Share 32 seeds with the block
        if(threadIdx.y == 0) 
        {
            shared_seeds[threadIdx.x] = seeds[i+threadIdx.x];
        }
        __syncthreads();
    	#pragma unroll 32
    	for(int j = 0; j < 32; j++)
        {
            //Use global index
    	    xdistance = shared_seeds[j].x -xglobal;
    	    ydistance = shared_seeds[j].y -yglobal;
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
  unsigned int xnBlocks, ynBlocks, nThreads;
  
  //para calcular el tiempo en cuda
  float TiempoTotal, TiempoKernel;
  int cont_gpu;   //como maximo tenemos 4 devices por lo que es el maximo que podemos aprovechar
  cudaEvent_t E0, E1, E2, E3;
  cudaEvent_t X1, X2, X3;

  
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
    const char* outputfile = "multigpu_rows.png";
    
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
        if( strcmp(inputfile, "-") == 0 )
            file = stdin;
        file = fopen(inputfile, "r");
        if( !file )
        {
            fprintf(stderr, "Failed to open %s for reading\n", inputfile);
            return 1;
        }
        if(fscanf(file, "%d", &count)) 
        {
            printf("Points = %d\n", count);
        }
        else printf("Failed to read number of seeds\n");
    }

    printf("MULTIGPU_ROWS with %d seeds, %d pixels of width and %d pixels of height \n", count, width, height);


    seed* seeds;
    size_t seedssize = (size_t)(sizeof(seed) * count);
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
    size_t full_imagesize = (size_t)(width*height*3); //3 is for the RGB color of each pixel
    size_t imagesize = (size_t)(width*height*3)/4; //3 is for the RGB color of each pixel
    unsigned char* image;
    unsigned char* image0;
    unsigned char* image1;
    unsigned char* image2;
    unsigned char* image3;
    if(pinned) {
      cudaMallocHost((unsigned char**)&image,full_imagesize);
      cudaMallocHost((unsigned char**)&image0,imagesize);
      cudaMallocHost((unsigned char**)&image1,imagesize);
      cudaMallocHost((unsigned char**)&image2,imagesize);
      cudaMallocHost((unsigned char**)&image3,imagesize);
    }
    else {
      image = (unsigned char*)malloc(full_imagesize);
      image0 = (unsigned char*)malloc(imagesize);
      image1 = (unsigned char*)malloc(imagesize);
      image2 = (unsigned char*)malloc(imagesize);
      image3 = (unsigned char*)malloc(imagesize);
    }
    memset(image, 0, full_imagesize);
    memset(image0, 0, imagesize);
    memset(image1, 0, imagesize);
    memset(image2, 0, imagesize);
    memset(image3, 0, imagesize);

    cudaGetDeviceCount(&cont_gpu);
    if (count < 4) { printf("No hay suficientes GPUs\n"); exit(0); }
    
    seed* device_seeds0;
    seed* device_seeds1;
    seed* device_seeds2;
    seed* device_seeds3;
    
    unsigned char* device_image0;
    unsigned char* device_image1;
    unsigned char* device_image2;
    unsigned char* device_image3;

    cudaSetDevice(0);
    cudaMalloc((unsigned char**)&device_image0, imagesize); 
    cudaMalloc((seed**)&device_seeds0, seedssize); 

    
    cudaSetDevice(1);
    cudaMalloc((unsigned char**)&device_image1, imagesize); 
    cudaMalloc((seed**)&device_seeds1, seedssize); 
    cudaEventCreate(&X1); 
    
    cudaSetDevice(2);
    cudaMalloc((unsigned char**)&device_image2, imagesize); 
    cudaMalloc((seed**)&device_seeds2, seedssize); 
    cudaEventCreate(&X2); 
    
    cudaSetDevice(3);
    cudaMalloc((unsigned char**)&device_image3, imagesize); 
    cudaMalloc((seed**)&device_seeds3, seedssize);
    cudaEventCreate(&X3); 

    //lo de los tiempos lo hace el device0

    cudaSetDevice(0);
    cudaEventRecord(E0, 0);
   
    int height4 = height/4;
    nThreads = 32; 
    xnBlocks = width/nThreads;
    ynBlocks = height4/nThreads;

    dim3 dimGrid(xnBlocks, ynBlocks, 1);
    dim3 dimBlock(nThreads, nThreads, 1); 


    //Fill the image  
    //GPU 0                
    cudaSetDevice(0);

    cudaMemcpyAsync(device_seeds0, seeds, seedssize, cudaMemcpyHostToDevice); 
    cudaMemcpyAsync(device_image0, image0, imagesize, cudaMemcpyHostToDevice);

    cudaEventRecord(E1, 0);
    voronoi_cuda<<<dimGrid, dimBlock>>>(count, device_seeds0, width, height4, device_image0, 0);
    cudaEventRecord(E2, 0); cudaEventSynchronize(E2);

    cudaMemcpyAsync(image, device_image0, imagesize, cudaMemcpyDeviceToHost);

    //GPU 1
    cudaSetDevice(1);

    cudaMemcpyAsync(device_seeds1, seeds, seedssize, cudaMemcpyHostToDevice); 
    cudaMemcpyAsync(device_image1, image1, imagesize, cudaMemcpyHostToDevice);

    voronoi_cuda<<<dimGrid, dimBlock>>>(count, device_seeds1, width, height4, device_image1, 1);

    cudaMemcpyAsync(&image[imagesize], device_image1, imagesize, cudaMemcpyDeviceToHost); 
    cudaEventRecord(X1, 0);
    
    //GPU 2
    cudaSetDevice(2);

    cudaMemcpyAsync(device_seeds2, seeds, seedssize, cudaMemcpyHostToDevice); 
    cudaMemcpyAsync(device_image2, image2, imagesize, cudaMemcpyHostToDevice);

    voronoi_cuda<<<dimGrid, dimBlock>>>(count, device_seeds2, width, height4, device_image2, 2);

    cudaMemcpyAsync(&image[2*imagesize], device_image2, imagesize, cudaMemcpyDeviceToHost); 
    cudaEventRecord(X2, 0);


    //GPU 3
    cudaSetDevice(3);

    cudaMemcpyAsync(device_seeds3, seeds, seedssize, cudaMemcpyHostToDevice); 
    cudaMemcpyAsync(device_image3, image3, imagesize, cudaMemcpyHostToDevice);

    voronoi_cuda<<<dimGrid, dimBlock>>>(count, device_seeds3, width, height4, device_image3, 3);

    cudaMemcpyAsync(&image[3*imagesize], device_image3, imagesize, cudaMemcpyDeviceToHost); 
    cudaEventRecord(X3, 0);


    cudaSetDevice(0);
    cudaEventSynchronize(X1);
    cudaEventSynchronize(X2);
    cudaEventSynchronize(X3);
    
    cudaEventRecord(E3, 0);
    cudaEventSynchronize(E3);

    cudaSetDevice(0);
    cudaFree(device_seeds0);
    cudaFree(device_image0);
    cudaSetDevice(1);
    cudaFree(device_seeds1);
    cudaFree(device_image1);
    cudaSetDevice(2);
    cudaFree(device_seeds2);
    cudaFree(device_image2);
    cudaSetDevice(3);
    cudaFree(device_seeds3);
    cudaFree(device_image3);
        
    cudaEventElapsedTime(&TiempoTotal,  E0, E3);
    cudaEventElapsedTime(&TiempoKernel, E1, E2);
    
    printf("Tiempo Global: %4.6f milseg\n", TiempoTotal);
    printf("Tiempo Kernel: %4.6f milseg\n", TiempoKernel);
    cudaSetDevice(0); cudaEventDestroy(E0); cudaEventDestroy(E1); cudaEventDestroy(E2); cudaEventDestroy(E3);
    cudaSetDevice(1); cudaEventDestroy(X1);
    cudaSetDevice(2); cudaEventDestroy(X2);
    cudaSetDevice(3); cudaEventDestroy(X3);

    

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
        cudaFreeHost(image); cudaFreeHost(image0); cudaFreeHost(image1); cudaFreeHost(image2); cudaFreeHost(image3);
	    cudaFreeHost(seeds);
    }
    else {
        free(image); free(image0); free(image1); free(image2); free(image3);
	    free(seeds);
    }
        
}
