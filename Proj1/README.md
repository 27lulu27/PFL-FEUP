# PFL - TP1 (Haskell)

## Participação
- João Cordeiro (up202205682)
- Luana Lima (up202206845)

Cada um de nós realizou 50% do projeto sendo que dividimos igualmente as primeiras 7 funções (João: cities, rome e isStronglyConnected; Luana: areAdjacent, distance, adjacent e pathDistance) e cada um fez uma das funções mais complexas (João: shortestPath; Luana: travelSales).


### Shortest Path
A função shortestPath tem a finalidade de calcular todos os caminhos mais curtos entre duas cidades num grafo representado pelo RoadMap. Se houver múltiplos caminhos com o mesmo comprimento mínimo entre a cidade inicial (start) e a cidade final (end), a função retornará todos esses caminhos.

O algoritmo shortestPath utiliza, para  encontrar todos os caminhos mais curtos, o algoritmo de busca em largura (Breadth-First Search - BFS). Este tipo de problema é perfeitamente adequado para o BFS, pois, ao explorar os vizinhos nível por nível, os primeiros caminhos que alcançam o nó alvo são garantidos como os mais curtos. Ele funciona particularmente bem neste caso, porque o BFS assegura que explora os caminhos em ordem crescente de comprimento.

O algoritmo começa por verificar se as cidades de início e fim são as mesmas. Se forem iguais, ele retorna imediatamente [[start]], pois o caminho mais rápido de uma cidade para ela mesma seria simplesmente a própria cidade. Se forem diferentes, a função executa o algoritmo BFS através da função auxiliar bfs.

Primeiro, o caminho, que contem apenas a cidade inicial, é adicionado a uma fila na função bfs. Em seguida, o BFS percorre essa fila, e para cada caminho na fila, estende o caminho atual adicionando cada cidade vizinha não visitada ao caminho atual. Quando a última cidade do caminho atual é igual à cidade final, esse caminho é adicionado à lista allPaths. O algoritmo continua até que todos os possíveis caminhos do início ao fim tenham sido explorados e adicionados a allPaths.

Após a conclusão do BFS, ele encontra a distância mínima de todos os caminhos através da função pathDistance. Em seguida, filtra todos os caminhos de allPaths para reter apenas aqueles que têm a menor distância, de modo a retornar apenas os caminhos mais curtos.

A função auxiliar bfs executa o BFS para explorar todos os caminhos do início ao fim, estendendo a cada passo cada caminho com cada cidade vizinha que ainda não foi visitada nesse caminho. A função auxiliar filterJust remove os valores Nothing da lista de distâncias, para que ela inclua apenas distâncias válidas, algo importante para obter a distância mínima e também para que a função considere apenas caminhos válidos.


*By João Cordeiro*


### Travel Sales
A função travelSales dá a solução para o Travel Salesman Problem (TSP). O objetivo é encontrar o caminho mais curto que cobre cada cidade no RoadMap exatamente uma vez e retorna à cidade original. Este é um clássico problema de otimização na ciência da computação, e a função aplica Programação Dinâmica com Bitmasking como uma maneira eficiente de lidar com isso.

Para resolver o TSP, travelSales primeiro verifica se o grafo é fortemente conectado usando a função isStronglyConnected. Caso o grafo não seja totalmente conectado, significa que não se pode resolver o TSP para todas as cidades, então a função retorna uma lista vazia. No caso de um grafo fortemente conectado, a função prossegue com o cálculo principal.

A função auxiliar toAdjMatrix converte RoadMap numa matriz de adjacência AdjMatrix. Esta função armazena as distâncias diretas entre as cidades na matriz de adjacência; portanto, a função pode consultar a distância entre duas cidades com facilidade. Isso acelera os cálculos, porque o tempo de acesso numa matriz de adjacência é constante.

O cálculo central do TSP é realizado através de auxTravelSales, que é uma função recursiva usando Programação Dinâmica juntamente com Bitmasking. A ideia aqui é que, nesta abordagem, cada bit de um inteiro bitmask representa se uma cidade foi visitada. Por exemplo, se houver quatro cidades, 0001 indica que apenas a primeira cidade foi visitada, enquanto 1111 significa que todas as cidades foram visitadas. Começando numa certa cidade, a função auxTravelSales tenta todas as cidades possíveis que ainda não foram visitadas, calcula recursivamente o caminho mínimo contendo cada cidade, marca cada cidade como visitada atualizando o bitmask.

Neste caso, os resultados intermédios são armazenados em forma de memoização. Ao fazer isso, reduz-se a cálculos redundantes para o mesmo conjunto de cidades visitadas e posições drasticamente, tornando assim a função bastante eficiente para grafos de tamanho moderado.

Uma vez que a função auxTravelSales tenha calculado a rota mais curta possível, a função reconstrói a rota: começando com a cidade inicial, a rota passa por cada uma das cidades selecionadas uma vez e, finalmente, termina retornando à cidade inicial, fechando o ciclo.

A função auxiliar toAdjMatrix retorna o argumento RoadMap na forma de matriz de adjacência. Esta estrutura de dados é eficiente para verificar distâncias diretas entre cidades. As cidades visitadas são guardadas através de bitmasking permitindo que a função forneça todos os subconjuntos das cidades sem usar uma lista. Já a função auxiliar, auxTravelSales, faz esse cálculo recursivo, usando Programação Dinâmica e bitmasking para encontrar a rota mais curta para o TSP de forma eficiente.

*By Luana Lima*
