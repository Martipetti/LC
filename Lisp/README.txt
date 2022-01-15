Parsing di stringhe URI

Progetto svolto da:
- Martino Pettinari 866496
- Daniela Merlo 866380

Approccio al lavoro:
Per sviluppare il parser di stringhe URI, in lisp, sono stati utilizzati il metodo coerce, per la trasformazione della stringa, passata in input, ad una lista di caratteri e un approccio ideale ad un automa a stati finiti (senza la creazione di stati o funzioni di transizioni ma, in base al carattere divisore, una chiamata al corretto metodo). L’approccio è stato quello di lavorare sulla stringa analizzando in modo sequenziale, tramite metodi ricorsivi, le componendi di essa. 

Composizione del programma:
Il programma utilizza come struttura un defstruct, le quali componenti vengono stanziate nel corso del parsing tramite variabili globali. 
Il programma gestisce ogni componente della stringa uri in modo separato, ad esempio, comincia con il riconoscimento dello scheme e dopo aver riconosciuto il carattere ‘:’ controlla quali caratteri ci sono in successione nella lista e in base a ciò passa la restante parte di lista (da ‘:’ in poi) all’adeguato metodo, per il proseguire dell’analisi.

Gestione errori:
Nei metodi sono sempre presenti controlli riguardo la possibile presenza di caratteri errati o sequenze non corrette di caratteri e, in caso di errore, il programma si ferma stampando a schermo un messaggio di errore specifico per ogni caso.

