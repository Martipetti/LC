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
  (if (null (check #\: lista)) 
      (error "URI non valida")
    (if (null (identificatore-id (list-id lista #\:))) 
        (error "scheme non valido")
      (let ((scheme (list-id lista #\:))
            (rest (id-list lista #\:)))
        (cond ((equalp scheme '(#\m #\a #\i #\l #\t #\o))
               (and (set-mailto rest) 
                    (setq scheme-def (coerce scheme 'string))))
              ((equalp scheme '(#\n #\e #\w #\s))
               (and (set-news rest) 
                    (setq scheme-def (coerce scheme 'string))))
              ((or (equalp scheme '(#\t #\e #\l)) 
                   (equal scheme '(#\f #\a #\x)))
               (and (set-tel rest) 
                    (setq scheme-def (coerce scheme 'string))))
              ((equalp scheme '(#\z #\o #\s))
               (and (set-zos rest) 
                    (setq scheme-def (coerce scheme 'string))))
              (t (and (setq scheme-def (coerce scheme 'string))
                       (autorithy rest))))))))


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
               (aut)
           (if (not (identificatore-id lista))
               (error "sistassi mailto non valida")
             (and (setq userinfo-def (coerce lista 'string))
                  (defparameter host-def nil)))))
       (coda)))

;gestione news
(defun set-news (lista)
  (if (null lista)
      (and  (aut)
            (coda))
        (if (identificatore-host lista)
            (and (setq host-def (coerce lista 'string))
                 (defparameter userinfo-def nil)
                 (coda))
            (error "sistassi news non valida"))))

;gestione tel e fax
(defun set-tel (lista)
  (if (null lista)
      (and  (aut) 
            (coda))
        (if (identificatore-id lista)
            (and (setq userinfo-def (coerce lista 'string))
                 (defparameter host-def nil)
                 (coda))
            (error "sistassi tel e fax non valida"))))                      

;metodo di gestione authority 
(defun autorithy (lista)
  (let ((id1 (car lista))
        (id2 (car (cdr lista)))
        (rest (cdr (cdr lista))))
      (if (and (equal id1 #\/) (equal id2 #\/)) 
        (set-userinfo rest)
        (if (check #\/ lista) 
         (and (aut)
             (setq port-def "80") 
             (set-path (id-list lista #\/)))
        (if (or (check #\? lista) (check #\# lista))
            (error "URI non valida")
         (and (aut)
             (coda)))))))

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
         (if (and (= (lung (list-id lista #\:)) 15)
                  (ip (list-id lista #\:)))
             (and (setq host-def (coerce (list-id lista #\:) 'string))
                  (set-port (id-list lista #\:)))
           (if (null (identificatore-host (list-id lista #\:))) 
               (error "host non valida")
             (and (setq host-def (coerce (list-id lista #\:) 'string))
                  (set-port (id-list lista #\:)))))
       (if (check #\/ lista)
           (if (and (= (lung (list-id lista #\/)) 15)
                    (ip (list-id lista #\/)))
               (and (setq host-def (coerce (list-id lista #\/) 'string))
                    (setq port-def "80") 
                    (set-path (id-list lista #\/)))
             (if (null (identificatore-host (list-id lista #\/))) 
                 (error "host non valida")
               (and (setq host-def (coerce (list-id lista #\/) 'string))
                    (setq port-def "80") 
                    (set-path (id-list lista #\/))))) 
             (if (identificatore-host lista) 
                 (if (and (= (lung lista) 15)
                          (ip lista))
                          (and (setq host-def (coerce lista 'string)) (coda))
                   (and (setq host-def (coerce lista 'string)) (coda)))
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

;controllo id44
(defun id44 (lista)
  (cond ((null lista) T)
        ((or (not (alphanumericp (car lista))) (eq (car lista) #\.)) nil)
        ((> (lung lista) 44) nil)
        (t (id44 (cdr lista)))))

;controllo id8
(defun id8 (lista)
  (cond ((null lista) T)
        ((not (alphanumericp (car lista))) nil)
        ((> (lung lista) 8) nil)
        (t (id8 (cdr lista)))))

;gestione zos     
(defun set-zos (lista)
  (if (null lista) 
      (error "sistassi zos non valida")
      ;ramo else mancante
     ))  
                               
;metodo path-zos  
(defun path-zos (lista)
  (if (null lista) (error "sistassi zos non valida")
    (if (check #\( lista)
        (let ((pa #\()
              (pc #\))) 
           (if (id44 (list-id lista pa))
            (and (append (list-id lista pa) '(#\())
              (if (check pc lista)
                  (if (id8 (remove #\) (id-list lista pa)))
                      (and (append (append (list-id lista pa) '(#\()) (id-list lista pa))
                           (setq path-def (coerce(append (append (list-id lista pa) '(#\()) (id-list lista pa)) 'string))(write path-def))
                    (error "sistassi id8 non valida"))
                (error "sistassi zos non valida")))
          (error "sistassi id442 non valida")))
      (if (id44 lista)
          (setq path-def (coerce lista 'string))
        (error "sintassi id44 non valida")))))

; lunghezza lista
(defun lung (lista)
  (cond ((null lista) 0)
        (t (+ 1 (lung (cdr lista))))))

;controllo che sia un ip
(defun ip (lista)
  (and (ip-cont lista 1)
       (ip-num lista)))

;controllo correttezza ordine elementi in ip
(defun ip-cont (lista cont)
  (cond ((and (< cont 4) 
              (digit-char-p (car lista))) 
         (ip-cont (cdr lista) (+ cont 1)))
        ((and (= cont 4) (equal (car lista) #\.))
         (ip-cont (cdr lista) 1))
        ((and (null lista) (or (= cont 1) (= cont 4))) 
         T)))

;controllo valore numeri ip
(defun ip-num (lista)
  (let ((n1 (to-num (first lista)))
        (n2 (to-num (second lista)))
        (n3 (to-num (third lista)))
        (p (fourth lista))
        (rest (cdr (cdr (cdr (cdr lista))))))
    (cond ((null lista) T)
          ((<= (somma n1 n2 n3) 255) (ip-num rest))
          (t (error "ip non valido")))))

;somma
(defun somma (n1 n2 n3)
  (+ (* n1 100) (* n2 10) n3))

;conversione
(defun to-num (n)
 (cond ((equal n #\0) 0)
       ((equal n #\1) 1)
       ((equal n #\2) 2)
       ((equal n #\3) 3)
       ((equal n #\4) 4)
       ((equal n #\5) 5)
       ((equal n #\6) 6)
       ((equal n #\7) 7)
       ((equal n #\8) 8)
       ((equal n #\9) 9)
       (t nil)))
     
(defun coda ()
 (and (setq port-def "80")
      (defparameter path-def nil)
      (defparameter query-def nil)
     (defparameter fragment-def nil)))

(defun aut ()
 (and (defparameter userinfo-def nil)
      (defparameter host-def nil)))    
                     

