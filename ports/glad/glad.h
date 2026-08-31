#pragma once

#include <glad/gl.h>

typedef GLADloadfunc GLADloadproc;

#ifdef GLAD_OPTION_GL_LOADER
static inline int gladLoadGLLoader(GLADloadproc load)
{
    return gladLoadGL(load);
}

#ifdef __cplusplus
static inline int gladLoadGL()
{
    return gladLoaderLoadGL();
}
#endif
#endif