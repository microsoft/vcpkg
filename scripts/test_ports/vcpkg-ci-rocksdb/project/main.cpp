#include <rocksdb/db.h>
#include <cassert>
#include <string>
#include <filesystem>
#include <memory>

int main() {
    std::filesystem::path tmp = std::filesystem::temp_directory_path() / "vcpkg-ci-rocksdb-test";
    std::filesystem::remove_all(tmp);
    std::unique_ptr<rocksdb::DB> db;
    rocksdb::Options options;
    options.create_if_missing = true;
    rocksdb::Status status = rocksdb::DB::Open(options, tmp.string(), &db);
    assert(status.ok());
    status = db->Put(rocksdb::WriteOptions(), "hello", "rocksdb");
    assert(status.ok());
    std::string value;
    status = db->Get(rocksdb::ReadOptions(), "hello", &value);
    assert(status.ok());
    assert(value == "rocksdb");
    std::filesystem::remove_all(tmp);
    return 0;
}
