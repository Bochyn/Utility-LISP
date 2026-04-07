(defun c:SelByColor (/ selObj entData layerName colorIndex rgbColor filterList layerColor)
  ;; Prompt user to select an object
  (setq selObj (car (entsel "\nSelect an object to match color: ")))
  (if selObj
    (progn
      ;; Get the entity data
      (setq entData (entget selObj))
      ;; Check the color of the selected object
      (cond
        ;; Handle indexed color (62 group code)
        ((assoc 62 entData)
         (setq colorIndex (cdr (assoc 62 entData)))
         ;; Check if color is BYLAYER (-256 indicates BYLAYER in AutoCAD)
         (if (= colorIndex -256)
           (progn
             ;; Get the object's layer
             (setq layerName (cdr (assoc 8 entData)))
             ;; Get the layer's color (62 group code from layer table)
             (setq layerColor (cdr (assoc 62 (tblsearch "layer" layerName))))
             ;; Set filter for objects on the same layer with the layer's color
             (setq filterList (list (cons 62 layerColor))))
           ;; If color is not BYLAYER, set filter for the object's indexed color
           (setq filterList (list (cons 62 colorIndex)))))
        
        ;; Handle RGB color (420 group code)
        ((assoc 420 entData)
         (setq rgbColor (cdr (assoc 420 entData)))
         ;; Set filter for objects with the same RGB color
         (setq filterList (list (cons 420 rgbColor))))
        
        ;; Handle BYBLOCK or invalid color cases
        (T
         (princ "\nThe selected object does not have a valid color property.")
         (exit)))
      
      ;; Select all objects matching the filter
      (sssetfirst nil (ssget "X" filterList))
      ;; Display success message
      (princ "\nAll objects with the same color have been selected.")
    )
    ;; Handle case where no object is selected
    (princ "\nNo object selected.")
  )
  (princ) ; End the function gracefully
)
