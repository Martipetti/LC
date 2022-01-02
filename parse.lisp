(defstruct uri scheme userinfo host port path query fragment)

(defun uri-parse (stringa)
  (let ((lista (coerce stringa 'list)))
  (if (null stringa) (error "stringa vuota")
    (and (set-scheme lista)
    (make-uri :scheme scheme-def
              :userinfo userinfo-def
              :host host-def)))))

;metodo di gestione dello scheme (controllare)       
(defun set-scheme (lista)
  (if (null (check #\: lista)) (error "URI non valida")
      (let ((scheme (list-id lista #\:))
            (rest (id-list lista #\:)))
          (and (setq scheme-def (coerce scheme 'string))
               (autorithy rest)))))

;metodo di gestione authority 
(defun autorithy (lista)
  (let ((id1 (car lista))          ;prendo primo slash
        (id2 (car (cdr lista)))    ;prendo secondo slash
        (rest (cdr (cdr lista))))  ;resto
      (if (and (equal id1 #\/) (equal id2 #\/)) 
        (set-userinfo rest) 
        (and (defvar userinfo-def nil) 
             (defvar host-def '()) 
             (set-rest lista)))))

;metodo per gestione di path, query, id e fragment
(defun set-userinfo (lista)
 (if (null (identificatore-id (list-id lista #\@))) (error "userinfo non valida")
  (if (null (check #\@ lista)) (and (defvar userinfo-def nil) (set-host lista))
    (and (setq userinfo-def (coerce (list-id lista #\@) 'string)) 
         (set-host (id-list lista #\@))))))

;gestione host
(defun set-host (lista)
   (if (or (null lista) (null (identificatore-host lista))) (error "host non valida")
    (if (check #\: lista)
        (setq host-def (coerce (list-id #\:) 'string))
      (if (check #\/ lista)
        (setq host-def (coerce (list-id #\/) 'string))
        (setq host-def (coerce lista 'string))))))

;gestione 
(defun set-rest (lista)
  (setq prova (coerce lista 'string)))

;ritorna la lista da un id in poi
(defun id-list (lista id)
 (if (null lista) nil
    (if (equal (car lista) id) (cdr lista)
      (id-list (cdr lista) id))))

;ritorna la lista dall'inizio fino ad un certo id
(defun list-id (lista id)
 ; (if (not (listp lista)) 
     ; (if (equal lista id) '()
      ;  (error "URI non valida"))
    (if (eq (car lista) id) '()
      (cons (car lista) (list-id (cdr lista) id))))


;metodo di controllo del member
(defun check (id lista)
  (member id lista))
;controllo identificatore  
(defun identificatore-id (lista)
  (cond ((null lista) T)
        ((or(eq (car lista) #\/)
         (eq (car lista) #\?)
         (eq (car lista) #\#)
         (eq (car lista) #\@)
         (eq (car lista) #\:)
         ) nil)
         (T (identificatore-id (cdr lista)))))   
;controllo identificatore host
(defun identificatore-host (lista)
  (cond ((null lista) T)
        ((or(eq (car lista) #\/)
         (eq (car lista) #\?)
         (eq (car lista) #\#)
         (eq (car lista) #\@)
         (eq (car lista) #\.)
         (eq (car lista) #\:)) nil)
         (T (identificatore-id (cdr lista)))))        
;controllo query         
(defun query-id (query)
  (if (eq (car query) #\#) nil 
         (query-id (cdr query))))       
