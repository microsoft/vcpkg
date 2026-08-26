#pragma once
#include <glad/gl.h>
typedef GLADloadfunc GLADloadproc;
static inline int gladLoadGLLoader(GLADloadproc load) {
    return gladLoadGL(load);
}
