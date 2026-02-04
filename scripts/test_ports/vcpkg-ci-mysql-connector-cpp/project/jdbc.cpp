#include <mysql/jdbc.h>
 
int main()
{
    sql::Driver* driver = sql::mysql::get_driver_instance();
    return 0;
}
