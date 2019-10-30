/**
 * q1.c
 *
 * A test for varying parameters for queries similar to Q1.
 *
 */

#ifdef __linux__
#define _BSD_SOURCE 500
#define _POSIX_C_SOURCE 2
#endif

#include <stdlib.h>
#include <stdio.h>
#include <stdint.h>
#include <assert.h>
#include <string.h>
#include <unistd.h>
#include <sys/time.h>

#include "weld.h"

// The generated input data.
struct gen_data {
    int64_t size;
    int32_t *x;
};

template <typename T>
struct weld_vector {
    T *data;
    int64_t size;
};

struct args {
    struct weld_vector<int32_t> x;
};

template <typename T>
weld_vector<T> make_weld_vector(T *data, int64_t size) {
    struct weld_vector<T> vector;
    vector.data = data;
    vector.size = size;
    return vector;
}

int32_t run_query(struct gen_data *d) {
    int32_t result;
    for (int i = 0; i < d->size; i++) {
        result += d->x[i];
    }
    return result;
}

int32_t run_query_weld(struct gen_data *d) {
    // Compile Weld module.
    weld_error_t e = weld_error_new();
    weld_conf_t conf = weld_conf_new();

    FILE *fptr = fopen("vector_sum.weld", "r");
    fseek(fptr, 0, SEEK_END);
    int string_size = ftell(fptr);
    rewind(fptr);
    char *program = (char *) malloc(sizeof(char) * (string_size + 1));
    fread(program, sizeof(char), string_size, fptr);
    program[string_size] = '\0';

    struct timeval start, end, diff;
    gettimeofday(&start, 0);
    weld_module_t m = weld_module_compile(program, conf, e);
    weld_conf_free(conf);
    gettimeofday(&end, 0);
    timersub(&end, &start, &diff);
    printf("Weld compile time: %ld.%06ld\n",
            (long) diff.tv_sec, (long) diff.tv_usec);

    if (weld_error_code(e)) {
        const char *err = weld_error_message(e);
        printf("Error message: %s\n", err);
        exit(1);
    }

   gettimeofday(&start, 0);
   struct args args;
   args.x = make_weld_vector<int32_t>(d->x, d->size);
   weld_value_t weld_args = weld_value_new(&args);

   // Run the module and get the result.
    conf = weld_conf_new();
    weld_context_t context = weld_context_new(conf);
    weld_value_t result = weld_module_run(m, context, weld_args, e);
    if (weld_error_code(e)) {
        const char *err = weld_error_message(e);
        printf("Error message: %s\n", err);
        exit(1);
    }
    int32_t final_result = *((int32_t *) weld_value_data(result));

    // Free the values.
    weld_value_free(result);
    weld_value_free(weld_args);
    weld_conf_free(conf);

    weld_error_free(e);
    weld_module_free(m);

    gettimeofday(&end, 0);
    timersub(&end, &start, &diff);
    printf("Weld: %ld.%06ld (result=%d)\n",
           (long) diff.tv_sec, (long) diff.tv_usec, final_result);

    return final_result;
}

/** Generates input data.
 *
 * @param num_items the number of line items.
 * @param num_buckets the number of buckets we hash into.
 * @param prob the selectivity of the branch.
 * @return the generated data in a structure.
 */
struct gen_data generate_data(int size) {
    struct gen_data d;

    d.size = size;
    d.x = (int32_t *)malloc(sizeof(int32_t) * size);

    srand(1);
    for (int i = 0; i < d.size; i++) {
        d.x[i] = rand();
    }

    return d;
}

int main(int argc, char **argv) {
    int size = (1E8 / sizeof(int));

    int ch;
    while ((ch = getopt(argc, argv, "n:")) != -1) {
        switch (ch) {
            case 'n':
                size = atoi(optarg);
                break;
            case '?':
            default:
                fprintf(stderr, "invalid options");
                exit(1);
        }
    }

    // Check parameters.
    assert(size > 0);

    struct gen_data d = generate_data(size);
    int32_t result;
    struct timeval start, end, diff;

    gettimeofday(&start, 0);
    result = run_query(&d);
    gettimeofday(&end, 0);
    timersub(&end, &start, &diff);
    printf("Single-threaded C++: %ld.%06ld (result=%d)\n",
            (long) diff.tv_sec, (long) diff.tv_usec, result);

    free(d.x);
    d = generate_data(size);

    result = run_query_weld(&d);

    return 0;
}
