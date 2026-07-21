#ifdef WIN32
#undef WIN32
#endif
#include <flann/flann.h>

#include <math.h>

int main(void)
{
    float dataset[] = {0.0f, 0.0f, 1.0f, 1.0f, 2.0f, 2.0f};
    float query[] = {1.8f, 2.1f};
    float speedup = 0.0f;
    float distance = 0.0f;
    int neighbor = -1;
    struct FLANNParameters parameters = DEFAULT_FLANN_PARAMETERS;
    parameters.algorithm = FLANN_INDEX_LINEAR;
    parameters.log_level = FLANN_LOG_NONE;

    flann_index_t index = flann_build_index(dataset, 3, 2, &speedup, &parameters);
    if (index == 0) {
        return 10;
    }

    if (flann_find_nearest_neighbors_index(index, query, 1, &neighbor, &distance, 1, &parameters) != 0) {
        return 11;
    }

    flann_free_index(index, &parameters);
    return neighbor == 2 && fabsf(distance - 0.05f) < 0.0001f ? 0 : 12;
}
