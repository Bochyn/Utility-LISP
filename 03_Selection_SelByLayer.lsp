(defun c:SelByLayer (/ selObj entData layerName filterList)
  ;; Poproś użytkownika o wybranie obiektu
  (setq selObj (car (entsel "\nSelect an object to match its layer: ")))
  (if selObj
    (progn
      ;; Pobierz dane wybranego obiektu
      (setq entData (entget selObj))
      ;; Pobierz nazwę warstwy z wybranego obiektu (8 group code)
      (setq layerName (cdr (assoc 8 entData)))
      ;; Sprawdź, czy nazwa warstwy jest poprawna
      (if layerName
        (progn
          ;; Utwórz filtr dla tej warstwy
          (setq filterList (list (cons 8 layerName)))
          ;; Zaznacz obiekty na tej warstwie
          (sssetfirst nil (ssget "X" filterList))
          ;; Wyświetl komunikat potwierdzający
          (princ (strcat "\nAll objects on layer '" layerName "' have been selected."))
        )
        (princ "\nCould not determine the layer of the selected object.")
      )
    )
    (princ "\nNo object selected.")
  )
  (princ) ; Zakończenie funkcji
)
