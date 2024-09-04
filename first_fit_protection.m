function protecao_first_fit()

% Elaboração da rede NSFNET
arestas = [
1 8 2828; 1 4 1136; 1 11 1702; 4 5 959; 4 11 683; 5 2 2349; 5 6 573; ...
11 12 2049; 6 7 732; 6 12 1450; 7 8 750; 12 13 1128; 12 14 1976; ...
8 9 706; 9 3 366; 9 10 451; 9 13 839; 2 3 596; 2 10 789; 3 14 385; ...
14 10 246
];

% Criação de um vetor de comprimentos de onda disponíveis para cada aresta
comp_onda = ones(size(arestas, 1), 10); 

% Defina seus nós de origem e destino aqui
origens = [1, 1, 1, 4]; % vetor com os nós de origem
destinos = [8, 9, 3, 5]; % vetor com os nós de destino

% Construção do gráfico direcionado com pesos nas arestas (distâncias)
Rede = graph(arestas(:, 1), arestas(:, 2), arestas(:, 3));
% Criação de uma tabela para armazenar a capacidade dos comprimentos de onda de cada aresta
Rede.Edges.Wavelengths = comp_onda;

for k = 1:length(origens) % loop para cada par de nós

    origem = origens(k);
    destino = destinos(k);

    % Definição do caminho de serviço
    caminho_servico = shortestpath(Rede, origem, destino);
    
    disp('Coprimmento de onda para caminho de serviço:');
    for i = 1:numel(caminho_servico) - 1
        edgeIndex = findedge(Rede, caminho_servico(i), caminho_servico(i + 1));
        wavelengthIndex = find(Rede.Edges.Wavelengths(edgeIndex, :), 1);
        if ~isempty(wavelengthIndex)
            disp(wavelengthIndex);
            Rede.Edges.Wavelengths(edgeIndex, wavelengthIndex) = 0;
        else
            disp('Não há mais comprimentos de onda disponíveis para esta aresta.');
            return;
        end
    end

    % Procura pelo caminho de proteção
    caminho_protecao = [];
    for i = 1:numel(caminho_servico) - 1
        Rede_temp = rmedge(Rede, caminho_servico(i), caminho_servico(i + 1));
        novo_caminho_protecao = shortestpath(Rede_temp, origem, destino);
        if isempty(novo_caminho_protecao)
            break;
        else
            caminho_protecao = novo_caminho_protecao;
        end
    end

    disp('Comprimento de onda para caminho de proteção:');
    for i = 1:numel(caminho_protecao) - 1
        edgeIndex = findedge(Rede, caminho_protecao(i), caminho_protecao(i + 1));
        wavelengthIndex = find(Rede.Edges.Wavelengths(edgeIndex, :), 1);
        if ~isempty(wavelengthIndex)
            disp(wavelengthIndex);
            Rede.Edges.Wavelengths(edgeIndex, wavelengthIndex) = 0;
        else
            disp('Não há mais comprimentos de onda disponíveis para esta aresta.');
            return;
        end
    end

    % Admitindo uma unidade de tráfego para todos os caminhos
    unidades_trafego = ones(1, numel(caminho_servico) - 1);

    % Demonstração dos caminhos primário e de backup, e as unidades de tráfego
    disp("Caminho de Serviço:");
    disp(caminho_servico);
    disp("Caminho de Proteção:");
    disp(caminho_protecao);
    disp("Unidades de Tráfego");
    disp(unidades_trafego);

 % Desenho do gráfico com caminhos serviço e de proteção
    figure;
    p = plot(Rede, 'Layout', 'force', 'EdgeLabel', Rede.Edges.Weight);
    hold on;
    % Destaque do caminho de backup em verde
    highlight(p, caminho_protecao, 'EdgeColor', 'g', 'LineWidth', 1.5);
    p2 = plot(nan, nan, 'g', 'LineWidth', 1.5); % Inclusão do caminho de proteção à legenda
    % Realce do caminho primário em azul
    highlight(p, caminho_servico, 'EdgeColor', 'blue', 'LineWidth', 1.5);
    p1 = plot(nan, nan, 'blue', 'LineWidth', 1.5); % Inclusão do caminho de serviço à legenda
    legend([p1, p2], {'Caminho de Serviço', 'Caminho de Proteção'}); % Criação da legenda
    hold off;
    title('Topologia da Rede com Caminhos de Serviço e de Proteção');
end
end