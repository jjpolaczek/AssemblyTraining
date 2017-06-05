#include <stdio.h>
#include <stdlib.h>
#ifdef __cplusplus
extern "C" {
#endif
 char output_str[256];
 int histFilter(unsigned char *pixels, int size, int *debug);
#ifdef __cplusplus
}
#endif

typedef struct Image
{
    unsigned char *pixels;
    unsigned char *header;
    int valid;
    int width;
    int height;
    int size;
    int offset;
}Image;
void hisCalc(Image img)
{
    int bufR[256], bufG[256],bufB[256];

    int pixels = (img.size - img.offset) / 3;
    for(int i = 0; i < 256; ++ i)
    {
        bufR[i] = 0;
        bufG[i] = 0;
        bufB[i] = 0;
    }
    int sanity = 0;
    for(int i = 0; i < pixels * 3; i+=3)
    {
        ++sanity;
        bufB[img.pixels[i]]++;
        bufG[img.pixels[i+1]]++;
        bufR[img.pixels[i+2]]++;
    }
    //Find nonzero//
    /*
    int rmin = 0, gmin = 0, bmin = 0;
    for(int i = 0; i < 256; ++ i)
    {
        if(rmin ==0)
            if(bufR[i] != 0)
                rmin = bufR[i];
        if(gmin ==0)
            if(bufG[i] != 0)
                rmin = bufG[i];
        if(bmin ==0)
            if(bufB[i] != 0)
                rmin = bufB[i];
    }*/
    int cR =0, cG =0, cB = 0;
    bufB[0] = 0;
    bufG[0] = 0;
    bufR[0] = 0;
    printf("SIZE %d %d\n", pixels, img.width * img.height);
    for(int i = 1; i < 256; ++ i)
    {
        cR += bufR[i];
        cG += bufG[i];
        cB += bufB[i];

        bufR[i] = ((cR * 255) / pixels);
        bufG[i] = ((cG * 255) / pixels);
        bufB[i] = ((cB * 255) / pixels);
    }
    printf("This is buffer for bananas %d\n",cR);
    for(int i = 0; i < 256; ++ i)
    {
         printf("%d ", (int) bufB[i]);
    }
    printf("\nThis is buffer for oranges\n");
}

Image loadImage(const char *filename)
{
    Image img;
    int tmp;
    int fpos = 0;
    char buf[64];
    FILE *f = fopen(filename,"rb");
    img.valid = 0;

    if(f != NULL)
    {
        fread(buf,sizeof(unsigned char),2,f);
        fpos += 2;
        if(buf[0] == 'B' && buf[1] == 'M')
            img.valid = 1;
        else
        {
            fclose(f);
            return img;
        }
        fread(&img.size,sizeof(unsigned char),4,f);
        fread(buf,sizeof(unsigned char),4,f);//Skip
        fread(&img.offset,sizeof(unsigned char),4,f);
        fread(&tmp,sizeof(unsigned char),4,f);
        fpos += 16;
        printf("Loading image: %d\n", tmp);
        if(tmp == 40)//Windows bmp v1 header//
        {
            fread(&img.width,sizeof(unsigned char),4,f);
            fread(&img.height,sizeof(unsigned char),4,f);
            fpos += 8;
        }
        else if(tmp == 124) // BMP v5 header
        {
            fread(&img.width,sizeof(unsigned char),4,f);
            fread(&img.height,sizeof(unsigned char),4,f);
            fpos += 8;
        }
        //Move to pixel array pos//
        if(fpos != img.offset)
        {
            fseek (f , img.offset - fpos , SEEK_CUR);
        }
        img.pixels = malloc(3*(img.size - img.offset));
        img.header = malloc(img.offset);
        fread(img.pixels,sizeof(unsigned char),3 *(img.size - img.offset),f);
        rewind(f);
        fread(img.header,sizeof(unsigned char),img.offset,f);
    }
    fclose(f);
    return img;
}
void saveImage(char *filename, Image img)
{
    FILE *f = fopen(filename,"wb");
    if(f != NULL)
    {
        fwrite(img.header,sizeof(unsigned char),img.offset,f);
        fwrite(img.pixels,sizeof(unsigned char),3 *(img.size - img.offset),f);
    }
    fclose(f);
}
void deleteImage(Image img)
{
    free(img.pixels);
    free(img.header);
}

int main(int argc, char** argv)
{ 
  printf("Loading image: %s\n", argv[1]);
  Image img;
  unsigned char buf[256];
  int debug;
  img = loadImage(argv[1]);
  hisCalc(img);
  //histFilter(img.pixels,img.size, &debug);
  histFilter(img.pixels,img.size - img.offset, (int*) buf);
  //printf("%d ", debug);
  for(int i = 0; i < 256; ++i)
       printf("%d ", (int) buf[i]);
  saveImage("result.bmp", img);
  printf("Image dimensions: %d width %d height\n", img.width, img.height);
  deleteImage(img);
  return 0;
}
