#define _USE_MATH_DEFINES

#include <cmath>
#include <iostream>
#include <numeric>
#include <vector>

using namespace std;

// Faz o operador do cout "<<", printar um vetor no formato "[x, y, z]" (Operator overloading)
template <typename T> ostream &operator<<(ostream &os, const vector<T> &v)
{
    os << "[";
    for (int i = 0; i < v.size(); ++i)
    {
        os << v[i];
        if (i != v.size() - 1)
            os << ", ";
    }
    os << "]";
    return os;
}

// Protótipos das funções
void inserir_valores(vector<double> &vetor);
vector<double> calcular_soma(const vector<double> &vetor1, const vector<double> &vetor2);
vector<double> calcular_subtracao(const vector<double> &vetor1, const vector<double> &vetor2);
double calcular_produto_escalar(const vector<double> &vetor1, const vector<double> &vetor2);
double encontrar_angulo(const vector<double> &vetor1, const vector<double> &vetor2);
vector<double> calcular_produto_vetorial(const vector<double> &vetor1, const vector<double> &vetor2);

int main(void)
{
    vector<double> vetor1(3);
    vector<double> vetor2(3);
    int input_operacao = 0;
    bool execute_operacao = true;
    char resposta_usuario = 'n';

    cout << "Insira os valores do primeiro vetor: (separados por espaço)\n";
    inserir_valores(vetor1);
    cout << "Insira os valores do segundo vetor: (separados por espaço)\n";
    inserir_valores(vetor2);

    while (execute_operacao)
    {
        cout << "Qual operação deseja efetuar?? (Digite o número correspondente)\n"
             << "1 - Soma de vetores\n"
             << "2 - Subtração de vetores\n"
             << "3 - Produto escalar\n"
             << "4 - Encontrar ângulo entre 2 vetores\n"
             << "5 - Produto vetorial\n";
        cin >> input_operacao;
        // Checa input da operação
        while (cin.fail() || input_operacao < 1 || input_operacao > 5)
        {
            cout << "Valor inválido!!! Tente novamente." << endl;
            cin >> input_operacao;
        }

        switch (input_operacao)
        {
        case 1: // Soma de vetores
            cout << vetor1 << " + " << vetor2 << " = " << calcular_soma(vetor1, vetor2) << endl;
            break;
        case 2: // Subtração de vetores
            cout << vetor1 << " - " << vetor2 << " = " << calcular_subtracao(vetor1, vetor2) << endl;
            break;
        case 3: // Produto escalar
            cout << "O produto escalar dos vetores informados é: " << calcular_produto_escalar(vetor1, vetor2) << endl;
            break;
        case 4: // Encontrar ângulo entre 2 vetores
            cout << "O ângulo entre os vetores " << vetor1 << " e " << vetor2
                 << " é de: " << encontrar_angulo(vetor1, vetor2) << "° (graus)" << endl;
            break;
        case 5: // Produto vetorial
            cout << vetor1 << " X " << vetor2 << " = " << calcular_produto_vetorial(vetor1, vetor2) << endl;
            break;
        }
        // Pergunta ao usuário se ele quer fazer alguma outra operação e repete caso receba input inválido
        do
        {
            cout << "Deseja fazer outra operação com os mesmos vetores?? (s/n)" << endl;
            cin >> resposta_usuario;
            if (tolower(resposta_usuario) == 'n')
            {
                execute_operacao = false;
            }
        } while (cin.fail());
    }

    return 0;
}
// Declaração das funções
void inserir_valores(vector<double> &vetor)
{
    int temp = 0;
    int i = 0;
    // Repete até preencher os 3 elementos do vetor
    while (i < 3)
    {
        cin >> temp;
        // Checa input por algum erro, se tiver, volta as interações para o começo
        if (cin.fail())
        {
            cin.clear();
            cin.ignore(numeric_limits<streamsize>::max(), '\n');
            cout << "Insira os valores novamente!" << endl;
            i = 0;
            continue;
        }
        // Se tudo deu certo faz o type casting e adiciona ao vetor
        vetor[i] = double(temp);
        ++i;
    }
    // Limpa o cin para caracteres excedentes não serem atribuídos para o próximo input
    cin.ignore(numeric_limits<streamsize>::max(), '\n');
}

vector<double> calcular_soma(const vector<double> &vetor1, const vector<double> &vetor2)
{
    vector<double> resultado_soma(3);

    for (int i = 0; i < 3; i++)
    {
        resultado_soma[i] = vetor1[i] + vetor2[i];
    }

    return resultado_soma;
}

vector<double> calcular_subtracao(const vector<double> &vetor1, const vector<double> &vetor2)
{
    vector<double> resultado_subtracao(3);

    for (int i = 0; i < 3; i++)
    {
        resultado_subtracao[i] = vetor1[i] - vetor2[i];
    }

    return resultado_subtracao;
}

double calcular_produto_escalar(const vector<double> &vetor1, const vector<double> &vetor2)
{
    vector<double> temp(3);

    // Faz multiplicação entre vetores e armazena em temp
    for (int i = 0; i < 3; i++)
    {
        temp[i] = vetor1[i] * vetor2[i];
    }
    // Soma todos os valores que estão dentro de temp
    double produto_escalar = reduce(temp.begin(), temp.end());

    return produto_escalar;
}

double encontrar_angulo(const vector<double> &vetor1, const vector<double> &vetor2)
{
    // Calcula a norma dos vetores
    double vetor1_norma = hypot(vetor1[0], vetor1[1], vetor1[2]);
    double vetor2_norma = hypot(vetor2[0], vetor2[1], vetor2[2]);

    // Acha o cosseno do ângulo, transforma em radianos depois converte para graus
    double cos_angulo = (calcular_produto_escalar(vetor1, vetor2)) / (vetor1_norma * vetor2_norma);
    double angulo_graus = (acos(cos_angulo) * 180.0) / M_PI;

    // Arrendonda para 2 casas decimais
    angulo_graus = round(angulo_graus * 100.0) / 100.0;

    return angulo_graus;
}

vector<double> calcular_produto_vetorial(const vector<double> &vetor1, const vector<double> &vetor2)
{
    vector<double> produto_vetorial(3);

    produto_vetorial[0] = (vetor1[1] * vetor2[2]) - (vetor1[2] * vetor2[1]);
    produto_vetorial[1] = (vetor1[2] * vetor2[0]) - (vetor1[0] * vetor2[2]);
    produto_vetorial[2] = (vetor1[0] * vetor2[1]) - (vetor1[1] * vetor2[0]);

    return produto_vetorial;
}
