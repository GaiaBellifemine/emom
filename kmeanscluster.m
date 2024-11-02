global numRigheDataset;
global numClusters;
global indexCanzone;

dataset = readmatrix('dataset.csv'); % carico il dataset nella matrice dataset
%dataset = readtable('dataset.csv');
%dataset(1,:) = []; % rimuove la prima riga (intestazione) dal dataset
[numRigheDataset, numColonneDataset] = size(dataset);
numClusters = 5;
indexCanzone = 1;
numGeneri = 3;
dataset = createCluster(dataset);
updateDataset(dataset);

function dataset = createCluster(dataset)
global numRigheDataset;
global numClusters;

%VD = zeros(2,numRigheDataset);

for i=1:numRigheDataset
    VD(i,1) = dataset(i,8); % carico la valence nella matrice VD
    VD(i,2) = dataset(i,7); % carico l'energy nella matrice VD
end

%VD = table2array(VD);
rng(1);
[idx,C,SSE] = kmeans(VD, numClusters); %ricavo idx e C
% 2 = numero di cluster
% C = matrice che contiene la locazione del centroide
% idx = vettore che contiene degli indici (1 o 2): ogni indice e' associato
% ad una canzone e ne indica il cluster di appartenenza
%(1 = cluster canzoni positive; 2 = cluster canzoni negative)

VD = [VD idx]; % aggiungo colonna dei cluster alla matrice
createClusterImage(VD, C);
dataset = [dataset idx];

%disp("cluster = "+C);

for i=1:size(C)
    SSE1 = computeSSE(dataset, C, VD, i);
   % disp("cluster = "+C);
    disp("SSE1 = "+SSE1);
end

disp("SSE2 = "+SSE);
end

function SSE = computeSSE(dataset, C, VD, clusterIndex)
    % Estrai i punti appartenenti al cluster
    idx = VD(:,3) == clusterIndex;
    clusterPoints = VD(idx, :);

    % Calcola le distanze euclidee tra i punti del cluster e il centroide
    distances = pdist2(clusterPoints(:, 1:2), C(clusterIndex, :));

    % Calcola la somma dei quadrati delle distanze
    SSE = sum(distances.^2);
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