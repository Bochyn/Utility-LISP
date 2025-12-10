(defun c:DimChain (/ *error* lastEnt ent ss choice blockName blockIndex insPt)

  ;; --- Obsługa błędów ---
  (defun *error* (msg)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nBłąd: " msg))
    )
    (setvar 'CMDECHO 1)
    (princ)
  )

  (setvar 'CMDECHO 0)
  
  ;; 1. Zapamiętaj ostatni obiekt
  (setq lastEnt (entlast))

  ;; 2. Uruchom pierwszy wymiar
  (princ "\nWstaw pierwszy wymiar dopasowany:")
  (command "_.DIMALIGNED")
  (while (> (getvar "CMDACTIVE") 0) (command pause))

  ;; 3. Sprawdź czy powstał wymiar
  (if (not (equal lastEnt (entlast)))
    (progn
      (princ "\nKontynuuj wymiarowanie (Enter lub ESC aby zakończyć):")
      
      ;; Dimcontinue dla ostatniego obiektu
      (command "_.DIMCONTINUE" (entlast))
      (while (> (getvar "CMDACTIVE") 0) (command pause))

      ;; 4. Zbieranie nowych wymiarów
      (setq ss (ssadd))
      (if lastEnt
        (setq ent (entnext lastEnt))
        (setq ent (entnext))
      )

      (while ent
        (if (= (cdr (assoc 0 (entget ent))) "DIMENSION")
          (ssadd ent ss)
        )
        (setq ent (entnext ent))
      )

      ;; 5. Decyzja: Blok / Grupa
      (if (> (sslength ss) 0)
        (progn
          ;; --- TUTAJ JEST NAPRAWA "UCIEKANIA W KOSMOS" ---
          ;; Rozkojarz wymiary zanim zrobisz z nich blok
          (command "_.DIMDISASSOCIATE" ss "") 
          ;; ------------------------------------------------

          (initget "1 2 3")
          (setq choice (getkword "\nWybierz akcję: [1=Block, 2=Group, 3=Skip] <1>: "))
          (if (not choice) (setq choice "1"))

          (cond
            ;; --- BLOK ---
            ((equal choice "1")
             (setq blockIndex 1 blockName "DimBlock1")
             (while (tblsearch "BLOCK" blockName)
               (setq blockIndex (1+ blockIndex))
               (setq blockName (strcat "DimBlock" (itoa blockIndex)))
             )
             
             ;; Używamy kodu 13 (Punkt geometrii, a nie tekstu - to co chcieliśmy)
             (setq insPt (cdr (assoc 13 (entget (ssname ss 0)))))
             
             (command "._-BLOCK" blockName insPt ss "")
             (command "._-INSERT" blockName insPt 1 1 0)
             (princ (strcat "\nUtworzono STABILNY blok: " blockName))
            )

            ;; --- GRUPA ---
            ((equal choice "2")
             (command "._GROUP" "_C" "*" "" ss "")
             (princ "\nUtworzono grupę.")
            )

            ;; --- POMIŃ ---
            ((equal choice "3")
             (princ "\nPozostawiono wymiary bez zmian.")
            )
          )
        )
        (princ "\nNie wykryto nowych wymiarów.")
      )
    )
    (princ "\nAnulowano.")
  )
  (setvar 'CMDECHO 1)
  (princ)
)
