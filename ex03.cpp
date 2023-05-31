#include <iostream>

using namespace std;

int main(void)
{
    int dia, mes;

    cout << "Qual é o dia?";
    cin >> dia;

    cout << "Qual é o mês?";
    cin >> mes;

    int i = 0;

    while (dia >= 1){
        dia--;
        i++;

    }

    if (mes > 1) {
        i+= (mes - 1) * 30;
    }

    cout << i;

    return 0;
}
