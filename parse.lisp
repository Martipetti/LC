(defstruct uri scheme userinfo host port path query fragment)

(defun uri-parse (stringa)
  (let ((lista (coerce stringa 'list)))
  (if (null stringa) (error "stringa vuota")
    (and (set-scheme lista)
    (make-uri :scheme scheme-def
              :userinfo userinfo-def
              :host host-def
              :port port-def)))))

;metodo di gestione dello scheme (controllare)       
(defun set-scheme (lista)
  (if (null (check #\: lista)) (error "URI non valida")
   (if (null (identificatore-id (list-id lista #\:))) (error "scheme non valido")
      (let ((scheme (list-id lista #\:))
            (rest (id-list lista #\:)))
          (and (setq scheme-def (coerce scheme 'string))
               (autorithy rest))))))
;da inserire metodi con sintassi speciali

;metodo di gestione authority 
(defun autorithy (lista)
  (let ((id1 (car lista))
        (id2 (car (cdr lista)))
        (rest (cdr (cdr lista))))
      (if (and (equal id1 #\/) (equal id2 #\/)) 
        (set-userinfo rest)
        (and (defparameter userinfo-def nil) 
             (defparameter host-def nil) 
             (set-rest lista)))))

;metodo per gestione di path, query, id e fragment
(defun set-userinfo (lista)
(if (null (check #\@ lista)) (and (defparameter userinfo-def nil) (set-host lista))
 (if (null (identificatore-id (list-id lista #\@))) (error "userinfo non valida")
   (and (setq userinfo-def (coerce (list-id lista #\@) 'string)) 
         (set-host (id-list lista #\@))))))

;gestione host
(defun set-host (lista)
   (if (null lista) (error "host non valida")
    (if (check #\: lista)
        (if (null (identificatore-host (list-id lista #\:))) 
            (error "host non valida")
          (and (setq host-def (coerce (list-id lista #\:) 'string))
             (set-port (id-list lista #\:))))
          (if (check #\/ lista)
              (if (null (identificatore-host (list-id lista #\/))) 
                  (error "host non valida")
                (and (setq host-def (coerce (list-id lista #\/) 'string))
                   (setq port-def "80")))
            (and (setq host-def (coerce lista 'string))
                 (setq port-def "80")
                 (defparameter path-def nil)
                 (defparameter query-def nil)
                 (defparameter fragment-def nil))))))

;gestione port
(defun set-port (lista)     
  (if (check #\/ lista) 
    (if (null (identificatore-port (list-id lista #\/))) (error "port non valida")
        (and (setq port-def (coerce (list-id lista #\/) 'string))
             (set-rest (id-list lista #\/))))
      (if (null (identificatore-port lista)) (error "port non valida")
        (and (setq port-def (coerce lista 'string))
           (defparameter path-def nil)
           (defparameter query-def nil)
           (defparameter fragment-def nil)))))

;gestione 
(defun set-rest (lista)
  (let ((id (car lista))
        (rest (cdr lista)))
    (if (and (equal id #\/) (not (null rest)))
        (set-path rest)
      (and (defparameter path-def nil)
           (defparameter query-def nil)
           (defparameter fragment-def nil)))))

;gestione path
(defun set-path (lista)
  (if (or (null lista) 
          (null (list-id lista #\?))
          (null (list-id lista #\#)))
       (and (defparameter path-def nil)
         (set-query lista))
    (if (check #\? lista)
        (if (identificatore-id (list-id lista #\?))
            (setq path-def (coerce (list-id lista #\?) 'string))
          (error "path non valida"))
      (if (identificatore-id lista)
          (setq path-def (coerce lista 'string))
        (error "path non valida")))))

;ritorna la lista da un id in poi
(defun id-list (lista id)
 (if (null lista) nil
    (if (equal (car lista) id) (cdr lista)
      (id-list (cdr lista) id))))

;ritorna la lista dall'inizio fino ad un certo id
(defun list-id (lista id)
  (if (null lista) nil
    (if (eq (car lista) id) '()
      (cons (car lista) (list-id (cdr lista) id)))))

;metodo di controllo del member
(defun check (id lista)
  (if (null (member id lista)) 
      nil
    T))

;controllo identificatore  
(defun identificatore-id (lista)
  (cond ((null lista) T)
        ((or(eq (car lista) #\/)
         (eq (car lista) #\?)
         (eq (car lista) #\#)
         (eq (car lista) #\@)
         (eq (car lista) #\:)) nil)
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

;controllo identificatore port
(defun identificatore-port (lista)
  (cond ((null lista) T)
        ((null (digit-char-p (car lista))) nil)
        (t (identificatore-port (cdr lista))))) 
;controllo query         
(defun query-id (query)
  (if (eq (car query) #\#) nil 
         (query-id (cdr query))))  

