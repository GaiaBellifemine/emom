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

for i=1:numRigheDataset
    VD(i,1) = dataset(i,8); % carico la valence nella matrice VD
    VD(i,2) = dataset(i,7); % carico l'energy nella matrice VD
end

rng(1);
[C,U]=fcm(VD,numClusters);
[~,I]=max(U);
I=I';
VD =[VD I];
createClusterImage(VD, C);
dataset = [dataset I];

for i=1:size(C)
    SSE = computeSSE(dataset, C, U, VD, i);
   % disp("cluster = "+C);
    disp("SSE = "+SSE);
end

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

function SSE = computeSSE(dataset, C, U, VD, clusterIndex)
    % Estrai i punti appartenenti al cluster
    idx = VD(:,3) == clusterIndex;
    clusterPoints = VD(idx, :);

    % Calcola le distanze euclidee tra i punti del cluster e il centroide
    distances = pdist2(clusterPoints(:, 1:2), C(clusterIndex, :));

    % Calcola la somma dei quadrati delle distanze
    SSE = sum(distances.^2);
end

%{
function SSE = computeSSE(dataset, C, U, VD, clusterIndex)
distanzaCVD = 0;
sommeDistanzeCVD = 0;
    
for i=1:size(VD)
    if VD(i,3) == clusterIndex
        distanzaCVD = (C(clusterIndex,1) - VD(i,1))^2 - (C(clusterIndex,2)- VD(i,2))^2;
        sommeDistanzeCVD = sommeDistanzeCVD + distanzaCVD;
        distanzaCVD = 0;
    end   
end

SSE = sommeDistanzeCVD;

end
%}

function updateDataset(dataset)

dataset2 = readtable('dataset.csv');
dataset2{:,9} = string(dataset(:,11)); %user ratings aggiornati
writetable(dataset2, 'dataset.csv', 'Delimiter', ';'); % Utilizza il punto e virgola come separatore
end