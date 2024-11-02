% Carica il dataset
dataset = readtable('dataset.csv');

% Applica la pulizia completa
dataset_pulito = cleanDataset(dataset);

% Salva il dataset pulito
writetable(dataset_pulito, 'dataset.csv', 'Delimiter', ';'); % Utilizza il punto e virgola come separatore

function dataset_pulito = cleanDataset(dataset)
% cleanDataset Pulisce un dataset eseguendo diverse operazioni di pulizia.

% Rimuovi le righe duplicate
[~, ia, ~] = unique(dataset, 'rows');
dataset = dataset(ia, :);

% Rimuovi le righe con valori mancanti o "[]" nelle colonne numeriche
colonne_numeriche = {'Popularity', 'Danceability', 'Energy', 'Valence'};
righe_da_rimuovere = any(isnan(dataset{:, colonne_numeriche}), 2);
dataset = dataset(~righe_da_rimuovere, :);

% Rimuovi le righe con "[]" nella colonna "Genere"
dataset_pulito = rimuovi_righe_genere_vuoto(dataset);
end

function dataset_pulito = rimuovi_righe_genere_vuoto(dataset)
% RIMUOVI_RIGHE_GENERE_VUOTO Rimuove le righe dove la colonna "Genere" contiene "[]".

% Trova gli indici delle righe dove "Genere" contiene "[]"
indici_vuoti = strcmp(dataset.Genre, '[]');

% Rimuovi le righe con "Genere" contenente "[]"
dataset_pulito = dataset(~indici_vuoti, :);
end

