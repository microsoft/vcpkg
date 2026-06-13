/*
 * Platform-specific file operations
 */
#include <stdio.h>
#include <unistd.h>

int eval_get_cwd(char *buf, size_t size) {
    if (getcwd(buf, size) == NULL) {
        return -1;
    }
    return 0;
}

int eval_file_exists(const char *path) {
    return access(path, F_OK) == 0;
}
