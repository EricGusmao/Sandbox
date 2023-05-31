#include <iostream>
#include <iomanip>


using namespace std;

int main(void)
{
    float peso, altura, imc;

    cout << "Digite seu peso: ";
    cin >> peso;

    cout << "Digite sua altura: ";
    cin >> altura;

    imc = peso / (altura * altura);

    cout << "Seu IMC é: " << fixed << setprecision(2) << imc << endl;

    if (imc < 18.5) {
        cout << "Você está abaixo peso";
    } else if ( 18.5 <= imc && imc < 25) {
        cout << "Você está no peso normal";
    } else if (25 <= imc && imc < 30){
        cout << "Você está acima do peso";
    } else if (imc > 30){
        cout << "Você está obeso";
    } else {
       cout << "Input inválido";
    }

    return 0;
}
