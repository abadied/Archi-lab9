#define _GNU_SOURCE
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <sys/types.h>
 #include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include "elf.h"
#include <sys/mman.h>

struct stat fd_stat;

int current_fd = -1;
int debug_mode = 0;
void* map_start = MAP_FAILED;

void examineElfFile(char* filename){
    if(current_fd != -1){
        close(current_fd);
        current_fd = -1;
    }
    if(((current_fd = open(filename, O_RDWR)) < 0)){
        perror("error in open \n");
        exit(-1);
    }
    if( fstat(current_fd, &fd_stat) != 0){
        perror("stat failed \n");
        exit(-1);
    }
    if (map_start != MAP_FAILED){
        munmap(map_start, fd_stat.st_size);
    }
    if ( (map_start = mmap(0, fd_stat.st_size, PROT_READ | PROT_WRITE, MAP_SHARED, current_fd, 0)) == MAP_FAILED ) {
        perror("mmap failed \n");
        exit(-4);
    }
}

void printProgramHeaders(){
    if (map_start == MAP_FAILED) {
        printf("no file opened\n");
        return;
    }
    Elf32_Ehdr *elfheader;
    elfheader = (Elf32_Ehdr*)map_start;
    
    int ph_off = elfheader->e_phoff;
    short phnum = elfheader->e_phnum;
    short phent_size = elfheader->e_phentsize;
    
    void* map_pheaders = (void*)((char*)map_start + ph_off);
    
    Elf32_Phdr *pheader;
    int i;
    for (i = 0; i < phnum; i++) {
        pheader = (Elf32_Phdr*)((char*)map_pheaders + phent_size*i);
        printf("0x%06x ",pheader->p_type);
        printf("0x%06x ",pheader->p_offset);
        printf("0x%08x ",pheader->p_vaddr);
        printf("0x%08x ",pheader->p_paddr);
        printf("0x%05x ",pheader->p_filesz);
        printf("0x%05x ",pheader->p_memsz);
        printf("0x%05x ",pheader->p_flags);
        printf("0x%04x \n",pheader->p_align);
    }
}


int main(int argc, char** argv){
    char filename[20];
	if(debug_mode){
		printf("Debugging");
	}	
	strcpy(filename, argv[1]);
	examineElfFile(filename);
	printProgramHeaders();
}