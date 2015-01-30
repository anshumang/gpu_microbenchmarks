#include <stdlib.h>
#include <stdio.h>

__global__ void read_mem(char* state){
      *state = threadIdx.x + blockIdx.x * blockDim.x + 0xffffffff;
      //for(int i=0; i<1; i++){
      //printf("%x\n", *((char *)0x6048a0000));
      //printf("%x\n", *((char *)0x6048a1000));
      printf("%p\n", state);
      if((long)state == 0x6048a0000){
	printf("Probe : Before allocated\n");
        unsigned long long start_address = 0x6048a0000, curr_address = 0x0;
        int count = 0;
	printf("Probe : 0MB to 64MB before allocated\n");
	while(count < 5){
		curr_address = start_address - count*0x1000000;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
	printf("Probe : 64MB to 72MB before allocated\n");
        count = 0;
	start_address = curr_address;
	while(count < 9){
		curr_address = start_address - count*0x100000;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
	printf("Probe : 72MB to 73MB before allocated\n");
        count = 0;
	start_address = curr_address;
	while(count < 16){
		curr_address = start_address - count*0x10000;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
	curr_address = curr_address - 0x1;
	printf("%p => %x\n", curr_address, *((char *)curr_address));
      }
      if((long)state == 0x8cd4a0000){
	printf("Probe : Allocated\n");
        unsigned long long start_address = 0x8cd4a0000, curr_address = 0x0;
        int count = 0;
	while(count < 10){
		curr_address = start_address + count*0x100000;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
	printf("Probe : Last 1MB of allocated\n");
        count = 0;
	start_address = curr_address;
	while(count < 16){
		curr_address = start_address + count*0x10000;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
	printf("Probe : Last 64KB of allocated\n");
        count = 0;
	start_address = curr_address;
	while(count < 16){
		curr_address = start_address + count*0x1000;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
	printf("Probe : Last 4KB of allocated\n");
        count = 0;
	start_address = curr_address;
	while(count < 16){
		curr_address = start_address + count*0x100;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
	printf("Probe : Last 512B of allocated\n");
        count = 0;
	start_address = curr_address;
	while(count < 16){
		curr_address = start_address + count*0x10;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
	printf("Probe : Last 32B of allocated\n");
        count = 0;
	start_address = curr_address;
	while(count < 16){
		curr_address = start_address + count*0x1;
		count++;
		printf("%p => %x\n", curr_address, *((char *)curr_address));
	}
      }
      //printf("[%p] = %x\n", 0x0, *((char *)0x0));
      //printf("[%p] = %x\n", 0x1, *((char *)0x1));
      //*state = *((char *)i);
      //}
      //printf("state from GPU = %x (at %p)\n", *state, state);
}

int main(){
    char *h_state, *d_state;
    h_state = (char *)malloc(sizeof(int));
    cudaError_t cerr;
    unsigned long long alloc_size = 1024*1024*1024;
    unsigned long long tot_alloc_size = 0;
    for(int i=0; i<11; i++){
	    cerr = cudaMalloc(&d_state, sizeof(char)*alloc_size);
	    if(cerr != cudaSuccess){
		    printf("cudaMalloc failed : %s\n", cudaGetErrorString(cerr));
	    }else{
		    tot_alloc_size+=alloc_size;
		    printf("Allocated another 1GB...total allocated = %llu\n", tot_alloc_size/(1024*1024*1024));
		    read_mem<<<1,1>>>(d_state);
		    cudaDeviceSynchronize();
	    }
    }
    alloc_size = 1024*1024*100; tot_alloc_size = 0;
    for(int i=0; i<1; i++){
	    cerr = cudaMalloc(&d_state, sizeof(char)*alloc_size);
	    if(cerr != cudaSuccess){
		    printf("cudaMalloc failed : %s\n", cudaGetErrorString(cerr));
	    }else{
		    tot_alloc_size+=alloc_size;
		    printf("Allocated another 100 MB...total allocated = %llu\n", tot_alloc_size/(1024*1024*100));
		    read_mem<<<1,1>>>(d_state);
		    cudaDeviceSynchronize();
	    }
    }
    alloc_size = 1024*1024*10; tot_alloc_size = 0;
    for(int i=0; i<5; i++){
	    cerr = cudaMalloc(&d_state, sizeof(char)*alloc_size);
	    if(cerr != cudaSuccess){
		    printf("cudaMalloc failed : %s\n", cudaGetErrorString(cerr));
	    }else{
		    tot_alloc_size+=alloc_size;
		    printf("Allocated another 10 MB...total allocated = %llu\n", tot_alloc_size/(1024*1024*10));
		    read_mem<<<1,1>>>(d_state);
		    cerr = cudaDeviceSynchronize();
		    if(cerr != cudaSuccess){
			    printf("cudaDeviceSynchronize failed : %s\n", cudaGetErrorString(cerr));
		    }
	    }
    }
#if 0
    long long address = 0xF00000000;
    unsigned count = 0;
    while(count++ < 1000){
    read_mem<<<1,1>>>(d_state, address);
    address = address + 0x100000;
    }
    cudaMemcpy(h_state, d_state, sizeof(int), cudaMemcpyDeviceToHost);
    printf("state from CPU = %x\n", *h_state);
#endif
    return 0;
}
