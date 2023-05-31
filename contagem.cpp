#include <iostream>

using namespace std;

int main(void)
{
    int num;

    cout << "Insira um número: ";
    cin >> num;

    if (num <= 0)
    {
        cout << "número inválido";
    } else {
        for (int i = 1; num > 0; i++) {
            if (i <= num) {
                cout << i << " ";
            } else{
                cout << endl;
                num--;
                i = 0;
            }
        }
    }

    return 0;
}