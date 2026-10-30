#include "test_helpers.h"

int main(){
    CHECK(1+1 == 2);
    CHECK_EQUAL( 2*3,6);

    return reportTestResults();
}
