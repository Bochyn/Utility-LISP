;;; ============================================================================
;;; SelByLayer.lsp
;;;
;;; Selects all objects sharing the same layer as a user-picked reference object.
;;;
;;; Command:    SelByLayer
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SelByLayer (/ selObj entData layerName filterList)
  ;; Prompt the user to pick a reference object
  (setq selObj (car (entsel "\nSelect an object to match its layer: ")))
  (if selObj
    (progn
      (setq entData (entget selObj))
      (setq layerName (cdr (assoc 8 entData))) ; 8 = layer name (DXF)
      (if layerName
        (progn
          (setq filterList (list (cons 8 layerName)))
          (sssetfirst nil (ssget "X" filterList))
          (princ (strcat "\nAll objects on layer '" layerName "' have been selected."))
        )
        (princ "\nCould not determine the layer of the selected object.")
      )
    )
    (princ "\nNo object selected.")
  )
  (princ)
)

(princ "\nLoaded: SelByLayer. Type SelByLayer at the command line.")
(princ)
