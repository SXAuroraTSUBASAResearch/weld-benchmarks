#include <stdio.h>
#include <dlfcn.h>
#include <stdlib.h>

extern void weld_runtime_init();
extern void* run(void*);

extern 
int main()
{
#if 0
    void* handle = dlopen("/usr/work0/home/k-marukawa/weld/weld/weld_rt/cpp/libweldrt.so", RTLD_NOW);
    if (!handle) {
        printf("Error: %s\n", dlerror());
    }
#endif
#if 0
    void* handle2 = dlopen("./libverun.so", RTLD_NOW);
    if (!handle2) {
        printf("Error: %s\n", dlerror());
    }
#endif
#if 0
#if 1
    void (*init)() = (void (*)())dlsym(handle2, "weld_runtime_init");
    (*init)();
#if 0
    void (*run_begin)(void (*run)(void*), void*, long long ml, int nw) = (void (*)(void (*)(void*), void*, long long, int))dlsym(handle2, "weld_run_begin");
    (*run_begin)((void (*)(void*))0, 0, 12, 2);
#endif
#endif
#endif
    weld_runtime_init();

    printf("reading csv file\n");
    // Read CSV file
    //   char*
    //   double x 23
    typedef struct { char name[3]; double data[23]; } csv;
    // FIXME: variable data length to use different size of input data.
    #define LENGTH 62963
    csv* data = malloc(LENGTH * sizeof(csv));
    FILE* fp = fopen("../../data/us_cities_states_counties_sf=1.csv", "r");
    if (fp == NULL) {
        perror("cannot open csv file");
        return -1;
    }
    // skip first line
    char* line_buf = NULL;
    size_t line_max = 0;
    (void)getline(&line_buf, &line_max, fp);
    free(line_buf);
    // read entire data from CSV file
    for (int i = 0; i < LENGTH; ++i) {
        // NY|534078|330336|938|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6|1.6
        if (fscanf(fp, "%2s|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg|%lg", data[i].name, &(data[i].data[0]), &(data[i].data[1]), &(data[i].data[2]), &(data[i].data[3]), &(data[i].data[4]), &(data[i].data[5]), &(data[i].data[6]), &(data[i].data[7]), &(data[i].data[8]), &(data[i].data[9]), &(data[i].data[10]), &(data[i].data[11]), &(data[i].data[12]), &(data[i].data[13]), &(data[i].data[14]), &(data[i].data[15]), &(data[i].data[16]), &(data[i].data[17]), &(data[i].data[18]), &(data[i].data[19]), &(data[i].data[20]), &(data[i].data[21]), &(data[i].data[22])) < 0) {
            break;
        }
    }
    fclose(fp);
    printf("read csv file\n");

    typedef long i64;
    typedef int i32;
    typedef struct { double* data; size_t length; } v0; // elements, size
    typedef struct { v0* data; size_t length; } v1;
    typedef struct { i64* data; size_t length; } v2;
    typedef struct { char* data; size_t length; } v3;
    typedef struct { v3* data; size_t length; } v4;
    typedef struct { v0 s0; v1 s1; v2 s2; v4 s3; } s2;
//    encoded_params is Struct([Vector(Scalar(F64)), Vector(Vector(Scalar(F64))), Vector(Scalar(I64)), Vector(Vector(Scalar(I8)))])

    s2 args;
    args.s0.data = malloc(LENGTH * sizeof(double));
    args.s0.length = LENGTH;
    for (int i = 0; i < LENGTH; ++i) {
      // set "Total Population"
      args.s0.data[i] = data[i].data[0];
    }
    args.s1.data = malloc(LENGTH * sizeof(v0));
    args.s1.length = LENGTH;
    for (int i = 0; i < LENGTH; ++i) {
      args.s1.data[i].data = malloc(3 * sizeof(double));
      args.s1.data[i].length = 3;
      // set "Total Population", "Total adult population", "Number of robberies"
      args.s1.data[i].data[0] = data[i].data[0];
      args.s1.data[i].data[1] = data[i].data[1];
      args.s1.data[i].data[2] = data[i].data[2];
    }
    args.s2.data = malloc(3 * sizeof(i64));
    args.s2.length = 3;
    // set 1, 2, -2000
    args.s2.data[0] = 1;
    args.s2.data[1] = 2;
    args.s2.data[2] = -2000;
    args.s3.data = malloc(LENGTH * sizeof(v3));
    args.s3.length = LENGTH;
    for (int i = 0; i < LENGTH; ++i) {
      args.s3.data[i].data = malloc(2 * sizeof(char));
      args.s3.data[i].length = 2;
      args.s3.data[i].data[0] = data[i].name[0];
      args.s3.data[i].data[1] = data[i].name[1];
    }
    typedef struct { i64 args; i32 nworkers; i64 memlimit; } input_arg_t;
    printf("sizeof(input_arg_t) = %lld\n", sizeof(input_arg_t));
    printf("&input_arg_t.memlimit = %llx\n", &((input_arg_t*)0)->memlimit);
    input_arg_t input;
    input.args = (i64)&args;
    input.nworkers = 1;
    input.memlimit = 100000000000;

#if 0
    void* (*run)(void*) = (void* (*)(void*))dlsym(handle2, "run");
    void* result = (*run)((void*)&input);
#else
    void* result = run((void*)&input);
#endif
    typedef struct { i64 output; i64 runid; i64 errno; } output_arg_t;
    output_arg_t* output = (output_arg_t*)result;
    printf("output %llx, runid %lld, errno %lld\n", output->output, output->runid, output->errno);
    printf("output should point Struct([Vector(Scalar(F64)), Vector(Vector(Scalar(I8)))]\n");
    i64* ptr = (i64*)output->output;
    printf("1st array data    %llx\n", ptr[0]);
    printf("1st array length  %lld\n", ptr[1]);
    printf("2nd array data    %llx\n", ptr[2]);
    printf("2nd array length  %lld\n", ptr[3]);
    i64* ptr2 = (i64*)ptr[2];
    printf("2nd 1st array data    %llx\n", ptr2[0]);
    printf("2nd 1st array length  %lld\n", ptr2[1]);
    printf("2nd 2nd array data    %llx\n", ptr2[2]);
    printf("2nd 2nd array length  %lld\n", ptr2[3]);
    return 0;
}
