(defstruct uri scheme userinfo host port path query fragment)

(defun uri-parse (stringa)
  (let ((lista (coerce stringa 'list)))
  (if (null stringa) (error "stringa vuota")
    (and (set-scheme lista)
    (make-uri :scheme scheme-def
              :userinfo userinfo-def
              :host host-def
              :port port-def
              :path path-def
              :query query-def
              :fragment fragment-def)))))

;metodo di gestione dello scheme (controllare)       
(defun set-scheme (lista)
  (if (null (check #\: lista)) (error "URI non valida")
    (if (null (identificatore-id (list-id lista #\:))) (error "scheme non valido")
      (let ((scheme (list-id lista #\:))
            (rest (id-list lista #\:)))
        (cond ((equal scheme '(#\m #\a #\i #\l #\t #\o))
               (and (set-mailto rest) 
                    (setq scheme-def (coerce scheme 'string))))
              (t (and (setq scheme-def (coerce scheme 'string))
                      (autorithy rest))))))))
;da inserire metodi con sintassi speciali

;gestione mailto
(defun set-mailto (lista)
  (and (if (check #\@ lista)
           (let ((userinfo (list-id lista #\@))
                 (host (id-list lista #\@)))
             (if (or (null userinfo) 
                     (null host)
                     (not (identificatore-id userinfo))
                     (not (identificatore-host host)))
                 (error "sintassi mailto non valida")
               (and (setq userinfo-def (coerce userinfo 'string))
                    (setq host-def (coerce host 'string)))))
         (if (null lista)
             (and (defparameter userinfo-def nil)
                  (defparameter host-def nil))
           (if (not (identificatore-id lista))
               (error "sistassi mailto non valida")
             (and (setq userinfo-def (coerce lista 'string))
                  (defparameter host-def nil)))))
       (and (defparameter port-def nil)
            (defparameter path-def nil)
            (defparameter query-def nil)
            (defparameter fragment-def nil))))

;metodo di gestione authority 
(defun autorithy (lista)
  (let ((id1 (car lista))
        (id2 (car (cdr lista)))
        (rest (cdr (cdr lista))))
      (if (and (equal id1 #\/) (equal id2 #\/)) 
        (set-userinfo rest)
        (if (check #\/ lista) 
         (and (defparameter userinfo-def nil) 
             (defparameter host-def nil)
             (setq port-def "80") 
             (set-path (id-list lista #\/)))
        (if (or (check #\? lista) (check #\# lista))
            (error "URI non valida")
         (and (defparameter userinfo-def nil) 
             (defparameter host-def nil)
             (setq port-def "80") 
             (defparameter path-def nil)
             (defparameter query-def nil)
             (defparameter fragment-def nil)))))))

;metodo per gestione di path, query, id e fragment
(defun set-userinfo (lista)
(if (null (check #\@ lista)) 
    (and (defparameter userinfo-def nil) 
         (set-host lista))
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
                     (setq port-def "80") (set-path (id-list lista #\/)))) 
            (if (identificatore-host lista) 
                (and (setq host-def (coerce lista 'string))
                 (setq port-def "80")
                 (defparameter path-def nil)
                 (defparameter query-def nil)
                 (defparameter fragment-def nil))
                 (error "host non valida"))))))

;gestione port
(defun set-port (lista)     
  (if (check #\/ lista) 
    (if (null (identificatore-port (list-id lista #\/))) (error "port non valida")
        (and (setq port-def (coerce (list-id lista #\/) 'string))
             (set-path (id-list lista #\/)))) 
      (if (null (identificatore-port lista)) (error "port non valida")
        (and (setq port-def (coerce lista 'string))
           (defparameter path-def nil)
           (defparameter query-def nil)
           (defparameter fragment-def nil)))))


;gestione path
(defun set-path (lista)
  (if (null lista) (defparameter path-def nil) 
    (if (check #\? lista)
        (if (identificatore-id (list-id lista #\?))
          (if (null (list-id lista #\?)) 
             (and (defparameter path-def nil) 
                  (set-query (id-list lista #\?)))      
             (and (setq path-def (coerce (list-id lista #\?) 'string)) 
                  (set-query (id-list lista #\?))))
          (error "path non valida"))
    (if (check #\# lista)
        (if (identificatore-id (list-id lista #\#)) 
           (if (null (list-id lista #\#)) 
               (and (defparameter path-def nil) 
               (set-fragment (id-list lista #\#))) 
        (and (setq path-def (coerce (list-id lista #\#) 'string)) 
             (defparameter query-def nil) 
             (set-fragment (id-list lista #\#))))
          (error "path non valida"))
      (if (identificatore-id lista)
          (and (setq path-def (coerce lista 'string)) 
               (defparameter query-def nil) 
               (defparameter fragment-def nil))
        (error "path non valida"))))))

;gestione query
(defun set-query (lista)
  (if (null lista) (error "query non valida") 
      (if (check #\# lista) 
        (if (query-id (list-id lista #\#)) 
        (and (setq query-def (coerce (list-id lista #\#) 'string)) 
             (set-fragment (id-list lista #\#)))
        (error "query non valida"))
       (if (query-id lista) (and (setq query-def (coerce lista 'string)) 
                            (defparameter fragment-def nil))
           (error "query non valida")))))

;gestione fragment
(defun set-fragment (lista)
  (if (null lista) (error "fragment non valido")
      (setq fragment-def (coerce lista 'string))))

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
(defun query-id (lista)
  (cond ((null lista) T)
        ((eq (car lista) #\#) nil)
        (t (query-id (cdr lista)))))  


