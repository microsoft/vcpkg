#include <rocksdb/c.h>
#include <assert.h>
#include <stdio.h>
#include <string.h>

int main(void) {
    char path[] = "vcpkg-ci-rocksdb-c-test";
    char* err = NULL;
    rocksdb_options_t* options = rocksdb_options_create();
    rocksdb_options_set_create_if_missing(options, 1);
    rocksdb_t* db = rocksdb_open(options, path, &err);
    assert(err == NULL);

    rocksdb_writeoptions_t* writeoptions = rocksdb_writeoptions_create();
    rocksdb_put(db, writeoptions, "hello", 5, "rocksdb", 7, &err);
    assert(err == NULL);

    rocksdb_readoptions_t* readoptions = rocksdb_readoptions_create();
    size_t len = 0;
    char* value = rocksdb_get(db, readoptions, "hello", 5, &len, &err);
    assert(err == NULL);
    assert(len == 7 && memcmp(value, "rocksdb", 7) == 0);
    rocksdb_free(value);

    rocksdb_readoptions_destroy(readoptions);
    rocksdb_writeoptions_destroy(writeoptions);
    rocksdb_close(db);
    rocksdb_destroy_db(options, path, &err);
    assert(err == NULL);
    rocksdb_options_destroy(options);
    puts("ok");
    return 0;
}
