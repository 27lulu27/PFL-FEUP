import qualified Data.List
import qualified Data.Array
import qualified Data.Bits

-- PFL 2024/2025 Practical assignment 1

-- Uncomment the some/all of the first three lines to import the modules, do not change the code of these lines.

type City = String
type Path = [City]
type Distance = Int

type RoadMap = [(City,City,Distance)]


type Bit = Integer
type AdjMatrix = Data.Array.Array (Int, Int) (Maybe Distance)



{- .Função 1 - cities
   .Objetivo: Esta função concatena numa única lista todos os pares de cidades de cada túplo do RoadMap, ignorando 
              a sua distância, e removendo depois as cidades duplicadas
   .Arguementos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
   .Retorna: Todas as cidades de um grafo
   .Complexidade Temporal: O(E), sendo E o número de estradas
-}
cities :: RoadMap -> [City]
cities rmap = Data.List.nub (concat [[c1, c2] | (c1, c2, _) <- rmap])




{- .Função 2 - areAdjacent
   .Objetivo: Esta função percorre todo o grafo e verifica se as duas cidades estão diretamente ligadas com recurso 
              à função auxiliar isAdjacent definidaa internamente que compara as duas cidades dadas com as cidades 
              de cada túplo do grafo
   .Arguementos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
                 (city1) - primeira cidade a ser analisada
                 (city2) - segunda cidade a ser analisada
   .Retorna: Um boleano que indica se duas cidades estão diretamente ligadas
   .Complexidade Temporal: O(E), sendo E o número de estradas
-}
areAdjacent :: RoadMap -> City -> City -> Bool
areAdjacent rmap city1 city2 = any isAdjacent rmap
    where isAdjacent (c1, c2, _) = (c1 == city1 && c2 == city2) || (c1 == city2 && c2 == city1)




{- .Função 3 - distance
   .Objetivo: Esta função percorre todo o grafo e encontra um túplo em que as duas cidades correspondem às duas cidades dadas
   .Arguementos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
                 (city1) - primeira cidade a ser analisada
                 (city2) - segunda cidade a ser analisada
   .Retorna: Caso seja encontrado a função retorna um *Just value* com a distância entre as duas cidades ligadas diretamente, 
             caso contrário retorna *Nothing*
   .Complexidade Temporal: O(E), sendo E o número de estradas
-}
distance :: RoadMap -> City -> City -> Maybe Distance
distance rmap city1 city2 =
    case Data.List.find (\(c1, c2, _) -> (c1 == city1 && c2 == city2) || (c1 == city2 && c2 == city1)) rmap of
        Just (_, _, d) -> Just d
        Nothing        -> Nothing




{- .Função 4 - adjacent
   .Objetivo: Esta função percorre cada túplo do grafo e verifica se a cidade dada é igual a alguma das cidades deste. Caso seja, 
              adiciona um par com a outra cidade e a distância entre as duas à lista
   .Arguementos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
                 (city) - cidade a ser analisada 
   .Retorna: Uma lista com as cidades adjacentes à cidade dada e a repetiva distância até ela em forma de par
   .Complexidade Temporal: O(E), sendo E o número de estradas
-}
adjacent :: RoadMap -> City -> [(City,Distance)]
adjacent rmap city = [(if city == c1 then c2 else c1, d) | (c1, c2, d) <- rmap, c1 == city || c2 == city]




{- .Função 5 - pathDistance
   .Objetivo: Esta função, para caminhos com várias cidades, verifica a distância entre as primeiras duas cidades usando a função 
              distance definida acima (3) e se as duas cidades estiverem diretamente conectadas, ou seja, se houver uma distânica 
              (se a função distance retornar um *Just value*) a verificação continua para o resto do caminho recursivamente, somando 
              as distâncias encontradas num total
   .Arguementos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
                 (path) - uma lista da cidades a serem consideradas para o caminho, sendo que pode ser vazia ([]), ter apenas uma 
                          cidade ([_]) ou várias cidades (c1:c2:cs)
   .Retorna: A soma de todas as distâncias individuais de um caminho entre duas cidades num *Just value*, se todos os pares 
             consecutivos de cidades esstiverem diretamente conectadas ou *Nothing* caso contrário
   .Complexidade Temporal: O(V*E), sendo V o número de cidades do path e E o número de estradas
-}
pathDistance :: RoadMap -> Path -> Maybe Distance
pathDistance _ [] = Just 0
pathDistance _ [_] = Just 0
pathDistance rmap (c1:c2:cs) = case distance rmap c1 c2 of
    Just d  -> case pathDistance rmap (c2:cs) of
                  Just total -> Just (d + total)
                  Nothing -> Nothing
    Nothing -> Nothing




