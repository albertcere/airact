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

static void voronoi(int count, const seed* seeds, int width, int height, unsigned char* image)
{

    unsigned int currentdistance, distance;
    int xdistance, ydistance;
    int index;
    unsigned char tempColor[3];


    for(int y = 0; y < height; ++y)
    {
        for(int x = 0; x < width; x++)
        {
            //For each pixel
            currentdistance = 0xFFFFFFFF;
            index = y*width*3+x*3; //Index on the MAT of RGBs
            for(int i = 0; i < count; i++)
            {
                //For each seed
                xdistance = seeds[i].x - x;
                ydistance = seeds[i].y - y;
                distance = xdistance*xdistance + ydistance*ydistance;
                //If new distance < current distance, update colour
                if(distance < currentdistance)
                {
                    currentdistance = distance;
                    tempColor[0] = seeds[i].color[0];
                    tempColor[1] = seeds[i].color[1];
                    tempColor[2] = seeds[i].color[2];
                }
            }
            //Update global colour
            image[index] = tempColor[0];
            image[index+1] = tempColor[1];
            image[index+2] = tempColor[2];
        }
    }
}

static void Usage()
{
    printf("Usage: main [options]\n");
    printf("\t-n <num points>\n");
    printf("\t-i <inputfile>\t\tA list of 2-tuples (float, float) representing 2-d coordinates\n");
    printf("\t-o <outputfile.png>\n");
    printf("\t-w <width>\n");
    printf("\t-h <height>\n");
}

int main(int argc, const char** argv) 
{
    
    //Time vars
    clock_t beginfull, endfull, beginalg, endalg;
    double timefull, timealg;

    beginfull = clock();

    //Default values
    
    //Number of seeds
    int count = 64;
    
    // Image dimension
    int width = 512;
    int height = 512;
    
    //Files
    const char* inputfile = 0;
    const char* outputfile = "seq.png";
    

    /*Change default values
        -i inputfyle
        -o outputfyle
        -n count
        -w width
        -h height
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

    printf("SEQ with %d seeds, %d pixels of width and %d pixels of height \n", count, width, height);

    size_t seedssize = (size_t)(sizeof(seed) * (size_t)count);
    seed* seeds = (seed*)malloc(seedssize);

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
    unsigned char* image = (unsigned char*)malloc(imagesize);
    memset(image, 0, imagesize);


    beginalg = clock();

    //Fill the image
    voronoi(count, (const seed*) seeds, width, height, image);


    endalg = clock();
    timealg = (double)(endalg - beginalg) / CLOCKS_PER_SEC;
    printf("Voronoi time spent = %lf \n", timealg);


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

    free(seeds);


    //Transform tu png
    char path[512];
    sprintf(path, "%s", outputfile);
    stbi_write_png(path, width, height, 3, image, width*3);

    free(image);


    endfull = clock();
    timefull = (double)(endfull - beginfull) / CLOCKS_PER_SEC;
    printf("Total time spent = %lf \n", timefull);
    printf("Wrote image in %s\n", path);
}
