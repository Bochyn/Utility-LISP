;;; ============================================================================
;;; SelByBlockColor.lsp
;;;
;;; Selects all block references (INSERTs) sharing the same color as a
;;; user-picked reference block.
;;;
;;; Command:    SelByBlockColor
;;; Alias:      none
;;; Repository: https://github.com/Bochyn/Utility-LISP
;;; License:    MIT
;;; ============================================================================

(defun c:SelByBlockColor (/ selObj entData colorIndex rgbColor layerName layerColor filterList)
  ;; Prompt user to pick a reference block
  (setq selObj (car (entsel "\nSelect a block to match color: ")))
  (if selObj
    (progn
      (setq entData (entget selObj))
      ;; Only INSERT entities are treated as blocks
      (if (= (cdr (assoc 0 entData)) "INSERT")
        (progn
          (cond
            ;; Indexed color (DXF group 62)
            ((assoc 62 entData)
             (setq colorIndex (cdr (assoc 62 entData)))
             ;; -256 = BYLAYER, resolve to the layer's own color
             (if (= colorIndex -256)
               (progn
                 (setq layerName (cdr (assoc 8 entData)))                         ; 8 = layer name
                 (setq layerColor (cdr (assoc 62 (tblsearch "layer" layerName)))) ; layer's indexed color
                 (setq filterList (list (cons 0 "INSERT") (cons 62 layerColor))))
               (setq filterList (list (cons 0 "INSERT") (cons 62 colorIndex)))))

            ;; True-color RGB (DXF group 420)
            ((assoc 420 entData)
             (setq rgbColor (cdr (assoc 420 entData)))
             (setq filterList (list (cons 0 "INSERT") (cons 420 rgbColor))))

            ;; BYBLOCK or unknown color state, nothing to match against
            (T
             (princ "\nThe selected block does not have a valid color property.")
             (exit)))

          (sssetfirst nil (ssget "X" filterList))
          (princ "\nAll blocks with the same color have been selected.")
        )
        (princ "\nThe selected object is not a block.")
      )
    )
    (princ "\nNo object selected.")
  )
  (princ)
)

(princ "\nLoaded: SelByBlockColor. Type SelByBlockColor at the command line.")
(princ)