{- .Função 6 - rome
   .Objetivo: Esta função utiliza a função auxiliar cityCounts definida internamente que, para cada cidade da lista de todas as 
              cidades únicas no grafo (cities rmap), conta o número de estrada conectadas a ela, percorredo o grafo e filtrando 
              por túplos em que a cidade apareça em qualquer posição. Após calcular o número de conexões para cada cidade, a 
              função encontra o maior número de conexões e junta numa lista todas as cidades que têm esse valor máximo de conexões   
   .Argumentos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
   .Retorna: Uma lista com os nomes das cidades com o maior número de estradas que se conectam a elas, ou seja, os vértices com 
             o grau mais alto
   .Complexidade Temporal: O(V*E), sendo V o número de cidades e E o número de estradas
-}
rome :: RoadMap -> [City]
rome rmap =
    let cityCounts = map (\c -> (c, length (filter (\(c1, c2, _) -> c1 == c || c2 == c) rmap))) (cities rmap)
        maxCount = maximum (map snd cityCounts)
    in [c | (c, count) <- cityCounts, count == maxCount]




{- .Função 7 - isStronglyConnected
   .Objetivo: Esta função, para cada cidade da lista de todas as cidades únicas no grafo (cities rmap), com auxílio da função 
              reachableFrom, verifica se todas as outras cidades são alcançáveis a partir dela
   .Argumentos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
   .Retorna: Um boleano que indica se todas as cidades no gráfico estão conectadas no grafo (ou seja, se todas as cidades forem 
             acessíveis a partir de todas as outras cidades
   .Complexidade Temporal: O(V*(V+E)), sendo V o número de cidades e E o número de estradas
-}
isStronglyConnected :: RoadMap -> Bool
isStronglyConnected rmap = all (\city -> reachableFrom city rmap (cities rmap)) (cities rmap)


{- .Função Auxiliar 7.1 - reachableFrom
   .Objetivo: Esta função verifica se todas as cidades são alcançáveis a partir de uma cidade inicial, recorrendo a uma "depth-first search"
   .Argumentos: (start) - a cidade de partida
                (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
                (allCities) - lista de todas as cidades do grafo
   .Retorna: Um boleano indicando se todas as cidades são alcançáveis a partir da cidade inicial
   .Complexidade Temporal: O(V+E), sendo V o número de cidades e E o número de estradas
-}
reachableFrom :: City -> RoadMap -> [City] -> Bool
reachableFrom start rmap allCities =
    let visited = dfs [start] rmap []
    in all (`elem` visited) allCities


{- .Função Auxiliar 7.2 - dfs
   .Objetivo: Implementa o algoritmo de "depth-first search" (DFS) para percorrer o grafo e identificar as cidades alcançáveis a partir 
              de uma cidade inicial
   .Argumentos: (stack) - lista de cidades a visitar
                (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
                (visited) - lista de cidades já visitadas
   .Retorna: A lista de cidades alcançadas a partir da cidade inicial
   .Complexidade Temporal: O(V+E), sendo V o número de cidades e E o número de estradas
-}
dfs :: [City] -> RoadMap -> [City] -> [City]
dfs [] _ visited = visited
dfs (c:cs) rmap visited
    | c `elem` visited = dfs cs rmap visited
    | otherwise = dfs (adjacentCities ++ cs) rmap (c : visited)
    where
        adjacentCities = [n | (n, _) <- adjacent rmap c]




{- .Função 8 - shortestPath
   .Objetivo: Esta função encontra o(s) caminho(s) mais curto(s) entre duas cidades específicas no grafo. Se o ponto de partida é 
              igual ao ponto final, o caminho mais curto é uma lista contendo apenas essa cidade. Caso contrário, a função utiliza uma 
              "breadth-first search" (bfs) para encontrar todos os caminhos entre a cidade de início e a cidade de destino. Após ter 
              todos os caminhos possíveis, a função usa a função pathDistance (5) para calcular a distância de cada caminho e filtra 
              apenas aqueles que têm a distância mínima entre os caminhos encontrados
   .Argumentos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
                (start) - a cidade de início
                (end) - a cidade de destino
   .Retorna: Uma lista dos caminhos mais curtos conectando as duas cidades fornecidas, ou uma lista vazia se não houver ligação entre 
             as cidades
   .Complexidade Temporal: O(V+E), onde V é o número de cidades e E o número de estradas.
-}
shortestPath :: RoadMap -> City -> City -> [Path]
shortestPath rmap start end
    | start == end = [[start]]
    | otherwise = case minDistance of
        Just minDist -> filter (\p -> pathDistance rmap p == Just minDist) allPaths
        Nothing -> []
  where
    allPaths = bfs [[start]] [] end rmap
    minDistance = case filterJust (map (pathDistance rmap) allPaths) of
                    [] -> Nothing
                    ds -> Just (minimum ds)


{- .Função Auxiliar 8.1 - filterJust
   .Objetivo: Filtra os valores do tipo Just de uma lista de Maybe
   .Argumentos: Lista de valores do tipo Maybe a
   .Retorna: Uma lista apenas com os valores não-nulos do tipo a
   .Complexidade Temporal: O(N), sendo N o número de elementos da lista
-}
filterJust :: [Maybe a] -> [a]
filterJust [] = []
filterJust (Just x : xs) = x : filterJust xs
filterJust (Nothing : xs) = filterJust xs


{- .Função Auxiliar 8.2 - bfs
   .Objetivo: Implementa o algoritmo de "breadth-first search" (BFS) para percorrer o grafo e gerar todos os caminhos entre duas cidades
   .Argumentos: (queue) - fila de caminhos a explorar
                (found) - lista de caminhos já encontrados
                (end) - cidade de destino
                (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
   .Retorna: Lista de todos os caminhos entre a cidade inicial e a final
   .Complexidade Temporal: O(V+E), sendo V o número de cidades e E o número de estradas
-}
bfs :: [Path] -> [Path] -> City -> RoadMap -> [Path]
bfs [] found _ _ = found
bfs (currentPath:queue) found end rmap
    | last currentPath == end =
        let newFound = currentPath : found
        in bfs queue newFound end rmap
    | otherwise =
        let nextCities = [next | (next, _) <- adjacent rmap (last currentPath), next `notElem` currentPath]
            newPaths = [currentPath ++ [next] | next <- nextCities]
        in bfs (queue ++ newPaths) found end rmap




{- .Função 9 - travelSales
   .Objetivo: Esta função resolve uma versão do "traveling salesman problem" (TSP) em que verifica se o grafo é fortemente 
              conectado para garantir que é possível visitar todas as cidades. Depois, converte o grafo numa matriz de adjacência 
              (`adjMatrix`) e com a função auxTravelSales que usa uma abordagem com bitmasking encontra o menor caminho que percorre 
              todas as cidades
   .Argumentos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
   .Retorna: O caminho mais curto que passa por todas as cidades do grafo, ou uma lista vazia se o grafo não for fortemente conectado
   .Complexidade Temporal: O(N^2 * 2^N), sendo N o número de cidades
-}
travelSales :: RoadMap -> Path
travelSales rmap
    | not (isStronglyConnected rmap) = []
    | otherwise = map (idxToCity cityIndices) (snd result) ++ [head (cities rmap)]
    where
        adjMatrix = toAdjMatrix rmap
        startMask = Data.Bits.bit 0
        numCities = length (cities rmap)
        visited = allVisited numCities
        startPos = 0
        result = auxTravelSales adjMatrix startMask startPos visited []
        cityIndices = cities rmap
        idxToCity :: [City] -> String -> City
        idxToCity idx cityStr = idx !! read cityStr


{- .Função Auxiliar 9.1 - allVisited
   .Objetivo: Esta função cria uma "bit mask" onde todos os bits até à posição são colocados a 1, representando todas as cidades visitadas
   .Argumentos: (n) - número de cidades a serem visitadas
   .Retorna: Uma "bit mask" do tipo Bit (Integer), onde os primeiros n bits estão a 1
   .Complexidade Temporal: O(1)
-}
allVisited :: Int -> Bit
allVisited n = Data.Bits.shiftL 1 n - 1


{- .Função Auxiliar 9.2 - isVisited
   .Objetivo: Esta função verifica se uma cidade específica já foi visitada examinando a "bitmask"
   .Argumentos: (mask) - uma "bit mask" do tipo Bit (Integer) que representa as cidades visitadas
                (city) - o index da cidade a ser verificada
   .Retorna: Um boleano indicando se o bit que corresponde à cidade está assinalado como visitada
   .Complexidade Temporal: O(1)
-}
isVisited :: Bit -> Int -> Bool
isVisited mask city = (mask Data.Bits..&. Data.Bits.shiftL 1 city) /= 0


{- .Função Auxiliar 9.3 - setVisited
   .Objetivo: Esta função marca uma cidade específica como visitada atualizando a "bit mask"
   .Argumentos: (mask) - uma "bit mask" do tipo Bit (Integer) que representa as cidades visitadas
                (city) - o index da cidade visitada
   .Retorna: Uma "bit mask" com o bit correspondente à cidade visitada colocado a 1
   .Complexidade Temporal: O(1)
-}
setVisited :: Bit -> Int -> Bit
setVisited mask city = mask Data.Bits..|. Data.Bits.shiftL 1 city


{- .Função Auxiliar 9.4 - auxTravelSales
   .Objetivo: Esta função resolve recursivamente o "traveling salesman problem" (TSP) usando programação dinámica e "bit masking"
   .Argumentos: (adjMatrix) - uma matrix de adjacência que representa as cidades já visitadas
                (mask) - uma "bit mask" do tipo Bit (Integer) que representa as cidades visitadas
                (pos) - o index da cidade atual
                (visitAll) - uma "bit mask" indicando se todas as cidades foram visitadas
                (path) - a lista dos indexs das cidades percorridas até ao momento em formato String
   .Retorna: Uma "bit mask" com o bit correspondente à cidade visitada colocado a 1
   .Complexidade Temporal: O(N^2 * 2^N), sendo N o número de cidades
-}
auxTravelSales :: AdjMatrix -> Bit -> Int -> Bit -> Path -> (Distance, Path)
auxTravelSales adjMatrix currentMask pos visitAll path
    | currentMask == visitAll =
        case adjMatrix Data.Array.! (pos, 0) of
            Just dist -> (dist, reverse (show pos : path))
            Nothing -> (100000000, [])
    | otherwise =
        let ((_, _), (maxRow, _)) = Data.Array.bounds adjMatrix
            distancesAndPaths = [(dist + newDist, newPath)
                | city <- [0 .. maxRow], not (isVisited currentMask city),
                  let dist = case adjMatrix Data.Array.! (pos, city) of
                               Just d -> d
                               Nothing -> 100000000,
                  let (newDist, newPath) = auxTravelSales adjMatrix (setVisited currentMask city) city visitAll (show pos : path)]
            (minDist, minPath) = minimum distancesAndPaths
        in (minDist, minPath)


{- .Função Auxiliar 9.5 - toAdjMatrix
   .Objetivo: Esta função convert um roadMap numa matrix de adjacência
   .Argumentos: (rmap) - um RoadMap com as cidades e a distância das estradas que as conectam
   .Retorna: Uma uma AdjMatrix onde o elemento da posição (i, j) representa a distância entre a iª e a jª cidades
-}
toAdjMatrix :: RoadMap -> AdjMatrix
toAdjMatrix rmap =
    let citiesList = cities rmap
        n = length citiesList
        bounds = ((0, 0), (n - 1, n - 1))
        idxMap = cityToIdx citiesList
        edges = [((idxMap c1, idxMap c2), Just dist) | (c1, c2, dist) <- rmap, idxMap c1 /= -1, idxMap c2 /= -1] ++
                [((idxMap c2, idxMap c1), Just dist) | (c1, c2, dist) <- rmap, idxMap c1 /= -1, idxMap c2 /= -1]
        diag = [((i, i), Just 0) | i <- [0 .. n - 1]]
    in Data.Array.array bounds ([(ix, Nothing) | ix <- Data.Array.range bounds] ++ edges ++ diag)


{- .Função Auxiliar 9.6 - cityToIdx
   .Objetivo: Esta função converte uma cidade para o seu índice correspondente numa lista de cidades
   .Argumentos: (cities) - lista de todas as cidades do grafo
                (city) - cidade a ser convertida
   .Retorna: O índice da cidade na lista, ou -1 caso a cidade não esteja presente
   .Complexidade Temporal: O(V), sendo V o número de cidades
-}
cityToIdx :: [City] -> City -> Int
cityToIdx cities city = case Data.List.elemIndex city cities of
    Just index -> index
    Nothing -> -1



-- 10
tspBruteForce :: RoadMap -> Path
tspBruteForce = undefined -- only for groups of 3 people; groups of 2 people: do not edit this function



-- Some graphs to test your work
gTest1 :: RoadMap
gTest1 = [("7","6",1),("8","2",2),("6","5",2),("0","1",4),("2","5",4),("8","6",6),("2","3",7),("7","8",7),("0","7",8),("1","2",8),("3","4",9),("5","4",10),("1","7",11),("3","5",14)]

gTest2 :: RoadMap
gTest2 = [("0","1",10),("0","2",15),("0","3",20),("1","2",35),("1","3",25),("2","3",30)]

gTest3 :: RoadMap -- unconnected graph
gTest3 = [("0","1",4),("2","3",2)]




{-
gTest4 :: RoadMap
gTest4 = [("A", "B", 3), ("B", "C", 4), ("C", "D", 5), ("D", "A", 6), ("B", "D", 2)]

gTest5 :: RoadMap
gTest5 = [("A", "B", 10), ("A", "C", 15), ("A", "D", 20), ("A", "E", 25), ("A", "F", 30),
        ("B", "C", 35), ("B", "D", 40), ("B", "E", 45), ("B", "F", 50),
        ("C", "D", 55), ("C", "E", 60), ("C", "F", 65),
        ("D", "E", 70), ("D", "F", 75),
        ("E", "F", 80)]

        
-- Test for cities function
cities gTest1 -- Expected: ["7","6","8","2","5","0","1","3","4"]
cities gTest2 -- Expected: ["0","1","2","3"]
cities gTest3 -- Expected: ["0","1","2","3"]

-- Test for areAdjacent function
areAdjacent gTest1 "0" "1" -- Expected: True
areAdjacent gTest1 "0" "2" -- Expected: False
areAdjacent gTest2 "0" "3" -- Expected: True
areAdjacent gTest3 "0" "3" -- Expected: False

-- Test for distance function
distance gTest1 "0" "1" -- Expected: Just 4
distance gTest1 "0" "2" -- Expected: Nothing
distance gTest2 "0" "2" -- Expected: Just 15
distance gTest3 "0" "3" -- Expected: Nothing

-- Test for adjacent function
adjacent gTest1 "0" -- Expected: [("1", 4), ("7", 8)]
adjacent gTest1 "2" -- Expected: [("8", 2), ("5", 4), ("3", 7), ("1", 8)]
adjacent gTest3 "0" -- Expected: [("1", 4)]
adjacent gTest3 "3" -- Expected: [("2", 2)]

-- Test for pathDistance function
pathDistance gTest1 ["0", "1", "2"] -- Expected: Just 12
pathDistance gTest1 ["0", "7", "8"] -- Expected: Just 15
pathDistance gTest2 ["0", "1", "2", "3"] -- Expected: Just 75
pathDistance gTest3 ["0", "1", "2"] -- Expected: Nothing  


    -- Test for rome function
rome gTest1 -- Expected: ["2", "5", "7"]
rome gTest2 -- Expected: ["0"]
rome gTest3 -- Expected: ["0", "1", "2", "3"]
rome gTest4 -- Expected: ["B", "D"]

-- Test for isStronglyConnected function
isStronglyConnected gTest1 -- Expected: True
isStronglyConnected gTest2 -- Expected: True
isStronglyConnected gTest3 -- Expected: False
isStronglyConnected gTest4 -- Expected: True

-- Test for shortestPath function
shortestPath gTest1 "0" "1" -- Expected: [["0", "1"]] as "0" to "1" is directly connected
shortestPath gTest1 "0" "3" -- Expected: [["0", "7", "8", "2", "3"]], finding the shortest path through multiple hops
shortestPath gTest2 "0" "3" -- Expected: [["0", "3"]], directly connected
shortestPath gTest3 "0" "3" -- Expected: [], as "0" and "3" are in disconnected components
shortestPath gTest4 "A" "D" -- Expected: [["A", "D"], ["A", "B", "D"]], since both paths have the same total distance

    -- Test for travelSales function
travelSales gTest1 -- Expected: Some path visiting all cities exactly once and returning to the start (e.g., ["0", "7", "6", "8", "2", "3", "4", "5", "1", "0"])
travelSales gTest2 -- Expected: Some path visiting all cities exactly once and returning to the start (e.g., ["0", "1", "3", "2", "0"])
travelSales gTest3 -- Expected: [], as not all cities are connected
travelSales gTest4 -- Expected: Some path visiting all cities exactly once and returning to the start (e.g., ["A", "B", "C", "D", "A"])
travelSales gTest4 -- Expected: Some path visiting all cities exactly once and returning to the start (e.g.,  ["A","D","B","E","C","F","A"])
-}