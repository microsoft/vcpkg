#include <leveldb/db.h>
#include <cassert>
#include <string>
#include <filesystem>

int main() {
    std::filesystem::path tmp = std::filesystem::temp_directory_path() / "vcpkg-ci-leveldb-test";
    std::filesystem::remove_all(tmp);
    leveldb::DB* db = nullptr;
    leveldb::Options options;
    options.create_if_missing = true;
    leveldb::Status status = leveldb::DB::Open(options, tmp.string(), &db);
    assert(status.ok());
    status = db->Put(leveldb::WriteOptions(), "hello", "leveldb");
    assert(status.ok());
    std::string value;
    status = db->Get(leveldb::ReadOptions(), "hello", &value);
    assert(status.ok());
    assert(value == "leveldb");
    delete db;
    std::filesystem::remove_all(tmp);
    return 0;
}
