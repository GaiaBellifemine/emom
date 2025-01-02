% Caricamento del dataset
global numRigheDataset;
global numClusters;

dataset = readmatrix('dataset.csv'); % Carica il dataset dal file CSV
[numRigheDataset, numColonneDataset] = size(dataset); % Ottiene le dimensioni del dataset
numClusters = 5; % Definisce il numero di cluster

% Applicazione dell'algoritmo FCM e aggiornamento del dataset
dataset = createCluster(dataset); 

% Aggiornamento del dataset con i risultati del clustering
updateDataset(dataset);

% Funzione per creare i cluster utilizzando FCM
function dataset = createCluster(dataset)
    global numRigheDataset;
    global numClusters;

    % Estrazione delle features (Valence ed Energy)
    VD = zeros(numRigheDataset, 2); 
    VD(:,1) = dataset(:,8); % Carica la Valence nella matrice VD
    VD(:,2) = dataset(:,7); % Carica l'Energy nella matrice VD

    % Inizializzazione del generatore di numeri casuali per riproducibilità
    rng(1); 

    % Applicazione dell'algoritmo FCM
    [C,U]=fcm(VD,numClusters); 

    % Assegnazione dei punti ai cluster in base al massimo grado di appartenenza
    [~,I]=max(U); 
    I=I'; 
    VD =[VD I]; 

    % Visualizzazione dei cluster
    createClusterImage(VD, C);

    % Calcolo e stampa dell'SSE per ogni cluster
    for i=1:size(C)
        SSE = computeSSE(dataset, C, U, VD, i);
        disp("SSE = "+SSE); 
    end

    % Aggiunta dell'indice di cluster al dataset
    dataset = [dataset I]; 

    return;
end

% Funzione per creare il grafico dei cluster
function createClusterImage(VD, C)
    figure;

    global numClusters;
    colors = hsv(numClusters); % Generazione dinamica dei colori
    gscatter(VD(:,1), VD(:,2), VD(:,3), colors, '..'); % Scatter plot con colori dinamici
    hold on;
    plot(C(:,1), C(:,2), 'kx', 'MarkerSize', 5); % Plotta i centroidi come croci nere

    % Creazione delle etichette della legenda
    legendStrings = cell(numClusters + 1, 1); 
    for i = 1:numClusters
        legendStrings{i} = sprintf('Cluster %d', i);
    end
    legendStrings{end} = 'Centroids';

    legend(legendStrings, 'Location', 'best');

    title 'Clusters';
    xlabel 'Valence';
    ylabel 'Energy';
    hold off;
end

% Funzione per calcolare l'SSE (Sum of Squared Errors) per ogni cluster
function SSE = computeSSE(dataset, C, U, VD, clusterIndex)
    % Estrai i punti appartenenti al cluster
    idx = VD(:,3) == clusterIndex;
    clusterPoints = VD(idx, :);

    % Calcola le distanze euclidee tra i punti del cluster e il centroide
    distances = pdist2(clusterPoints(:, 1:2), C(clusterIndex, :));

    % Calcola la somma dei quadrati delle distanze
    SSE = sum(distances.^2);
end

% Funzione per aggiornare il dataset con i risultati del clustering
function updateDataset(dataset)

    dataset2 = readtable('dataset.csv'); % Carica il dataset da file
    dataset2{:,9} = string(dataset(:,11)); % Aggiorna la colonna 9 del dataset con gli indici di cluster
    writetable(dataset2, 'dataset.csv', 'Delimiter', ';'); % Salva il dataset aggiornato con separatore ';'
end