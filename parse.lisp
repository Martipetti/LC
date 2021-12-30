(defstruct uri scheme userinfo host port path query fragment)

(defun uri-parse (stringa)
  (let ((lista (coerce stringa 'list)))
  (if (null stringa) (error "stringa vuota")
    (and (set-scheme lista)
    (make-uri :scheme scheme-def
              :host host-1
              :path path-1     ;campi aggiuntivi uri
              :query query-1
              :fragment fragment-1)))))
;metodo di gestione dello scheme (controllare)       
(defun set-scheme (lista)
  (let ((scheme (list-id lista #\:))
        (rest (id-list lista #\:)))
    (if (not (string-id scheme)) (error "URI non valida")
      (and (setq scheme-def (coerce scheme 'string))
        (if(and (eq (car rest) #\/)
                (eq (car (cdr rest)) #\/))
                (authority rest)
                (coda rest)       
                       )))))

;ritorna la lista da un id in poi
(defun id-list (lista id)
 (if (null lista) nil
   (if (equal (car lista) id) (cdr lista)
     (id-list (cdr lista) id))))
;ritorna la lista dall'inizio fino ad un certo id
(defun list-id (lista id)
  (if (null lista) '()
    (list-to-id (rev lista) id)))
(defun list-to-id (lista id)
  (if (null lista) nil
    (if (equal (car lista) id) (rev (cdr lista))
      (list-to-id (cdr lista) id))))
;funzione di reverse
(defun rev (l) 
  (cond ((null l) '())
        (t (append (rev (cdr l)) (list (car l)))))) 

;controllo dello scheme
(defun string-id (scheme)
   (and (not (null scheme)) (identificatore-id scheme))
)
(defun identificatore-id (scheme)
  (if (or(eq (car scheme) #\/)
         (eq (car scheme) #\?)
         (eq (car scheme) #\#)
         (eq (car scheme) #\@)
         (eq (car scheme) #\:)) nil 
         (cdr scheme)
         ))    
;controllo query         
(defun query-id (query)
  (if (eq (car scheme) #\#) nil 
         (cdr scheme)
         ))    
;authority (solo prova)
(defun authority (aut)
(if (null aut) (error "aut non valida")
      (setq host-1 (coerce aut 'string))))

;metodo per gestire la query (probabilmente da rivedere)
(defun query (q)
(if (eq (car q) #\?) 
      (let ((query1 (list-id lista #\?))
            (r (id-list lista #\?)))
           (if (not (query-id path)) (error "URI non valida")
           (and (setq query-1 (coerce query1 'string))
             (if (eq (car r) #\#)
                (fragment r)    
                       ))))))
;metodo per gestire il fragment (forse da rivedere)
(defun fragment (f)
(if (eq (car f) #\#) 
      (let ((fragment1 (list-id lista #\#))
       (setq fragment-1 (coerce fragment1 'string))))))
                                    
;metodo per gestire path,query e fragment semplificato 
(defun coda (rest)
(if (eq (car rest) #\/)   ;al posto di if si potrebbe usare anche when 
      (let ((path (list-id lista #\/))
            (r (id-list lista #\/)))
           (if (not (identificatore-id path)) (error "URI non valida")
           (and (setq path-1 (coerce path 'string))
             (if (eq (car r) #\?)
                (query r)    
                       ))))))
      
