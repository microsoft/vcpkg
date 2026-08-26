#pragma once
#include <glad/gl.h>
#ifdef __cplusplus
static inline int gladLoadGL() {
    return gladLoaderLoadGL();
}
#endif
typedef GLADloadfunc GLADloadproc;
static inline int gladLoadGLLoader(GLADloadproc load) {
    return gladLoadGL(load);
}
