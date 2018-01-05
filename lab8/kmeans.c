/**************************************************************

	The program reads an RGB bitmap image file and uses the K-Means algorithm
	algorithm to compress the image by clustering all pixels
        Author: Nikos Bellas, ECE Department, University of Thessaly
**************************************************************/

#include "qdbmp.h"
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>


/* Creates a negative image of the input bitmap file */
int main( int argc, char* argv[] )
{
	BMP*	bmp;
	UINT*   cluster;   /* For each pixel position, it shows the cluster that this pixel belongs */
	UCHAR	r, g, b;
	UINT    width, height, row, col;
	UINT    i;
	UCHAR  *meansR, *meansG, *meansB;   /* Holds the (R, G, B) means of each cluster  */
	UINT    noClusters;   /* Number of of clusters. It is given by the user */
	UINT    dist, minDist, minCluster, iter, maxIterations;
	UINT    noOfMoves;     /* Total number of inter-cluster moves between two succesive iterations */
	UINT    totr, totb, totg, sizeCluster;
	UCHAR   bytes_per_pixel;
	UINT    bytes_per_row;
	UCHAR*  pixel;

	/* Check arguments */
	if ( argc != 4 )
	{ 
		fprintf( stderr, "Usage: %s <input file> <output files> <Number of Clusters>\n", argv[ 0 ] );
		return 1;
	}

	/* Read the input (uncompressed) image file */
	bmp = BMP_ReadFile( argv[ 1 ] );
	BMP_CHECK_ERROR( stdout, -1 ); 
    
    
	/* Get image's dimensions */
	width = BMP_GetWidth( bmp );
	height = BMP_GetHeight( bmp );
	bytes_per_pixel = bmp->Header.BitsPerPixel >> 3;
	bytes_per_row = bmp->Header.ImageDataSize / height;

	noClusters = ( UINT ) atoi(argv[3]);   
	meansR = (UCHAR*) malloc( noClusters * sizeof( UCHAR ) );
    meansG = (UCHAR*) malloc( noClusters * sizeof( UCHAR ) );
	meansB = (UCHAR*) malloc( noClusters * sizeof( UCHAR ) );
	
	/* 1. Initialize cluster means with (R, G, B) values from random coordinates of the Input Image*/
	srand (time(NULL));
    for (i = 0; i < noClusters; ++i) {

    	col = rand() % width;
        row = rand() % height;

        /* Get pixel's RGB values */
		BMP_GetPixelRGB( bmp, col, row, &(meansR[i]), &(meansG[i]), &(meansB[i]) );
    }
    
    /* The cluster assignement for each pixel */
	cluster = (UINT*) calloc( width*height, sizeof(UINT) );  /* Important to also initialize all entries to 0 */
	if ( cluster == NULL )
	{
        free( cluster );
		free( bmp );
		return 1;
	}


    maxIterations = 10;
    iter = 0;


    /* Main loop runs at least once */ 

    do {

    	noOfMoves = 0;
    	++iter; 
    	printf("ITER %ld\n", iter);

        totr = totb = totg = 0;
	   /* 2. Go through each pixel in the input image and calculate its nearest mean. 
	         The output of phase 2 is the cluster* data structure.                    */


	  for (row = 0 ; row < height ; ++row) {
		for (col = 0 ; col < width ; ++col)  {

		
			/* Calculate the location of the relevant pixel (rows are flipped) */
		    pixel = bmp->Data + ( ( bmp->Header.Height - row - 1 ) * bytes_per_row + col  * bytes_per_pixel );
          
            /* Get pixel's RGB values */
			BMP_GetPixelRGB( bmp, col, row, &r, &g, &b );
			
            minDist = 10000; /* Larger than the lagest possible value */
			for (i = 0; i < noClusters; ++i) {
                /* Distance metric. May replace with something cheaper */
				dist = (UINT) (r-meansR[i])*(r-meansR[i]) + (g-meansG[i])*(g-meansG[i]) + (b-meansB[i])*(b-meansB[i]);
                if (dist < minDist * minDist) {
                	  minDist = (UINT) sqrt(dist);
                	  minCluster = i;

                }
			}
            
            if (*(cluster+row*width + col) != minCluster) {

            	 *(cluster+row*width + col) = minCluster;
            	 ++noOfMoves;
            }

		}   /* for */
	   }  /* for */


     /* 3. Update the mean of each cluster based on the pixels assigned to them. */
      if (noOfMoves > 0) {
      	  for (i = 0; i < noClusters; ++i) {

            totr = totb = totg = 0;
            sizeCluster = 0;

			for (row = 0 ; row < height ; ++row) {
				for (col = 0 ; col < width ; ++col)  {
					if (*(cluster+row*width + col) == i) {
		                 BMP_GetPixelRGB( bmp, col, row, &r, &g, &b );
	       	             totr += r; 
	       	             totg += g;
	       	             totb += b;
                         sizeCluster++;

                    }

		       }
		   }

		   meansR[i] = (UCHAR) (totr/sizeCluster);
		   meansG[i] = (UCHAR) (totg/sizeCluster);
		   meansB[i] = (UCHAR) (totb/sizeCluster);
		   
		  }
              
      }

       /* 4. Goto 2 if not convergence and less than a max number of iterations. Else goto 5 */
    } while ((iter < maxIterations) && (noOfMoves > 0));



    for (i = 0; i < noClusters; ++i) {
       printf("means[%ld] = (%d, %d, %d)\n", i, (int)meansR[i], (int)meansG[i], (int)meansB[i]);
    }
    

    /* 5. Replace the pixel of the original image with the mean of the corresponding cluster */


	  for (row = 0 ; row < height ; ++row) {
		for (col = 0 ; col < width ; ++col)  {
            
            i = *(cluster+row*width + col);
		   /* Note: colors are stored in BGR order */
	
           BMP_SetPixelRGB( bmp, col, row, meansR[i], meansG[i], meansB[i] );

        }

    }


   /* Write out the output image and finish */
	BMP_WriteFile( bmp, argv[ 2 ] );
	BMP_CHECK_ERROR( stdout, -2 );


	/* Free all memory allocated for the image */
	BMP_Free( bmp );
	free(meansG);
	free(meansR);
	free(meansB);


	return 0;
}

 
