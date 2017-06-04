#include <stdio.h>
#include <stdlib.h>
#ifdef __cplusplus
extern "C" {
#endif
 char output_str[256];
 int histFilter(unsigned char *pixels, int size);
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
  img = loadImage(argv[1]);
  histFilter(img.pixels,img.size);
  saveImage("result.bmp", img);
  printf("Image dimensions: %d width %d height\n", img.width, img.height);
  deleteImage(img);
  return 0;
}
