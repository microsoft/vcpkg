/*  Minimal unistd.h, just to get fontconfig to compile */
#ifndef UNISTD_H
#define UNISTD_H

#include <io.h>

#ifndef R_OK
#define R_OK 4
#endif

#ifndef W_OK
#define W_OK 2
#endif

#ifndef F_OK
#define F_OK 0
#endif

typedef int mode_t;

#endif