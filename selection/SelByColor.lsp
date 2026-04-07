;;; ============================================================================
;;; SelByColor.lsp
;;;
;;; Selects all objects sharing the same color as a user-picked reference object.
;;;
;;; Command:    SelByColor
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SelByColor (/ selObj entData layerName colorIndex rgbColor filterList layerColor)
  ;; Prompt user to pick a reference object
  (setq selObj (car (entsel "\nSelect an object to match color: ")))
  (if selObj
    (progn
      (setq entData (entget selObj))
      (cond
        ;; Indexed color (DXF group 62)
        ((assoc 62 entData)
         (setq colorIndex (cdr (assoc 62 entData)))
         ;; -256 = BYLAYER, resolve to the layer's own color
         (if (= colorIndex -256)
           (progn
             (setq layerName (cdr (assoc 8 entData)))                         ; 8 = layer name
             (setq layerColor (cdr (assoc 62 (tblsearch "layer" layerName)))) ; layer's indexed color
             (setq filterList (list (cons 62 layerColor))))
           (setq filterList (list (cons 62 colorIndex)))))

        ;; True-color RGB (DXF group 420)
        ((assoc 420 entData)
         (setq rgbColor (cdr (assoc 420 entData)))
         (setq filterList (list (cons 420 rgbColor))))

        ;; BYBLOCK or unknown color state, nothing to match against
        (T
         (princ "\nThe selected object does not have a valid color property.")
         (exit)))

      (sssetfirst nil (ssget "X" filterList))
      (princ "\nAll objects with the same color have been selected.")
    )
    (princ "\nNo object selected.")
  )
  (princ)
)

(princ "\nLoaded: SelByColor. Type SelByColor at the command line.")
(princ)
