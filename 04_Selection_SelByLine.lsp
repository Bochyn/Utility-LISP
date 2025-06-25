(defun c:SelByLine (/ selObj entData lineweight layerName layerWeight filterList)
  ;; Prompt user to select an object
  (setq selObj (car (entsel "\nSelect an object to match lineweight: ")))
  (if selObj
    (progn
      ;; Get the entity data
      (setq entData (entget selObj))
      ;; Determine the lineweight of the selected object
      (setq lineweight (cdr (assoc 370 entData))) ; 370 is the lineweight group code
      ;; Check if lineweight is BYLAYER (-1 indicates BYLAYER in AutoCAD)
      (if (= lineweight -1)
        (progn
          ;; Get the object's layer
          (setq layerName (cdr (assoc 8 entData)))
          ;; Get the lineweight set for the layer
          (setq layerWeight (cdr (assoc 370 (tblsearch "layer" layerName))))
          ;; Use the layer's lineweight for filtering
          (setq filterList (list (cons 370 layerWeight)))
        )
        ;; Use the object's lineweight directly for filtering
        (setq filterList (list (cons 370 lineweight)))
      )
      ;; Select all objects matching the lineweight
      (sssetfirst nil (ssget "X" filterList))
      ;; Output success message
      (princ (strcat "\nAll objects with lineweight "
                     (if (= lineweight -1)
                       (strcat "BYLAYER (" (rtos layerWeight) ")")
                       (rtos lineweight)
                     )
                     " have been selected."))
    )
    ;; Handle case where no object is selected
    (princ "\nNo object selected.")
  )
  (princ) ; End the function
)
