#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/***	structs		***/
typedef struct {
	unsigned short length;
	char name[16];
	char signature[];
} Virus;

typedef struct Link Link;

struct Link{
	Virus *v;
	Link *next;
};

/***	virus list methods	***/
void printv(Virus* v) {
	printf("Virus name: %s\nVirus size: %d\nSignature:\n", v->name, v->length);
	int i;
	for (i = 0; i < v->length; i++) {
		printf("%02hhX ",v->signature[i]);
	}
	printf("\n");
}

void list_print(Link* virus_list) {
	if(virus_list) {
		printv(virus_list->v);
		printf("\n");
		list_print(virus_list->next);
	}
}

Link* list_append(Link* virus_list, Virus* data) {
	if(!virus_list) {
		Link* newLink = (Link*)malloc(sizeof(Link));
		newLink->v = data;
		newLink->next = NULL;
		return newLink;
	}
	virus_list->next = list_append(virus_list->next, data);
	return virus_list;
}

void list_free(Link* virus_list) {
	if(virus_list) {
		list_free(virus_list->next);
		free(virus_list->v);
		free(virus_list);
	}
}

Link* getSigs(char* fname) {
	FILE* sigFile = fopen(fname, "r");
	char* buffer = (char*)malloc(2 * sizeof(char));
	
	char bigEndian = fgetc(sigFile);
	Link* vList = NULL;
	
	if(bigEndian) {
		exit(1);
	}
	
	unsigned int length;
	
	while(fread(buffer, sizeof(char), 2, sigFile)) {
		
		length = (buffer[1] << 8) + buffer[0];
		Virus* v = malloc(sizeof(char) * length);
		v->length = length - 18;
		
		fread(v->name, sizeof(char), length - 2, sigFile);
		
		vList = list_append(vList,v);
	}
	free(buffer);
	fclose(sigFile);
	
	return vList;
}

void detect_virus(char* buffer, Link* virus_list, unsigned int size, int singlePrint) {
	Virus* v;
	int i;
	
	while(virus_list) {
		v = virus_list->v;
		
		for(i = 0; i < size - v->length; i++) {
			if(!memcmp(buffer + i, v->signature, v->length)) {
				printf("Location: %d\nVirus Name: %s\nSize of Virus: %d\n", i, v->name, v->length);
				if (singlePrint) {
					return;
				}
			}
		}
		
		virus_list = virus_list->next;
	}
}

/***	main	***/
int main(int argc, char **argv) {
	
	int i;
	char* filename = "";
	int singlePrint = 0;
	
	for (i = 1; i< argc; i++) {
		if (!strcmp(argv[i],"-f")) {
			singlePrint = 1;
		}
		else {
			filename = argv[i];
		}
	}
	
	if (filename[0] == '\0') {
		exit(1);
	}
	
	Link* vList = getSigs("sig");
	
	FILE* suspected = fopen(filename, "r");
	char* buffer = (char*)malloc(10000 * sizeof(char));
	int bRead = fread(buffer, sizeof(char), 10000, suspected);

	detect_virus(buffer, vList, bRead, singlePrint);
	
	list_free(vList);
	free(buffer);
	fclose(suspected);
	
	return 0;
}