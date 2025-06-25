;; Funkcja sumująca powierzchnie wielu polilinii
(defun c:SUMAREA (/ ss cnt i ent obj objID fieldStr pt)
  (prompt "\nWybierz zamknięte polilinie do zsumowania: ")
  (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE"))))
  
  (if ss
    (progn
      (setq cnt (sslength ss))
      
      ;; Tworzenie stringa pola z formatowaniem
      ;; %lu2 - jednostki dziesiętne
      ;; %ct8[0.0001] - conversion factor 0.0001
      ;; %pr2 - zaokrąglenie do 2 miejsc po przecinku (0.00)
      ;; %th44 - separator tysięcy (przecinek)
      (setq fieldStr "%<\\AcExpr (")
      (setq i 0)
      
      (repeat cnt
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        
        (if (= (vlax-get-property obj 'Closed) :vlax-true)
          (progn
            (setq objID (vla-get-objectid obj))
            
            (if (> i 0)
              (setq fieldStr (strcat fieldStr " + "))
            )
            
            (setq fieldStr (strcat fieldStr 
              "%<\\AcObjProp Object(%<\\_ObjId " 
              (itoa objID) 
              ">%).Area>%"
            ))
          )
          (prompt (strcat "\nPolilinia " (itoa (1+ i)) " została pominięta (nie jest zamknięta)"))
        )
        (setq i (1+ i))
      )
      
      ;; Zamknięcie wyrażenia z formatowaniem
      (setq fieldStr (strcat fieldStr ") \\f \"%lu2%ct8[0.0001]%pr2%ps[]%th44\">%"))
      
      (setq pt (getpoint "\nWskaż punkt wstawienia pola tekstowego: "))
      
      (if pt
        (progn
          (command "_MTEXT" pt "_Height" (getvar "TEXTSIZE") "_Width" 0 fieldStr "")
          (prompt (strcat "\nUtworzono pole sumujące " (itoa cnt) " polilinii."))
          (prompt "\nFormatowanie: conversion factor 0.0001, zaokrąglenie do 0.00")
        )
      )
    )
    (prompt "\nNie wybrano żadnych polilinii!")
  )
  (princ)
)