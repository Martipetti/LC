(defstruct uri scheme userinfo host port path query fragment)

(defun uri-parse (stringa)
  (let ((lista (coerce stringa 'list)))
  (if (null stringa) (error "stringa vuota")
    (and (set-scheme lista)
    (make-uri :scheme scheme-def)))))
        
(defun set-scheme (lista)
  (let ((scheme (list-id lista #\:))
        (rest (id-list lista #\:)))
    (if (not (string-id scheme)) (error "URI non valida")
      (setq scheme-def (coerce scheme 'string)))))

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
(defun query-id (query)
  (if (eq (car scheme) #\#) nil 
         (cdr scheme)
         ))    
