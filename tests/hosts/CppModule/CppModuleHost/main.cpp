#include <iostream>

#include "module.h"

int main()
{
    int expected = 1;
    int actual = module(expected);

    std::cout << "module() actual: " << actual << " expected: " << expected << std::endl;

    if (actual != expected)
    {
        std::cout << "Test failed!" << std::endl;

        return 1;
    }
    
    return 0;
}
