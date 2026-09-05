#include <pqxx/pqxx>

int main()
{
    pqxx::connection cx{"postgresql://vcpkg@localhost/tests"};
    pqxx::work tx{cx};
    return 0;
}
