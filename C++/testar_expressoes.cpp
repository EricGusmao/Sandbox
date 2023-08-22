#include <iostream>
#include <sstream>

using namespace std;

//Cria stream de string
stringstream ss;

//Função
void checar_Imprimir(string parametros_str)
{
    int parametros;
    //Coloca parametros_str na stream e converte pra int
    ss << parametros_str;
    ss >> parametros;
    //Faz o output e a checagem
    cout << parametros_str << " é " << (parametros ? "Verdadeiro" : "Falso") << endl << endl;
}

//Main
int main(void)
{
    //Recebe o input
    int opcao;
    
    //Mensagem inicial e input do user
    cout << "1- Para o 1º exercício" << endl << "2- Para o 2º exercício" << endl;
    cin >> opcao;
    cout << endl;


    switch(opcao)
    {
        // Receber os valores
        int A, B, C;

        //1º exercício
        case 1:
        {
            A = 7;
            B = 9;
            C = 2;

            string expressoes1[] = {
            "(A == B) && (B > C)", 
            "(A != B) || (B < C)", 
            "!(A > B)", 
            "(A < B) && (B > C)", 
            "A >= B) || (B == C)",
            "!(A <= B)", 
            "!((A < B) && (B - A != C))"
            };

            for(int it = 0 ; it <= 6; it++)
            {
                checar_Imprimir(expressoes1[it]);
            }

            break;
        }
        

        //2º exercício
        case 2 :
        {
            A = 3;
            B = 4;
            C = 8;

            string expressoes2[] = {
            "A > 3 && C == 8", 
            "A != 2 || B <= 5", 
            "A == 3 || B >= 2 && C == 8", 
            "A == 3 && !( B <= 4 ) && C == 8", 
            "A != 8 || B == 4 && C > 2",
            "B > A && C != A", 
            "A > B || B < 5"
            };

            for(int it2 = 0 ; it2 <= 6; it2++)
            {
                checar_Imprimir(expressoes2[it2]);
            }

            break;
        }
        
        //Checagem de erro no Input
        default: 
        {
            cout << "Caracter Inválido";
            
            break;
        }
    }
    return 0;
}