(defun c:SelByLineType (/ selObj entData linetypeName layerName layerLinetype filterList)
  ;; Prompt user to select an object
  (setq selObj (car (entsel "\nSelect an object to match linetype: ")))
  (if selObj
    (progn
      ;; Get entity data
      (setq entData (entget selObj))
      ;; Get linetype
      (setq linetypeName (cdr (assoc 6 entData))) ; 6 group code is linetype
      ;; Check if linetype is BYLAYER
      (if (or (null linetypeName) (equal linetypeName "BYLAYER"))
        (progn
          ;; Get the object's layer
          (setq layerName (cdr (assoc 8 entData)))
          ;; Get the linetype from the layer
          (setq layerLinetype (cdr (assoc 6 (tblsearch "layer" layerName))))
          ;; Use layer's linetype for filtering
          (setq filterList (list (cons 6 layerLinetype))))
        ;; Use the object's linetype directly
        (setq filterList (list (cons 6 linetypeName))))
      ;; Select objects with the same linetype
      (sssetfirst nil (ssget "X" filterList))
      ;; Display success message
      (princ (strcat "\nAll objects with linetype '" (if linetypeName linetypeName "BYLAYER") "' have been selected."))
    )
    ;; No object selected
    (princ "\nNo object selected.")
  )
  (princ) ; End the function
)
