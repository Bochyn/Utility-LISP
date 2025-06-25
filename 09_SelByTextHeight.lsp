;;; SelByTextHeight.lsp

(defun c:SelByTextHeight (/ ss ent entData txtHeight i)
  (setvar "CMDECHO" 0)
  
  ;; Komunikat startowy
  (princ "\nWybierz tekst wzorcowy: ")
  
  ;; Pobierz pojedynczy obiekt tekstowy jako wzorzec
  (setq ent (car (entsel)))
  
  ;; Sprawdź czy wybrany obiekt istnieje
  (if (null ent)
    (progn
      (princ "\nNie wybrano żadnego obiektu.")
      (princ)
      (exit)
    )
  )
  
  ;; Pobierz dane obiektu
  (setq entData (entget ent))
  
  ;; Sprawdź czy to jest tekst
  (if (and (/= (cdr (assoc 0 entData)) "TEXT")
           (/= (cdr (assoc 0 entData)) "MTEXT")
           (/= (cdr (assoc 0 entData)) "ATTDEF")
           (/= (cdr (assoc 0 entData)) "ATTRIB"))
    (progn
      (princ "\nWybrany obiekt nie jest tekstem.")
      (princ)
      (exit)
    )
  )
  
  ;; Pobierz wysokość tekstu
  (if (= (cdr (assoc 0 entData)) "MTEXT")
    ;; Dla MTEXT
    (setq txtHeight (cdr (assoc 40 entData)))
    ;; Dla TEXT, ATTDEF, ATTRIB
    (setq txtHeight (cdr (assoc 40 entData)))
  )
  
  (princ (strcat "\nWyszukiwanie tekstów o wysokości: " (rtos txtHeight 2 2)))
  
  ;; Wyszukaj wszystkie obiekty tekstowe w rysunku
  (setq ss (ssget "X" '((0 . "TEXT,MTEXT,ATTDEF,ATTRIB"))))
  
  ;; Jeśli nie znaleziono żadnych tekstów, zakończ
  (if (null ss)
    (progn
      (princ "\nNie znaleziono żadnych obiektów tekstowych w rysunku.")
      (princ)
      (exit)
    )
  )
  
  ;; Utwórz nową selekcję dla pasujących obiektów
  (setq newSS (ssadd))
  
  ;; Przeglądaj każdy obiekt tekstowy i sprawdź jego wysokość
  (setq i 0)
  (repeat (sslength ss)
    (setq ent (ssname ss i))
    (setq entData (entget ent))
    
    ;; Sprawdź wysokość tekstu
    (if (= (cdr (assoc 0 entData)) "MTEXT")
      ;; Dla MTEXT
      (if (equal (cdr (assoc 40 entData)) txtHeight 0.0001)
        (setq newSS (ssadd ent newSS))
      )
      ;; Dla TEXT, ATTDEF, ATTRIB
      (if (equal (cdr (assoc 40 entData)) txtHeight 0.0001)
        (setq newSS (ssadd ent newSS))
      )
    )
    
    (setq i (1+ i))
  )
  
  ;; Pokaż wynik
  (if (> (sslength newSS) 0)
    (progn
      (sssetfirst nil newSS)
      (princ (strcat "\nZaznaczono " (itoa (sslength newSS)) " obiektów tekstowych."))
    )
    (princ "\nNie znaleziono tekstów o podanej wysokości.")
  )
  
  (princ)
)

(princ "\nZaładowano komendę SelByTextHeight. Wpisz SelByTextHeight lub STH aby użyć.")
(defun c:STH () (c:SelByTextHeight))
(princ)