global numRigheDataset;
global numClusters;
global indexCanzone;

dataset = readmatrix('dataset.csv'); % carico il dataset nella matrice dataset
datasetStringFormat = readtable('dataset.csv'); % contiene i dati non numerici del dataset
%dataset = readtable('dataset.csv');
%dataset(1,:) = []; % rimuove la prima riga (intestazione) dal dataset
[numRigheDataset, numColonneDataset] = size(dataset);
numClusters = 2;
indexCanzone = 1;
numGeneri = 3;
%dataset = createCluster(dataset);

emotionIndex = getUserEmotion(); % prende in input l'emozione dell'utente in formato numerico
%[emotion, cluster, genres] = associateParamsToEmotion(emotionIndex);
dataset = predictRatings(dataset); % metodo che prevede un rating per ogni canzone del dataset sulla base dei punteggi che ha assegnato l'utente nelle esecuzioni precedenti
%[dataset,songs] = reccomendSongs(dataset, cluster, genres, emotion);
dataset = generatePlaylist(dataset, emotionIndex);
dataset = displayAndRateSongs(dataset, datasetStringFormat);
updateDataset(dataset);

%% Fase di input dell'emozione dell'utente
function emotion = getUserEmotion() % prende in input l'emozione dell'utente
disp("EMOTION INPUT PHASE");
disp("1 = happiness;");
disp("2 = sadness");
disp("3 = hanger");
disp("4 = excitement");
disp("5 = calmness");
emotion = input("Choose an emotion between 1 and 5: "); % prendo in input l'emozione dell'utente in forma numerica

while emotion < 1 || emotion > 5 % controllo che l'utente inserisca un input valido
    emotion = input("Invalid input. Please, choose an emotion between 1 and 5: ");
end
end

%% Metodo che predice ad assegna un rating ad ogni canzone, sulla base dei rating assegnati in passato dall'utente + grado popolarità canzone
function dataset = predictRatings(dataset)
global numRigheDataset;
popolarita = zeros(1,numRigheDataset);
ratings = zeros(1,numRigheDataset);

for i=1:numRigheDataset
    popolarita(i) = dataset(i,5); % popolarita della canzone
    ratings(i) = dataset(i,10); % valutazione preliminare che aveva dato l'utente al brano mediante lo script ratingsystem
end

mdl = fitlm(ratings.', popolarita);
predictedRatings = predict(mdl, ratings.');
dataset = [dataset predictedRatings]; % aggiorno il dataset con la nuova informazione predictedRatings
dataset = sortrows(dataset,11,'descend'); % ordino la lista di canzoni sulla base del rating previsto, dal maggiore al minore
end

%% Mostra a schermo le canzoni da consigliare all'utente e che l'utente dovrà valutare
function dataset = displayAndRateSongs(dataset, datasetStringFormat)
global numRigheDataset;
%global indexCanzone;
conta = 0;
top10 = 10;

for i=1:numRigheDataset
    if (dataset(i,12)==1 && conta ~= top10) % controllo se la colonna 9 del dataset ha il cluster numero 3 al suo interno
        disp(string(datasetStringFormat(i,2).(1)) + " - " + string(datasetStringFormat(i,3).(1))); % stampa l'i-esimo titolo + stampa l'i-esimo autore
        userRating = input("Rate the song choosing a number between 0 and 100: "); % prendo in input l'emozione dell'utente in forma numerica
        while userRating < 0 || userRating > 100 % controllo che l'utente inserisca un input valido
            userRating = input("Invalid input. Please, rate the song choosing a number between 0 and 100: ");
        end
        dataset(i, 10) = userRating;
        conta = conta + 1;
    end
end

end

function dataset = generatePlaylist(dataset, emotionIndex)
global numRigheDataset;
	% emotion e' in formato intero
	sogliaDanceability = 0.5;
	addToPlayList = 1;
    
	switch(emotionIndex)
		case 1 % happiness
			for i=1:numRigheDataset
				if (((dataset(i,9)==3) || (dataset(i,9)==3)) && dataset(i,6) >= sogliaDanceability) % controllo se la colonna 9 del dataset ha il cluster numero 3 al suo interno
					dataset(i,12) = addToPlayList; % aggiorno il dataset con la nuova informazione: 1 = la canzone va fara' parte del sottoinsieme di possibili brani da raccomandare all'utente
				end
			end
		case 2 % sadness
			%cluster = 2;
			for i=1:numRigheDataset
				if ((dataset(i,9)==4 || dataset(i,9)==5) && dataset(i,6) < sogliaDanceability) % controllo se la Danceability e' < o > di sogliaDanceability)
					dataset(i,12) = addToPlayList; % aggiorno il dataset con la nuova informazione: 1 = la canzone va fara' parte del sottoinsieme di possibili brani da raccomandare all'utente
				end
			end
		case 3 % hanger
			for i=1:numRigheDataset
				if ((dataset(i,9)==1 && dataset(i,6) < sogliaDanceability) || ((dataset(i,9)==4 || dataset(i,9)==5)&& dataset(i,6) >= sogliaDanceability))
					dataset(i,12) = addToPlayList; % aggiorno il dataset con la nuova informazione: 1 = la canzone va fara' parte del sottoinsieme di possibili brani da raccomandare all'utente
				end
			end
		case 4 % excitement
			for i=1:numRigheDataset
				if (dataset(i,9)==2 && dataset(i,6) >= sogliaDanceability)
					dataset(i,12) = addToPlayList; % aggiorno il dataset con la nuova informazione: 1 = la canzone va fara' parte del sottoinsieme di possibili brani da raccomandare all'utente
				end
			end
		case 5 % calmness
			for i=1:numRigheDataset
				if ((dataset(i,9)==2 || dataset(i,9)==3) && dataset(i,6) < sogliaDanceability)
					dataset(i,12) = addToPlayList; % aggiorno il dataset con la nuova informazione: 1 = la canzone va fara' parte del sottoinsieme di possibili brani da raccomandare all'utente
				end
			end
		otherwise
			disp("Invalid input. ");
     end
end

%% updateDataset
function updateDataset(dataset)

dataset2 = readtable('dataset.csv');
dataset2{:,10} = string(dataset(:,10)); %user ratings aggiornati
writetable(dataset2, 'dataset.csv', 'Delimiter', ';'); % Utilizza il punto e virgola come separatore
end