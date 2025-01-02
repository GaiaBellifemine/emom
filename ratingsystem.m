%% Rating System
% L'utente dovra' valutare, in fase preliminare, alcune canzoni che il
% sistema gli proporra'.
% Il rating dell'utente verra' aggiunto al dataset e verra' in seguito
% utilizzato come feature per raccomandare canzoni all'utente.

dataset = readmatrix('dataset.csv'); % carico il dataset nella matrice dataset
datasetStringFormat = readtable('dataset.csv'); % contiene i dati non numerici del dataset
[numRigheDataset, numColonneDataset] = size(dataset);

for i=1:20
    indexCanzone = randi([1 numRigheDataset], 1, 1);
    
    for j=1:numRigheDataset
        %visibilita = rand(1);
        if dataset(j,1) == indexCanzone % ho trovato la canzone di songs nel dataset
            disp(string(datasetStringFormat(j,2).(1)) + " - " + string(datasetStringFormat(j,3).(1))); % stampa l'i-esimo titolo + stampa l'i-esimo autore
            userRating = input("Rate the song choosing a number between 0 and 100: "); % prendo in input l'emozione dell'utente in forma numerica
            
            while userRating < 0 || userRating > 100 % controllo che l'utente inserisca un input valido
                userRating = input("Invalid input. Please, rate the song choosing a number between 0 and 100: ");
            end
            dataset(j, 10) = userRating;
        end        
    end
end

updateDataset(dataset);

function updateDataset(dataset)
dataset2 = readtable('dataset.csv');
dataset2{:,10} = string(dataset(:,10)); %user ratings aggiornati
writetable(dataset2, 'dataset.csv', 'Delimiter', ';'); % Utilizza il punto e virgola come separatore
end