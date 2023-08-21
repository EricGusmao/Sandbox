#include <iostream>

using namespace std;

void ordenar_decrescente(int array[10])
{
    for (int i = 0; i < 9; ++i)
    {
        bool trocado = false;

        for (int j = 0; j < (9 - i); ++j)
        {
            if (array[j] < array[j + 1])
            {
                int temp = array[j];
                array[j] = array[j + 1];
                array[j + 1] = temp;

                trocado = true;
            }
        }

        if (trocado == false)
            break;
    }
}

void decrescente_to_crescente(int array[10])
{
    int temp[10];

    for (int i = 0; i < 10; ++i)
    {
        temp[i] = array[i];
    }

    for (int i = 0; i < 10; ++i)
    {
        array[9 - i] = temp[i];
    }
}

double media_array(int array[10])
{
    int soma = 0;
    double media = 0;

    for (int i = 0; i < 10; ++i)
        soma += array[i];

    media = soma / 10.0;

    return media;
}

void imprimir_array(int array[10])
{
    for (int i = 0; i < 10; ++i)
        cout << array[i] << " ";
    cout << endl;
}

int main(void)
{
    int numeros[10];

    cout << "Insira os 10 valores do array" << endl;
    for (int i = 0; i < 10; ++i)
        cin >> numeros[i];

    ordenar_decrescente(numeros);

    cout << "Em ordem decrescente: ";
    imprimir_array(numeros);

    decrescente_to_crescente(numeros);

    cout << "Em ordem crescente: ";
    imprimir_array(numeros);

    cout << "Maior número da lista: " << numeros[9] << endl;
    cout << "Menor número da lista: " << numeros[0] << endl;
    cout << "Média dos elementos da lista: " << media_array(numeros) << endl;

    return 0;
}
