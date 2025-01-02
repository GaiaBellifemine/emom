global numRigheDataset;
global numClusters;

dataset = readmatrix('dataset.csv'); % Carica il dataset con dati numerici
datasetStringFormat = readtable('dataset.csv'); % Carica il dataset mantenendo i formati originali (per visualizzazione)
[numRigheDataset, numColonneDataset] = size(dataset); % Ottiene le dimensioni del dataset
numClusters = 5; % Imposta il numero di cluster desiderato

% Applica l'algoritmo K-means e aggiorna il dataset
dataset = createCluster(dataset);

% Aggiorna il file CSV con i risultati del clustering
updateDataset(dataset);

% Funzione per creare i cluster utilizzando K-means
function dataset = createCluster(dataset)
    global numRigheDataset;
    global numClusters;

    % Estrae le features (Valence ed Energy)
    VD = zeros(numRigheDataset, 2); 
    VD(:,1) = dataset(:,8); % Carica la Valence nella matrice VD
    VD(:,2) = dataset(:,7); % Carica l'Energy nella matrice VD

    % Applica l'algoritmo K-means
    [idx,C,SSE] = kmeans(VD, numClusters); 
    % idx: indice del cluster per ogni punto dati
    % C: centroidi dei cluster
    % SSE: somma degli errori al quadrato

    % Aggiunge l'indice del cluster al dataset
    VD = [VD idx]; 
    dataset = [dataset idx];

    % Visualizza i cluster
    createClusterImage(VD, C);

    % Stampa l'SSE
    disp("SSE2 = "+SSE);
end

function createClusterImage(VD, C)
figure;

global numClusters;
colors = hsv(numClusters); % Generazione dinamica dei colori
gscatter(VD(:,1), VD(:,2), VD(:,3), colors, '..'); % Scatter plot con colori dinamici
hold on;
plot(C(:,1), C(:,2), 'kx', 'MarkerSize', 5); % Plotta i centroidi come croci nere
legendStrings = cell(numClusters + 1, 1); % Creazione dinamica delle etichette della legenda
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

function updateDataset(dataset)

dataset2 = readtable('dataset.csv');
dataset2{:,9} = string(dataset(:,11)); %user ratings aggiornati
writetable(dataset2, 'dataset.csv', 'Delimiter', ';'); % Utilizza il punto e virgola come separatore
end
