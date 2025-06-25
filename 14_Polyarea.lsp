(defun c:Polyarea (/ ent obj objID fieldStr pt txtHeight)
  (prompt "\nWybierz polilinię: ")
  (setq ent (car (entsel)))
  
  (if ent
    (progn
      ;; Sprawdzenie czy to polilinia
      (if (or (= (cdr (assoc 0 (entget ent))) "LWPOLYLINE")
              (= (cdr (assoc 0 (entget ent))) "POLYLINE"))
        (progn
          (setq obj (vlax-ename->vla-object ent))
          
          ;; Sprawdzenie czy polilinia jest zamknięta
          (if (= (vlax-get-property obj 'Closed) :vlax-true)
            (progn
              ;; Pytanie o wysokość tekstu
              (setq txtHeight (getreal (strcat "\nPodaj wysokość tekstu <" (rtos (getvar "TEXTSIZE") 2 2) ">: ")))
              (if (not txtHeight) (setq txtHeight (getvar "TEXTSIZE")))
              
              ;; Pobranie Object ID
              (setq objID (vla-get-objectid obj))
              
              ;; Tworzenie stringa pola z formatowaniem
              ;; %pr2 - zaokrąglenie do 2 miejsc po przecinku (0.00)
              (setq fieldStr (strcat 
                "%<\\AcObjProp Object(%<\\_ObjId " 
                (itoa objID) 
                ">%).Area \\f \"%lu2%ct8[0.0001]%pr2%ps[]%th44\">%"
              ))
              
              ;; Wybór punktu wstawienia
              (setq pt (getpoint "\nWskaż punkt wstawienia pola tekstowego: "))
              
              (if pt
                (progn
                  (command "_MTEXT" pt "_Height" txtHeight "_Width" 0 fieldStr "")
                  (prompt "\nPole tekstowe z powierzchnią zostało utworzone!")
                  (prompt "\nFormatowanie: conversion factor 0.0001, zaokrąglenie do 0.00")
                )
              )
            )
            (prompt "\nWybrana polilinia nie jest zamknięta!")
          )
        )
        (prompt "\nWybrany obiekt nie jest polilinią!")
      )
    )
    (prompt "\nNie wybrano żadnego obiektu!")
  )
  (princ)
)

(prompt "\nProgram załadowany. Dostępne komendy:")
(prompt "\n  POLYAREA - powierzchnia pojedynczej polilinii")
(prompt "\n  SUMAREA - suma powierzchni wielu polilinii")
(prompt "\nFormatowanie: conversion factor 0.0001, zaokrąglenie do 0.00")
(princ)