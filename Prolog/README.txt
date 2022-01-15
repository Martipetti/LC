Parsing di stringhe URI

Progetto svolto da:
- Martino Pettinari 866496
- Daniela Merlo 866380

Approccio al lavoro e composizione del programma:
Per sviluppare il parser di stringhe URI, in prolog, siamo partiti gestendo la stringa in input come una lista di caratteri. Il programma è formato da vari 
metodi per la gestione delle componenti dell’URI. Ogni metodo verifica che la lista di caratteri data come argomento, rispetti la sintassi della componente 
dell’URI che sta gestendo; trovando un risultato positivo, trasforma la lista di caratteri in una stringa per poi istanziare la corrispettiva componente dell’URI.
Come da specifiche abbiamo distinto 3 casi principali:
-	URI con authority 
-	URI senza authority
-	Sintassi speciali
In particolare in tutti i casi abbiamo considerato parte obbligatoria dell’URI: Scheme:
Solo nella sintassi speciale ‘zos’ il path risulta obbligatorio 
Abbiamo tenuto come porta di default ‘80’ anche per le sintassi speciali 
In tutti i casi, come da specifiche, in presenza della parte di URI che comprende: Path, Query e Fragment è obbligatorio che prima ci sia il carattere ‘/ ‘ 

Esempi di stringhe accettate e non accettate:
•	“http:path”   false
•	“http:/?query  true
•	“http:/#fragment”  true
•	“zos://unimib.it”  false 

Gestione errori:
Nei metodi sono sempre presenti controlli riguardo la possibile presenza di caratteri errati o sequenze non corrette di caratteri e, in caso di errore, 
il programma stampa a video false. 


